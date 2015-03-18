% Analysis_20140509_AllCI
% Compilation of all final analyses:
% 1) ROI MVPA
%	a. pre-whiten data using PCA
%	b. classify shape and operation within this component space
%	c. accuracies + correlate confusion matrices with model
% % 2) GC MVPA
% %	a. take the top 10 ICA components for each ROI and calculate GC patterns
% %	   between ROI pairs
% %	b. classify shape + operation using GC patterns for each pair and direction
% %	c. accuracies + correlate confusion matrices with model
% % 3) ROI cross-classification
% %	a. take the top 50 ICA components for each ROI.
% %	b. for each pair of ROIs, match up these 50 components so that the ROIs are
% %	   now ideally in the same space.
% %	c. cross-classify between the masks
PrepMR;
nThread			= 12;
strNameAnalysis	= '20140508_allci';

strDirOut	= DirAppend(strDirAnalysis,strNameAnalysis);
CreateDirPath(strDirOut);

ifo			= MR.SubjectInfo;
cSubject	= ifo.code.fmri;
cMask		= MR.UnionMasks.allcontrolallci;
nMask		= numel(cMask);

% cMaskLabel		= upper(cMask);
% cMaskLabel{5}	= 'LOC';

% dimICAGC		= 10;
% dimICACC		= 50;

% colMask	=	[
% 				0	222	222	%dlpfc
% 				224	0	224	%fef
% 				255	0	0	%occ
% 				224	144	0	%pcu
% 				64	96	255	%loc
% 				0	160	0	%ppc
% 			]/255;

%open a MATLAB pool
	MATLABPoolOpen(nThread);

%ROI Classification!
	[res,stat]	= MR.Analyze.ROIMVPA(...
					'subject'	, cSubject	, ...
					'mask'		, cMask	, ...
					'ifo'		, ifo		, ...
					'nthread'	, nThread	  ...
					);

% 	%figures
% 		h	= MR.Plot.Accuracy(stat,'outdir',strDirOut);
% 		h	= MR.Plot.ConfusionCorrelation(stat,'outdir',strDirOut);
% 		h	= MR.Plot.Confusion(stat,'outdir',strDirOut);

%close the MATLAB pool
	MATLABPoolClose;
    
strPathOut = PathUnsplit(strDirOut,'result','mat');
    
save(strPathOut,'res','stat')
    