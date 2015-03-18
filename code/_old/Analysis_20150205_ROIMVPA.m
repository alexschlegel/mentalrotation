% Analysis_20150205_ROIMVPA.m
% 4-way operation classification in each ROI.
% ROIs included in this analysis are the 6 "core" and 7 "motor" ROIs.
% All ROIs are bilateral and mutually exclusive."
% Uses all 5 test TRs for classification.
% 1) ROI MVPA
%   	a. pre-whiten data using PCA
%       b. classify rotation type within this component space
%	Updated: 2015-02-05
nThread = 11;

% Create directory for analysis results
strNameAnalysis = '20150205_ROIMVPA';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;

% Get cell of masks
cMask = MR.UnionMasks();
cMask = cMask.all;

dimPCAMin = 10;

%open a MATLAB pool
	MATLABPoolOpen(nThread);


%ROI Classification!
	[res,stat]	= MR.Analyze.ROIMVPA(...
					'subject'		, cSubject	, ...
					'mask'			, cMask     , ...
					'mindim'		, dimPCAMin	, ...
					'ifo'			, ifo		, ...
					'nthread'		, nThread	, ...
					'load'			, false		, ...
                    'force_pre'     , true      , ...
					'force_each'	, true		, ...
                    'force_mvpa'    , true        ...
                    		);
%figures
h	= MR.Plot.Accuracy(stat,'outdir',strDirOut);
h	= MR.Plot.ConfusionCorrelation(stat,'outdir',strDirOut);
h	= MR.Plot.Confusion(stat,'outdir',strDirOut);
            
      
strPathOut = PathUnsplit(strDirOut,'result','mat');
    
save(strPathOut,'res','stat');
    
    
%close the MATLAB pool
	MATLABPoolClose;
 
    


