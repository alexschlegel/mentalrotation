function y = Translate(x)
% MR.Translate
% 
% Description:	translate strings for presentation 
% 
% Syntax:	y = MR.Translate(x)
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent map

if isempty(map)
	cMap	=	{
					'shape'	'representation'
				};
	
	map	= mapping(cMap(:,1),cMap(:,2));
end

switch class(x)
	case 'cell'
		y	= cellfun(@TranslateOne,x,'uni',false);
	case 'char'
		y	= TranslateOne(x);
	otherwise
		error('wtf?');
end

%------------------------------------------------------------------------------%
function y = TranslateOne(x)
	y	= unless(map(x),x);
end
%------------------------------------------------------------------------------%

end
