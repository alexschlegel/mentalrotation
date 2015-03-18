function [rotLR,rotBF] = Operate(op)
% MR.Operate
% 
% Description:	calculate the output of an operation
% 
% Syntax:	[rotLR,rotBF] = MR.Operate(op)
% 
% In:
%	op	  - the operation ('l', 'r', 'b', 'f', or 'n')
% 
% Out:
% 	outLR - the output l/r rotation
%	outBF - the output b/f rotation
% 
% Updated: 2014-02-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[rotLR, rotBF]	= deal(0);

switch lower(op)
	case 'l'
		rotLR = -90;
	case 'r'
		rotLR = 90;
	case 'b'
		rotBF = -90;
	case 'f'
		rotBF = 90;
	case 'n'
	otherwise
		error('"%s" is not a valid operation.',op);
end
