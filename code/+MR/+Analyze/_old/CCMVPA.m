function [res,stat,cMaskPair] = CCMVPA(varargin)
% MR.Analyze.CCMVPA
% 
% Description:	perform an ROI cross-classification (between each pair of ROIs)
%				of shapes and operations
% 
% Syntax:	[res,stat,cMaskPair] = MR.Analyze.CCMVPA(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<all>) the names of the masks to use
%		dim:		(50) the number of PCA components to use
%		ifo:		(<load>) the result of a call to GO.SubjectInfo
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force_mvpa:	(true) true to force classification
%		force_each:	(false) true to force each mask computation
%		force_pre:	(false) true to force preprocessing steps
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	res			- the MVPA results
%	stat		- extra stats on the MVPA results
%	cMaskPair	- an nMaskPair x 2 cell of mask pairs for each classification
%				  result
% 
% Updated: 2014-04-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'subject'		, {}	, ...
		'mask'			, {}	, ...
		'dim'			, 50	, ...
		'ifo'			, []	, ...
		'nthread'		, 12	, ...
		'load'			, true	, ...
		'force_mvpa'	, true	, ...
		'force_each'	, false	, ...
		'force_pre'		, false	, ...
		'silent'		, false	  ...
		);

strDirOut	= MR.Data.Directory('ccmvpa');

%subject codes
	cSubject	= MR.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%masks
	[cPathMask,cMask]	= MR.Path.Mask('subject',cSubject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject cMask opt.dim};
	
	if opt.load
		sData	= MR.Data.Load('ccmvpa',param);
		
		if ~isempty(sData)
			res		= sData.res;
			stat	= sData.stat;
			
			return;
		end
	end

%get the subject info
	if isempty(opt.ifo)
		ifo	= MR.SubjectInfo('subject',cSubject);
	else
		ifo	= opt.ifo;
	end

%align the ROIs to a common space
	[cPathData,cMaskPair]	= MR.Analyze.ROIAlign(...
								'subject'	, cSubject		, ...
								'mask'		, cMask			, ...
								'dim'		, opt.dim		, ...
								'ifo'		, ifo			, ...
								'nthread'	, opt.nthread	, ...
								'load'		, opt.load		, ...
								'force'		, opt.force_pre	, ...
								'silent'	, opt.silent	  ...
								);
	nMaskPair				= size(cMaskPair,1);

%run each cross-classification
	cScheme	= MR.Param('scheme');
	nScheme	= numel(cScheme);
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.figures,2);
	kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);
	
	conf	= MR.ConfusionModels;
	
	[res,stat]	= deal(struct);
	for kS=1:nScheme
		strScheme	= cScheme{kS};
		
		% break up into subjects to avoid overloading MultiTask.
		cOutPrefix = cellfun(@(f) [getfield(regexp(PathGetFilePre(f,'favor','nii.gz'),'(?<prefix>.+)-[^-]+$','names'),'prefix') '-' strScheme],cPathData(:,:,1),'uni',false);
        cTarget = repmat(ifo.label.mvpa.target.(strScheme).correct,[1 nMaskPair]);
        kChunk = repmat(ifo.label.mvpa.chunk.correct,[1 nMaskPair]);
        
        for kSub = 1:nSubject
            % get subsets of parameters
            cPathDataSub = cPathData(kSub,:,:);
            cOutPrefixSub = cOutPrefix(kSub,:); 
            cTargetSub = cTarget(kSub,:);
            kChunkSub = kChunk(kSub,:);
            
		MVPAClassify(cPathDataSub,cTargetSub,kChunkSub,...
							'spatiotemporal'	, true				, ...
							'target_blank'		, 'Blank'			, ...
							'zscore'			, kRun				, ...
							'output_dir'		, strDirOut			, ...
							'output_prefix'		, cOutPrefixSub		, ...
							'nthread'			, opt.nthread		, ...
							'debug'				, 'all'				, ...
							'force'				, opt.force_mvpa	, ...
							'force_each'		, opt.force_each	, ...
							'silent'			, opt.silent		, ...
                            'combine'           , false               ...
							);
        end
        % now combine the data and do the group stats.
        res.(strScheme) = MVPAClassify(cPathData, cTarget, kChunk, ...
                            'output_dir'    , strDirOut     , ...
                            'output_prefix' , cOutPrefix    , ...
                            'nthread'       , opt.nthread   , ...
                            'debug'         , 'all'         , ...
                            'load'          , true          , ...
                            'silent'        , opt.silent      ...
                            );
        
		stat.(strScheme).acc	= reshape(res.(strScheme).allway.accuracy.mean,[nSubject nMaskPair]);
		stat.(strScheme).mAcc	= mean(stat.(strScheme).acc)';
		stat.(strScheme).seAcc	= stderr(stat.(strScheme).acc)';
		
		stat.(strScheme).conf	= reshape(res.(strScheme).allway.confusion,[4 4 nSubject nMaskPair]);
		stat.(strScheme).mConf	= squeeze(mean(stat.(strScheme).conf,3));
		stat.(strScheme).seConf	= squeeze(stderr(stat.(strScheme).conf,[],3));
		
		[h,p,ci,stats]				= ttest(stat.(strScheme).acc,0.25,'tail','right');
		[pThresh,pFDR]				= fdr(p,0.05);
		stat.(strScheme).pAcc		= p';
		stat.(strScheme).pfdrAcc	= pFDR';
		stat.(strScheme).tAcc		= stats.tstat';
		stat.(strScheme).dfAcc		= stats.df';
		
		[r,stats]					= corrcoef2(reshape(conf{1},[],1),reshape(permute(stat.(strScheme).mConf,[3 1 2]),nMaskPair,[]));
		[pThresh,pFDR]				= fdr(stats.p,0.05);
		stat.(strScheme).pConf		= stats.p;
		stat.(strScheme).pfdrConf	= pFDR;
		stat.(strScheme).rConf		= stats.r;
		stat.(strScheme).dfConf		= stats.df;
	end

%save the result
	sData.res			= res;
	sData.stat			= stat;
	
	MR.Data.Save(sData,'ccmvpa',param);
