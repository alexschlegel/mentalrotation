% Analysis_20141022_All
% ROIs included in this analysis are 6 core gridop ROIs + 4 LH motor ROIs.
% Compilation of all final analyses:
% 1) ROI MVPA
%   	a. pre-whiten data using PCA
%       b. classify rotation type within this component space
% 2) GC MVPA
%   	a. take the top 10 PCA components for each ROI and calculate GC
%   	patterns between ROI pairs
%   	b. classify rotation type using GC patterns for each pair and direction
% 3) ROI cross-classification
%   	a. take the top 50 PCA components for each ROI.
%   	b. for each pair of ROIs, match up these 50 components so that the ROIs
%   	are now ideally in the same space.
%   	c. cross-classify between the masks

nThread = 11;

% Create directory for analysis results
strNameAnalysis = '20141022_all';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Preprocess data that has not yet been preprocessed
%MR.Preprocess.All('nthread', nThread, 'force', false);

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;

% Get cell of masks
cMask = MR.UnionMasks();
cMask = [cMask.all; 'all'; 'core'; 'motor'];
cHemi = {'_left', '_right', ''};
cMask = MR.Preprocess.LateralMasks(cMask, cHemi);
cMask = reshape(cMask, [], 1);

dimPCAMin = 10;
dimPCAGC = 10;
dimPCACC = 50;

%open a MATLAB pool
	MATLABPoolOpen(nThread);


%ROI Classification!
	[res,stat]	= MR.Analyze.ROIMVPA(...
					'subject'		, cSubject	, ...
					'mask'			, cMask     , ...
					'mindim'		, dimPCAMin	, ...
					'ifo'			, ifo		, ...
					'nthread'		, nThread	  ...
					);
            
               
% Extra comparisons
comps = MR.Analyze.MRComps(stat, ifo, nThread, true);
      
strPathOut = PathUnsplit(strDirOut,'result','mat');
    
save(strPathOut,'res','stat','comps');
    
    
%close the MATLAB pool
	MATLABPoolClose;
 
    


