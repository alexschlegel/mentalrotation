function im = Stimulus(locT,colT,shpT,rotT,flipT,shpC,rotC,flipC)
% GO.Stim.Stimulus
% 
% Description:	render a stimulus
% 
% Syntax:	im = GO.Stim.Stimulus(locT,colT,shpT,rotT,flipT,shpC,rotC,flipC)
% 
% In:
% 	locT	- the target location (1:2)
%	colT	- the target color (1:2)
%	shpT	- the target shape (1:4)
%	rotT	- the target rotation (0:3)
%	flipT	- the target flip ([0 'h' 'v'])
%	shpC	- the control shape
%	rotC	- the control rotation
%	flipC	- the control flip
% 
% Out:
% 	im	- the stimulus image
% 
% Updated: 2013-08-30
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
colC	= 3 - colT;

if shpT<3%rect
	shpRect		= shpT;
	rotRect		= rotT;
	flipRect	= flipT;
	colRect		= colT;
	
	shpPolar	= shpC-2;
	rotPolar	= rotC;
	flipPolar	= flipC;
	colPolar	= colC;
else%polar
	shpRect		= shpC;
	rotRect		= rotC;
	flipRect	= flipC;
	colRect		= colC;
	
	shpPolar	= shpT-2;
	rotPolar	= rotT;
	flipPolar	= flipT;
	colPolar	= colT;
end

im	= GO.Stim.Overlap(shpRect,rotRect,flipRect,colRect,shpPolar,rotPolar,flipPolar,colPolar);
