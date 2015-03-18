function s = UnionMasks()
% MR.UnionMasks
% 
% Description:	get a struct of masks to include in each type of union
% 
% Syntax:	s = MR.UnionMasks()
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

s			      = struct;
%s.network	      = {'cere';'dlpfc';'fef';'fo';'mfc';'mtl';'occ';'pcu';'pitc';'ppc';'sef';'thal'};
s.core		      = {'dlpfc';'fef';'occ';'pcu';'pitc';'ppc'};
s.core_left       = MR.Preprocess.LateralMasks(s.core,{'_left'});
s.core_right      = MR.Preprocess.LateralMasks(s.core,{'_right'});
s.motor           = {'pre_sma';'premotor';'primary_motor';'sma'; 'somatosensory'; 'cerebellum'};
s.motor_left      = MR.Preprocess.LateralMasks(s.motor,{'_left'});
s.motor_right     = MR.Preprocess.LateralMasks(s.motor,{'_right'});
s.coremotor       = [s.core ; s.motor];
s.coremotor_left  = MR.Preprocess.LateralMasks(s.coremotor,{'_left'});
s.coremotor_right = MR.Preprocess.LateralMasks(s.coremotor,{'_right'});
s.all             = [s.core; s.motor;{'frontal_pole'}];
s.all_left        = MR.Preprocess.LateralMasks(s.all, {'_left'});
s.all_right       = MR.Preprocess.LateralMasks(s.all, {'_right'});
%s.allcontrolallci = {'cere';'dlpfc';'fef';'fo';'mfc';'mtl';'occ';'pcu';'pitc';'ppc';'sef';'thal';'premotor';'sma';'primary_motor';'pre_sma';'prepre_sma';'somatosens'};

%s.corethal    	  = [s.core; 'thal'];

%cBase	= fieldnames(s);
%nBase	= numel(cBase);
%
%for kB=1:nBase
%	strBase	= cBase{kB};
%	
%	cMask	= s.(strBase);
%	nMask	= numel(cMask);
%	
%	for kM=1:nMask
%		strMask	= cMask{kM};
%		
%		s.([strBase '_no_' strMask])	= setdiff(cMask,strMask); 
%	end
%end
