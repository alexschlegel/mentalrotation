% Analysis_20150318_ROIMVPA.m
% 4-way operation classification in each ROI.
% ROIs included in this analysis are the 6 "core" and 7 "motor" ROIs.
% All ROIs are bilateral and mutually exclusive."
% Uses all 5 test TRs for classification.
% 1) ROI MVPA
%   	a. pre-whiten data using PCA
%       b. classify rotation type within this component space
%	Updated: 2015-03-18
nThread	= 12;

dimPCAMin	= 10;

%create directory for analysis results
	strNameAnalysis	= '20150318_roimvpa';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo			= MR.SubjectInfo;
	cSession	= ifo.code.fmri;

%get masks
	cMask	= MR.UnionMasks;
	cMask	= cMask.all;

%targets and chunks
	cTarget	= ifo.label.mvpa.target.operation.correct;
	kChunk	= ifo.label.mvpa.chunk.correct;
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.operation,2);
	kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);

%ROI Classification!
	res	= MVPAROIClassify(...
		'output_dir'		, strDirOut		, ...
		'dir_data'			, strDirData	, ...
		'subject'			, cSession		, ...
		'mask'				, cMask			, ...
		'mask_variant'		, 'unique'		, ...
		'mindim'			, dimPCAMin		, ...
		'targets'			, cTarget		, ...
		'chunks'			, kChunk		, ...
		'target_blank'		, 'Blank'		, ...
		'zscore'			, kRun			, ...
		'spatiotemporal'	, true			, ...
		'debug'				, 'all'			, ...
		'nthread'			, nThread		, ...
		'force'				, false			  ...
		);
	
	conf	= MR.ConfusionModels;
	conf	= conf{1};
		
	stat	= MVPAClassifyExtraStats(res,...
				'confusion_model'	, conf	  ...
				);

%save the results
	strPathOut	= PathUnsplit(strDirOut,'result','mat');    
	save(strPathOut,'res','stat');

%figures
	strDirFigure	= DirAppend(strDirOut,'figures');
	
	h	= MR.Plot.Accuracy(stat,'outdir',strDirFigure);
	h	= MR.Plot.ConfusionCorrelation(stat,'outdir',strDirFigure);
	h	= MR.Plot.Confusion(stat,'outdir',strDirFigure);
