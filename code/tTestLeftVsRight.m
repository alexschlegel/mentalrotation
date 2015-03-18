PrepMR;
cMaskLabelL = {'pre_sma';'premotor';'primary_motor';'sma'};
cMaskLabelR = {'pre_sma';'premotor';'primary_motor';'sma'};

strNameAnalysis	= '20140514_allci_namecorrected';
strDirOut	= DirAppend(strDirAnalysis,strNameAnalysis);
strPathOut = PathUnsplit(strDirOut,'result','mat');
load(strPathOut);

tTestStructLVR = struct('accuracy',[],'correlation',[]);
nMask = numel(cMaskLabelL);

cAccL = {
        res.operation.pre_sma.allway.accuracy.mean;
        res.operation.premotor.allway.accuracy.mean;
        res.operation.primary_motor.allway.accuracy.mean;
        res.operation.sma.allway.accuracy.mean;
        };
cAccR = {
        res.operation.pre_sma_r.allway.accuracy.mean;
        res.operation.premotor_r.allway.accuracy.mean;
        res.operation.primary_motor_r.allway.accuracy.mean;
        res.operation.sma_r.allway.accuracy.mean;
        };

for kMask = 1:nMask
    cAccLn = cell2mat(cAccL(kMask));
    cAccRn = cell2mat(cAccR(kMask));
    strMask = cMaskLabelL{kMask};
    [h,p,ci,stats] = ttest(cAccLn,cAccRn,'tail','right');
    tTestStructLVR.accuracy.(strMask) = struct('h',h,'p',p,'ci',ci,'stats',stats);
end

% from stat.confusion.corr.subject.allway.group.r
cAllMaskLabel = stat.label{2};
bMaskL = ismember(cAllMaskLabel,cMaskLabelL);
bMaskR = ismember(cAllMaskLabel,cMaskLabelR);

cCorrL =    [
            reshape(stat.confusion.corr.subject.allway.r(bMaskL,:)',[],1);
            ];
cCorrR =    [
            reshape(stat.confusion.corr.subject.allway.r(bMaskR,:)',[],1);
            ];
cFisherCorrL = fisherz(cCorrL);
cFisherCorrR = fisherz(cCorrR);

for kMask = 1:nMask
    strMask = cMaskLabelL{kMask};
    cFisherCorrLn = cFisherCorrL(((kMask-1)*22)+1:((kMask-1)*22)+22);
    cFisherCorrRn = cFisherCorrR(((kMask-1)*22)+1:((kMask-1)*22)+22);
    [h,p,ci,stats] = ttest(cFisherCorrLn,cFisherCorrRn,'tail','right');
    tTestStructLVR.correlation.(strMask) = struct('h',h,'p',p,'ci',ci,'stats',stats);
end

%save

strTestOut = PathUnsplit(strDirOut,'ttestLVsR','mat');
save(strTestOut,'tTestStructLVR');
    
