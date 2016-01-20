function Analysis_20141208_LvR_permutation2
% Analysis_20141208_LvR_permutation2.m
%
% Description: Prepare a script to run permutation testing on the left
% hemisphere vs. right hemisphere contrast. Splits the brain in half and
% subtracts right hemisphere flipped to the left from left hemisphere.
%
% This version uses a whole-brain mask instead of a gray-matter mask.

global strDirAnalysis strDirData;

nPermutation = 5000;

% Create directory for analysis results
strNameAnalysis = '20141208_LvR_permutation2';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;
nSubject = numel(cSubject);

% Get paths to MNI-space 1st level z-stats
cPathZOrig = cellfun(@(s) PathUnsplit(DirAppend(strDirData, 'functional', ...
    s, 'feat_cat', 'stats'), 'pe1Z-2mni-3mm', 'nii.gz'), cSubject, 'uni', false);

%create a brain for visualization
	strBrain		= 'MNI152_T1_1mm_brain';
	strPathBrain1mm	= FSLPathMNIAnatomical('type',strBrain);
	strPathBrain	= PathUnsplit(strDirOut,[strBrain '-3mm'],'nii.gz');
	b				= FSLResample(strPathBrain1mm,3,...
						'output'	, strPathBrain			  ...
						);
    strPathBrainLeft = PathAddSuffix(strPathBrain, '-left','favor','nii.gz');
    niiAnat = NIfTIRead(strPathBrain);
    anatData = niiAnat.data;
    anatDataLeft = GetLeft(anatData);
    niiAnat.data = anatDataLeft;
    NIfTIWrite(niiAnat, strPathBrainLeft);
    
%construct the brain mask
    strPathBrainMask = PathUnsplit(strDirOut, 'brain_mask','nii.gz');
    maskWhole = logical(anatData);
    maskLeft = GetLeftMask(anatData);
    maskRight = GetRightMask(anatData);
    brainMask = maskLeft & maskRight;
    niiAnat.data = brainMask;
    NIfTIWrite(niiAnat, strPathBrainMask);

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

% Construct the analysis script
strOut = PathUnsplit(strDirOut, strComparison);
strScript = ['randomise -i ' strPathMerged ' -o ' strOut ' -d ' strPathD...
    ' -t ' strPathCT ' -m ' strPathBrainMask ' -V -T -n ' num2str(nPermutation)];

%save the analysis script
strPathScript	= PathUnsplit(strDirOut,'run_analysis','sh');
fput(strScript, strPathScript);

% Run it!
RunBashScript(strScript, 'debug', true);

%fdr correct
StatFDRCorrect(strDirOut,'mask',strPathBrainMask);
	
niimax	= @(f) disp([PathGetFileName(f) ': ' num2str(max(reshape(getfield(NIfTIRead(f),'data'),[],1)))]);
cF		= FindFiles(strDirOut,'p_');
cellfun(niimax,cF)

        

    function strPathOut = CreateLvR(strPathZ)
        % Takes a file of MNI-space z-stats and creates the LvR contrast image.
        % Out: strPathOut = path to LvR contrast image.
        nii = NIfTIRead(strPathZ);
        mOrig = nii.data;
        mOrig(~maskWhole) = NaN;
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
        % Out: mLeft: left hemisphere data matrix
        
        mLeft = mOrig;
        mLeft(1:31,:,:) = NaN;
        
    end
    
    function bLeft = GetLeftMask(mOrig)
        bLeft = mOrig;
        bLeft(1:31,:,:) = 0;
        bLeft = logical(bLeft);
    end        

    function [mRight, bRight] = GetRight(mOrig)
        % Get the right hemisphere data
        % In: original data matrix
        % Out: mRight: right hemisphere data matrix
        %      bRight: logical version of mRight
        
        mRight = mOrig;
        mRight(1:29,:,:) = mRight(2:30,:,:);
        mRight(30:60,:,:) = NaN;
        mRight = flipdim(mRight, 1);      
    end

    function bRight = GetRightMask(mOrig)
        bRight = mOrig;
        bRight(1:29,:,:) = bRight(2:30,:,:);
        bRight(30:60,:,:) = 0;
        bRight = flipdim(bRight, 1);
        bRight = logical(bRight);
    end
end