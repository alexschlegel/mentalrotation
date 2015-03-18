function Analysis_20141210_CCMVPA
% Analysis_20141210_CCMVPA.m
%
% Description: Run cross-classification MVPA for all bilateral masks.

nthread = 11;

global strDirAnalysis;

% Create directory for results
strNameAnalysis = '20141210_CCMVPA';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Get subject info
ifo = MR.SubjectInfo;
cSubject = ifo.code.fmri;
nSubject = numel(cSubject);

% Get cell of masks
sMask = MR.UnionMasks;
cMaskAll = sMask.all;
cMaskAll = [cMaskAll; 'core'; 'motor'];

% Do CCMVPA
% [res, stat, cMaskPair] = MR.Analyze.CCMVPA(...
%                        'mask'           ,   cMaskAll,   ...
%                        'nthread'        ,   nthread,    ...
%                        'force_mvpa'     ,   false,      ...
%                        'ifo'            ,   ifo         ...
%                        );

% shortcut %
 load(PathUnsplit(strDirOut, 'results','mat'), 'res', 'stat','cMaskPair');
                   
% Recalculate stats for interesting sets of masks
% statTemp = stat.operation;
% statTemp.maskPairs = cMaskPair;
% stat.operation = rmfield(stat.operation, fieldnames(stat.operation));
% stat.operation.all = statTemp;

cMaskMotor = sMask.motor;
cMaskNonmotor = sMask.core;

arrMPMotorROI = find(arrayfun(@(k) any(strcmp(cMaskPair{k,1}, cMaskMotor)) & any(strcmp(cMaskPair{k,2}, cMaskMotor)),...
                                1:size(cMaskPair, 1)));
arrMPCoreROI = find(arrayfun(@(k) any(strcmp(cMaskPair{k,1},cMaskNonmotor)) & any(strcmp(cMaskPair{k,2},cMaskNonmotor)),...
                                1:size(cMaskPair, 1)));
arrMPMotorU_CoreROI = find(arrayfun(@(k) (any(strcmp(cMaskPair{k,1},cMaskNonmotor)) & strcmp(cMaskPair{k,2},'motor')) ...
                                | (any(strcmp(cMaskPair{k,2},cMaskNonmotor)) & strcmp(cMaskPair{k,1},'motor')), ...
                                1:size(cMaskPair, 1)));
arrMPCoreU_MotorROI = find(arrayfun(@(k) (any(strcmp(cMaskPair{k,1},cMaskMotor)) & strcmp(cMaskPair{k,2},'core')) ...
                                | (any(strcmp(cMaskPair{k,2},cMaskMotor)) & strcmp(cMaskPair{k,1},'core')), ...
                                1:size(cMaskPair, 1)));
arrMPInterunion = find(arrayfun(@(k) strcmp(cMaskPair{k,1}, 'core') & strcmp(cMaskPair{k,2}, 'motor'),...
                                1:size(cMaskPair, 1)));
arrSma_CoreROI = find(arrayfun(@(k) (any(strcmp(cMaskPair{k,1},cMaskNonmotor)) & strcmp(cMaskPair{k,2},'sma'))...                            
                                | (any(strcmp(cMaskPair{k,2},cMaskNonmotor)) & strcmp(cMaskPair{k,1},'sma')),...
                                1:size(cMaskPair,1)));

cGroupNames = {'motor_roi'
               'nonmotor_roi'
               'motor_union_and_nonmotors'
               'nonmotor_union_and_motors'
               'interunion'
               'sma_and_nonmotors'
               };

cMPs = {arrMPMotorROI
        arrMPCoreROI
        arrMPMotorU_CoreROI
        arrMPCoreU_MotorROI
        arrMPInterunion
        arrSma_CoreROI
        };
    
cellfun(@MaskSubsetStats, cGroupNames, cMPs);
                   
% Save results
save(PathUnsplit(strDirOut,'results','mat'),'res','stat','cMaskPair');

    function MaskSubsetStats(strName, arrMaskPair)
        % Calculate fdr-corrected stats for a subset of the mask pairs.
        % In: strName   - the struct name of the subset
        %     arrMaskPair - an array of the indices of mask pairs to
        %                 include.
        sAll = stat.operation.all;
        
        s.acc = sAll.acc(:,arrMaskPair);
        s.mAcc = sAll.mAcc(arrMaskPair);
        s.seAcc = sAll.seAcc(arrMaskPair);
        
        s.conf = sAll.conf(:,:,:,arrMaskPair); 
        s.mConf = sAll.mConf(:,:,arrMaskPair);
        s.seConf = sAll.seConf(:,:,arrMaskPair);
        
        s.pAcc = sAll.pAcc(arrMaskPair);
        [~,s.pfdrAcc] = fdr(s.pAcc, 0.05);
        s.tAcc = sAll.tAcc(arrMaskPair);
        s.dfAcc = sAll.dfAcc(arrMaskPair);
        
        s.pConf = sAll.pConf(arrMaskPair);
        [~,s.pfdrConf] = fdr(s.pConf, 0.05);
        s.rConf = sAll.rConf(arrMaskPair);
        s.dfConf = sAll.dfConf(arrMaskPair);
        
        s.maskPairs = cMaskPair(arrMaskPair,:);
        
        stat.operation.(strName) = s;
    end

end