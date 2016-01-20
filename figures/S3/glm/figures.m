strDirIn	= '/home/alex/studies/gridop/figures/gcmvpa_schematic/glm/orig/';

cROI	=	{
				'ppc'
				'pcu'
			};
nROI	= numel(cROI);

cPathROI	= cellfun(@(r) PathUnsplit(strDirIn,['right-' r],'jpg'),cROI,'uni',false);

%flatten the ROI images
	cPathFlat	= cellfun(@(f) PathAddSuffix(f,'-flat'),cPathROI,'uni',false);
	
	for k=1:nROI
		im	= rgbRead(cPathROI{k});
		msk	= im2mask(im);
		col	= immean(im,msk);
		im	= b2rgb(msk,col,[1 1 1]);
		rgbWrite(im,cPathFlat{k});
	end