function im = Overlap(shpRect,rotRect,flipRect,colRect,shpPolar,rotPolar,flipPolar,colPolar,varargin)
% GridOp.Stim.Overlap
% 
% Description:	create an overlap stimulus image
% 
% Syntax:	im = GridOp.Stim.Overlap(shpRect,rotRect,flipRect,colRect,shpPolar,rotPolar,flipPolar,colPolar,[s]=<default>)
% 
% In:
% 	shpRect		- rect shape number
%	rotRect		- the number of 90 degree CW rotations of the rect shape
%				  (negative for CCW)
%	flipRect	- rect flip: 0 for none, 'h' for H flip, 'v' for V flip
%	colRect		- rect color number
% 	shpPolar	- polar shape number
%	rotPolar	- polar rotation
%	flipPolar	- polar flip
%	colPolar	- polar color number
%	[s]			- the size of the output image
% 
% Out:
% 	im	- the output image
% 
% Updated: 2013-08-30
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent sPre chkPre msk mMsk;

s	= ParseArgs(varargin,GO.Param('size','stim'));

%overlap mask
	if isempty(mMsk)
		mMsk	= mapping;
	end
	
	chk	= GO.Param('size','checker');
	
	if isempty(sPre) || sPre~=s || isempty(chkPre) || chkPre~=chk
	%we switched sizes, get the new mask
		sPre	= s;
		chkPre	= chk;
		
		%look for it first in the mask mapping
		msk	= mMsk({s,chk});
		
		if isempty(msk)
		%doesn't exist, generate it
			sChecker		= round(chk);
			sCheckerPre		= ceil(s/sChecker);
			rowCheckerPre	= repmat([false true; true false],[1 ceil(sCheckerPre/2)]);
			imCheckerPre	= repmat(rowCheckerPre,[ceil(sCheckerPre/2) 1]);
			imCheckerPre	= imCheckerPre(1:sCheckerPre,1:sCheckerPre);
			msk				= imresize(imCheckerPre,[s s],'nearest');
			
			mMsk({s,chk})	= msk;
		end
	end

%rect
	[imRect,bRect] = GO.Stim.Rect(shpRect,rotRect,flipRect,colRect,s);
%polar
	[imPolar,bPolar] = GO.Stim.Polar(shpPolar,rotPolar,flipPolar,colPolar,s);
%overlap
	bRect	= bRect & (~bPolar | msk);
	bPolar	= bPolar & (~bRect | ~msk);

%RGB image
	colRect		= GO.Param('color','fore',colRect);
	colPolar	= GO.Param('color','fore',colPolar);
	colBack		= GO.Param('color','back');
	
	col	= im2double([colBack; colRect; colPolar]);
	
	im			= zeros(s,'uint8');
	im(bRect)	= 1;
	im(bPolar)	= 2;
	
	im	= ind2rgb(im,col);
