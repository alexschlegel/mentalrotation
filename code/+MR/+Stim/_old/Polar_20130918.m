function [im,b] = Polar(shp,rot,flip,col,varargin)
% GridOp.Stim.Polar
% 
% Description:	create a polar stimulus image
% 
% Syntax:	[im,b] = GridOp.Stim.Polar(shp,rot,flip,col,[s]=<default>)
% 
% In:
% 	shp		- the shape number
%	rot		- the number of 90 degree CW rotations (negative for CCW)
%	flip	- flip: 0 for none, 'h' for H flip, 'v' for V flip
%	col		- the color number
%	[s]		- the size of the output image
% 
% Out:
% 	im	- the output image
%	b	- the binary image
% 
% Updated: 2013-08-30
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= ParseArgs(varargin,GO.Param('size','stim'));

%the shape
	shp	= GO.Param('shape','polar',shp);
	
	%polar coordinates
		xy		= GetInterval(-s/2,s/2,s);
		[x,y]	= meshgrid(xy,xy);
		r		= sqrt(x.^2 + y.^2);
		a		= atan2(y,x);
		
		shell	= 4-floor(8*r/s);
		quad	= floor(mod(2*(1 + a./pi)-1,4))+1;
	
	b	= false(s);
	
	for kS=1:4
		for kQ=1:4
			if shp(kS,kQ)
				b(shell==kS & quad==kQ)	= true;
			end
		end
	end
%flip it
	switch flip
		case 0%nothing to do
		case 'h'%horizontal flip
			b	= fliplr(b);
		case 'v'%vertical flip
			b	= flipud(b);
	end
%rotate it
	b	= imrotate(b,-rot*90);

%RGB image
	colBack	= GO.Param('color','back');
	colFore	= GO.Param('color','fore',col);
	col		= im2double([colBack; colFore]);
	
	im	= ind2rgb(uint8(b),col);
