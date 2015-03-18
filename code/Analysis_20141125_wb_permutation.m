% Analysis_20141125_wb_permutation.m
%
% Description: Prepare a script to run whole-brain permutation testing on
% the model-vs-movie group contrast.

PrepMR

nPermutation = 5000;

% Create directory for analysis results
strNameAnalysis = '20141125_wb_permutation';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;
nSubject = numel(cSubject);

% Get paths to pe1 for mental rotation condition from 1st level feat directories
cDir_orig = cellfun(@(s) PathUnsplit(DirAppend(strDirData, 'functional', ...
    s, 'feat_cat', 'stats'), 'pe1', 'nii.gz'), cSubject, 'uni', false);

% z-score the betas
[b, cDirZ_orig] = NIfTI2ZScore(cDir_orig);

% Create paths to save registered copes
cDirZ_1mm = cellfun(@(f) PathAddSuffix(f, '-2mni', 'favor', 'nii.gz'), cDirZ_orig,'uni', false);

% Get paths to standard images
cDirStandard = cellfun(@(s) PathUnsplit(DirAppend(strDirData, 'functional', ...
    s, 'feat_cat', 'reg'), 'standard', 'nii.gz'), cSubject, 'uni', false);

% Get paths to transformation .mat files
cDirXfm = cellfun(@(f) PathUnsplit(PathGetDir(f), 'example_func2standard', 'mat'), cDirStandard, 'uni', false);

% Register copes
if ~all(FSLRegisterFLIRT(cDirZ_orig, cDirStandard, ...
        'output',   cDirZ_1mm,  ...
        'xfm'   ,   cDirXfm))
    error('FLIRT failed. Check inputs.');
end

% Resample to 3mm
[b, cDirZ] = FSLResample(cDirZ_1mm, 3);
if ~all(b)
    error('Resampling failed.');
end

% Merge the data
strPathMerged = PathUnsplit(strDirOut, 'betas-merged', 'nii.gz');
if ~FSLMerge(cDirZ, strPathMerged)
    error('Data merging failed.');
end

% Construct the design matrix
strComparison = 'movie_v_model';

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

%construct the gray matter mask
	%extract the mask
		strDirFreeSurfer	= DirAppend(strDirData,'mni-freesurfer');
		[b,strPathGMOrig]	= FreeSurferMaskGM(strDirFreeSurfer);
	%transform it to FSL MNI 3mm space
		strPathXFM		= PathUnsplit(DirAppend(strDirFreeSurfer,'mri'),'brain-2mni','mat');
		strPathRef		= PathUnsplit(DirAppend(strDirFreeSurfer,'mri'),'brain-2mni','nii.gz');
		strPathGM1mm	= PathAddSuffix(strPathGMOrig,'-2mni','favor','nii.gz');
		b				= FSLRegisterFLIRT(strPathGMOrig,strPathRef,...
							'output'	, strPathGM1mm			, ...
							'xfm'		, strPathXFM			, ...
							'interp'	, 'nearestneighbour'	  ...
							);
	%resample to 3mm
		[b,strPathGM]	= FSLResample(strPathGM1mm,3,...
								'interp'	, 'nearestneighbour'	, ...
								'force'		, true					  ...
							);

% Construct the analysis script
strOut = PathUnsplit(strDirOut, strComparison);
strScript = ['randomise -i ' strPathMerged ' -o ' strOut ' -d ' strPathD ...
    ' -t ' strPathCT ' -m ' strPathGM ' -T -n ' num2str(nPermutation)];

%save the analysis script
strPathScript	= PathUnsplit(strDirOut,'run_analysis','sh');
fput(strScript, strPathScript);

% Run it!
RunBashScript(strScript, 'debug', true);

%create a brain for visualization
	strBrain		= 'MNI152_T1_1mm_brain';
	strPathBrain1mm	= FSLPathMNIAnatomical('type',strBrain);
	strPathBrain	= PathUnsplit(strDirOut,[strBrain '-3mm'],'nii.gz');
	b				= FSLResample(strPathBrain1mm,3,...
						'output'	, strPathBrain			  ...
						);
                    
%fdr correct
StatFDRCorrect(strDirOut,'mask',strPathGM);
	
niimax	= @(f) disp([PathGetFileName(f) ': ' num2str(max(reshape(getfield(NIfTIRead(f),'data'),[],1)))]);
cF		= FindFiles(strDirOut,'p_');
cellfun(niimax,cF)                    