function strRunType = RunType(mr,kRun)
% MentalRotation.RunType
% 
% Description:	get the type of the specified run
% 
% Syntax:	strRunType = mr.RunType(kRun)
% 
% In:
% 	kRun	- the run to test
% 
% Out:
% 	strRunType	- the type ('m' or 'h') of run kRun
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nRunMR		= MR.Param('exp','runsmr');
strRunType	= conditional(kRun<=nRunMR,'m','h');
