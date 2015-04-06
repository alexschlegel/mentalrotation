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
%		force:		(false)
%		nthread:	(12)
% 
% Updated: 2015-03-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'force'		, false	, ...
		'nthread'	, 12	  ...
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
			'nthread'	, opt.nthread			  ...
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
				'force'		, opt.force		, ...
				'nthread'	, opt.nthread	  ...
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
					'nthread'		, opt.nthread			  ...
					);

%create disjoint masks
	cPathMaskAll	= cellfun(@(d) cellfun(@(m) PathUnsplit(d,m,'nii.gz'),sMask.all,'uni',false),cDirMask,'uni',false);
	
	[b,cPathMaskDisjoint]	= MRIMaskDisjoint(cPathMaskAll,...
								'nthread'	, opt.nthread	, ...
								'force'		, opt.force		  ...
								);

% no more union masks
% 	cUnionName	= fieldnames(sUnion);
% 	
% 	MultiTask(@(n) UnionMask(sUnion.(n),n),{cUnionName},...
% 		'description'	, 'constructing union masks'	, ...
% 		'nthread'		, opt.nthread					  ...
% 		);

% Get mutually exclusive ("unique") masks
% Remember: use MRIMaskMerge and MRIMaskInvert.

% sets of masks defined in UnionMasks that should be mutually exclusive
cSetLabel = {'all'; 'all_left'; 'all_right'};
cSets = cellfun(@(l) sUnion.(l), cSetLabel, 'uni',false);

cPathMask = cellfun(@(sub) cellfun(@(set) cellfun(@(m) ...
    PathUnsplit(DirAppend(strDirData,'mask',sub),m,'nii.gz'),set,'uni',false), ...
    cSets, 'uni', false), cSubject, 'uni', false);

cDirUnique = cellfun(@(sub) DirAppend(strDirData,'mask',sub,'unique'), cSubject, 'uni', false);
[b, ~] = cellfun(@mkdir, cDirUnique, 'uni', false);
if ~all(cell2mat(b))
    error('Directories for unique masks could not be created');
end
cPathUniqueMask = MultiTask(@(sub, dir) cellfun(@(set) MakeUniqueMasks(set, dir), ... 
    sub,'uni', false), {cPathMask, cDirUnique}, ...
    'description',  'generating non-intersecting masks',    ...
    'nthread',      opt.nthread                             ...
    );

cPathUniqueMaskFlat = cellnestflatten(cPathUniqueMask);

if ~all(FileExists(cPathUniqueMaskFlat))
    error('Creation of unique masks failed');
end


%-----------------------------------------------------------------------------%
% Generate unique masks for each mask in cSet (relative to the other masks
% in the set)
% cSet is a cell of paths to masks.
% strUniqueDir is the directory into which to put the unique masks.
% Returns a cell of paths to the unique masks.
function cPath = MakeUniqueMasks(cSet, strUniqueDir)

strTempMask = GetTempFile('ext', 'nii.gz');
cName = cellfun(@(mask) PathGetFilePre(mask, 'favor', 'nii.gz'), cSet, 'uni', false);
cPath = cellfun(@(name) PathUnsplit(strUniqueDir, name, 'nii.gz'), cName, 'uni',false);
for i = 1:numel(cSet)
    if ~FileExists(cPath{i}) || opt.force
        cOtherMasks = setdiff(cSet, cSet(i));
        MRIMaskMerge(cOtherMasks, strTempMask, 'silent', true); % union of other masks
        MRIMaskInvert(strTempMask, 'output', strTempMask); % voxels not in other masks
        MRIMaskMerge({strTempMask; cSet{i}},cPath{i},'method','and','silent',true);
        % voxels in this mask AND not in other masks
    end
end
end
%------------------------------------------------------------------------------%

end
