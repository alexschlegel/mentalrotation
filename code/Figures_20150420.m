% quick and dirty figures for my Georgetown talk
strDirOut	= '/home/alex/work/brains/talks/20150421-georgetown/figures';

%ROI classification
	strNameAnalysis	= '20150318_roimvpa';
	strDirRes		= DirAppend(strDirAnalysis,strNameAnalysis);
	strPathRes		= PathUnsplit(strDirRes,'result','mat');
	load(strPathRes);
	
	m		= res.result.allway.stats.confusion.corr.mz;
	se		= res.result.allway.stats.confusion.corr.sez;
	pfdr	= res.result.allway.stats.confusion.corr.pfdr;
	
	cLabel	= cellfun(@(str) strrep(str,'_',''),res.mask,'uni',false);
	nROI	= numel(cLabel);
	
	col	= GetPlotColors(2);
	col	= repmat(col(2,:),[nROI 1]);
	
	h	= alexplot(m,...
			'error'					, se				, ...
			'grouplabel'			, cLabel			, ...
			'grouplabellocation'	, 45				, ...
			'sig'					, pfdr				, ...
			'color'					, col				, ...
			'ylabel'				, 'Fisher''s Z(r)'	, ...
			'wax'					, 0.88				, ...
			'tax'					, 0.02				, ...
			'hax'					, 0.75				, ...
			'type'					, 'bar'				  ...
			);
	
	strPathOut	= PathUnsplit(strDirOut,'roi_classification','png');
	fig2png(h.hF,strPathOut);

%ROI cross-classification
	strNameAnalysis	= '20150320_roiccmvpa';
	strDirRes		= DirAppend(strDirAnalysis,strNameAnalysis);
	strPathRes		= PathUnsplit(strDirRes,'result','mat');
	load(strPathRes);
	
	t		= squareform(res.result.allway.stats.confusion.corr.t);
	p		= squareform(res.result.allway.stats.confusion.corr.p);
	pfdr	= squareform(res.result.allway.stats.confusion.corr.pfdr);
	
	[t,p,pfdr]	= varfun(@(x) x + conditional(logical(eye(size(x))),NaN,0),t,p,pfdr);
	
	h	= alexplot(t,...
			'sig'			, pfdr			, ...
			'label'			, cLabel		, ...
			'lut'			, col(1,:)		, ...
			'colorbar'		, false			, ...
			'ring_radius'	, 0.8			, ...
			'ring_phase'	, pi/6			, ...
			'cmin'			, 1.75			, ...
			'cmax'			, 4				, ...
			'arcmethod'		, 'line'		, ...
			'arcwidth'		, 'scale'		, ...
			'arcwidthmin'	, 1				, ...
			'arcwidthmax'	, 12			, ...
			'wax'			, 0.95			, ...
			'hax'			, 0.95*4/5		, ...
			'tax'			, 0.02			, ...
			'w'				, 400			, ...
			'h'				, 500			, ...
			'type'			, 'connection'	  ...
			);
	
	strPathOut	= PathUnsplit(strDirOut,'roi_cross_classification','png');
	fig2png(h.hF,strPathOut);
