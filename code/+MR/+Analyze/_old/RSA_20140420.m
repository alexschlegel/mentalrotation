function [rsa,cOrder] = RSA(varargin)
% GO.Analyze.RSA
% 
% Description:	calculate RSA patterns for each subject and mask
% 
% Syntax:	[rsa,cOrder] = GO.Analyze.RSA(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<core>) the names of the masks to use
%		ncomp:		(10) the number of ICA components to use
%		ifo:		(<load>) the result of a call to GO.SubjectInfo
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force:		(false) true to force computation
%		force_pre:	(false) true to force preprocessing
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	rsa		- an nSubject x nMask cell of RSA matrices
%	cOrder	- an nCondition x 1 cell specifying the ordering of conditions in
%			  the RSA matrices
% 
% Updated: 2014-04-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'subject'	, {}	, ...
		'mask'		, {}	, ...
		'ncomp'		, 10	, ...
		'ifo'		, []	, ...
		'nthread'	, 12	, ...
		'load'		, true	, ...
		'force'		, false	, ...
		'force_pre'	, false	, ...
		'silent'	, false	  ...
		);

%subject codes
	cSubject	= GO.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%mask paths
	[cPathMask,cMask]	= GO.Path.Mask('subject',opt.subject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject cMask opt.ncomp};
	
	if ~opt.force && opt.load
		sData	= GO.Data.Load('rsa',param);
		
		if ~isempty(sData)
			rsa		= sData.rsa;
			cOrder	= sData.cOrder;
			
			return;
		end
	end

%get the subject info
	if isempty(opt.ifo)
		ifo	= GO.SubjectInfo('subject',cSubject);
	else
		ifo	= opt.ifo;
	end

%calculate ICA components
	[C,cPathICA,cPathMask]	= GO.Analyze.ICA(...
								'subject'	, cSubject		, ...
								'mask'		, cMask			, ...
								'mindim'	, opt.ncomp		, ...
								'nthread'	, opt.nthread	, ...
								'load'		, opt.load		, ...
								'force'		, opt.force_pre	, ...
								'silent'	, opt.silent	  ...
								);

%calculate the RSA patterns
	cTarget	= ifo.label.mvpa.target.shapeop.correct;
	
	[rsa,cOrder]	= fMRIRSA(cPathICA,cTarget,...
						'mask'				, cPathMask		, ...
						'distance'			, 'mahalanobis'	, ...
						'spatiotemporal'	, true			, ...
						'nthread'			, opt.nthread	, ...
						'silent'			, opt.silent	  ...
						);

%save the result
	sData.rsa		= rsa;
	sData.cOrder	= cOrder;
	
	GO.Data.Save(sData,'rsa',param);
