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
	cTarget	= ifo.label.te.target.operation.all;
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.operation,2);
	kChunk	= reshape(repmat(1:nRun,[durRun 1]),[],1);
	
	%exclude hand rotation trials
		kChunk(kChunk>10)	= 0;

%ROI directed connectivity classification!
	conf	= MR.ConfusionModels;
	conf	= conf{1};
	
	res	= MVPAROIDCClassify(...
			'dir_out'			, strDirOut			, ...
			'dir_data'			, strDirData		, ...
			'subject'			, cSession			, ...
			'mask'				, cMask				, ...
			'mask_variant'		, 'disjoint'		, ...
			'dim'				, dimPCA			, ...
			'targets'			, cTarget			, ...
			'chunks'			, kChunk			, ...
			'target_blank'		, 'Blank'			, ...
			'target_subset'		, {'r','b','l','f'}	, ...
			'confusion_model'	, conf				, ...
			'debug'				, 'all'				, ...
			'debug_multitask'	, 'info'			, ...
			'nthread'			, nThread			, ...
			'force'				, false				  ...
			);

strPathOut	= PathUnsplit(strDirOut,'result','mat');
save(strPathOut,'res');
