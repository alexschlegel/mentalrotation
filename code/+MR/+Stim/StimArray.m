function im = StimArray(varargin)
% MR.Stim.StimArray
% 
% Description:	render all the stimuli together
% 
% Syntax:	im = MR.Stim.StimArray(<options>)
% 
% In:
%	<options>:
%		map:	(see MR.Stim.Stimulus)
% 
% Out:
% 	im	- the stimulus image
% 
% Updated: 2013-11-16
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'map'	, []	  ...
		);

s	= MR.Param('size','stim');
pad	= 10;
col	= im2double(MR.Param('color','back'));
im	= arrayfun(@(k) imPad(MR.Stim.Stimulus(k,'map',opt.map),col,s+pad,s+pad),1:4,'uni',false);
im	= cat(2,im{:});
