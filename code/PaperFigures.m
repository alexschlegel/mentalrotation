%figures for the paper

strDirOut	= '/home/alex/studies/mentalrotation/figures/';
CreateDirPath(strDirOut);

%save motor masks as STL files
	strDirOut2	= DirAppend(strDirOut,'2');
	
	strDirFS		= '/home/alex/studies/mentalrotation/data/mni-freesurfer/';
	strDirOutBrain	= DirAppend(strDirOut2,'brain');
	CreateDirPath(strDirOutBrain);
	
	%copied from MR.Preprocess.Masks
	cMaskBilateral	=	{
							{
								'pmv'
								{'ctx_lh_S_front_inf' 'ctx_lh_G_front_inf_Opercular' 'ctx_rh_S_front_inf' 'ctx_rh_G_front_inf_Opercular'}
								{[0 0 0; 1 1 1/3] [] [0 0 0; 1 1 1/3] []}
							}
							{
								'pmd'
								{'ctx_lh_G_front_middle' 'ctx_lh_S_front_sup' 'ctx_rh_G_front_middle' 'ctx_rh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3] [0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3]}
							}
							{
								'sma'
								{'ctx_lh_G_front_sup' 'ctx_lh_S_front_sup' 'ctx_rh_G_front_sup' 'ctx_rh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3] [0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3]}
							}
							{
								'pre_sma'
								{'ctx_lh_G_front_sup' 'ctx_rh_G_front_sup'}
								{[0 0 1/3; 1 1 2/3] [0 0 1/3; 1 1 2/3]}
							}
							{
								'primary_motor'
								{'ctx_lh_S_central' 'ctx_lh_G_precentral' 'ctx_lh_S_precentral-sup-part' 'ctx_lh_S_precentral-inf-part' 'ctx_rh_S_central' 'ctx_rh_G_precentral' 'ctx_rh_S_precentral-sup-part' 'ctx_rh_S_precentral-inf-part'}
								[]
							}
							{
								'somatosensory'
								{'ctx_lh_G_postcentral' 'ctx_rh_G_postcentral'}
								[]
							}
							{
								'cerebellum'
								{'Left-Cerebellum-Cortex' 'Right-Cerebellum-Cortex'}
								[]
							}
						};
	
	cMaskBilateral	= cat(2,cMaskBilateral{:})';
	
	cMask	= cMaskBilateral;
	
	cMaskName	= cMask(:,1);
	cMaskLabel	= cMask(:,2);
	cCrop		= cMask(:,3);
	
	cPathSTL	= cellfun(@(m) PathUnsplit(strDirOutBrain,m,'stl'),cMaskName,'uni',false);
	nMask		= numel(cMaskLabel);
	
	progress('action','init','total',nMask,'label','mask STLs');
	for kM=1:nMask
		stl	= FreeSurferSTL(strDirFS,cMaskLabel{kM},...
				'name'	, cMaskName{kM}	, ...
				'crop'	, cCrop{kM}		  ...
				);
		
		STLWrite(stl,cPathSTL{kM});
		
		progress;
	end


%ROI MVPA results
	strPathRes	= '/home/alex/studies/mentalrotation/analysis/20150318_roimvpa/result.mat';
	res			= MATLoad(strPathRes,'res');
	
	col.motor	=	[
						218	154	80	%pmv
						236	236	172	%pmd
						232	231	0	%sma
						220	187	106	%pre_sma
						222	177	0	%primary_motor
						218	176	128	%somatosensory
						237	140	0	%cerebellum
					];
	col.ci		=	[
						0	224	224	%dlpfc
						224	0	224	%fef
						0	160	0	%ppc
						160	72	0	%pcu
						0	96	255	%loc
						224	0	0	%occ
					];
	
	lbl.motor	=	{
						'preMv'
						'preMd'
						'SMA'
						'preSMA'
						'PM'
						'PS'
						'CERE'
					};
	lbl.ci		=	{
						'DLPFC'
						'FEF'
						'PPC'
						'PCU'
						'LOC'
						'OCC'
					};
	
	cGroup		= fieldnames(col);;
	nGroup		= numel(cGroup);
	
	msk		= MR.Masks;
	
	mAll	= res.result.allway.stats.confusion.corr.mz;
	seAll	= res.result.allway.stats.confusion.corr.sez;
	
	yMax	= ceil(2*max(mAll+seAll))/2;
	yMin	= 0;
	
	for kG=1:nGroup
		strGroup	= cGroup{kG};
		
		bGroup	= ismember(res.mask,msk.(strGroup));
		
		m		= mAll(bGroup);
		se		= seAll(bGroup);
		[~,p]	= fdr(res.result.allway.stats.confusion.corr.p(bGroup),0.05);
		
		[m,kSort]	= sort(m,'descend');
		se			= se(kSort);
		p			= p(kSort);
		c			= col.(strGroup)(kSort,:);
		g			= lbl.(strGroup)(kSort);
		
		h	= alexplot(m,...
				'error'					, se				, ...
				'sig'					, p					, ...
				'ylabel'				, 'Fisher''s z(r)'	, ...
				'grouplabel'			, g					, ...
				'grouplabellocation'	, 45				, ...
				'ymin'					, yMin				, ...
				'ymax'					, yMax				, ...
				'color'					, c					, ...
				'type'					, 'bar'				  ...
				);
		
		strPathOut	= PathUnsplit(strDirOut2,sprintf('roimvpa-%s',strGroup),'png');
		fig2png(h.hF,strPathOut);
	end
	
%ROI classification confusion matrices
	strDirOutS2	= DirAppend(strDirOut,'S2');
	CreateDirPath(strDirOutS2);
	
	strPathRes	= '/home/alex/studies/mentalrotation/analysis/20150318_roimvpa/result.mat';
	res			= MATLoad(strPathRes,'res');
	
	nROI	= numel(res.mask);
	
	conf	= res.result.allway.stats.confusion.mean;
	
	confSum	= repmat(sum(conf,1),[4 1 1]);
	pConf	= 100*conf./confSum;
	
	for kR=1:nROI
		c	= pConf(:,:,kR);
		
		h	= alexplot(c,...
				'axistype'	, 'off'			, ...
				'substyle'	, 'bw'			, ...
				'cmmin'		, min(c(:))		, ...
				'cmmax'		, max(c(:))		, ...
				'tplabel'	, false			, ...
				'values'	, true			, ...
				'colorbar'	, false			, ...
				'type'		, 'confusion'	  ...
				);
		
		strPathOut	= PathUnsplit(strDirOutS2,sprintf('cm-%s',res.mask{kR}),'png');
		fig2png(h.hF,strPathOut);
	end

%ROI cross-classification
	strDirOut3	= DirAppend(strDirOut,'3');
	CreateDirPath(strDirOut3);
	
	strPathRes	= '/home/alex/studies/mentalrotation/analysis/20150320_roiccmvpa/result.mat';
	res			= MATLoad(strPathRes,'res');
	
	cLabelOrig	= [lbl.motor; lbl.ci];
	cLabel		=	{
						'preSMA'
						'SMA'
						'preMv'
						'preMd'
						'PM'
						'PS'
						'CERE'
						'OCC'
						'LOC'
						'PCU'
						'PPC'
						'DLPFC'
						'FEF'
					};
	
	%reviewer 2 wants Zs, not Ts
	%[t,kOrder]	= ReorderConfusion(squareform(res.result.allway.stats.confusion.corr.t),cLabelOrig,cLabel);
	[z,kOrder]	= ReorderConfusion(squareform(res.result.allway.stats.confusion.corr.mz),cLabelOrig,cLabel);
	p			= ReorderConfusion(squareform(res.result.allway.stats.confusion.corr.p),cLabelOrig,cLabel);
	pfdr		= ReorderConfusion(squareform(res.result.allway.stats.confusion.corr.pfdr),cLabelOrig,cLabel);
	
	[z,p,pfdr]	= varfun(@(x) x + conditional(logical(eye(size(x))),NaN,0),z,p,pfdr);
	
	zMin	= floor(4*nanmin(z(pfdr<=0.05)))/4;
	zMax	= ceil(4*nanmax(z(pfdr<=0.05)))/4;
	
	h	= alexplot(z,...
			'sig'			, p				, ...
			'sigcorr'		, pfdr			, ...
			'label'			, cLabel		, ...
			'lut'			, zeros(1,3)	, ...
			'colorbar'		, false			, ...
			'ring_radius'	, 0.8			, ...
			'ring_phase'	, pi/6			, ...
			'cmin'			, zMin			, ...
			'cmax'			, zMax			, ...
			...%'arcmethod'		, 'line'		, ...
			'arcwidth'		, 'scale'		, ...
			'arcwidthmin'	, 1				, ...
			'arcwidthmax'	, 12			, ...
			'wax'			, 0.9			, ...
			'hax'			, 0.9			, ...
			'tax'			, 0.05			, ...
			'w'				, 500			, ...
			'h'				, 500			, ...
			'type'			, 'connection'	  ...
			);
	
	strPathOut	= PathUnsplit(strDirOut3,'roi_cross_classification','png');
	fig2png(h.hF,strPathOut);

%hand/mental cross-classification
	strDirOut4	= DirAppend(strDirOut,'4');
	CreateDirPath(strDirOut4);
	
	strPathRes	= '/home/alex/studies/mentalrotation/analysis/20150417_handcrossclassification/result.mat';
	res			= MATLoad(strPathRes,'res');
	
	strPathResPre	= '/home/alex/studies/mentalrotation/analysis/20150318_roimvpa/result.mat';
	resPre			= MATLoad(strPathResPre,'res');
	
	mAll	= res.result.allway.stats.confusion.corr.mz;
	seAll	= res.result.allway.stats.confusion.corr.sez;
	
	mAllPre		= resPre.result.allway.stats.confusion.corr.mz;
	
	yMax	= ceil(2*max(mAll+seAll))/2;
	yMin	= floor(2*min(mAll-seAll))/2;
	
	for kG=1:nGroup
		strGroup	= cGroup{kG};
		
		bGroup	= ismember(res.mask,msk.(strGroup));
		
		mPre	= mAllPre(bGroup);
		m		= mAll(bGroup);
		se		= seAll(bGroup);
		[~,p]	= fdr(res.result.allway.stats.confusion.corr.p(bGroup),0.05);
		
		[mPre,kSort]	= sort(mPre,'descend');
		m				= m(kSort);
		se				= se(kSort);
		p				= p(kSort);
		c				= col.(strGroup)(kSort,:);
		g				= lbl.(strGroup)(kSort);
		
		h	= alexplot(m,...
				'error'					, se				, ...
				'sig'					, p					, ...
				'ylabel'				, 'Fisher''s z(r)'	, ...
				'grouplabel'			, g					, ...
				'grouplabellocation'	, 45				, ...
				'ymin'					, yMin				, ...
				'ymax'					, yMax				, ...
				'color'					, c					, ...
				'type'					, 'bar'				  ...
				);
		
		strPathOut	= PathUnsplit(strDirOut4,sprintf('hmcross-%s',strGroup),'png');
		fig2png(h.hF,strPathOut);
	end
