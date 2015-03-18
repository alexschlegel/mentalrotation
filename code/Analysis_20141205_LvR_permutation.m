function Analysis_20141205_LvR_permutation
% Analysis_20141205_LvR_permutation.m
%
% Description: Prepare a script to run permutation testing on the left
% hemisphere vs. right hemisphere contrast. Splits the brain in half and
% subtracts right hemisphere flipped to the left from left hemisphere.

global strDirAnalysis strDirData;

nPermutation = 5000;

% Create directory for analysis results
strNameAnalysis = '20141205_LvR_permutation';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;
nSubject = numel(cSubject);

% Get paths to MNI-space 1st level z-stats
cPathZOrig = cellfun(@(s) PathUnsplit(DirAppend(strDirData, 'functional', ...
    s, 'feat_cat', 'stats'), 'pe1Z-2mni-3mm', 'nii.gz'), cSubject, 'uni', false);

% Split into hemispheres and subtract right from left
cPathLvR = cellfun(@CreateLvR, cPathZOrig, 'uni', false);

% Merge the data
strPathMerged = PathUnsplit(strDirOut, 'LvR-merged', 'nii.gz');
if ~FSLMerge(cPathLvR, strPathMerged)
    error('Data merging failed.');
end

% Construct the design matrix
strComparison = 'left_v_right';
d = ones(nSubject, 1);
% t-tests
ct = [1;  % left > right
     -1]; % right > left
 
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
    %get just the left half
        niiGM = NIfTIRead(strPathGM);
        niiGM.data = GetLeft(niiGM.data);
        strPathGMLeft = PathAddSuffix(strPathGM, '-left', 'favor', 'nii.gz');
        NIfTIWrite(niiGM, strPathGMLeft);
        
%create a brain for visualization
	strBrain		= 'MNI152_T1_1mm_brain';
	strPathBrain1mm	= FSLPathMNIAnatomical('type',strBrain);
	strPathBrain	= PathUnsplit(strDirOut,[strBrain '-3mm'],'nii.gz');
	b				= FSLResample(strPathBrain1mm,3,...
						'output'	, strPathBrain			  ...
						);
    strPathBrainLeft = PathAddSuffix(strPathBrain, '-left','favor','nii.gz');
    niiAnat = NIfTIRead(strPathBrain);
    niiAnat.data = GetLeft(niiAnat.data);
    NIfTIWrite(niiAnat, strPathBrainLeft);
        

% Construct the analysis script
strOut = PathUnsplit(strDirOut, strComparison);
strScript = ['randomise -i ' strPathMerged ' -o ' strOut ' -d ' strPathD...
    ' -t ' strPathCT ' -m ' strPathGMLeft ' -V -T -n ' num2str(nPermutation)];

%save the analysis script
strPathScript	= PathUnsplit(strDirOut,'run_analysis','sh');
fput(strScript, strPathScript);

% Run it!
RunBashScript(strScript, 'debug', true);

%fdr correct
StatFDRCorrect(strDirOut,'mask',strPathGMLeft);
	
niimax	= @(f) disp([PathGetFileName(f) ': ' num2str(max(reshape(getfield(NIfTIRead(f),'data'),[],1)))]);
cF		= FindFiles(strDirOut,'p_');
cellfun(niimax,cF)

        

    function strPathOut = CreateLvR(strPathZ)
        % Takes a file of MNI-space z-stats and creates the LvR contrast image.
        nii = NIfTIRead(strPathZ);
        mOrig = nii.data;
        mLeft = GetLeft(mOrig);
        mRight = GetRight(mOrig);
        mLvR = mLeft - mRight;
        nii.data = mLvR;
        strPathOut = PathAddSuffix(strPathZ, '-LvR', 'favor', 'nii.gz');
        NIfTIWrite(nii, strPathOut);
    end

    function mLeft = GetLeft(mOrig)
        % Get the left hemisphere data
        % In: original data matrix
        % Out: left hemisphere data matrix
        
        mLeft = mOrig;
        mLeft(1:31,:,:) = 0;
    end

    function mRight = GetRight(mOrig)
        % Get the right hemisphere data
        % In: original data matrix
        % Out: right hemisphere data matrix
        
        mRight = mOrig;
        mRight(1:29,:,:) = mRight(2:30,:,:);
        mRight(30:60,:,:) = 0;
        mRight = flipdim(mRight, 1);
    end
end