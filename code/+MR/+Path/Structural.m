function cPathStructural = Structural(varargin)
% MR.Path.Structural
% 
% Description:	get the path to structural data
% 
% Syntax:	cPathStructural = MR.Path.Structural(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		state:		(<default>) see MR.SubjectInfo
% 
% Out:
% 	cPathStructural	- an nSubject x 1 cell of the subjects' strucutral data file
%					  paths
% 
% Updated: 2014-03-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'subject'	, []	, ...
		'state'		, []	  ...
		);

cSubject		= MR.Subject('subject',opt.subject,'state',opt.state);
strDirStruct	= DirAppend(strDirData,'structural');
cDirStruct		= cellfun(@(s) DirAppend(strDirStruct,s),cSubject,'uni',false);
cPathStructural	= cellfun(@(d) PathUnsplit(d,'data','nii.gz'),cDirStruct,'uni',false);
