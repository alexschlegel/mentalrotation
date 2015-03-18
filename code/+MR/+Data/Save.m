function Save(d,strName,varargin)
% MR.Data.Save
% 
% Description:	save data for later retrieval
% 
% Syntax:	MR.Data.Save(d,strName,[param]=<none>)
% 
% In:
% 	d		- the data
%	strName	- the data name
%	[param]	- a variable storing parameters for the data, in case different
%			  versions of the data exist with different parameters 
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

param	= ParseArgs(varargin,[]);

save(MR.Data.Path(strName,param),'d','param');
