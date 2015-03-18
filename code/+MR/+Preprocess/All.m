function All(varargin)
% MR.Preprocess.All
% 
% Description:	do all the preliminary preprocessing. mainly here as a record.
% 
% Syntax:	MR.Preprocess.All(<options>)
% 
% In:
% 	<options>:
%		nthread:	(12)
%		force:		(false)
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

syncmri;

MR.Preprocess.Organize(varargin{:});
MR.Preprocess.Functional(varargin{:});
MR.Preprocess.FreeSurfer(varargin{:});
MR.Preprocess.Masks(varargin{:});
