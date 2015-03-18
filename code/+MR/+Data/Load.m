function d = Load(strName,varargin)
% MR.Data.Load
% 
% Description:	load data previously saved with MR.Data.Save
% 
% Syntax:	d = MR.Data.Load(strName,[param]=<none>)
% 
% In:
%	strName	- the data name
%	[param]	- a variable storing parameters for the data, in case different
%			  versions of the data exist with different parameters 
% 
% Out:
% 	d	- the data, or an empty array if the data don't exist
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPathData	= MR.Data.Path(strName,varargin{:});

if FileExists(strPathData)
	load(strPathData,'d');
else
	d	= [];
end
