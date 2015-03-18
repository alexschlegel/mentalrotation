function strDir = Directory(strName)
% MR.Data.Directory
% 
% Description:	get the path to a directory in which to store stuff
% 
% Syntax:	str = MR.Data.Directory(strName)
% 
% Updated: 2014-03-07
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;
persistent strDirStore

if isempty(strDirStore)
	strDirStore	= DirAppend(strDirData,'store');
	CreateDirPath(strDirStore);
end

strDir	= DirAppend(strDirStore,strName);
CreateDirPath(strDir);
