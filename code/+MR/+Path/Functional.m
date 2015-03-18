function cPathFunctional = Functional(varargin)
% MR.Path.Functional
% 
% Description:	get the path to functional data
% 
% Syntax:	cPathFunctional = MR.Path.Functional(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		state:		('preprocess') see MR.SubjectInfo
%		space:		('subject') the space of the functional data to return. can
%					be 'subject' or 'mni'.
% 
% Out:
% 	cPathFunctional	- an nSubject x 1 cell of the subjects' concatenated
%					  functional data file paths
% 
% Updated: 2014-04-16
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'subject'	, []			, ...
		'state'		, 'preprocess'	, ...
		'space'		, 'subject'		  ...
		);

opt.space	= CheckInput(opt.space,'space',{'subject','mni'});

cSubject			= MR.Subject('subject',opt.subject,'state',opt.state);
strDirFunctional	= DirAppend(strDirData,'functional');
strSuffix			= switch2(opt.space,'subject','','mni','-standard-3mm');
cPathFunctional		= cellfun(@(s) PathUnsplit(DirAppend(strDirFunctional,s),['data_cat' strSuffix],'nii.gz'),cSubject,'uni',false);
