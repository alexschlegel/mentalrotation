% Analysis_20150318_ROIMVPA.m
% 4-way operation classification in each ROI.
% ROIs included in this analysis are the 6 "core" and 7 "motor" ROIs.
% All ROIs are bilateral and mutually exclusive.
% Uses all 5 test TRs for classification.
% 1) ROI MVPA
%   	a. pre-whiten data using PCA
%       b. classify rotation type within this component space
% Updated: 2015-03-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
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
	cMask	= MR.Masks;
	cMask	= cMask.all;

%targets and chunks
	cTarget	= ifo.label.mvpa.target.operation.correct;
	kChunk	= ifo.label.mvpa.chunk.correct;
	
	cTargetSubset	= {'l';'r';'b';'f'};
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.operation,2);
	kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);

%ROI Classification!
	strDirMVPA	= DirAppend(strDirOut,'mvpa');
	
	conf	= MR.ConfusionModels;
	conf	= conf{1};
	
	res	= MVPAROIClassify(...
			'dir_out'			, strDirMVPA	, ...
			'dir_data'			, strDirData	, ...
			'subject'			, cSession		, ...
			'mask'				, cMask			, ...
			'mask_variant'		, 'disjoint'	, ...
			'mindim'			, dimPCAMin		, ...
			'targets'			, cTarget		, ...
			'chunks'			, kChunk		, ...
			'target_subset'		, cTargetSubset	, ...
			'target_blank'		, 'Blank'		, ...
			'zscore'			, kRun			, ...
			'spatiotemporal'	, true			, ...
			'confusion_model'	, conf			, ...
			'debug'				, 'all'			, ...
			'debug_multitask'	, 'info'		, ...
			'nthread'			, nThread		, ...
			'force'				, false			  ...
			);

%save the results
	strPathOut	= PathUnsplit(strDirOut,'result','mat');    
	save(strPathOut,'res');
