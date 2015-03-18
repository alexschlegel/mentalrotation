function [C,strPathICA,cPathMaskICA] = GroupICA(varargin)
% GO.Analyze.ICA
% 
% Description:	run FSL's MELODIC tool on gridop functional whole group
%				concatenated data
% 
% Syntax:	[C,strPathICA,cPathMaskICA] = GO.Analyze.GroupICA(<options>)
% 
% In:
% 	<options>:
%		subject:	(<all>) the subjects to include
%		mask:		(<core>) the names of the masks to use
%		mindim:		(10) the minimum number of ICA dimensions
%		nthread:	(12) number of threads to use
%		load:		(true) true to load the results if we previously saved them
%		force:		(false) true to force computation
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	C				- an nMask x 1 cell of ICA component signals
%	strPathICA		- the ICA NIfTI file path
%	cPathMaskICA	- an nMask x 1 cell of ICA mask file paths
% 
% Updated: 2014-03-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'subject'	, {}	, ...
		'mask'		, {}	, ...
		'mindim'	, 10	, ...
		'nthread'	, 12	, ...
		'load'		, true	, ...
		'force'		, false	, ...
		'silent'	, false	  ...
		);

strDirOut	= GO.Data.Directory('groupica');

%subject codes
	cSubject	= GO.Subject('subject',opt.subject);
	nSubject	= numel(cSubject);
%mask paths
	[cPathMask,cMask]	= GO.Path.Mask('subject',cSubject,'mask',opt.mask);
	nMask				= numel(cMask);

%have we done this already?
	param	= {cSubject cMask opt.mindim};
	
	if ~opt.force && opt.load
		sData	= GO.Data.Load('groupica',param);
		
		if ~isempty(sData)
			C				= sData.C;
			strPathICA		= sData.strPathICA;
			cPathMaskICA	= sData.cPathMaskICA;
			
			return;
		end
	end

%get the functional data paths
	cPathData	= GO.Path.Functional('subject',cSubject);

%concatenate them
	
	
%call MELODIC
	cPathData	= repmat(cPathData,[1 nMask]);
	cPathMask	= cat(2,cPathMask{:})';
	
	cDirMELODIC		= cellfun(@(d,m) DirAppend(PathGetDir(d),[PathGetFilePre(d,'favor','nii.gz') '-' PathGetFilePre(m,'favor','nii.gz') '-all.ica']),cPathData,cPathMask,'uni',false);
	
	C	= FSLMELODIC(cPathData,...
			'out'		, cDirMELODIC	, ...
			'mask'		, cPathMask		, ...
			'mindim'	, opt.mindim	, ...
			'pcaonly'	, false			, ...
			'nthread'	, opt.nthread	, ...
			'force'		, opt.force		, ...
			'silent'	, opt.silent	  ...
			);

%save the NIfTI files
	cPathICA		= cellfun(@(s) PathUnsplit(strDirOut,s,'nii.gz'),cSubject,'uni',false);
	cPathMaskICA	= cellfun(@(s) cellfun(@(m) PathUnsplit(strDirOut,[s '-' m],'nii.gz'),cMask,'uni',false),cSubject,'uni',false);
	
	progress(nSubject,'label','saving ICA data');
	for kS=1:nSubject
		%make the data file
			data	= cat(2,C{kS,:});
			nData	= size(data,2);
			
			data	= permute(data,[2 3 4 1]);
			nii		= make_nii(data);
			
			NIfTIWrite(nii,cPathICA{kS});
		%make the masks
			kMaskPre	= 0;
			for kM=1:nMask
				nCompMask	= size(C{kS,kM},2);
				kMaskStart	= kMaskPre+1;
				kMaskEnd	= kMaskStart + nCompMask - 1;
				
				msk							= zeros(nData,1);
				msk(kMaskStart:kMaskEnd)	= 1;
				
				niiMask	= make_nii(msk);
				
				NIfTIWrite(niiMask,cPathMaskICA{kS}{kM});
				
				kMaskPre	= kMaskEnd;
			end
		
		progress;
	end

%save the result
	sData.C				= C;
	sData.cPathICA		= cPathICA;
	sData.cPathMaskICA	= cPathMaskICA;
	
	GO.Data.Save(sData,'ica',param);
