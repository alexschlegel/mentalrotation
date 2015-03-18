PrepMR;
ifo = MR.SubjectInfo;
g = ifo.subject.group;
cSubjects = ifo.id;
bGroup1 = logical(g-1);
bGroup2 = logical(g-2);

%load ROIMVPA results

strNameAnalysis	= '20140514_allci_namecorrected';
strDirOut	= DirAppend(strDirAnalysis,strNameAnalysis);
strPathOut = PathUnsplit(strDirOut,'result','mat');

load(strPathOut);

% get the classification accuracies

cMask = {'cere';'dlpfc';'fef';'fo';'mfc';'mtl';'occ';'pcu';'pitc';'ppc';'sef';'thal';'premotor';'sma';'primary_motor';'pre_sma';'prepre_sma';'somatosens';'primary_motor_r';'sma_r';'premotor_r';'pre_sma_r';'prepre_sma_r';'somatosens_r';'frontal_pole'};
cMask = sort(cMask);
nMask = numel(cMask);

cMaskOrig = {'dlpfc';'fef';'occ';'pcu';'pitc';'ppc';'premotor';'sma';'primary_motor';'pre_sma'};
cMaskOrig = sort(cMaskOrig);
nMaskOrig = numel(cMaskOrig);

tTestStruct = struct('accuracy',[],'correlation',[],'orig',[]);
tTestStruct.orig = struct('accuracy',[],'correlation',[]);

for kMask = 1:nMask
    strMask = cMask{kMask};
    cAcc = res.operation.(strMask).allway.accuracy.mean;
    cAccMovie = cAcc(bGroup1);
    cAccModel = cAcc(bGroup2);
    [h,p,ci,stats] = ttest2(cAccModel,cAccMovie,'tail','right');
    tTestStruct.accuracy.(strMask) = struct('h',h,'p',p,'ci',ci,'stats',stats);
end

bMaskOrig   = ismember(cMask,cMaskOrig);
cPValueA     = num2cell(stat.accuracy.p.allway');
cOrigPA      = cPValueA(bMaskOrig);
OrigPA       = cell2mat(cOrigPA);
[pThreshAcc,pAdjustedAcc] = fdr(OrigPA,.05);
tTestStruct.orig.accuracy = struct('pthresh',pThreshAcc,'pfdr',pAdjustedAcc);

for kMask = 1:nMask
    strMask = cMask{kMask};
    cCorr = num2cell(stat.confusion.corr.subject.allway.r(kMask,:)');
    cCorrMovie = cCorr(bGroup1);
    cCorrModel = cCorr(bGroup2);
    cFisherCorrMovie = cell2mat(cellfun(@fisherz,cCorrMovie,'UniformOutput',false));
    cFisherCorrModel = cell2mat(cellfun(@fisherz,cCorrModel,'UniformOutput',false));
    [h,p,ci,stats] = ttest2(cFisherCorrModel,cFisherCorrMovie,'tail','right');
    tTestStruct.correlation.(strMask) = struct('h',h,'p',p,'ci',ci,'stats',stats);
end

cPValueC     = num2cell(stat.confusion.corr.group.allway.p');
cOrigPC      = cPValueC(bMaskOrig);
OrigPC       = cell2mat(cOrigPC);
[pThreshCorr,pAdjustedCorr] = fdr(OrigPC,.05);
tTestStruct.orig.correlation = struct('pthresh',pThreshCorr,'pfdr',pAdjustedCorr);

strTestOut = PathUnsplit(strDirOut,'ttest','mat');
save(strTestOut,'tTestStruct')
    
% write up: "There was a significant difference between the groups
%           (t(df) = tstat, p=0.0%^%).