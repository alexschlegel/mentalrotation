function comps = MRComps(stat, varargin)
% MR.Analyze.MRComps
%
% Description: do some additional comparisons after doing ROIMVPA on the
% mental rotation data.
%
% Syntax: comps = MRComps(stat, [ifo]=ifo, [cores]=11,[accuracy]=true);
%
% In:
%   stat:   the stat struct returned by MR.Analyze.ROIMVPA
%   [ifo]:  Subject info object returned by MR.SubjectInfo
%   [accuracy]: perform comparisons on accuracies as well as correlations.
%
% Out:
%   comps:        Struct with comparison results.
%     comps.group: results from an unpaired t-test on correlation z-values
%                  between members of the movie and model groups. 
%     comps.hemi:  results from a paired t-test on correlation z-values
%                  between right- and left-hemisphere ROIs.
 
% get subject info
[ifo, acc] = ParseArgs(varargin, [], true);
if isempty(ifo)
    ifo = MR.SubjectInfo;
end

% select masks
masks = MR.UnionMasks;
% add union motor mask to motor mask sets
masks.motor = [masks.motor; 'motor'];
masks.motor_left = [masks.motor_left; 'motor_left'];
masks.motor_right = [masks.motor_right; 'motor_right'];
% do same for "all"
masks.all = [masks.all; 'motor'; 'core'; 'all'];
masks.all_left = [masks.all_left; 'motor_left'; 'core_left'; 'all_left'];
masks.all_right = [masks.all_right; 'motor_right'; 'core_right'; 'all_right'];
% lateral motor
masks.latm = [masks.motor_left; masks.motor_right];
% cMask_motor = [masks.motor; 'motor'];
% cMask_motorleft  = cellfun(@(m) [m '_left'], cMask_motor, 'uni', false);
% cMask_motorright = cellfun(@(m) [m '_right'], cMask_motor, 'uni', false);
% cMask_latm = [cMask_motorleft; cMask_motorright];

% find indices of each maskset in the stats
cMask_all = stat.label{2};
fGetIndex = @(mask) find(strcmp(mask,cMask_all));
iMasks = structfun(@(maskset) cellfun(fGetIndex,maskset),masks,'uni',false);

% [~, stats.coremotor] = MR.Analyze.ROIMVPA('mask' , cMask_coremotor, ...
%                                           'ifo'  , ifo,             ...
%                                           'cores', cores);
% [~, stats.coremotor_orig] = MR.Analyze.ROIMVPA('mask', masks.coremotor_orig, 'ifo', ifo, 'cores', cores);                                      
%                                       
% [~, stats.latm] = MR.Analyze.ROIMVPA('mask', cMask_latm, 'ifo', ifo, 'cores', cores);


%-----Group comparison--------------------------------------------------

% get masks
iMaskCore = iMasks.core;
iMaskMotor = [iMasks.motor; iMasks.motor_left]; % do comparisons on the bilateral and left motor masks

% get subject groups
arrMovie = find(ifo.subject.group == 1);
arrModel = find(ifo.subject.group == 2);

% perform between-group unpaired t-test
fGetCorrZ = @(mask,subject) stat.confusion.corr.subjectJK.allway.z(mask,subject);
z_movie_core = fGetCorrZ(iMaskCore,arrMovie);
z_movie_motor = fGetCorrZ(iMaskMotor,arrMovie);
z_model_core = fGetCorrZ(iMaskCore,arrModel);
z_model_motor = fGetCorrZ(iMaskMotor,arrModel);

% 2-tailed for core areas
[groupCompare.corr.core.h, groupCompare.corr.core.p, groupCompare.corr.core.ci, groupCompare.corr.core.stats] = ...
    ttest2JK(z_model_core, z_movie_core, 0.05, 'both', 'equal', 2);

% right-tailed for motor areas
[groupCompare.corr.motor.rt.h, groupCompare.corr.motor.rt.p, groupCompare.corr.motor.rt.ci, groupCompare.corr.motor.rt.stats] = ...
    ttest2JK(z_model_motor, z_movie_motor, 0.05, 'right', 'equal', 2);

% let's do a left-tailed too just for kicks
[groupCompare.corr.motor.lt.h, groupCompare.corr.motor.lt.p, groupCompare.corr.motor.lt.ci, groupCompare.corr.motor.lt.stats] = ...
    ttest2JK(z_model_motor, z_movie_motor, 0.05, 'left', 'equal', 2);

if(acc) % accuracy comparisons
    fGetAcc = @(mask,subject) stat.accuracy.all.allway(:,mask,subject);
    acc_movie_core = fGetAcc(iMaskCore, arrMovie);
    acc_movie_motor = fGetAcc(iMaskMotor, arrMovie);
    acc_model_core = fGetAcc(iMaskCore, arrModel);
    acc_model_motor = fGetAcc(iMaskMotor, arrModel);
    
    % core areas
    [groupCompare.acc.core.h, groupCompare.acc.core.p, groupCompare.acc.core.ci, groupCompare.acc.core.stats] = ...
        ttest2(acc_model_core, acc_movie_core, 'tail', 'both','dim', 3);
    
    % right-tailed motor
    [groupCompare.acc.motor.rt.h, groupCompare.acc.motor.rt.p, groupCompare.acc.motor.rt.ci, groupCompare.acc.motor.rt.stats] = ...
        ttest2(acc_model_motor, acc_movie_motor, 'tail', 'right', 'dim', 3);
    
    % left-tailed motor
    [groupCompare.acc.motor.lt.h, groupCompare.acc.motor.lt.p, groupCompare.acc.motor.lt.ci, groupCompare.acc.motor.lt.stats] = ...
        ttest2(acc_model_motor, acc_movie_motor, 'tail', 'left', 'dim', 3);
end

groupCompare.masks.core = cMask_all(iMaskCore);
groupCompare.masks.motor = cMask_all(iMaskMotor);


%--------Hemisphere comparison-------


% perform between-hemisphere paired t-test (two-tailed)
arrSubjects = 1:numel(ifo.code.fmri);

z_left = fGetCorrZ(iMasks.all_left,arrSubjects);
z_right = fGetCorrZ(iMasks.all_right,arrSubjects);

[hemiCompare.corr.h, hemiCompare.corr.p, hemiCompare.corr.ci, hemiCompare.corr.stats] = ...
    ttestJK(z_left, z_right, 0.05, 'both', 2);

if (acc)
    acc_left = fGetAcc(iMasks.all_left,arrSubjects);
    acc_right = fGetAcc(iMasks.all_right,arrSubjects);
    
    [hemiCompare.acc.h, hemiCompare.acc.p, hemiCompare.acc.ci, hemiCompare.acc.stats] = ...
        ttest(acc_left, acc_right, 'tail', 'both', 'dim', 3);
end

hemiCompare.masks = cMask_all(iMasks.all);

comps.group = groupCompare;
comps.hemi = hemiCompare;

% more mask groups for comparison

% only the original subjects and ROIs
% cSubject = ifo.code.fmri;
% cOldSubject = cSubject(~strncmp('07sep14', cSubject, 7));
% [~,stats.oldsubjects_coremotor_orig] = MR.Analyze.ROIMVPA('subject', cOldSubject, 'mask', masks.coremotor_orig, 'cores', cores); 

% false discovery rate corrections
[~, comps.group.corr.motor.rt.pfdr] = fdr(comps.group.corr.motor.rt.p, 0.05);
[~, comps.group.corr.motor.lt.pfdr] = fdr(comps.group.corr.motor.lt.p, 0.05);
[~, comps.group.corr.core.pfdr] = fdr(comps.group.corr.core.p, 0.05);
[~, comps.hemi.corr.pfdr] = fdr(comps.hemi.corr.p, 0.05);

if(acc)   
    [~, comps.group.acc.motor.rt.pfdr] = fdr(comps.group.acc.motor.rt.p, 0.05);
    [~, comps.group.acc.motor.lt.pfdr] = fdr(comps.group.acc.motor.lt.p, 0.05);
    [~, comps.group.acc.core.pfdr] = fdr(comps.group.acc.core.p, 0.05);
    [~, comps.hemi.acc.pfdr] = fdr(comps.hemi.acc.p, 0.05);
end

end
