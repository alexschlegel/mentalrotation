strDirOut	= '/home/alex/studies/gridop/figures/S2/classification/';

roi1	= 'ppc';
roi2	= 'pcu';

%load the results
	strPathRes	= PathUnsplit('/mnt/tsestudies/wertheimer/gridop/data/store/','ccmvpa1','mat');
	load(strPathRes);
	
	conf	=	{[
					4 2 1 1
					2 4 1 1
					1 1 4 2
					1 1 2 4
				]};
	
	res			= d.res;
	cMaskPair	= d.cMaskPair;
	stat		= struct;
	
	nMask		= 6;
	nSubject	= 19;
	
	nMaskPair		= size(cMaskPair,1);
	cMaskPairDiff	= cMaskPair(1:end-nMask,:);
	nMaskPairDiff	= size(cMaskPairDiff,1);
	
	cScheme	= {'shape';'operation'};
	nScheme	= numel(cScheme);
	
	for kS=1:nScheme
		strScheme	= cScheme{kS};
		
		%accuracy
			stat.(strScheme).acc	= reshape(res.(strScheme).allway.accuracy.mean,[nSubject nMaskPair]);
			stat.(strScheme).acc	= stat.(strScheme).acc(:,1:nMaskPairDiff);
			stat.(strScheme).mAcc	= mean(stat.(strScheme).acc,1)';
			stat.(strScheme).seAcc	= stderr(stat.(strScheme).acc,[],1)';
			
			[h,p,ci,stats]				= ttest(stat.(strScheme).acc,0.25,'tail','right');
			[pThresh,pFDR]				= fdr(p,0.05);
			stat.(strScheme).pAcc		= p';
			stat.(strScheme).pfdrAcc	= pFDR';
			stat.(strScheme).tAcc		= stats.tstat';
			stat.(strScheme).dfAcc		= stats.df';
		
		%confusion
			stat.(strScheme).conf	= reshape(res.(strScheme).allway.confusion,[4 4 nSubject nMaskPair]);
			stat.(strScheme).conf	= stat.(strScheme).conf(:,:,:,1:nMaskPairDiff);
			stat.(strScheme).mConf	= squeeze(mean(stat.(strScheme).conf,3));
			stat.(strScheme).seConf	= squeeze(stderr(stat.(strScheme).conf,[],3));
			
			[r,stats]					= corrcoef2(reshape(conf{1},[],1),reshape(permute(stat.(strScheme).mConf,[3 1 2]),nMaskPairDiff,[]));
			[pThresh,pFDR]				= fdr(stats.p,0.05);
			stat.(strScheme).pConf		= stats.p;
			stat.(strScheme).pfdrConf	= pFDR;
			stat.(strScheme).rConf		= stats.r;
			stat.(strScheme).dfConf		= stats.df;
		
		%jackknifed confusion
			confJK	= permute(stat.(strScheme).conf,[3 1 2 4]);
			for kM=1:nMaskPairDiff
				confCur				= reshape(confJK(:,:,:,kM),nSubject,[]);
				confCurJK			= jackknife(@(x) mean(x,1),confCur);
				confJK(:,:,:,kM)	= reshape(confCurJK,nSubject,4,4);
			end
			stat.(strScheme).confJK		= permute(confJK,[2 3 1 4]);
			
			%these should be the same as non-jackknifed
			stat.(strScheme).mConfJK	= squeeze(mean(stat.(strScheme).confJK,3));
			stat.(strScheme).seConfJK	= squeeze(stderrJK(stat.(strScheme).confJK,[],3));
			
			stat.(strScheme).rConfJK	= NaN(nSubject,nMaskPairDiff);
			for kU=1:nSubject
				for kM=1:nMaskPairDiff
					stat.(strScheme).rConfJK(kU,kM)	= corrcoef2(reshape(conf{1},[],1),reshape(stat.(strScheme).confJK(:,:,kU,kM),1,[]));
				end
			end
			
			stat.(strScheme).mRConfJK	= mean(stat.(strScheme).rConfJK,1)';
			stat.(strScheme).seRConfJK	= stderrJK(stat.(strScheme).rConfJK,[],1)';
			
			[h,p,ci,stats]					= ttestJK(stat.(strScheme).rConfJK,0,0.05,'right',1);
			[pThresh,pFDR]					= fdr(p,0.05);
			stat.(strScheme).pRConfJK		= p';
			stat.(strScheme).pfdrRConfJK	= pFDR';
			stat.(strScheme).tRConfJK		= stats.tstat';
			stat.(strScheme).dfRConfJK		= stats.df';
	end
	
	k	= union(find(strcmp(cMaskPairDiff(:,1),roi1) & strcmp(cMaskPairDiff(:,2),roi2)),find(strcmp(cMaskPairDiff(:,1),roi2) & strcmp(cMaskPairDiff(:,2),roi1)));

%plot
	z	=	fisherz([
				stat.shape.rConf(k)
				stat.operation.rConf(k)
			]);
	t	=	[
				stat.shape.tRConfJK(k)
				stat.operation.tRConfJK(k)
			];
	se	=	[
				stat.shape.seRConfJK(k)
				stat.operation.seRConfJK(k)
			];
	sig	=	[
				stat.shape.pfdrRConfJK(k)
				stat.operation.pfdrRConfJK(k)
			];
	
	cScheme	=	{
					'representation'
					'manipulation'
				};
	
	h	= alexplot(z,...
			'error'					, se				, ...
			'sig'					, sig				, ...
			'ylabel'				, 'Fisher''s z(r)'	, ...
			'grouplabel'			, cScheme			, ...
			'legendlocation'		, 'NorthEast'		, ...
			'hline'					, 0					, ...
			'hlinecolor'			, 'black'			, ...
			'ymin'					, -0.3				, ...
			'ymax'					, 1.2				, ...
			'dimnsig'				, false				, ...
			'w'						, 400				, ...
			'h'						, 300				, ...
			'axistype'				, 'L'				, ...
			'lax'					, 0.2				, ...
			'wax'					, 0.79				, ...
			'tax'					, 0.03				, ...
			'hax'					, 0.75				, ...
			'showgrid'				, false				, ...
			'fontsize'				, 1.5				, ...
			'type'					, 'bar'				  ...
			);
	
	strPathOut	= PathUnsplit(strDirOut,'classification','png');
	fig2png(h.hF,strPathOut);
	