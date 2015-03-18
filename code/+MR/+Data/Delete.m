function d = Delete(strName,varargin)
% MR.Data.Delete
% 
% Description:	delete data previously saved with MR.Data.Save
% 
% Syntax:	MR.Data.Delete(strName,[param]=<none>)
% 
% In:
%	strName	- the data name
%	[param]	- a variable storing parameters for the data, in case different
%			  versions of the data exist with different parameters 
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPathData	= MR.Data.Path(strName,varargin{:});

if FileExists(strPathData)
	delete(strPathData);
end
