function h = ConfusionCorrelation(stat,varargin)
% MR.Plot.ConfusionCorrelation
% 
% Description:	plot confusion correlation figures using info from a stat
%				struct returned by MR.Analyze.ROIMVPA
% 
% Syntax:	h = MR.Plot.ConfusionCorrelation(stat,<options>)
% 
% Updated: 2014-03-09
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nModel	= size(stat.confusion.corrcompare.group.allway.r,3);

cLabelGroup	= stat.label{1};
cLabelBar	= stat.label{2};
cLabelBar = strrep(cLabelBar,'frontal_pole','fo');
cLabelBar = strrep(cLabelBar,'premotor','pm');
cLabelBar = strrep(cLabelBar,'primary_motor','mc');
cLabelBar = strrep(cLabelBar,'somatosens','ss');
cLabelBar = strrep(cLabelBar,'prepre_sma','ba_9');
cLabelBar = strrep(cLabelBar,'pre','p');
cLabelBar = strrep(cLabelBar,'pitc','loc');

for kM=1:nModel
	z	= fisherz(stat.confusion.corrcompare.group.allway.r(:,:,kM));
	err	= [];
	p	= stat.confusion.corrcompare.group.allway.p(:,:,kM);
	
	zThresh	= fisherz(stat.confusion.corrcompare.group.allway.cutoff);
	
	strName	= sprintf('confusioncorrelation%d',kM);
	
	h	= MR.Plot.Bar(z,err,p,cLabelGroup,cLabelBar,...
			'name'		, strName			, ...
			'groups'	, cLabelGroup		, ...
			'bars'		, cLabelBar			, ...
			'ylabel'	, 'Fisher''s Z(r)'	, ...
			'ymin'		, 0					, ...
			'ymax'		, 3.5				, ...
			'thresh'	, zThresh			, ...
			varargin{:});
end
