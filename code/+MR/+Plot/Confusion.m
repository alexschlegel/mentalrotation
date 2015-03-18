function h = Confusion(stat,varargin)
% MR.Plot.Confusion
% 
% Description:	plot confusion matrices using info from a stat struct returned
%				by MR.Analyze.ROIMVPA
% 
% Syntax:	h = MR.Plot.Confusion(stat,<options>)
% 
% Updated: 2014-04-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'outdir'	, []	  ...
		);

cLabelScheme	= stat.label{1};
cLabelROI		= stat.label{2};
cLabelROI = strrep(cLabelROI,'frontal_pole','fo');
cLabelROI = strrep(cLabelROI,'premotor','pm');
cLabelROI = strrep(cLabelROI,'primary_motor','mc');
cLabelROI = strrep(cLabelROI,'somatosens','ss');
cLabelROI = strrep(cLabelROI,'prepre_sma','ba_9');
cLabelROI = strrep(cLabelROI,'pre','p');
cLabelROI = strrep(cLabelROI,'pitc','loc');

kSchemeOrder	= MR.Plot.Order(cLabelScheme);
kROIOrder		= MR.Plot.Order(cLabelROI);

cLabelScheme	= cLabelScheme(kSchemeOrder);
cLabelROI		= cLabelROI(kROIOrder);
C				= stat.confusion.mean.allway(kSchemeOrder,kROIOrder,:,:);

nScheme	= numel(cLabelScheme);
nROI	= numel(cLabelROI);

%color bar
	lutCP	=	[
					0		0		0
					0		0		0
					0.15	0.15	0.15
					0.5		0.5		0.5
					1		1		1
					1		1		0
					1		1		0
				];
	tC		= MapValue([10 15 20 25 35 47 50],10,50,0,1);
	
	colScheme	= GetPlotColors(2);
	lutScheme	= arrayfun(@(k) [lutCP(1:end-2,:); colScheme(k,:); colScheme(k,:)],(1:2)','uni',false);
	
	lut			= MakeLUT(lutCP,255,tC,'interp','pchip');
	lutScheme	= cellfun(@(x) MakeLUT(x,255,tC,'interp','pchip'),lutScheme,'uni',false);

%LUTs
	for kS=1:nScheme
		[h,im]	= ShowPalette(lutScheme{kS}(end:-1:1,:),150,900);
		
		strName		= sprintf('lut-%s',cLabelScheme{kS});
		strPathOut	= PathUnsplit(opt.outdir,strName,'png');
		imwrite(im,strPathOut);
		
		close(h);
	end

%plot
	h	= cell(nScheme,nROI);
	
	model	= MR.ConfusionModels;
	
	for kS=1:nScheme
		for kR=0:nROI
			if kR==0
				conf	= model{1};
				
				cmMin	= 1;
				cmMax	= 4;
			else
				conf	= squeeze(C(kS,kR,:,:));
				conf	= 100*conf./repmat(sum(conf),[size(conf,1) 1]);
				
				cmMin	= 15;
				cmMax	= 35;
			end
			
			hSingle		= alexplot(conf,...
							'lut'			, lutScheme{kS}	, ...
							'cmmin'			, cmMin			, ...
							'cmmax'			, cmMax			, ...
							'tplabel'		, false			, ...
							'values'		, true			, ...
							'w'				, 200			, ...
							'h'				, 200			, ...
							'wax'			, 1				, ...
							'hax'			, 1				, ...
							'lax'			, 0				, ...
							'tax'			, 0				, ...
							'style'			, 'bare'		, ...
							'colorbar'		, false			, ...
							'scalelabel'	, '*'			, ...
							'values_unit'	, false			, ...
							'type'			, 'confusion'	  ...
							);
			
			if ~isempty(opt.outdir)
				if kR==0
					strROI	= 'model'; 
				else
					strROI	= cLabelROI{kR};
				end
				
				strName		= sprintf('confusion-%s-%s',cLabelScheme{kS},strROI);
				strPathOut	= PathUnsplit(opt.outdir,strName,'png');
				im			= fig2png(hSingle.hF,strPathOut,'dpi',600);
			end
			
			if kR~=0
				strTitle	= conditional(kS==1,cLabelROI{kR},[]);
				strLabelY	= conditional(kR==1,cLabelScheme{kS},[]);
				
				h{kS,kR}	= alexplot(conf,...
								'title'			, strTitle		, ...
								'ylabel'		, strLabelY		, ...
								'lut'			, lut			, ...
								'cmmin'			, cmMin(1)		, ...
								'cmmax'			, cmMax(1)		, ...
								'tplabel'		, false			, ...
								'values'		, true			, ...
								'w'				, 150			, ...
								'h'				, 150			, ...
								'wax'			, 0.8			, ...
								'hax'			, 0.8			, ...
								'lax'			, 0.2			, ...
								'tax'			, 0.2			, ...
								'colorbar'		, false			, ...
								'scalelabel'	, '*'			, ...
								'values_unit'	, false			, ...
								'type'			, 'confusion'	  ...
								);
				
				if kR==1
					set(h{kS,kR}.hYlabel,'Position',[0 0.5 0],'FontSize',18);
				end
			end
		end
	end

%combine
	h	= multiplot(h,...
			'label'		, false	, ...
			'spacer'	, false	  ...
			);
	
% 	colormap(lut);
    colormap(lutScheme{1});

%save
	if ~isempty(opt.outdir)
		strPathOut	= PathUnsplit(opt.outdir,'confusions','png');
		im			= fig2png(h.hF,strPathOut,'dpi',600);
	end
