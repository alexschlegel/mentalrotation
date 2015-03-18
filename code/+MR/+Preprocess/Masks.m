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
%		subject:	(<all>) the subjects to process
%		force:		(false)
%		nthread:	(12)
% 
<<<<<<< HEAD
% Updated: 2015-01-14
=======
% Updated: 2014-12-09
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'subject'	, {}	, ...
		'force'		, false	, ...
		'nthread'	, 12	  ...
		);

cSubject	= MR.Subject('subject',opt.subject,'state','fmri');

strDirMaskOut	= DirAppend(strDirData,'mask');

%CI masks
	strDirMaskCI	= DirAppend(strDirData,'masks_from_ci');
	cPathMaskMNI	= FindFilesByExtension(strDirMaskCI,'nii.gz');
	
<<<<<<< HEAD
    %remove the occ and non-core ci masks
        cRemove = {
            'occ'
            'cere'
            'sef'
            'thal'
            'mtl'
            'mfc'
            'fo'
            };
        bRemove					= cellfun(@(f) ~all(cellfun(@isempty,regexp(PathGetFilePre(f,'favor','nii.gz'),cRemove,'once'))),cPathMaskMNI);
=======
    %remove the occ masks
        bRemove					= cellfun(@(f) ~isempty(strfind(PathGetFilePre(f,'favor','nii.gz'),'occ')),cPathMaskMNI);
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
        cPathMaskMNI(bRemove)	= [];
    
    nMask			= numel(cPathMaskMNI);
	
	cDirReg		= cellfun(@(s) DirAppend(strDirData,'functional',s,'feat_cat','reg'),cSubject,'uni',false);
	bDo			= cellfun(@isdir,cDirReg);
	
	[cSubject,cDirReg]	= varfun(@(x) x(bDo),cSubject,cDirReg);
	nSubject			= numel(cSubject);
	
	cDirMask	= cellfun(@(s) DirAppend(strDirMaskOut,s),cSubject,'uni',false);
	cellfun(@CreateDirPath,cDirMask);
	
	cPathXFMMNI2Func	= cellfun(@(d) PathUnsplit(d,'standard2example_func','mat'),cDirReg,'uni',false);
	cPathFunc			= cellfun(@(d) PathUnsplit(d,'example_func','nii.gz'),cDirReg,'uni',false);
	
	cPathMaskMNIRep		= repmat(cPathMaskMNI,[1 nSubject]);
	cPathXFMMNI2FuncRep	= repmat(cPathXFMMNI2Func',[nMask 1]);
	cPathFuncRep		= repmat(cPathFunc',[nMask 1]);
	cDirMaskRep			= repmat(cDirMask',[nMask 1]);
	
	cPathMaskRep	= cellfun(@(dm,fm) PathUnsplit(dm,PathGetFileName(fm)),cDirMaskRep,cPathMaskMNIRep,'uni',false);
	
	b	= FSLRegisterFLIRT(cPathMaskMNIRep,cPathFuncRep,...
			'output'	, cPathMaskRep			, ...
			'xfm'		, cPathXFMMNI2FuncRep	, ...
			'interp'	, 'nearestneighbour'	, ...
			'force'		, opt.force				, ...
			'nthread'	, opt.nthread			  ...
			);

%occipital and motor masks
	cMaskLabel	=	{
                        % occipital
						{'ctx_lh_G_and_S_occipital_inf' 'ctx_lh_G_occipital_middle' 'ctx_lh_G_occipital_sup' 'ctx_lh_G_cuneus' 'ctx_lh_Pole_occipital' 'ctx_lh_S_oc_middle_and_Lunatus' 'ctx_lh_S_oc_sup_and_transversal' 'ctx_lh_S_occipital_ant'}
						{'ctx_rh_G_and_S_occipital_inf' 'ctx_rh_G_occipital_middle' 'ctx_rh_G_occipital_sup' 'ctx_rh_G_cuneus' 'ctx_rh_Pole_occipital' 'ctx_rh_S_oc_middle_and_Lunatus' 'ctx_rh_S_oc_sup_and_transversal' 'ctx_rh_S_occipital_ant'}
						{'ctx_lh_G_and_S_occipital_inf' 'ctx_lh_G_occipital_middle' 'ctx_lh_G_occipital_sup' 'ctx_lh_G_cuneus' 'ctx_lh_Pole_occipital' 'ctx_lh_S_oc_middle_and_Lunatus' 'ctx_lh_S_oc_sup_and_transversal' 'ctx_lh_S_occipital_ant' 'ctx_rh_G_and_S_occipital_inf' 'ctx_rh_G_occipital_middle' 'ctx_rh_G_occipital_sup' 'ctx_rh_G_cuneus' 'ctx_rh_Pole_occipital' 'ctx_rh_S_oc_middle_and_Lunatus' 'ctx_rh_S_oc_sup_and_transversal' 'ctx_rh_S_occipital_ant'}
                        % frontal pole
<<<<<<< HEAD
%                         {'ctx_lh_G_and_S_transv_frontopol'}
%                         {'ctx_rh_G_and_S_transv_frontopol'}
%                         {'ctx_lh_G_and_S_transv_frontopol' 'ctx_rh_G_and_S_transv_frontopol'}
                        % lh
                        {'ctx_lh_S_central' 'ctx_lh_G_precentral' 'ctx_lh_S_precentral-sup-part' 'ctx_lh_S_precentral-inf-part'}	% primary_motor
                        {'ctx_lh_G_front_sup' 'ctx_lh_S_front_sup'}                                                                 % sma
                        {'ctx_lh_G_front_middle' 'ctx_lh_S_front_sup'}                                                              % pmd
                        {'ctx_lh_S_front_inf' 'ctx_lh_G_front_inf_Opercular'}                                                       % pmv
                        {'ctx_lh_G_front_sup'}                                                                                      % pre_sma
%                         {'ctx_lh_G_front_sup'}                                                                                      % prepre_sma
                        {'ctx_lh_G_postcentral'}                                                                                    % somatosensory
                        {'Left-Cerebellum-Cortex'}                                                                                  % cerebellum
=======
                        {'ctx_lh_G_and_S_transv_frontopol'}
                        {'ctx_rh_G_and_S_transv_frontopol'}
                        {'ctx_lh_G_and_S_transv_frontopol' 'ctx_rh_G_and_S_transv_frontopol'}
                        % lh
                        {'ctx_lh_S_central' 'ctx_lh_G_precentral' 'ctx_lh_S_precentral-sup-part' 'ctx_lh_S_precentral-inf-part'}
                        {'ctx_lh_G_front_sup' 'ctx_lh_S_front_sup'}
                        {'ctx_lh_G_front_middle' 'ctx_lh_S_front_sup'}
                        {'ctx_lh_G_front_sup'}
                        {'ctx_lh_G_front_sup'}
                        {'ctx_lh_G_postcentral'}
                        {'Left-Cerebellum-Cortex'}
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        % rh
                        {'ctx_rh_S_central' 'ctx_rh_G_precentral' 'ctx_rh_S_precentral-sup-part' 'ctx_rh_S_precentral-inf-part'}
                        {'ctx_rh_G_front_sup' 'ctx_rh_S_front_sup'}
                        {'ctx_rh_G_front_middle' 'ctx_rh_S_front_sup'}
<<<<<<< HEAD
                        {'ctx_rh_S_front_inf' 'ctx_rh_G_front_inf_Opercular'}
                        {'ctx_rh_G_front_sup'}
%                         {'ctx_rh_G_front_sup'}
=======
                        {'ctx_rh_G_front_sup'}
                        {'ctx_rh_G_front_sup'}
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        {'ctx_rh_G_postcentral'}
                        {'Right-Cerebellum-Cortex'}
                        % bilateral                      
                        {'ctx_lh_S_central' 'ctx_lh_G_precentral' 'ctx_lh_S_precentral-sup-part' 'ctx_lh_S_precentral-inf-part' 'ctx_rh_S_central' 'ctx_rh_G_precentral' 'ctx_rh_S_precentral-sup-part' 'ctx_rh_S_precentral-inf-part'}
                        {'ctx_lh_G_front_sup' 'ctx_lh_S_front_sup' 'ctx_rh_G_front_sup' 'ctx_rh_S_front_sup'}
                        {'ctx_lh_G_front_middle' 'ctx_lh_S_front_sup' 'ctx_rh_G_front_middle' 'ctx_rh_S_front_sup'}
<<<<<<< HEAD
                        {'ctx_lh_S_front_inf' 'ctx_lh_G_front_inf_Opercular' 'ctx_rh_S_front_inf' 'ctx_rh_G_front_inf_Opercular'}
                        {'ctx_lh_G_front_sup' 'ctx_rh_G_front_sup'}
%                         {'ctx_lh_G_front_sup' 'ctx_rh_G_front_sup'}
=======
                        {'ctx_lh_G_front_sup' 'ctx_rh_G_front_sup'}
                        {'ctx_lh_G_front_sup' 'ctx_rh_G_front_sup'}
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        {'ctx_lh_G_postcentral' 'ctx_rh_G_postcentral'}
                        {'Left-Cerebellum-Cortex' 'Right-Cerebellum-Cortex'}
					};
	cCrop		=	{
                        % occipital
						[]
						[]
						[]
                        % frontal pole
<<<<<<< HEAD
%                         []
%                         []
%                         []
                        % lh
                        []                                      % primary_motor
                        {[0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3]}    % sma
                        {[0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3]}    % pmd
                        {[0 0 0; 1 1 1/3] []}                   % pmv
                        [0 0 1/3; 1 1 2/3]                      % pre_sma
%                         [0 0 2/3; 1 1 1]                        % prepre_sma
                        []                                      % somatosensory
=======
                        []
                        []
                        []
                        % lh
                        []                                      % primary
                        {[0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3]}    % supplementary
                        {[0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3]}    % pre
                        [0 0 1/3; 1 1 2/3]                      % pre-sup
                        [0 0 2/3; 1 1 1]                        % prepre-sup
                        []                                      % somato
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        []                                      % cerebellum
                        % rh
                        []
                        {[0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3]}
                        {[0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3]}
<<<<<<< HEAD
                        {[0 0 0; 1 1 1/3] []}
                        [0 0 1/3; 1 1 2/3]
%                         [0 0 2/3; 1 1 1]
=======
                        [0 0 1/3; 1 1 2/3]
                        [0 0 2/3; 1 1 1]
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        []
                        []
                        % bilateral
                        []
                        {[0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3] [0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3]}
                        {[0 0 0; 1 1 1/3] [.5 0 0; 1 1 1/3] [0 0 0; 1 1 1/3] [0 0 0; .5 1 1/3]}
<<<<<<< HEAD
                        {[0 0 0; 1 1 1/3] [] [0 0 0; 1 1 1/3] []}
                        {[0 0 1/3; 1 1 2/3] [0 0 1/3; 1 1 2/3]}
%                         {[0 0 2/3; 1 1 1] [0 0 2/3; 1 1 1]}
=======
                        {[0 0 1/3; 1 1 2/3] [0 0 1/3; 1 1 2/3]}
                        {[0 0 2/3; 1 1 1] [0 0 2/3; 1 1 1]}
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        []
                        []
                        
					};
	cMaskName	=	{
						'occ_left'
						'occ_right'
						'occ'
                        
<<<<<<< HEAD
%                         'frontal_pole_left'
%                         'frontal_pole_right'
%                         'frontal_pole'
                        
                        'primary_motor_left'
                        'sma_left'
                        'pmd_left'
                        'pmv_left'
                        'pre_sma_left'
%                         'prepre_sma_left'
=======
                        'frontal_pole_left'
                        'frontal_pole_right'
                        'frontal_pole'
                        
                        'primary_motor_left'
                        'sma_left'
                        'premotor_left'
                        'pre_sma_left'
                        'prepre_sma_left'
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        'somatosensory_left'
                        'cerebellum_left'
                        
                        'primary_motor_right'
                        'sma_right'
<<<<<<< HEAD
                        'pmd_right'
                        'pmv_right'
                        'pre_sma_right'
%                         'prepre_sma_right'
=======
                        'premotor_right'
                        'pre_sma_right'
                        'prepre_sma_right'
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        'somatosensory_right'
                        'cerebellum_right'
                        
                        'primary_motor'
                        'sma'
<<<<<<< HEAD
                        'pmd'
                        'pmv'
                        'pre_sma'
%                         'prepre_sma'
=======
                        'premotor'
                        'pre_sma'
                        'prepre_sma'
>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
                        'somatosensory'
                        'cerebellum'
					};
	nMask		= numel(cMaskLabel);
	
	cDirFEAT		= reshape(cellfun(@(s) DirAppend(strDirData,'functional',s,'feat_cat'),cSubject,'uni',false),1,[]);
	cDirFreeSurfer	= reshape(cellfun(@(s) DirAppend(strDirData,'structural',s,'freesurfer'),cSubject,'uni',false),1,[]);
	
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

<<<<<<< HEAD

 	sUnion	= MR.UnionMasks;

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
% function UnionMask(cMask,strName)	
% 		
% 		for kS=1:nSubject
% 			strSubject	= cSubject{kS};
% 			
% 			strDirMaskCur	= DirAppend(strDirMaskOut,strSubject);
% 			cPathMask		= cellfun(@(m) PathUnsplit(strDirMaskCur,m,'nii.gz'),cMask,'uni',false);
%             
%             strPathUnion = PathUnsplit(strDirMaskCur,strName,'nii.gz');
%             MRIMaskMerge(cPathMask,strPathUnion,'force',opt.force,'silent',true);
%             
% 		end
% 	
% end
%------------------------------------------------------------------------------%
=======
%union masks
	sUnion	= MR.UnionMasks;
	
	cUnionName	= fieldnames(sUnion);
	
	MultiTask(@(n) UnionMask(sUnion.(n),n),{cUnionName},...
		'description'	, 'constructing union masks'	, ...
		'nthread'		, opt.nthread					  ...
		);
	
%------------------------------------------------------------------------------%
function UnionMask(cMask,strName)	
		
		for kS=1:nSubject
			strSubject	= cSubject{kS};
			
			strDirMaskCur	= DirAppend(strDirMaskOut,strSubject);
			cPathMask		= cellfun(@(m) PathUnsplit(strDirMaskCur,m,'nii.gz'),cMask,'uni',false);
            
            strPathUnion = PathUnsplit(strDirMaskCur,strName,'nii.gz');
            MRIMaskMerge(cPathMask,strPathUnion,'force',opt.force,'silent',true);
            
		end
	
end
%------------------------------------------------------------------------------%

>>>>>>> db7db01acb983decc481cadb5fd309cd0ade99e7
end
