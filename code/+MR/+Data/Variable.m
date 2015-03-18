function str = Variable(strName,varargin)
% MR.Data.Variable
% 
% Description:	get the variable name for a piece of data
% 
% Syntax:	str = MR.Data.Variable(strName,[param]=<none>)
% 
% In:
%	strName	- the data name
%	[param]	- a variable storing parameters for the data, in case different
%			  versions of the data exist with different parameters 
% 
% Out:
% 	str	- the data's variable name
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;
persistent strDirStore strPathName

param	= ParseArgs(varargin,[]);

if isempty(strPathName)
	strDirStore	= DirAppend(strDirData,'store');
	CreateDirPath(strDirStore);
	
	strPathName	= PathUnsplit(strDirStore,'name','mat');
end

if ~FileExists(strPathName)
	sName	= struct;
	save(strPathName,'sName');
end

%get the variable name
	str	= str2fieldname(strName);
	if ~isempty(param)
		load(strPathName,'sName');
		
		if ~isfield(sName,str)
			sName.(str)	= {};
		end
		
		kParam	= FindCell(sName.(str),param,1);
		if isempty(kParam)
			kParam				= numel(sName.(str)) + 1;
			sName.(str){kParam}	= param;
			
			save(strPathName,'sName');
		end
		
		str	= [strName num2str(kParam)];
	end
