function strDir = Directory(strName)
% MR.Data.Directory
% 
% Description:	get the path to a directory in which to store stuff
% 
% Syntax:	str = MR.Data.Directory(strName)
% 
<<<<<<< HEAD
% Updated: 2015-02-05
% - Changed "store" to "processed"
=======
% Updated: 2014-03-07
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;
persistent strDirStore

if isempty(strDirStore)
<<<<<<< HEAD
	strDirStore	= DirAppend(strDirData,'processed');
=======
	strDirStore	= DirAppend(strDirData,'store');
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
	CreateDirPath(strDirStore);
end

strDir	= DirAppend(strDirStore,strName);
CreateDirPath(strDir);
