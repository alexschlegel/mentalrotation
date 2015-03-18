function b = FreeSurfer(varargin)
% MR.Preprocess.FreeSurfer
% 
% Description:	run the structural data through FreeSurfer
% 
% Syntax:	b = MR.Preprocess.FreeSurfer(<options>)
% 
% In:
%	<options>:
%		stage:		(<all>) an array of the stages to process
%		subject:	(<all>) the codes of the subjects to process
%		opt:		('') extra options for freesurfer
%		nthread:	(11) the number of threads to use
%		force:		(false) true to reprocess everything
% 
% Updated: 2014-03-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'stage'		, []	, ...
		'subject'	, []	, ...
		'opt'		, ''	, ...
		'nthread'	, 11	, ...
		'force'		, false	  ...
		);

cPathStruct	= MR.Path.Structural('subject',opt.subject,'state','fmri');

b	= FreeSurferProcess(cPathStruct,...
		'stage'		, opt.stage		, ...
		'opt'		, opt.opt		, ...
		'nthread'	, opt.nthread	, ...
		'force'		, opt.force		  ...
		);
