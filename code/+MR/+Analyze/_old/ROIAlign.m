function [cPathData,cMaskPair] = ROIAlign(varargin)
% GO.Analyze.ROIAlign
% 
% Description:	align PCA components between ROIs
% 
% Syntax:	[cPathData,cMaskPair] = ROIAlign(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<all>) the names of the masks to use
%		dim:		(50) the number of PCA components to use
%		ifo:		(<load>) the result of a call to GO.SubjectInfo
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force:		(false) true to force computation
%		force_pre:	(false) true to force preprocessing steps
%		silent:		(false) true to suppress status messages
% 
% Out:
%	cPathData	- an nSubject x nMaskPair x 2 cell of aligned PCA NIfTI files
%	cMaskPair	- an nMaskPair x 2 cell of mask pairs
% 
% Updated: 2014-05-01
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'subject'	, {}	, ...
		'mask'		, {}	, ...
		'dim'		, 50	, ...
		'ifo'		, []	, ...
		'nthread'	, 12	, ...
		'load'		, true	, ...
		'force'		, false	, ...
		'force_pre'	, false	, ...
		'silent'	, false	  ...
		);

strDirOut	= MR.Data.Directory('roialign');

%subject codes
	cSubject	= MR.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%mask paths
	[cPathMask,cMask]	= MR.Path.Mask('subject',opt.subject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject cMask opt.dim};
	
	if ~opt.force && opt.load
		sData	= MR.Data.Load('roialign',param);
		
		if ~isempty(sData)
			cPathData	= sData.cPathData;
			cMaskPair	= sData.cMaskPair;
			
			return;
		end
	end

%get the subject info
	if isempty(opt.ifo)
		ifo	= MR.SubjectInfo('subject',cSubject);
	else
		ifo	= opt.ifo;
	end

%data paths
	[C,cPathPCA, ~]	= MR.Analyze.PCA(...
								'subject'	, cSubject		, ...
								'mask'		, cMask			, ...
								'dim'		, opt.dim		, ...
								'nthread'	, opt.nthread	, ...
								'load'		, opt.load		, ...
								'force'		, opt.force_pre	, ...
								'silent'	, opt.silent	  ...
								);

%align the PCA components for each mask pair. do the alignment for each trial,
%leaving data for that trial out of the alignment calculation
	[cMaskPair,kMaskPair]	= handshakes(cMask);
	cMaskPair				= [cMaskPair; repmat(cMask,[1 2])];
	kMaskPair				= [kMaskPair; repmat((1:nMask)',[1 2])];
	nMaskPair				= size(cMaskPair,1);
	
	%get the output file paths
		cPathData	= cell(nSubject,nMaskPair,2);
		
		for kS=1:nSubject
			strSubject	= cSubject{kS};
			
			for kM=1:nMaskPair
				strMask1	= cMaskPair{kM,1};
				strMask2	= cMaskPair{kM,2};
				
				cPathData{kS,kM,1}	= PathUnsplit(strDirOut,sprintf('%s-%s_%s-%s',strSubject,strMask1,strMask2,strMask1),'nii.gz');
				cPathData{kS,kM,2}	= PathUnsplit(strDirOut,sprintf('%s-%s_%s-%s',strSubject,strMask1,strMask2,strMask2),'nii.gz');
			end
		end
	
	b	= MATLABPoolOpen(opt.nthread);
	
	progress(nSubject,'label','aligning ICA components for each mask pair','silent',opt.silent);
	for kS=1:nSubject
		kChunk	= ifo.label.mvpa.chunk.correct{kS};
		
		parfor kM=1:nMaskPair
			if opt.force || ~FileExists(cPathData{kS,kM,1}) || ~FileExists(cPathData{kS,kM,2})
				kM1	= kMaskPair(kM,1);
				kM2	= kMaskPair(kM,2);
				
				%PCA subsets
					C1	= C{kS,kM1}(:,1:opt.dim);
					C2	= C{kS,kM2}(:,1:opt.dim);
				%match up the two sets of components, chunk by chunk (to make sure
				%we aren't artifically inflating the similarity between signals)
					[C1,C2]	= SignalMatch(C1,C2,'chunk',kChunk);
				
				%save the components to a NIfTI file
					nii1	= make_nii(permute(C1,[2 3 4 1]));
					nii2	= make_nii(permute(C2,[2 3 4 1]));
					
					NIfTIWrite(nii1,cPathData{kS,kM,1});
					NIfTIWrite(nii2,cPathData{kS,kM,2});
			end
		end
		
		progress;
	end
	
	b	= MATLABPoolClose;

%save the result
	sData.cPathData	= cPathData;
	sData.cMaskPair	= cMaskPair;
	
	MR.Data.Save(sData,'roialign',param);
