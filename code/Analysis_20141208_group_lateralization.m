% Analysis_20141208_group_lateralization.m
%
% Description: Contrast lateralization of activation between movie and model
% subject groups. The first t-test contrasts mean lateralization over the
% whole brain, the second over only areas with significant lateralization,
% and the third does a voxelwise contrast.

PrepMR;

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;
nSubject = numel(cSubject);

% Create a directory to store the results
strNameAnalysis = '20141208_group_lateralization';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% -- Mean Lateralization -- %

% Get lateralization data
strNameLvRAnalysis = '20141208_LvR_permutation2'; % get files from previous analysis
strDirLvRAnalysis = DirAppend(strDirAnalysis, strNameLvRAnalysis);
strPathLatMerged = PathUnsplit(strDirLvRAnalysis, 'LvR-merged', 'nii.gz');

% Get left brain mask
strPathLBMaskOld = PathUnsplit(strDirLvRAnalysis, 'brain_mask','nii.gz');
strPathLBMask = PathUnsplit(strDirOut, 'left_brain_mask', 'nii.gz');
FileCopy(strPathLBMaskOld, strPathLBMask);

% Get mask of significant lateralization
threshold = 0.05;
strPathLatMask = PathUnsplit(strDirOut, 'left_brain_mask_high_lat','nii.gz');
strPathLvR1 = PathUnsplit(strDirLvRAnalysis, 'left_v_right_tfce_fdrcorrp_tstat1','nii.gz');
strPathLvR2 = PathUnsplit(strDirLvRAnalysis, 'left_v_right_tfce_fdrcorrp_tstat2','nii.gz');
nii1 = NIfTIRead(strPathLvR1);
mask1 = nii1.data;
mask1(mask1 < 1-threshold | isnan(mask1)) = 0;
mask1 = logical(mask1);

nii2 = NIfTIRead(strPathLvR2);
mask2 = nii2.data;
mask2(mask2 < 1-threshold | isnan(mask2)) = 0;
mask2 = logical(mask2);

mask = mask1 | mask2;
nii1.data = mask;
NIfTIWrite(nii1, strPathLatMask);

% Take absolute value of lateralization
strPathLatMergedAbs = PathUnsplit(strDirOut, 'LvR-merged-abs','nii.gz');
merged_nii = NIfTIRead(strPathLatMerged);
data_abs = abs(merged_nii.data);
merged_nii.data = data_abs;
NIfTIWrite(merged_nii, strPathLatMergedAbs);

% Get mean lateralization for each subject over whole brain
arrLateralization = NIfTIMaskMean(strPathLatMergedAbs, strPathLBMask);

% Separate into subject groups
arrMovieLat = arrLateralization(ifo.subject.group == 1);
arrModelLat = arrLateralization(ifo.subject.group == 2);

% t-test!
[s.h, s.p, s.ci, s.stats] = ttest2(arrModelLat, arrMovieLat, 'tail', 'right');
ttest_model_gt_movie_wb = s;
[s.h, s.p, s.ci, s.stats] = ttest2(arrModelLat, arrMovieLat, 'tail', 'left');
ttest_model_lt_movie_wb = s;
save(PathUnsplit(strDirOut, 'mean_lateralization_wb','mat'), 'ttest_model_gt_movie_wb', 'ttest_model_lt_movie_wb');

% repeat over high lateralization areas

% Mean lateralization over mask
arrLateralizationHL = NIfTIMaskMean(strPathLatMergedAbs, strPathLatMask);

% Separate into subject groups
arrMovieLatHL = arrLateralizationHL(ifo.subject.group == 1);
arrModelLatHL = arrLateralizationHL(ifo.subject.group == 2);

% t-test!
[s.h, s.p, s.ci, s.stats] = ttest2(arrModelLatHL, arrMovieLatHL, 'tail', 'right');
ttest_model_gt_movie_hl = s;
[s.h, s.p, s.ci, s.stats] = ttest2(arrModelLatHL, arrMovieLatHL, 'tail', 'left');
ttest_model_lt_movie_hl = s;
save(PathUnsplit(strDirOut, 'mean_lateralization_hl', 'mat'), 'ttest_model_gt_movie_hl', 'ttest_model_lt_movie_hl');

% -- Voxelwise Lateralization -- %

nPermutation = 5000;

% Construct the design matrix
strComparison = 'model_v_movie';

d = zeros(nSubject, 1);
for k = 1:nSubject
    d(k) = conditional(ifo.subject.group(k) == 2, 1, -1); % model = 1, movie = -1
end
% t-tests
ct = [ 1; % model > movie
      -1];% movie > model
  
%save the design
strNameDesign	= ['design-' strComparison];					
[strPathD,strPathCT] = FSLWriteDesign(d,ct,[],[],'dir_out',strDirOut,'name',strNameDesign);

% Construct the analysis script
strOut = PathUnsplit(strDirOut, strComparison);
strScript = ['randomise -i ' strPathLatMergedAbs ' -o ' strOut ' -d ' strPathD ...
    ' -t ' strPathCT ' -m ' strPathLBMask ' -T -n ' num2str(nPermutation)];

%save the analysis script
strPathScript	= PathUnsplit(strDirOut,'run_analysis','sh');
fput(strScript, strPathScript);

% Run it!
RunBashScript(strScript, 'debug', true);

% Get brain for visualization
strBrain = 'MNI152_T1_1mm_brain-3mm-left';
strPathBrainLeftOld = PathUnsplit(strDirLvRAnalysis, strBrain ,'nii.gz');
strPathBrainLeft = PathUnsplit(strDirOut, strBrain, 'nii.gz');
FileCopy(strPathBrainLeftOld, strPathBrainLeft);

%fdr correct
StatFDRCorrect(strDirOut,'mask',strPathLBMask);