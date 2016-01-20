strDirIn	= '/mnt/tsestudies/wertheimer/gridop/data/store/pca-50/';
strDirOut	= '/home/alex/studies/gridop/figures/S2/roialign/';

kPCA	= [1 2 3 50];
nPCA	= numel(kPCA);

subject	= '04oct13as';
roi		=	{
				'ppc'
				'pcu'
			};
nROI	= numel(roi);

colMask	=	[
				0	160	0	%ppc
				224	144	0	%pcu
			]/255;

sz	= 1500;

strPathPCA1	= PathUnsplit(DirAppend(strDirIn,sprintf('%s-%s',subject,roi{1})),'melodic_white','');
strPathPCA2	= PathUnsplit(DirAppend(strDirIn,sprintf('%s-%s',subject,roi{2})),'melodic_white','');

pca1	= str2array(fget(strPathPCA1));
pca2	= str2array(fget(strPathPCA2));

pca1	= pca1(end:-1:1,:);
pca2	= pca2(end:-1:1,:);

D	= pdist2(pca1,pca2,'correlation');

%negative correlations
	bNeg	= D>1;
	D(bNeg)	= 2-D(bNeg); %1 - (-(1 - D))
	
	%anything negative is just due to floating point error
		D(D<0)	= 0;

imD	= imresize(normalize(D,'prctile',0.01),[sz sz],'nearest');
strPathOut	= PathUnsplit(strDirOut,'dist','png');
imwrite(imD,strPathOut);

%minimize the trace
	kY2X	= mintrace(D);
	DMatch	= D(:,kY2X);

imDMatch	= imresize(normalize(DMatch,'prctile',0.01),[sz sz],'nearest');
strPathOut	= PathUnsplit(strDirOut,'dist_match','png');
imwrite(imDMatch,strPathOut);

%save the matched timecourses
	[pcaM{1},pcaM{2}] = SignalMatch(pca1',pca2');
	
	for kR=1:nROI
		pca	= pcaM{kR}(:,end:-1:1)';
		
		kROI	= 1:164;	%one run's worth
		
		for kP=1:nPCA
			kCur	= kPCA(kP);
			k		= size(pca,1) - kCur + 1;
			pcaCur	= 2*normalize(pca(k,kROI),'prctile',0.01)-1;
			
			h	= alexplot(pcaCur,...
					'color'			, colMask(kR,:)	, ...
					'ymin'			, -1			, ...
					'ymax'			, 1				, ...
					'linewidth'		, 1.5			, ...
					'axiswidth'		, 1.5			, ...
					'pgrid'			, 2				, ...
					'axistype'		, 'zero'		, ...
					'showyvalues'	, false			, ...
					'lax'			, 0.01			, ...
					'wax'			, 0.99			, ...
					'tax'			, 0				, ...
					'hax'			, 1				, ...
					'l'				, 0				, ...
					'w'				, 1350			, ...
					'h'				, 200			  ...
					);
			
			strPathOut	= PathUnsplit(strDirOut,['pca-' roi{kR} '-' StringFill(kCur,2)],'png');
			fig2png(h.hF,strPathOut);
		end
	end
	