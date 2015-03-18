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
%		ifo:		(<load>) the result of a call to GO.SubjectInfo
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force_mvpa:	(true) true to force classification
%		force_each:	(false) true to force each mask computation
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
		'subject'		, {}	, ...
		'mask'			, {}	, ...
		'ifo'			, []	, ...
		'nthread'		, 12	, ...
		'load'			, true	, ...
		'force_mvpa'	, true	, ...
		'force_each'	, false	, ...
		'force_pre'		, false	, ...
		'silent'		, false	  ...
		);

strDirOut	= GO.Data.Directory('rsa');

%subject codes
	cSubject	= GO.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%mask paths
	[cPathMask,cMask]	= GO.Path.Mask('subject',opt.subject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject cMask};
	
	if opt.load
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
	[C,cPathData,cPathMask]	= GO.Analyze.ICA(...
								'subject'	, cSubject		, ...
								'mask'		, cMask			, ...
								'nthread'	, opt.nthread	, ...
								'load'		, opt.load		, ...
								'force'		, opt.force_pre	, ...
								'silent'	, opt.silent	  ...
								);

%calculate the RSA patterns
	%allway classifications
		durRun	= GO.Param('trrun');
		nRun	= size(ifo.shape,2);
		kRun	= reshape(repmat(1:nRun,[durRun 1]),[],1);
		
		
		cTarget	= ifo.label.mvpa.target.shapeop.correct;
		kChunk	= ifo.label.mvpa.chunk.correct;
		
		cOutPrefix	= cSubject;
		
		res	= MVPAClassify(cPathData,cTarget,kChunk,...
				'path_mask'			, cPathMask			, ...
				'mask_name'			, cMask				, ...
				'spatiotemporal'	, true				, ...
				'target_blank'		, 'Blank'			, ...
				'zscore'			, kRun				, ...
				'output_dir'		, strDirOut			, ...
				'output_prefix'		, cOutPrefix		, ...
				'nthread'			, opt.nthread		, ...
				'debug'				, 'all'				, ...
				'force'				, opt.force_mvpa	, ...
				'force_each'		, opt.force_each	, ...
				'silent'			, opt.silent		  ...
				);
	%convert the confusion matrices to RSA matrices
		rsa	= cell(nSubject,nMask);
		
		nCondition	= size(res.(cMask{1}).allway.confusion,1);
		bDiag		= logical(eye(nCondition));
		
		for kM=1:nMask
			for kS=1:nSubject
				%confusion matrix
					cm	= res.(cMask{kM}).allway.confusion(:,:,kS);
				%confusion rate
					cm	= cm./repmat(sum(cm),[nCondition 1]);
				%error (i.e. dissimilarity
					cm	= 1 - cm;
				
				%make it symmetric
					cm	= (cm+cm')/2;
				
				%set the diagonal to zero
				cm(bDiag)	= 0;
				
				rsa{kS,kM}	= cm;
			end
		end
	
	cOrder	= res.(cMask{1}).allway.target{1};

%save the result
	sData.rsa		= rsa;
	sData.cOrder	= cOrder;
	
	GO.Data.Save(sData,'rsa',param);
