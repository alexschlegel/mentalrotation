% Analysis_20150320_ROIDCMVPA.m
% ROI directed connectivity classification analysis between each ROI from
% ROIMVPA
nThread	= 12;

dimPCA	= 10;

%create directory for analysis results
	strNameAnalysis	= '20150320_roidcmvpa';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo			= MR.SubjectInfo;
	cSession	= ifo.code.fmri;

%get masks
	cMask	= MR.UnionMasks;
	cMask	= cMask.all;

%targets and chunks
	cTarget	= ifo.label.mvpa.target.operation.all;
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.operation,2);
	kChunk	= reshape(repmat(1:nRun,[durRun 1]),[],1);

%ROI directed connectivity classification!
	res	= MVPAROIDCClassify(...
			'output_dir'		, strDirOut		, ...
			'dir_data'			, strDirData	, ...
			'subject'			, cSession		, ...
			'mask'				, cMask			, ...
			'mask_variant'		, 'unique'		, ...
			'dim'				, dimPCA		, ...
			'targets'			, cTarget		, ...
			'chunks'			, kChunk		, ...
			'target_blank'		, 'Blank'		, ...
			'debug'				, 'all'			, ...
			'nthread'			, nThread		, ...
			'force'				, false			  ...
			);
	
	conf	= GO.ConfusionModels;
	conf	= conf{1};
		
	stat	= MVPAClassifyExtraStats(res,...
				'confusion_model'	, conf	  ...
				);

strPathOut	= PathUnsplit(strDirOut,'result','mat');
save(strPathOut,'res','stat');
