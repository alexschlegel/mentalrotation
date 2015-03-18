function [C,cPathPCA,cPathMaskPCA] = PCA(varargin)
% MR.Analyze.PCA
% 
% Description:	run FSL's MELODIC tool on gridop functional data
% 
% Syntax:	[C,cPathPCA,cPathMaskPCA] = MR.Analyze.PCA(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<all>) the names of the masks to use
%		mindim:		(10) the minimum number of PCA dimensions
%		dim:		([]) manually set the number of PCA dimensions
%		ica:		(false) true to return ICA components rather than PCA
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force:		(false) true to force computation
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	C				- an nSubject x nMask cell of PCA component signals
%	cPathPCA		- an nSubject x 1 cell of PCA NIfTI files
%	cPathMaskPCA	- an nSubject x 1 cell of nMask x 1 cells of PCA mask files
% 
% Updated: 2014-12-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'subject'	, {}	, ...
		'mask'		, {}	, ...
		'mindim'	, 10	, ...
		'dim'		, []	, ...
		'ica'		, false	, ...
		'nthread'	, 12	, ...
		'load'		, true	, ...
		'force'		, false	, ...
		'silent'	, false	  ...
		);

strDim		= tostring(unless(opt.dim,'auto'));
strDataName	= ['pca-' strDim];

status(sprintf('Using %s data (mindim=%d)',strDataName,opt.mindim),'silent',opt.silent);
strDirOut	= MR.Data.Directory(strDataName);

%subject codes
	cSubject	= MR.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%mask paths
	[cPathMask,cMask]	= MR.Path.Mask('subject',opt.subject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject cMask opt.mindim opt.dim};
	
	if ~opt.force && opt.load
		sData	= MR.Data.Load(strDataName,param);
		
		if ~isempty(sData)
			C				= sData.C;
			cPathPCA		= sData.cPathPCA;
			cPathMaskPCA	= sData.cPathMaskPCA;
			
			return;
		end
	end

%get the functional data paths
	cPathData	= MR.Path.Functional('subject',cSubject);
	
%call MELODIC
	cPathData	= repmat(cPathData,[1 nMask]);
	cPathMask	= cat(2,cPathMask{:})';
	
	cSubjectRep		= repmat(cSubject,[1 nMask]);
 	cMaskRep	 	= repmat(cMask',[nSubject 1]);
%    cMaskRep	 	= (repmat(cMask',[1 nSubject]))';
	
	cDirMELODIC	= cellfun(@(s,m) DirAppend(strDirOut,[s '-' m]),cSubjectRep,cMaskRep,'uni',false);
	
	C	= FSLMELODIC(cPathData,...
			'out'		, cDirMELODIC	, ...
			'mask'		, cPathMask		, ...
			'mindim'	, opt.mindim	, ...
			'dim'		, opt.dim		, ...
			'pcaonly'	, ~opt.ica		, ...
			'nthread'	, opt.nthread	, ...
			'force'		, opt.force		, ...
			'silent'	, opt.silent	  ...
			);

%save the NIfTI files
	cPathPCA		= cellfun(@(s) PathUnsplit(strDirOut,s,'nii.gz'),cSubject,'uni',false);
	cPathMaskPCA	= cellfun(@(s) cellfun(@(m) PathUnsplit(strDirOut,[s '-' m],'nii.gz'),cMask,'uni',false),cSubject,'uni',false);
	
	progress(nSubject,'label','saving PCA data');
	for kS=1:nSubject
		%make the data file
			data	= cat(2,C{kS,:});
			nData	= size(data,2);
			
			data	= permute(data,[2 3 4 1]);
			nii		= make_nii(data);
			
			NIfTIWrite(nii,cPathPCA{kS});
		%make the masks
			kMaskPre	= 0;
			for kM=1:nMask
				nCompMask	= size(C{kS,kM},2);
				kMaskStart	= kMaskPre+1;
				kMaskEnd	= kMaskStart + nCompMask - 1;
				
				msk							= zeros(nData,1);
				msk(kMaskStart:kMaskEnd)	= 1;
				
				niiMask	= make_nii(msk);
				
				NIfTIWrite(niiMask,cPathMaskPCA{kS}{kM});
				
				kMaskPre	= kMaskEnd;
			end
		
		progress;
	end

%save the result
	sData.C				= C;
	sData.cPathPCA		= cPathPCA;
	sData.cPathMaskPCA	= cPathMaskPCA;
	
	MR.Data.Save(sData,strDataName,param);
