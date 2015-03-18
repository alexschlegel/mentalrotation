% Analysis_20141117_All
% ROIs included in this analysis are 6 core gridop ROIs + 4 LH motor ROIs.
% 1) ROI MVPA
%   	a. pre-whiten data using PCA
%       b. classify rotation type within this component space
%	Updated: 2014-11-17
%		Uses all 5 test TRs for classification.
nThread = 12;

% Create directory for analysis results
strNameAnalysis = '20141117_All';
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
					'nthread'		, nThread	, ...
					'load'			, false		, ...
					'force_each'		, true		 ...	
                    		);
%figures
h	= MR.Plot.Accuracy(stat,'outdir',strDirOut);
h	= MR.Plot.ConfusionCorrelation(stat,'outdir',strDirOut);
h	= MR.Plot.Confusion(stat,'outdir',strDirOut);
            
               
% Extra comparisons
comps = MR.Analyze.MRComps(stat, ifo, nThread, true);
      
strPathOut = PathUnsplit(strDirOut,'result','mat');
    
save(strPathOut,'res','stat','comps');
    
    
%close the MATLAB pool
	MATLABPoolClose;
 
    


