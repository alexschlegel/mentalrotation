% Analysis_20150320_ROICCMVPA.m
% ROI cross-classification analysis between each ROI from ROIMVPA
nCore	= 12;

dimPCA	= 50;

%create directory for analysis results
	strNameAnalysis	= '20150320_roiccmvpa';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo			= MR.SubjectInfo;
	cSession	= ifo.code.fmri;

%get masks
	cMask	= MR.Masks;
	cMask	= cMask.all;

%targets and chunks
	cTarget	= ifo.label.mvpa.target.operation.correct;
	kChunk	= ifo.label.mvpa.chunk.correct;
	
	cTargetSubset	= {'l';'r';'b';'f'};
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.operation,2);
	kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);

%exclude the hand rotation runs
	kTREnd	= 1640;
	
	cTarget	= cellfun(@(t) [t(1:kTREnd); repmat({'discard'},[numel(t)-kTREnd 1])],cTarget,'uni',false);
	kChunk	= cellfun(@(c) [c(1:kTREnd); repmat(0,[numel(c)-kTREnd 1])],kChunk,'uni',false);

%ROI Cross-classification!
	strDirMVPA	= DirAppend(strDirOut,'mvpa');
	
	conf	= MR.ConfusionModels;
	conf	= conf{1};
	
	res	= MVPAROICrossClassify(...
			'dir_out'			, strDirMVPA	, ...
			'dir_data'			, strDirData	, ...
			'subject'			, cSession		, ...
			'mask'				, cMask			, ...
			'mask_variant'		, 'disjoint'	, ...
			'dim'				, dimPCA		, ...
			'targets'			, cTarget		, ...
			'chunks'			, kChunk		, ...
			'target_subset'		, cTargetSubset	, ...
			'target_blank'		, 'Blank'		, ...
			'zscore'			, kRun			, ...
			'spatiotemporal'	, true			, ...
			'confusion_model'	, conf			, ...
			'debug'				, 'all'			, ...
			'debug_multitask'	, 'info'		, ...
			'cores'				, nCore			, ...
			'force'				, false			  ...
			);

%save the results
	strPathOut	= PathUnsplit(strDirOut,'result','mat');
	save(strPathOut,'res');
