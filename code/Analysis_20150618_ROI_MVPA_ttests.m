% Analysis_20150618_ROI_MVPA_ttests.m
%
% Take the MVPA results for each ROI. Then do unpaired t-tests between movie and
% model subject groups.
PrepMR

% Create directory for analysis results
strNameAnalysis = '20150618_ROI_MVPA_ttests';
strDirOut = DirAppend(strDirAnalysis, strNameAnalysis);
CreateDirPath(strDirOut);

% Get subject info
	ifo = MR.SubjectInfo;
	
	res.group	= ifo.subject.group;

%ROI classification
	%load the MVPA results
		strPathMVPA	= PathUnsplit(DirAppend(strDirAnalysis,'20150318_roimvpa'),'result','mat');
		resMVPA		= MATLoad(strPathMVPA,'res');
		
		res.mask	= resMVPA.mask;
	
	%calculate the correlation for each subject and ROI
		confModel	= MR.ConfusionModels;
		confModel	= reshape(confModel{1},[],1);
		
		conf	= resMVPA.result.allway.confusion;
		
		[~,~,nROI,nSubject]	= size(conf);
		
		[res.r,stat]	= corrcoef2(confModel,permute(reshape(conf,[],nROI,nSubject),[2 3 1]));
		res.z			= fisherz(res.r);
	
	% do unpaired t-tests between movie and model subject groups
		zMovie	= res.z(:,ifo.subject.group==1);
		zModel	= res.z(:,ifo.subject.group==2);
		
		[h,res.p,ci,res.stats]	= ttest2(zMovie,zModel,'dim',2,'tail','both');
		
		[~,res.pfdr]	= fdr(res.p,0.05);
	
	r.roi	= res;
	clear res;

%ROI cross-classification
	%load the MVPA ROI CC results
		strPathMVPA	= PathUnsplit(DirAppend(strDirAnalysis,'20150320_roiccmvpa'),'result','mat');
		resMVPA		= MATLoad(strPathMVPA,'res');
		
		res.mask	= resMVPA.mask;
	
	%calculate the correlation for each subject and ROI
		confModel	= MR.ConfusionModels;
		confModel	= reshape(confModel{1},[],1);
		
		conf	= resMVPA.result.allway.confusion;
		
		[~,~,nROI,nSubject]	= size(conf);
		
		[res.r,stat]	= corrcoef2(confModel,permute(reshape(conf,[],nROI,nSubject),[2 3 1]));
		res.z			= fisherz(res.r);
	
	% do unpaired t-tests between movie and model subject groups
		zMovie	= res.z(:,ifo.subject.group==1);
		zModel	= res.z(:,ifo.subject.group==2);
		
		[h,res.p,ci,res.stats]	= ttest2(zMovie,zModel,'dim',2,'tail','both');
		
		[~,res.pfdr]	= fdr(res.p,0.05);
	
	r.roicc	= res;
	clear res

%manual/mental cross-classification
	%load the MVPA manual/mental CC results
		strPathMVPA	= PathUnsplit(DirAppend(strDirAnalysis,'20150417_handcrossclassification'),'result','mat');
		resMVPA		= MATLoad(strPathMVPA,'res');
		
		res.mask	= resMVPA.mask;
	
	%calculate the correlation for each subject and ROI
		confModel	= MR.ConfusionModels;
		confModel	= reshape(confModel{1},[],1);
		
		conf	= resMVPA.result.allway.confusion;
		
		[~,~,nROI,nSubject]	= size(conf);
		
		[res.r,stat]	= corrcoef2(confModel,permute(reshape(conf,[],nROI,nSubject),[2 3 1]));
		res.z			= fisherz(res.r);
	
	% do unpaired t-tests between movie and model subject groups
		zMovie	= res.z(:,ifo.subject.group==1);
		zModel	= res.z(:,ifo.subject.group==2);
		
		[h,res.p,ci,res.stats]	= ttest2(zMovie,zModel,'dim',2,'tail','both');
		
		[~,res.pfdr]	= fdr(res.p,0.05);
	
	r.mmcc	= res;
	clear res

%save the results
	res	= r;
	strPathOut = PathUnsplit(strDirOut, 'result', 'mat');
	save(strPathOut, 'res');
