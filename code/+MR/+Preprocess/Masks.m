function b = Masks(varargin)
% MR.Masks
% 
% Description:	prepare masks from CI, the anatomical occipital mask and
% the motor/somatosensory masks.
% 
% Syntax:	b = MR.Masks(<options>)
% 
% In:
% 	<options>:
%		force:	(false)
%		cores:	(12)
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'force'	, false	, ...
		'cores'	, 12	  ...
		);

cSession	= MR.Subject('state','fmri');

strDirMaskOut	= DirAppend(strDirData,'mask');

sMask	= MR.Masks;

%CI masks
	cMaskCI	= setdiff(sMask.ci,'occ');
	
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

%occipital and motor masks
	%more human-readable first
	cMaskBilateral	=	{
							{
								'occ'
								{'ctx_lh_G_and_S_occipital_inf' 'ctx_lh_G_occipital_middle' 'ctx_lh_G_occipital_sup' 'ctx_lh_G_cuneus' 'ctx_lh_Pole_occipital' 'ctx_lh_S_oc_middle_and_Lunatus' 'ctx_lh_S_oc_sup_and_transversal' 'ctx_lh_S_occipital_ant' 'ctx_rh_G_and_S_occipital_inf' 'ctx_rh_G_occipital_middle' 'ctx_rh_G_occipital_sup' 'ctx_rh_G_cuneus' 'ctx_rh_Pole_occipital' 'ctx_rh_S_oc_middle_and_Lunatus' 'ctx_rh_S_oc_sup_and_transversal' 'ctx_rh_S_occipital_ant'}
								[]
							}
							{
								'pmv'
								{'ctx_lh_S_front_inf' 'ctx_lh_G_front_inf_Opercular' 'ctx_rh_S_front_inf' 'ctx_rh_G_front_inf_Opercular'}
								{[0 0 0; 1 1 1/3] [] [0 0 0; 1 1 1/3] []}
							}
							{
								'pmd'
								{'ctx_lh_G_front_middle' 'ctx_lh_S_front_sup' 'ctx_rh_G_front_middle' 'ctx_rh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3] [0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3]}
							}
							{
								'sma'
								{'ctx_lh_G_front_sup' 'ctx_lh_S_front_sup' 'ctx_rh_G_front_sup' 'ctx_rh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3] [0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3]}
							}
							{
								'pre_sma'
								{'ctx_lh_G_front_sup' 'ctx_rh_G_front_sup'}
								{[0 0 1/3; 1 1 2/3] [0 0 1/3; 1 1 2/3]}
							}
							{
								'primary_motor'
								{'ctx_lh_S_central' 'ctx_lh_G_precentral' 'ctx_lh_S_precentral-sup-part' 'ctx_lh_S_precentral-inf-part' 'ctx_rh_S_central' 'ctx_rh_G_precentral' 'ctx_rh_S_precentral-sup-part' 'ctx_rh_S_precentral-inf-part'}
								[]
							}
							{
								'somatosensory'
								{'ctx_lh_G_postcentral' 'ctx_rh_G_postcentral'}
								[]
							}
							{
								'cerebellum'
								{'Left-Cerebellum-Cortex' 'Right-Cerebellum-Cortex'}
								[]
							}
						};
	cMaskUnilateral	=	{
							{
								'occ_left'
								{'ctx_lh_G_and_S_occipital_inf' 'ctx_lh_G_occipital_middle' 'ctx_lh_G_occipital_sup' 'ctx_lh_G_cuneus' 'ctx_lh_Pole_occipital' 'ctx_lh_S_oc_middle_and_Lunatus' 'ctx_lh_S_oc_sup_and_transversal' 'ctx_lh_S_occipital_ant'}
								[]
							}
							{
								'pmv_left'
								{'ctx_lh_S_front_inf' 'ctx_lh_G_front_inf_Opercular'}
								{[0 0 0; 1 1 1/3] []}
							}
							{
								'pmd_left'
								{'ctx_lh_G_front_middle' 'ctx_lh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [1/2 0 0; 1 1 1/3]}
							}
							{
								'sma_left'
								{'ctx_lh_G_front_sup' 'ctx_lh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [0 0 0; 1/2 1 1/3]}
							}
							{
								'pre_sma_left'
								{'ctx_lh_G_front_sup'}
								[0 0 1/3; 1 1 2/3]
							}
							{
								'primary_motor_left'
								{'ctx_lh_S_central' 'ctx_lh_G_precentral' 'ctx_lh_S_precentral-sup-part' 'ctx_lh_S_precentral-inf-part'}
								[]
							}
							{
								'somatosensory_left'
								{'ctx_lh_G_postcentral'}
								[]
							}
							{
								'cerebellum_left'
								{'Left-Cerebellum-Cortex'}
								[]
							}
							{
								'occ_right'
								{'ctx_rh_G_and_S_occipital_inf' 'ctx_rh_G_occipital_middle' 'ctx_rh_G_occipital_sup' 'ctx_rh_G_cuneus' 'ctx_rh_Pole_occipital' 'ctx_rh_S_oc_middle_and_Lunatus' 'ctx_rh_S_oc_sup_and_transversal' 'ctx_rh_S_occipital_ant'}
								[]
							}
							{
								'pmv_right'
								{'ctx_rh_S_front_inf' 'ctx_rh_G_front_inf_Opercular'}
								{[0 0 0; 1 1 1/3] []}
							}
							{
								'pmd_right'
								{'ctx_rh_G_front_middle' 'ctx_rh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3]}
							}
							{
								'sma_right'
								{'ctx_rh_G_front_sup' 'ctx_rh_S_front_sup'}
								{[0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3]}
							}
							{
								'pre_sma_right'
								{'ctx_rh_G_front_sup'}
								[0 0 1/3; 1 1 2/3]
							}
							{
								'primary_motor_right'
								{'ctx_rh_S_central' 'ctx_rh_G_precentral' 'ctx_rh_S_precentral-sup-part' 'ctx_rh_S_precentral-inf-part'}
								[]
							}
							{
								'somatosensory_right'
								{'ctx_rh_G_postcentral'}
								[]
							}
							{
								'cerebellum_right'
								{'Right-Cerebellum-Cortex'}
								[]
							}
						};
	
	cMaskBilateral	= cat(2,cMaskBilateral{:})';
	cMaskUnilateral	= cat(2,cMaskUnilateral{:})';
	
	cMask		= [cMaskBilateral; cMaskUnilateral];
	cMaskName	= cMask(:,1);
	cMaskLabel	= cMask(:,2);
	cCrop		= cMask(:,3);

	nMask		= numel(cMaskLabel);
	
	cDirFEAT		= reshape(cellfun(@(s) DirAppend(strDirData,'functional',s,'feat_cat'),cSession,'uni',false),1,[]);
	cDirFreeSurfer	= reshape(cellfun(@(s) DirAppend(strDirData,'structural',s,'freesurfer'),cSession,'uni',false),1,[]);
	
	%compute the Freesurfer to functional space transforms
		b	= FreeSurfer2FEAT(cDirFreeSurfer,cDirFEAT,...
				'force'	, opt.force	, ...
				'cores'	, opt.cores	  ...
				);
		
		cPathFS2F	= cellfun(@(d) PathUnsplit(DirAppend(d,'reg'),'freesurfer2example_func','mat'),cDirFEAT,'UniformOutput',false);
		cPathF		= cellfun(@(d) PathUnsplit(DirAppend(d,'reg'),'example_func','nii.gz'),cDirFEAT,'UniformOutput',false);
	%extract the masks
		cDirFreeSurferR	= repmat(cDirFreeSurfer,[nMask 1]);
		cDirMaskR		= repmat(cDirMask',[nMask 1]);
		cMaskLabelR		= repmat(cMaskLabel,[1 nSubject]);
		cMaskNameR		= repmat(cMaskName,[1 nSubject]);
		cCropR			= repmat(cCrop,[1 nSubject]);
		cPathFS2FR		= repmat(cPathFS2F,[nMask 1]);
		cPathFR			= repmat(cPathF,[nMask 1]);
		
		cPathMaskOcc	= cellfun(@(d,m) PathUnsplit(d,m,'nii.gz'),cDirMaskR,cMaskNameR,'uni',false);
		
		cInput	=	{...
						cDirFreeSurferR						, ...
						cMaskLabelR							, ...
						'crop'			, cCropR			, ...
						'xfm'			, cPathFS2FR		, ...
						'ref'			, cPathFR			, ...
						'output'		, cPathMaskOcc		, ...
						'force'			, opt.force			  ...
					};
		
		b	= MultiTask(@FreeSurferMask,cInput,...
					'description'	, 'extracting masks'	, ...
					'cores'			, opt.cores				  ...
					);

%create disjoint masks
	cPathMaskAll	= cellfun(@(d) cellfun(@(m) PathUnsplit(d,m,'nii.gz'),sMask.all,'uni',false),cDirMask,'uni',false);
	cPathMaskLeft	= cellfun(@(d) cellfun(@(m) PathUnsplit(d,m,'nii.gz'),sMask.left.all,'uni',false),cDirMask,'uni',false);
	cPathMaskRight	= cellfun(@(d) cellfun(@(m) PathUnsplit(d,m,'nii.gz'),sMask.right.all,'uni',false),cDirMask,'uni',false);
	
	[b,cPathMaskDisjoint]	= MRIMaskDisjoint(cPathMaskAll,...
								'cores'	, opt.cores	, ...
								'force'	, opt.force	  ...
								);
	
	[b,cPathMaskDisjointLeft]	= MRIMaskDisjoint(cPathMaskLeft,...
									'cores'	, opt.cores	, ...
									'force'	, opt.force	  ...
									);
	
	[b,cPathMaskDisjointRight]	= MRIMaskDisjoint(cPathMaskRight,...
									'cores'	, opt.cores	, ...
									'force'	, opt.force	  ...
									);
	
