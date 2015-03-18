function [res,stat] = ROIMVPA(varargin)
% MR.Analyze.ROIMVPA
% 
% Description:	perform an ROI classification of shapes and operations
% 
% Syntax:	[res,stat] = MR.Analyze.ROIMVPA(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<core>) the names of the masks to use
%		pca:		(true) true to perform the classification on PCAed masks
%		ifo:		(<load>) the result of a call to MR.SubjectInfo
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force_mvpa:	(true) true to force classification
%		force_each:	(false) true to force each mask computation
%		force_pre:	(false) true to force preprocessing steps
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	res		- the MVPA results
%	stat	- extra stats on the MVPA results
% 
% Updated: 2014-03-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'subject'		, {}	, ...
		'mask'			, {}	, ...
		'pca'			, true	, ...
		'ifo'			, []	, ...
		'nthread'		, 12	, ...
		'load'			, true	, ...
		'force_mvpa'	, true	, ...
		'force_each'	, false	, ...
		'force_pre'		, false	, ...
		'silent'		, false	  ...
		);

strDirOut	= MR.Data.Directory('roimvpa');

%subject codes
	cSubject	= MR.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%masks
	[cPathMask,cMask]	= MR.Path.Mask('subject',cSubject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject, cMask, opt.pca};
	
	if opt.load
		sData	= MR.Data.Load('roimvpa',param);
		
		if ~isempty(sData)
			res		= sData.res;
			stat	= sData.stat;
			
			return;
		end
	end

%data paths
	if opt.pca
		[C,cPathData,cPathMask]	= MR.Analyze.PCA(...
									'subject'	, cSubject		, ...
									'mask'		, cMask			, ...
									'nthread'	, opt.nthread	, ...
									'load'		, opt.load		, ...
									'force'		, opt.force_pre	, ...
									'silent'	, opt.silent	  ...
									);
	else
		cPathData	= MR.Path.Functional('subject',cSubject);
	end

%get the subject info
	if isempty(opt.ifo)
		ifo	= MR.SubjectInfo('subject',cSubject);
	else
		ifo	= opt.ifo;
	end

%run each classification
	cScheme	= MR.Param('scheme');
	nScheme	= numel(cScheme);
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.shape,2);
	kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);
	
	res	= struct;
	for kS=1:nScheme
		strScheme	= cScheme{kS};
		
		cTarget	= ifo.label.mvpa.target.(strScheme).correct;
		kChunk	= ifo.label.mvpa.chunk.correct;
		
		cOutPrefix	= cellfun(@(s) [s '-' strScheme],cSubject,'uni',false);
		
		res.(strScheme)	= MVPAClassify(cPathData,cTarget,kChunk,...
							'path_mask'			, cPathMask			, ...
							'mask_name'			, cMask				, ...
							'spatiotemporal'	, true				, ...
							'target_blank'		, 'Blank'			, ...
							'zscore'			, kRun				, ...
							'output_dir'		, strDirOut			, ...
							'output_prefix'		, cOutPrefix		, ...
							'nthread'			, opt.nthread		, ...
							'debug'				, 'all'				, ...
							'force'				, opt.force_mvpa	, ...
							'force_each'		, opt.force_each	, ...
							'silent'			, opt.silent		  ...
							);
	end

%calculate some extra stats
	conf	= MR.ConfusionModels;
	
	stat	= MVPAClassifyExtraStats(res,...
				'confusion_model'	, conf			, ...
				'silent'			, opt.silent	  ...
				);
	
%save the result
	sData.res			= res;
	sData.stat			= stat;
	
	MR.Data.Save(sData,'roimvpa',param);
