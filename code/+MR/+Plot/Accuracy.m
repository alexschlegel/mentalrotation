function h = Accuracy(stat,varargin)
% MR.Plot.Accuracy
% 
% Description:	plot an accuracy figure using info from a stat struct returned
%				by MR.Analyze.ROIMVPA
% 
% Syntax:	h = MR.Plot.Accuracy(stat,<options>)
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

acc	= 100*stat.accuracy.mean.allway;
err	= 100*stat.accuracy.se.allway;
p	= stat.accuracy.pfdr.allway;

cLabelGroup	= stat.label{1};
cLabelBar	= stat.label{2};
cLabelBar = strrep(cLabelBar,'frontal_pole','fo');
cLabelBar = strrep(cLabelBar,'premotor','pm');
cLabelBar = strrep(cLabelBar,'primary_motor','mc');
cLabelBar = strrep(cLabelBar,'somatosens','ss');
cLabelBar = strrep(cLabelBar,'prepre_sma','ba_9');
cLabelBar = strrep(cLabelBar,'pre','p');
cLabelBar = strrep(cLabelBar,'pitc','loc');

%plot
	h	= MR.Plot.Bar(acc,err,p,cLabelGroup,cLabelBar,...
			'name'		, 'accuracy'		, ...
			'groups'	, cLabelGroup		, ...
			'bars'		, cLabelBar			, ...
			'ylabel'	, 'Accuracy (%)'	, ...
			'ymin'		, 15				, ...
			'ymax'		, 50				, ...
			'thresh'	, 25				, ...
			varargin{:});
