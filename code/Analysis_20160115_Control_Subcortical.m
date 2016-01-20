% Analysis_20160115_Control_Subcortical
% look at univariate differences in brainstem and dorsal striatum between mental
% and manual rotations
% Updated: 2016-01-15
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nCore	= 12;

%create directory for analysis results
	strNameAnalysis	= '20160115_control_subcortical';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo			= MR.SubjectInfo;
	cSession	= ifo.code.fmri;

%masks
	cMask	=	{
					'brainstem'
					'dstriatum'
				};
	
	strDirMask	= DirAppend(strDirData,'mask');
	cDirMask	= cellfun(@(s) DirAppend(strDirMask,s),cSession,'uni',false);
	
	cPathMask	= cellfun(@(d) cellfun(@(m) PathUnsplit(d,m,'nii.gz'),cMask,'uni',false),cDirMask,'uni',false);

%functional betas
	strDirFunctional	= DirAppend(strDirData,'functional');
	
	cDirStats	= cellfun(@(s) DirAppend(strDirFunctional,s,'feat_cat','stats'),cSession,'uni',false);
	
	%from Analysis_20141117_FEAT
		cPathBetaMental	= cellfun(@(d) PathUnsplit(d,'pe1','nii.gz'),cDirStats,'uni',false);
		cPathBetaManual	= cellfun(@(d) PathUnsplit(d,'pe5','nii.gz'),cDirStats,'uni',false);
		
		%one subject only has 2 predictors in the GLM, but the 2nd appears to be manual rotations
			bStrange					= ~FileExists(cPathBetaManual);
			cPathBetaManual(bStrange)	= cellfun(@(d) PathUnsplit(d,'pe3','nii.gz'),cDirStats(bStrange),'uni',false);

%get the mean beta within each mask and condition
	betaMental	= cellfunprogress(@(fb,fm) cellfun(@(m) NIfTI.MaskMean(fb,m),fm),cPathBetaMental,cPathMask,...
					'label'	, 'loading mental betas'	, ...
					'uni'	, false						  ...
					);
	betaManual	= cellfunprogress(@(fb,fm) cellfun(@(m) NIfTI.MaskMean(fb,m),fm),cPathBetaManual,cPathMask,...
					'label'	, 'loading manual betas'	, ...
					'uni'	, false						  ...
					);
	
	%reorganize the data
		betaMental	= cat(2,betaMental{:})';
		betaManual	= cat(2,betaManual{:})';
	
	%test for differences
		[h,p,ci,stats]	= ttest(betaMental,betaManual);
		
		res	= struct(...
				'mean'	, [mean(betaMental,1); mean(betaManual,1)]				, ...
				'se'	, [stderr(betaMental,[],1); stderr(betaManual,[],1)]	, ...
				't'		, stats.tstat											, ...
				'df'	, stats.df												, ...
				'p'		, p														  ...
				);
	
	%save the results
		strPathOut	= PathUnsplit(strDirOut,'result','mat');
		save(strPathOut,'res');
	