function conf = ConfusionModels()
% MR.ConfusionModels
% 
% Description:	get the confusion models to compare to actual confusion matrices
% 
% Syntax:	conf = MR.ConfusionModels()
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
conf	=	{
				[
					4 2 1 1
					2 4 1 1
					1 1 4 2
					1 1 2 4
				]
				[
					5 1 1 1
					1 5 1 1
					1 1 5 1
					1 1 1 5
				]
				[
					3 3 1 1
					3 3 1 1
					1 1 3 3
					1 1 3 3
				]
			};
