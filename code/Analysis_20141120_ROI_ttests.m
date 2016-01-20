% Analysis_20141120_ROI_ttests.m
%
% Take the FEAT 1st level reuslts and average them for each ROI (producing
% a scalar for each ROI). Then do paired t-tests between L and R
% hemispeheres, and unpaired t-tests between movie and model subject groups.

PrepMR
global strDirData
global strDirAnalysis

% Create directory for analysis results
strNameAnalysis = '20141120_ROI_ttests';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;
nSubject = numel(cSubject);

% Get masks and mask names
cMask = cellfun(@(s) reshape(FindFiles(DirAppend(strDirData, 'mask', s)),1,[]), cSubject, 'uni', false);
[~,cMaskName] = cellfun(@(f) PathSplit(f,'favor','nii.gz'), cMask{1}, 'uni', false);
cMaskFlat = cell(nSubject, numel(cMaskName));
for k = 1:numel(cMask)
    cMaskFlat(k,:) = cMask{k};
end

% Get 1st level FEAT results.
cPathPE = reshape(cellfun(@(s) PathUnsplit(DirAppend(strDirData, 'functional', s,...
    'feat_cat', 'stats'),'pe1','nii.gz'), cSubject, 'uni', false),[],1);
cPathPERep = repmat(cPathPE, 1, numel(cMaskName));

% Mean the results for each mask
cMaskMean = cellfun(@NIfTI.MaskMean, cPathPERep, cMaskFlat, 'uni', false);
sMaskMean = cell2struct(cMaskMean, cMaskName, 2);

% do paired t-tests between L and R hemispheres
leftMasks = cMaskName(~cellfun(@isempty, strfind(cMaskName, '_left')));
rightMasks = strrep(leftMasks, '_left', '_right');
baseMasks = strrep(leftMasks, '_left','');
% do the ttest for all subjects
for iMask = 1:numel(baseMasks)
    leftMaskMeans = vertcat(sMaskMean.(leftMasks{iMask}));
    rightMaskMeans = vertcat(sMaskMean.(rightMasks{iMask}));
    
    [leftVsRight.(baseMasks{iMask}).h, ...
     leftVsRight.(baseMasks{iMask}).p, ...
     leftVsRight.(baseMasks{iMask}).ci, ...
     leftVsRight.(baseMasks{iMask}).stats] = ttest(leftMaskMeans, rightMaskMeans, 'tail', 'both');
end

% do unpaired t-tests between movie and model subject groups
movieSubjects = ifo.subject.group == 1;
modelSubjects = ifo.subject.group == 2;
for iMask = 1:numel(cMaskName)
	strMaskName = cMaskName{iMask};
	movieMaskMeans = vertcat(sMaskMean(movieSubjects).(strMaskName));
	modelMaskMeans = vertcat(sMaskMean(modelSubjects).(strMaskName));
	
	[modelVsMovie.(strMaskName).h, ...
	 modelVsMovie.(strMaskName).p, ...
	 modelVsMovie.(strMaskName).ci, ...
	 modelVsMovie.(strMaskName).stats] = ttest2(modelMaskMeans, movieMaskMeans, 'tail', 'both');
	 
	 modelVsMovie.(strMaskName).mModel	= mean(modelMaskMeans);
	 modelVsMovie.(strMaskName).seModel	= stderr(modelMaskMeans);
	 
	 modelVsMovie.(strMaskName).mMovie	= mean(movieMaskMeans);
	 modelVsMovie.(strMaskName).seMovie	= stderr(movieMaskMeans);
end

strPathOut = PathUnsplit(strDirOut, 'results', 'mat');
save(strPathOut, 'sMaskMean', 'leftVsRight','modelVsMovie');
