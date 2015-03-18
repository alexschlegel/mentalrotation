function kOrder = Order(c)
% MR.Plot.Order
% 
% Description:	get the plot order of a set of things
% 
% Syntax:	kOrder = MR.Plot.Order(c)
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isequal(c,{'operation';'shape'})
	kOrder	= [2 1];
elseif iscellstr(c) && ismember('network',c)
	kNetwork	= find(strcmp('network',c));
	kOrder		= [kNetwork 1:kNetwork-1 kNetwork+1:numel(c)];
else
	kOrder	= 1:numel(c);
end
