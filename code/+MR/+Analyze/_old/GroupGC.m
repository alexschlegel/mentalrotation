function [gc,cPathGC] = GroupGC(varargin)
% GO.Analyze.GC
% 
% Description:	calculate granger causality patterns between ICAed mask
%				functional whole group concatenated data
% 
% Syntax:	[gc,cPathGC] = GO.Analyze.GroupGC(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<core>) the names of the masks to use
%		ncomp:		(10) the number of ICA components to use
%		nd:			(1) the maximum number of components in one GC set
%		ifo:		(<load>) the result of a call to GO.SubjectInfo
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force:		(false) true to force computation
%		force_pre:	(false) true to force preprocessing
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	gc		- a nMaskPair x 1 cell of GC patterns
%	cPathGC	- a nMaskPair x 1 cell of GC NIfTI files
% 
% Updated: 2014-03-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'subject'	, {}	, ...
		'mask'		, {}	, ...
		'ncomp'		, 10	, ...
		'nd'		, 1		, ...
		'ifo'		, []	, ...
		'nthread'	, 12	, ...
		'load'		, true	, ...
		'force'		, false	, ...
		'force_pre'	, false	, ...
		'silent'	, false	  ...
		);

opt.outdir	= GO.Data.Directory('groupgc');

%subject codes
	cSubject	= GO.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%mask paths
	[cPathMask,cMask]	= GO.Path.Mask('subject',opt.subject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject, cMask, opt.ncomp, opt.nd};
	
	if ~opt.force && opt.load
		sData	= GO.Data.Load('groupgc',param);
		
		if ~isempty(sData)
			gc		= sData.gc;
			cPathGC	= sData.cPathGC;
			
			return;
		end
	end

%get the subject info
	if isempty(opt.ifo)
		ifo	= GO.SubjectInfo('subject',cSubject);
	else
		ifo	= opt.ifo;
	end

%parameters
	cCondition	= reshape(ifo.condition.shapeop,[],1);
	
	cTarget		= ifo.label.te.target.shapeop.correct;
	tCondition	= cellfun(@(t) cellfun(@(c) find(strcmp(c,t)),cCondition,'uni',false),cTarget,'uni',false);

%calculate ICA components
	[C,cPathICA,cPathMask]	= GO.Analyze.GroupICA(...***
								'subject'	, cSubject		, ...
								'mask'		, cMask			, ...
								'mindim'	, opt.ncomp		, ...
								'nthread'	, opt.nthread	, ...
								'load'		, opt.load		, ...
								'force'		, opt.force_pre	, ...
								'silent'	, opt.silent	  ...
								);

%calculate the GC patterns for each subject, pair of masks, and condition
	[cMaskPair,kMaskPair]	= handshakes(cMask);
	[cMaskPair,kMaskPair]	= varfun(@(x) [x; x(:,end:-1:1)],cMaskPair,kMaskPair);
	nMaskPair				= size(cMaskPair,1);
	
	kSubject	= (1:nSubject)';
	kMaskSrc	= kMaskPair(:,1);
	kMaskDst	= kMaskPair(:,2);
	cMaskSrc	= cMaskPair(:,1);
	cMaskDst	= cMaskPair(:,2);
	
	%{nSubject nMaskPair}{nCondition}(nT nComp)
	CSrc		= arrayfun(@(s) arrayfun(@(m) cellfun(@(t) C{s,m}(t,1:opt.ncomp),tCondition{s},'uni',false),kMaskSrc','uni',false),kSubject,'uni',false);
	CDst		= arrayfun(@(s) arrayfun(@(m) cellfun(@(t) C{s,m}(t,1:opt.ncomp),tCondition{s},'uni',false),kMaskDst','uni',false),kSubject,'uni',false);
	[CSrc,CDst]	= varfun(@(x) cat(1,x{:}),CSrc,CDst);
	
	cSubjectRep	= repmat(cSubject,[1 nMaskPair]);
	cMaskSrcRep	= repmat(cMaskSrc',[nSubject 1]);
	cMaskDstRep	= repmat(cMaskDst',[nSubject 1]);
	
	%i don't know if this helps, but try to cut down on the amount of data that
	%needs to be sent for the MultiTask jobs
		clear ifo varargin C;
		opt	= rmfield(opt,'ifo');

	%{nSubject nMaskPair}(nGC nGC nCondition)
	[gc,cPathGC]	= MultiTask(@GCOne,{CSrc,CDst,cSubjectRep,cMaskSrcRep,cMaskDstRep,opt},...
						'description'	, 'calculating granger causality patterns'	, ...
						'nthread'		, opt.nthread								, ...
						'silent'		, opt.silent								  ...
						);
	
	%save some sanity later
		data				= struct;
		data.order			= 'subject maskpair condition';
		data.subject		= cSubject;
		data.maskpair.src	= cMaskPair(:,1);
		data.maskpair.dst	= cMaskPair(:,2);
		data.condition		= reshape(cCondition,[],1);

%save the result
	sData.gc		= gc;
	sData.data		= data;
	sData.cPathGC	= cPathGC;
	
	GO.Data.Save(sData,'gc',param);

%------------------------------------------------------------------------------%
function [gc,strPathOut] = GCOne(src,dst,strSubject,strMaskSrc,strMaskDst,opt)
	strPathOut	= PathUnsplit(opt.outdir,sprintf('gc_%dd-%s-%s_to_%s',opt.nd,strSubject,strMaskSrc,strMaskDst),'nii.gz');
	
	if opt.force || ~FileExists(strPathOut)
		%calculate the GC pattern for each condition
			%gc	= cellfun(@(src,dst) GrangerCausalitySubsets(src,dst,'size',opt.nd,'signal_block',GO.Param('te','block'),'silent',true),src,dst,'uni',false);
			gc	= cellfun(@(src,dst) GrangerCausalitySubsets(src,dst,'size',opt.nd,'silent',true),src,dst,'uni',false);
			gc	= cat(3,gc{:});
		%save to a NIfTI file
			data	= permute(gc,[1 2 4 3]);
			nii		= make_nii(data);
			
			NIfTIWrite(nii,strPathOut);
	else
		gc	= squeeze(getfield(NIfTIRead(strPathOut),'data'));
	end
%------------------------------------------------------------------------------%
