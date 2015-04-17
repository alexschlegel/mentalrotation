% Analysis_20150415_ROIDCMVPA.m
% ROI directed connectivity classification analysis between each ROI from
% ROIMVPA. trying again with more intelligent parameters.
nThread	= 12;

dimPCA		= 20;
fSelect		= 0.25;
classifier	= 'SMLR';

%create directory for analysis results
	strNameAnalysis	= '20150415_roidcmvpa';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo			= MR.SubjectInfo;
	cSession	= ifo.code.fmri;

%get masks
	cMask	= MR.Masks;
	cMask	= cMask.all;

%targets and chunks
	cTarget	= ifo.label.te.target.operation.all;
	
	cTargetSubset	= {'l';'r';'b';'f'};
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.operation,2);
	kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);
	
% 	%chunk by figures (grouped in two so we get good lengths for GC calculation)
% 		nFigure		= numel(ifo.condition.figures);
% 		fig2chunk	= reshape(repmat(1:nFigure/2,[2 1]),[],1);
		
% 		[bFigure,kFigure]	= cellfun(@(t) ismember(t,ifo.condition.figures),ifo.label.te.target.figures.all,'uni',false);
		
% 		fig2chunk	= [0; fig2chunk];
% 		kChunk		= cellfun(@(k) fig2chunk(k+1),kFigure,'uni',false);
	
	kChunk	= kRun;

%exclude the hand rotation runs
	kTREnd	= 1640;
	
	cTarget	= cellfun(@(t) [t(1:kTREnd); repmat({'discard'},[numel(t)-kTREnd 1])],cTarget,'uni',false);
	
	kChunk	= cellfun(@(k) conditional(kRun>10,0,k),kChunk,'uni',false);

%ROI directed connectivity classification!
	strDirMVPA	= DirAppend(strDirOut,'mvpa');
	
	conf	= MR.ConfusionModels;
	conf	= conf{1};
	
	res	= MVPAROIDCClassify(...
			'dir_out'			, strDirMVPA	, ...
			'dir_data'			, strDirData	, ...
			'subject'			, cSession		, ...
			'mask'				, cMask			, ...
			'mask_variant'		, 'disjoint'	, ...
			'dim'				, dimPCA		, ...
			'targets'			, cTarget		, ...
			'chunks'			, kChunk		, ...
			'classifier'		, classifier	, ...
			'selection'			, fSelect		, ...
			'target_subset'		, cTargetSubset	, ...
			'target_blank'		, 'Blank'		, ...
			'zscore'			, false			, ...
			'confusion_model'	, conf			, ...
			'debug'				, 'all'			, ...
			'debug_multitask'	, 'info'		, ...
			'nthread'			, nThread		, ...
			'force'				, false			  ...
			);

%save the results
	strPathOut	= PathUnsplit(strDirOut,'result','mat');
	save(strPathOut,'res');
