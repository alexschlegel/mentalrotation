% Analysis_20150517_HandCrossClassification.m
% cross-classification. train on mental rotation, test on hand rotation, or vice
% versa
% Updated: 2015-04-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nCore	= 12;

dimPCAMin	= 10;

%create directory for analysis results
	strNameAnalysis	= '20150417_handcrossclassification';
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
	
	%just get the rotation direction
		cTarget	= cellfun(@(ct) cellfun(@(t) conditional(strcmp(t,'Blank'),t,t(end)),ct,'uni',false),cTarget,'uni',false);
	
	durRun	= MR.Param('trrun');
	nRun	= size(ifo.operation,2);
	kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);
	
	kChunk	= ifo.label.mvpa.chunk.correct;
	
	%chunk 1 for correct mr trials, chunk 2 for hr trials
		kChunk	= cellfun(@(c) double(c>0) + conditional(kRun<10,0,c>0),kChunk,'uni',false);

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
