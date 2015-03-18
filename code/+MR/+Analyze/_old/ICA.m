function [C,cPathICA,cPathMaskICA] = ICA(varargin)
% GO.Analyze.ICA
% 
% Description:	run FSL's MELODIC tool on gridop functional data
% 
% Syntax:	[C,cPathICA,cPathMaskICA] = GO.Analyze.ICA(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<core>) the names of the masks to use
%		mindim:		(10) the minimum number of ICA dimensions
%		dim:		([]) manually set the number of ICA dimensions
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force:		(false) true to force computation
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	C				- an nSubject x nMask cell of ICA component signals
%	cPathICA		- an nSubject x 1 cell of ICA NIfTI files
%	cPathMaskICA	- an nSubject x 1 cell of nMask x 1 cells of ICA mask files
% 
% Updated: 2014-04-30
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[C,cPathICA,cPathMaskICA]	= GO.Analyze.PCA(varargin{:});
