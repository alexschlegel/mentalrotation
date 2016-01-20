%miscellaneous numbers for the paper

ifo	= MR.SubjectInfo;
msk	= MR.Masks;

cDirFunctional	= cellfun(@(s) DirAppend(strDirData,'functional',s),ifo.code.fmri,'uni',false);

roi		=	{
				'cerebellum'
				'somatosensory'
				'primary_motor'
				'pmd'
				'pmv'
				'sma'
				'pre_sma'
				'occ'
				'loc'
				'pcu'
				'ppc'
				'fef'
				'dlpfc'
			};
roiAbb	=	{
				'CERE'
				'PS'
				'PM'
				'preMd'
				'preMv'
				'SMA'
				'preSMA'
				'OCC'
				'LOC'
				'PCU'
				'PPC'
				'FEF'
				'DLPFC'
			};
nROI	= numel(roi);

%number of features per mask
	cPathPCA	= cellfun(@(m) cellfun(@(s) PathUnsplit(DirAppend(s,sprintf('data_cat-%s.ica',m)),'melodic_pca','nii.gz'),cDirFunctional,'uni',false),msk.all,'uni',false);
	cPathPCA	= cat(2,cPathPCA{:});
	
	dimPCA	= cellfunprogress(@(f) size(getfield(NIfTI.Read(f),'data'),4),cPathPCA);
	
	mDim	= mean(dimPCA(:));
	seDim	= stderr(dimPCA(:));

%table S1 and behavioral results
	%we want to show the results in LRFB order
		cOrder		= {'l';'r';'f';'b'};
		nOp			= numel(cOrder);
		
		[b,kOp]	= ismember(cOrder,ifo.condition.operation);
	
	%mean correct per rotation
		nSubject	= numel(ifo.id);
		kSubject	= (1:nSubject)';
		nRun		= 10;
		
		op	= reshape(ifo.operation(:,1:nRun,:),nSubject,[]);
		c	= reshape(ifo.correct(:,1:nRun,:),nSubject,[])==1;
		
		cSubject	= arrayfun(@(ks) arrayfun(@(ko) c(ks,op(ks,:)==ko),kOp,'uni',false),kSubject,'uni',false);
		cSubject	= cellfun(@(x) cat(1,x{:}),cSubject,'uni',false);
		cSubject	= permute(cat(3,cSubject{:}),[3 1 2]);
		
		mSubject	= sum(cSubject,3);
		fSubject	= mean(cSubject,3);
		
		tableS1	= [mean(mSubject,1)' stderr(mSubject,[],1)' mean(fSubject,1)'];
		
		mRotation	= mean(tableS1(:,1));
		
	%mean correct over all trials
		mAll	= mean(mSubject(:));
		seAll	= stderr(mSubject(:));
		fAll	= mean(fSubject(:));
		sefAll	= stderr(fSubject(:));
	
	%one-way anova
		[p,tab,stats]	= anova1(fSubject,[],'off');
	
	%between group differences
		fMovie	= mean(fSubject(ifo.subject.group==1,:),2);
		fModel	= mean(fSubject(ifo.subject.group==2,:),2);
		
		mfMovie	= mean(fMovie);
		mfModel	= mean(fModel);
		seMovie	= stderr(fMovie);
		seModel	= stderr(fModel);
		
		[h,p,ci,stats]	= ttest2(fMovie,fModel);

%tableS2
	res	= MATLoad('/home/alex/studies/mentalrotation/analysis/20141120_ROI_ttests/results.mat','modelVsMovie');
	
	mMovie	= cellfun(@(r) res.(r).mMovie,roi);
	seMovie	= cellfun(@(r) res.(r).seMovie,roi);
	mModel	= cellfun(@(r) res.(r).mModel,roi);
	seModel	= cellfun(@(r) res.(r).seModel,roi);
	
	t	= cellfun(@(r) -res.(r).stats.tstat,roi); %negative because Ethan did it the other way
	p	= cellfun(@(r) res.(r).p,roi);
	
	[~,pfdr]	= fdr(p,0.05);
	
	tab	= struct(...
		'roi'		, {roiAbb}	, ...
		'mMovie'	, mMovie	, ...
		'seMovie'	, seMovie	, ...
		'mModel'	, mModel	, ...
		'seModel'	, seModel	, ...
		't'			, t			, ...
		'p'			, p			, ...
		'pfdr'		, pfdr		  ...
		);
	
	disp(struct2table(tab,'precision',3));

%tableS3-S5
	load('/home/alex/studies/mentalrotation/analysis/20150618_ROI_MVPA_ttests/result.mat');
	
	%S3
		[~,kOrder]	= ismember(roi,res.roi.mask);
		
		mMovie	= mean(res.roi.z(kOrder,res.roi.group==1),2);
		seMovie	= stderr(res.roi.z(kOrder,res.roi.group==1),[],2);
		mModel	= mean(res.roi.z(kOrder,res.roi.group==2),2);
		seModel	= stderr(res.roi.z(kOrder,res.roi.group==2),[],2);
		
		tab	= struct(...
				'roi'		, {roiAbb}						, ...
				'mMovie'	, mMovie						, ...
				'seMovie'	, seMovie						, ...
				'mModel'	, mModel						, ...
				'seModel'	, seModel						, ...
				't'			, res.roi.stats.tstat(kOrder)	, ...
				'p'			, res.roi.p(kOrder)				, ...
				'pfdr'		, res.roi.pfdr(kOrder)			  ...
				);
		
		disp(struct2table(tab,'precision',3));
	
	%S4
		cPair		= handshakes(roi);
		cPairAbb	= handshakes(roiAbb);
		nPair		= size(cPair,1);
		
		%get the significant pairs
			resCC		= MATLoad('/home/alex/studies/mentalrotation/analysis/20150320_roiccmvpa/result.mat','res');
			bSig		= resCC.result.allway.stats.confusion.corr.pfdr<=0.05;
			cPairSig	= resCC.mask(bSig,:);
			nPairSig	= size(cPairSig,1);
			
			bPairUse	= arrayfun(@(k) any(strcmp(cPairSig(:,1),cPair{k,1}) & strcmp(cPairSig(:,2),cPair{k,2})) | any(strcmp(cPairSig(:,1),cPair{k,2}) & strcmp(cPairSig(:,2),cPair{k,1})),(1:nPair)');
		
		kOrder	= arrayfun(@(k) find( (strcmp(res.roicc.mask(:,1),cPair{k,1}) & strcmp(res.roicc.mask(:,2),cPair{k,2})) | (strcmp(res.roicc.mask(:,1),cPair{k,2}) & strcmp(res.roicc.mask(:,2),cPair{k,1}))),(1:nPair)');
		
		mMovie	= nanmean(res.roicc.z(kOrder,res.roi.group==1),2);
		seMovie	= nanstderr(res.roicc.z(kOrder,res.roi.group==1),[],2);
		mModel	= nanmean(res.roicc.z(kOrder,res.roi.group==2),2);
		seModel	= nanstderr(res.roicc.z(kOrder,res.roi.group==2),[],2); 
		
		tab	= struct(...
				'roi1'		, {cPairAbb(:,1)}				, ...
				'roi2'		, {cPairAbb(:,2)}				, ...
				'mMovie'	, mMovie						, ...
				'seMovie'	, seMovie						, ...
				'mModel'	, mModel						, ...
				'seModel'	, seModel						, ...
				't'			, res.roicc.stats.tstat(kOrder)	, ...
				'p'			, res.roicc.p(kOrder)			, ...
				'pfdr'		, res.roicc.pfdr(kOrder)		  ...
				);
		tab	= structfun2(@(x) x(bPairUse),tab);
		
		%redo FDR correction
			[~,tab.pfdr]	= fdr(tab.p,0.05);
		
		disp(struct2table(tab,'precision',3));
	
	%S5
		%get the significant ROIs
			resMMCC	= MATLoad('/home/alex/studies/mentalrotation/analysis/20150417_handcrossclassification/result.mat','res');
			bSig	= resMMCC.result.allway.stats.confusion.corr.p<=0.05;
			cROISig	= resMMCC.mask(bSig,:);
			nROISig	= size(cROISig,1);
			
			bROIUse	= ismember(res.mmcc.mask,cROISig);
		
		[~,kOrder]	= ismember(roi,res.mmcc.mask);
		
		mMovie	= mean(res.mmcc.z(kOrder,res.roi.group==1),2);
		seMovie	= stderr(res.mmcc.z(kOrder,res.roi.group==1),[],2);
		mModel	= mean(res.mmcc.z(kOrder,res.roi.group==2),2);
		seModel	= stderr(res.mmcc.z(kOrder,res.roi.group==2),[],2);
		
		tab	= struct(...
				'roi'		, {roiAbb}						, ...
				'mMovie'	, mMovie						, ...
				'seMovie'	, seMovie						, ...
				'mModel'	, mModel						, ...
				'seModel'	, seModel						, ...
				't'			, res.mmcc.stats.tstat(kOrder)	, ...
				'p'			, res.mmcc.p(kOrder)				, ...
				'pfdr'		, res.mmcc.pfdr(kOrder)			  ...
				);
		tab	= structfun2(@(x) x(bROIUse),tab);
		
		%redo FDR correction
			[~,tab.pfdr]	= fdr(tab.p,0.05);
		
		disp(struct2table(tab,'precision',3));
		