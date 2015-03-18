function strPathMovie = GetMoviePath(id,op,varargin)
% MR.GetMoviePath
% 
% Description:	get the path to a figure operation movie
% 
% Syntax:	strPathMovie = GetMoviePath(id,op,<options>)
% 
% In:
% 	id	- the figure id
%	op	- the operation to show ('l', 'r', 'b', or 'f')
%	<options>:
%		flip:		(false) true to flip the figure
%		rot180:		(<none>) 'lr' to rotate 180 degrees along the L/R axis, or
%					'bf' to rotate 180 degrees along the B/F axes
% 
% Out:
% 	strPathMovie	- the path to the movie file
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase;

opt	= ParseArgs(varargin,...
		'flip'		, false	, ...
		'rot180'	, 'no'	  ...
		);

strFigure	= StringFill(id,2);
strFlip		= conditional(opt.flip,'flip','orig');
strRot		= ['rot' opt.rot180];

strDirStim	= DirAppend(strDirBase,'stimuli');
strDirMovie	= DirAppend(strDirStim,strFigure,strFlip,strRot);

strPathMovie	= PathUnsplit(strDirMovie,op,'avi');
