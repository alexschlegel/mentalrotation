function b = MasksControl(varargin)
% MR.MasksControl
% 
% Description:	prepare control masks from CI
% 
% Syntax:	b = MR.MasksControl(<options>)
% 
% In:
% 	<options>:
%		force:	(false)
%		cores:	(12)
% 
% Updated: 2016-01-13
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'force'		, false	, ...
		'cores'		, 12	  ...
		);

cSession	= MR.Subject('state','fmri');

strDirMaskOut	= DirAppend(strDirData,'mask');

sMask	= MR.Masks;

%CI masks
	cMaskCI	=	{
					'mfc'
					'mtl'
					'thal'
				};
	
	strDirMaskCI	= DirAppend(strDirData,'mask-ci');
	cPathMaskCI		= cellfun(@(m) PathUnsplit(strDirMaskCI,m,'nii.gz'),cMaskCI,'uni',false);
	nMaskCI			= numel(cPathMaskCI);
	
	cDirReg		= cellfun(@(s) DirAppend(strDirData,'functional',s,'feat_cat','reg'),cSession,'uni',false);
	bDo			= cellfun(@isdir,cDirReg);
	
	[cSession,cDirReg]	= varfun(@(x) x(bDo),cSession,cDirReg);
	nSession			= numel(cSession);
	
	cDirMask	= cellfun(@(s) DirAppend(strDirMaskOut,s),cSession,'uni',false);
	cellfun(@CreateDirPath,cDirMask);
	
	cPathXFMMNI2Func	= cellfun(@(d) PathUnsplit(d,'standard2example_func','mat'),cDirReg,'uni',false);
	cPathFunc			= cellfun(@(d) PathUnsplit(d,'example_func','nii.gz'),cDirReg,'uni',false);
	
	cPathMaskCIRep		= repmat(cPathMaskCI,[1 nSession]);
	cPathXFMMNI2FuncRep	= repmat(cPathXFMMNI2Func',[nMaskCI 1]);
	cPathFuncRep		= repmat(cPathFunc',[nMaskCI 1]);
	cDirMaskRep			= repmat(cDirMask',[nMaskCI 1]);
	
	cPathMaskRep	= cellfun(@(dm,fm) PathUnsplit(dm,PathGetFileName(fm)),cDirMaskRep,cPathMaskCIRep,'uni',false);
	
	b	= FSLRegisterFLIRT(cPathMaskCIRep,cPathFuncRep,...
			'output'	, cPathMaskRep			, ...
			'xfm'		, cPathXFMMNI2FuncRep	, ...
			'interp'	, 'nearestneighbour'	, ...
			'force'		, opt.force				, ...
			'cores'		, opt.cores				  ...
			);

%brain stem and dorsal striatum
	%more human-readable first
	cMaskBilateral	=	{
							{
								'brainstem'
								{'Brain-Stem'}
								[]
							}
							{
								'dstriatum'
								{'Left-Caudate', 'Left-Putamen', 'Right-Caudate', 'Right-Putamen'}
								[]
							}
						};
	
	cMaskBilateral	= cat(2,cMaskBilateral{:})';
	
	cMask		= [cMaskBilateral];
	cMaskName	= cMask(:,1);
	cMaskLabel	= cMask(:,2);
	cCrop		= cMask(:,3);

	nMask		= numel(cMaskLabel);
	
	cDirFEAT		= reshape(cellfun(@(s) DirAppend(strDirData,'functional',s,'feat_cat'),cSession,'uni',false),1,[]);
	cDirFreeSurfer	= reshape(cellfun(@(s) DirAppend(strDirData,'structural',s,'freesurfer'),cSession,'uni',false),1,[]);
	
	%compute the Freesurfer to functional space transforms
		b	= FreeSurfer2FEAT(cDirFreeSurfer,cDirFEAT,...
				'force'		, opt.force	, ...
				'cores'		, opt.cores	  ...
				);
		
		cPathFS2F	= cellfun(@(d) PathUnsplit(DirAppend(d,'reg'),'freesurfer2example_func','mat'),cDirFEAT,'UniformOutput',false);
		cPathF		= cellfun(@(d) PathUnsplit(DirAppend(d,'reg'),'example_func','nii.gz'),cDirFEAT,'UniformOutput',false);
	%extract the masks
		cDirFreeSurferR	= repmat(cDirFreeSurfer,[nMask 1]);
		cDirMaskR		= repmat(cDirMask',[nMask 1]);
		cMaskLabelR		= repmat(cMaskLabel,[1 nSession]);
		cMaskNameR		= repmat(cMaskName,[1 nSession]);
		cCropR			= repmat(cCrop,[1 nSession]);
		cPathFS2FR		= repmat(cPathFS2F,[nMask 1]);
		cPathFR			= repmat(cPathF,[nMask 1]);
		
		cPathMask	= cellfun(@(d,m) PathUnsplit(d,m,'nii.gz'),cDirMaskR,cMaskNameR,'uni',false);
		
		cInput	=	{...
						cDirFreeSurferR						, ...
						cMaskLabelR							, ...
						'crop'			, cCropR			, ...
						'xfm'			, cPathFS2FR		, ...
						'ref'			, cPathFR			, ...
						'output'		, cPathMask			, ...
						'force'			, opt.force			  ...
					};
		
		b	= MultiTask(@FreeSurferMask,cInput,...
					'description'	, 'extracting masks'	, ...
					'cores'			, opt.cores			  ...
					);
