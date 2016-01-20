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
%		cores:		(11) the number of processor cores to use
%		force:		(false) true to reprocess everything
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'stage'		, []	, ...
		'subject'	, []	, ...
		'opt'		, ''	, ...
		'cores'		, 11	, ...
		'force'		, false	  ...
		);

cPathStruct	= MR.Path.Structural('subject',opt.subject,'state','fmri');

b	= FreeSurferProcess(cPathStruct,...
		'stage'		, opt.stage		, ...
		'opt'		, opt.opt		, ...
		'cores'		, opt.cores		, ...
		'force'		, opt.force		  ...
		);
