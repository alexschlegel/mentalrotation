function ShowFigure(mr,id,varargin)
% MentalRotation.ShowFigure
% 
% Description:	show a figure
% 
% Syntax:	mr.ShowFigure(id,<options>)
% 
% In:
% 	id	- the figure id
%	<options> (see MR.GetFigure). also...
%		window:	(<default>) the window on which to show the figure
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'window'	, []	  ...
		);

imFigure	= MR.GetFigure(id,varargin{:});

mr.Experiment.Show.Image(imFigure,[],MR.Param('size','stim'),'window',opt.window);
