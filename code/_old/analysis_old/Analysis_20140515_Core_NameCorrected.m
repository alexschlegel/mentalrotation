% Analysis_20140515_Core_NameCorrected
% Compilation of all final analyses:
% 1) ROI MVPA
%	a. pre-whiten data using PCA
%	b. classify shape and operation within this component space
%	c. accuracies + correlate confusion matrices with model

PrepMR;
nThread			= 12;
strNameAnalysis	= '20140515_core_namecorrected';

strDirOut	= DirAppend(strDirAnalysis,strNameAnalysis);
CreateDirPath(strDirOut);

ifo			= MR.SubjectInfo;
cSubject	= ifo.code.fmri;
cMask		= MR.UnionMasks.all;
nMask		= numel(cMask);

cMaskLabel		= upper(cMask);
cMaskLabel{5}	= 'LOC';

% dimICAGC		= 10;
% dimICACC		= 50;

%open a MATLAB pool
	MATLABPoolOpen(nThread);

%ROI Classification!
	[res,stat]	= MR.Analyze.ROIMVPA(...
					'subject'	, cSubject	, ...
					'mask'		, cMask	, ...
					'ifo'		, ifo		, ...
					'nthread'	, nThread	  ...
					);
                
strPathOut = PathUnsplit(strDirOut,'result','mat');
    
save(strPathOut,'res','stat')

	%figures
		h	= MR.Plot.Accuracy(stat,'outdir',strDirOut);
		h	= MR.Plot.ConfusionCorrelation(stat,'outdir',strDirOut);
		h	= MR.Plot.Confusion(stat,'outdir',strDirOut);

%close the MATLAB pool
	MATLABPoolClose;
    
save(strPathOut,'res','stat')

tTestInProgress;
tTestLeftVsRight;