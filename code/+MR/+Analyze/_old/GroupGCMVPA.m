function [res,stat] = GroupGCMVPA(varargin)
% GO.Analyze.GroupGCMVPA
% 
% Description:	perform classification of shapes and operations based on GC
%				patterns between areas of the concatenated whole group data
% 
% Syntax:	[res,stat] = GO.Analyze.GroupGCMVPA(<options>)
% 
% In:
% 	<options>:
%		subject:			(<all>) the subjects to include
%		mask:				(<core>) the names of the masks to use
%		nd:					(1) the number of dimension for GC pattern
%							calculation
%		classifier:			('SMLR') the classifier to use
%		classifier_param:	([]) the classifier parameters
%		selection:			(100) the number of features to select
%		ifo:				(<load>) the result of a call to GO.SubjectInfo
%		nthread:			(12) number of threads to use
%		load:				(true) true to load the results if we previously saved them
%		force_mvpa:			(true) true to force classification
%		force_each:			(false) true to force each mask pair computation
%		force_pre:			(false) true to force preprocessing steps
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	res		- the MVPA results
%	stat	- extra stats on the MVPA results
% 
% Updated: 2014-03-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'subject'			, {}		, ...
		'mask'				, {}		, ...
		'nd'				, 1			, ...
		'classifier'		, 'SMLR'	, ...
		'classifier_param'	, []		, ...
		'selection'			, 100		, ...
		'ifo'				, []		, ...
		'nthread'			, 12		, ...
		'load'				, true		, ...
		'force_mvpa'		, true		, ...
		'force_each'		, false		, ...
		'force_pre'			, false		, ...
		'silent'			, false		  ...
		);

strDirOut	= GO.Data.Directory('groupgcmvpa');

%subject codes
	cSubject	= GO.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%masks
	[cPathMask,cMask]	= GO.Path.Mask('subject',cSubject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject cMask opt.nd opt.classifier opt.classifier_param opt.selection};
	
	if opt.load
		sData	= GO.Data.Load('groupgcmvpa',param);
		
		if ~isempty(sData)
			res		= sData.res;
			stat	= sData.stat;
			
			return;
		end
	end

%get the subject info
	if isempty(opt.ifo)
		ifo	= GO.SubjectInfo('subject',cSubject);
	else
		ifo	= opt.ifo;
	end

%calculate GC patterns
	[gc,cPathGC]	= GO.Analyze.GroupGC(...***
						'subject'	, cSubject		, ...
						'mask'		, cMask			, ...
						'nd'		, opt.nd		, ...
						'ifo'		, ifo			, ...
						'nthread'	, opt.nthread	, ...
						'load'		, opt.load		, ...
						'force'		, opt.force_pre	, ...
						'silent'	, opt.silent	  ...
						);

%parameters
	cScheme	= GO.Param('scheme');
	nScheme	= numel(cScheme);
	
	cCondition	= reshape(ifo.condition.shapeop,[],1);
	nCondition	= numel(cCondition);
	
	cTargetShapeOp		= reshape(cCondition,[],1);
	cTargetShape		= cellfun(@(s) s(1:2),cTargetShapeOp,'uni',false);
	cTargetOperation	= cellfun(@(s) s(4:end),cTargetShapeOp,'uni',false);
	cTarget				= {cTargetShape; cTargetOperation};
	
	[cMaskPair,kMaskPair]	= handshakes(cMask);
	[cMaskPair,kMaskPair]	= varfun(@(x) [x; x(:,end:-1:1)],cMaskPair,kMaskPair);
	nMaskPair				= size(cMaskPair,1);

%open a MATLAB pool now to avoid the overhead
	[b,nThread,pool]	= MATLABPoolOpen(opt.nthread);

%classify shapes and operations for each subject/mask pair
	res	= struct;
	
	progress(nScheme,'name','scheme','label','classifying each GC pattern scheme');
	for kS=1:nScheme
		strScheme	= cScheme{kS};
		
		cTargetCur	= cTarget{kS};
		
		%construct the chunk array
			kChunk				= zeros(nCondition,1);
			cConditionUnique	= unique(cTargetCur);
			nConditionUnique	= numel(cConditionUnique);
			for kU=1:nConditionUnique
				strCur			= cConditionUnique{kU};
				kCur			= find(strcmp(strCur,cTargetCur));
				nCur			= numel(kCur);
				
				kChunk(kCur)	= 1:nCur;
			end
		
		progress(nMaskPair,'name','pair','label','classifying each mask pair');
		for kP=1:nMaskPair
			strMaskSrc	= cMaskPair{kP,1};
			strMaskDst	= cMaskPair{kP,2};
			
			cOutputPrefix	= cellfun(@(s) sprintf('%s-%s-%s_to_%s',s,strScheme,strMaskSrc,strMaskDst),cSubject,'uni',false);
			
			res.(strScheme).(strMaskSrc).(strMaskDst)	= MVPAClassify(cPathGC(:,kP),cTargetCur,kChunk,...
															'classifier'		, opt.classifier		, ...
															'classifier_param'	, opt.classifier_param	, ...
															'selection'			, opt.selection			, ...
															'zscore'			, false					, ...
															'output_dir'		, strDirOut				, ...
															'output_prefix'		, cOutputPrefix			, ...
															'nthread'			, opt.nthread			, ...
															'debug'				, 'all'					, ...
															'force'				, opt.force_mvpa		, ...
															'force_each'		, opt.force_each		, ...
															'silent'			, true					  ...
															);
			
			progress('name','pair');
		end
		
		progress('name','scheme');
	end

%close the MATLAB pool
	if pool.opened
		MATLABPoolClose(pool);
	end

%calculate some extra stats
	conf	= GO.ConfusionModels;
	
	stat	= MVPAClassifyExtraStats(res,...
				'confusion_model'	, conf			, ...
				'silent'			, opt.silent	  ...
				);
	
%save the result
	sData.res			= res;
	sData.stat			= stat;
	
	GO.Data.Save(sData,'gcmvpa',param);
