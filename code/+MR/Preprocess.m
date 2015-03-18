function Preprocess(varargin)
% GO.Preprocess
% 
% Description:	preprocess the gridop data
% 
% Syntax:	GO.Preprocess(<options>)
% 
% In:
% 	<options>:
%		nthread:	(12)
%		force:		(false)
% 
% Updated: 2014-02-21
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData

opt	= ParseArgs(varargin,...
		'nthread'	, 12	, ...
		'force'		, false	  ...
		);

strDirRaw	= DirAppend(strDirData,'raw');

s			= GO.SubjectInfo;
kAnalyze	= find(~cellfun(@isempty,s.code.fmri));
nRun		= size(s.shape,1);

cSubjectCode	= s.code.fmri(kAnalyze);
nSubject		= numel(cSubjectCode);

%organize the data
	[b,cPathRaw,cPathOut]	= PARRECOrganize(strDirRaw,'nthread',opt.nthread);

%preprocess the fMRI data
	strDirStructural	= DirAppend(strDirData,'structural');
	strDirFunctional	= DirAppend(strDirData,'functional');
	
	%BET the structurals
		cPathStructural		= cellfun(@(s) PathUnsplit(DirAppend(strDirStructural,s),'data','nii.gz'),cSubjectCode,'uni',false);
		[b,cPathStructural]	= FSLBet(cPathStructural,...
								'thresh'	, 0.25			, ...
								'nthread'	, opt.nthread	, ...
								'force'		, opt.force		  ...
								);
	
	cPathFunctional	= cellfun(@(s) arrayfun(@(r) PathUnsplit(DirAppend(strDirFunctional,s),['data_' StringFill(r,2)],'nii.gz'),(1:nRun)','uni',false),cSubjectCode,'uni',false);
	cPathStructural	= cellfun(@(s,f) repmat({s},size(f)),cPathStructural,cPathFunctional,'uni',false);
	
	[cPathFunctional,cPathStructural]	= varfun(@cellnestflatten,cPathFunctional,cPathStructural);
	
	[bSuccess,cPathOut,tr]	= FSLFEATPreprocess(cPathFunctional,cPathStructural,...
								'motion_correct'		, true			, ...
								'slice_time_correct'	, 1				, ...
								'spatial_fwhm'			, 6				, ...
								'norm_intensity'		, false			, ...
								'highpass'				, 100			, ...
								'lowpass'				, false			, ...
								'force'					, opt.force		, ...
								'nthread'				, opt.nthread	  ...
								);

%concatenate the fMRI runs
	cPathPP	= reshape(mat2cell(reshape(cPathOut,[nRun nSubject]),nRun,ones(nSubject,1)),[],1);
	
	[b,cPathCat,cDirFEATCat]	= FSLConcatenate(cPathPP,...
									'nthread'	, opt.nthread	, ...
									'force'		, opt.force		  ...
									);

%masks
	b	= GO.Masks(...
			'force'		, opt.force		, ...
			'nthread'	, opt.nthread	  ...
			);
	
	strDirMask	= DirAppend(strDirData,'mask');
	cPathMask	= cellfun(@(s) cellfun(@(m) PathUnsplit(DirAppend(strDirMask,s),['mask-' m '-merged-2func'],'nii.gz'),cMask,'uni',false),cSubjectCode,'uni',false);
