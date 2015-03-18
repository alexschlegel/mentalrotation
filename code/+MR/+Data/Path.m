function strPathData = Path(strName,varargin)
% MR.Data.Path
% 
% Description:	get the path to the file storing a piece of data 
% 
% Syntax:	strPathData = Path(strName,[param]=<none>)
% 
% In:
%	strName	- the data name
%	[param]	- a variable storing parameters for the data, in case different
%			  versions of the data exist with different parameters 
% 
% Out:
% 	strPathData	- the path to the file storing the data
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

strDirStore	= DirAppend(strDirData,'store');
strVarName	= MR.Data.Variable(strName,varargin{:});
strPathData	= PathUnsplit(strDirStore,strVarName,'mat');
