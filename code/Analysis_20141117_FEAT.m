function Analysis_20141117_FEAT
% Analysis_20141117_FEAT.m
% 
% Description: Process functional data through a 1st level GLM, using 3
% conditions: correct mental rotation, incorrect mental rotation, and hand
% rotation.
%
% NOTE: FSLFEATfMRI was terminated after completion of first-level analysis
% because higher-level analysis will be done manually. (Would not be
% accurate in this script anyway since the subject(s) with no incorrect
% trials had to be processed seperately.)

PrepMR
global strDirData
global strDirAnalysis

% Create directory for analysis results
strNameAnalysis = '20141117_FEAT';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Experiment constants
n_condition = 3;
condition_name = {'mentalRotation';'handRotation';'incorrect'};
dur_block = 5;
dur_rest = 5;
dur_pre = 0;
dur_post = -1;

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;
nSubject = numel(cSubject);

% Construct condition cells
nRun = MR.Param('exp','runs');
arrCondition = ifo.correct;
% convert boolean 1s to 1s, 0s to 3s, and everything in last 3 runs to 2s.
arrCondition = ~arrCondition;
arrCondition = 2*arrCondition;
arrCondition = arrCondition + 1;
arrCondition(:,nRun-2:nRun,:) = 2;
c = num2cell(arrCondition, [2,3]);
c = cellfun(@(subjCondition) num2cell(reshape(subjCondition,nRun,[]),2),c, 'uni',false);
c = cellfun(@(subjCondition) cellfun(@(run) reshape(run, [],1),subjCondition,'uni',false),c,'uni',false);
% if any subjects got no trials incorrect, do something different with them
condsPresent = cellfun(@(subjCondition) unique(vertcat(subjCondition{:})), c, 'uni', false);
subsPerfectScore = cellfun(@(conds) numel(conds) == 2, condsPresent);
subsNormal = ~subsPerfectScore;

% Get functional data
cDirFunctional = cellfun(@(s) DirAppend(strDirData, 'functional', s), cSubject, 'uni', false);

% Get structural data
cPathStructural = cellfun(@(s) PathUnsplit(DirAppend(strDirData, 'structural',s),'data','nii.gz'),cSubject,'uni',false);

nCore = 12;

%open a MATLAB pool
%MATLABPoolOpen(nThread);

%Do FEAT!
b	= FSLFEATfMRI(cDirFunctional(subsNormal), cPathStructural(subsNormal),c(subsNormal),strDirOut, ...
		'n_condition'		, n_condition		, ...
		'condition_name'	, condition_name	, ...
		'tcontrast_name'	, condition_name	, ...
		'dur_block'			, dur_block			, ...
		'dur_rest'			, dur_rest			, ...
		'dur_pre'			, dur_pre			, ...
		'dur_post'			, dur_post			, ...
		'firstlevel'		, 'subject'			, ...
		'cores'				, nCore				, ...
		'force'				, false				  ...
		);
b	= true;

b = b & FSLFEATfMRI(cDirFunctional(subsPerfectScore), cPathStructural(subsPerfectScore), c(subsPerfectScore), strDirOut,...
                'n_condition'   ,   n_condition-1       ,   ...
                'condition_name',   condition_name(1:2) ,   ...
                'tcontrast_name',   condition_name(1:2) ,   ...
                'dur_block'     ,   dur_block           ,   ...
                'dur_rest'      ,   dur_rest            ,   ...
                'dur_pre'       ,   dur_pre             ,   ...
                'dur_post'      ,   dur_post            ,   ...
                'nthread'       ,   nThread             ,   ...
                'firstlevel'    ,   'subject'               ...
                );
            
%MATLABPoolClose;          
           
if b
    disp('Success!');
else
    error('FEAT was unsuccessful.');
end
end
