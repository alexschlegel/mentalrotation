classdef GridOp < PTB.Object
% GridOp
%
% Description:	the gridop experiment object 
%
% Syntax: go = GridOp(<options>)
%
%			subfunctions:
%				Start(<options>):	start the object
%				End:				end the object
%               Prepare:            prepare necessary info
%               Run:                execute a gridop run
%
% In:
% 	<options>:
%       debug:		(0) the debug level
%
% Out: 
%
% Updated: 2013-08-23
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		Experiment;
		
		%running reward total
			reward;
		%prompt images
			prompt;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		argin;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function go = GridOp(varargin)
			go	= go@PTB.Object([],'gridop');
			
			go.argin	= varargin;
			
			%parse the inputs
			opt = ParseArgsOpt(varargin,...
				'debug'					, 0  ...
				);
			
			opt.name	= 'gridop';
			opt.context	= 'fmri';
			opt.tr		= GO.Param('time','tr');
			
			%window
				opt.background	= GO.Param('color','back');
				opt.text_color	= GO.Param('text','color');
				opt.text_size	= GO.Param('text','size');
				opt.text_family	= GO.Param('text','font');
			
			opt.input			= 'buttonbox';
			opt.input_scheme	= 'lr';
			
			%options for PTB.Experiment object
			cOpt = Opt2Cell(opt);
			
			%initialize the experiment
			go.Experiment	= PTB.Experiment(cOpt{:});
			
			%start
			go.Start;
		end
		%----------------------------------------------------------------------%
		function Start(go,varargin)
		%start the gridop object
			go.argin	= append(go.argin,varargin);
			
			%register the response button set
				go.Experiment.Input.Set('response',{GO.Param('response','correct'),GO.Param('response','incorrect')});
				go.Experiment.Input.Set('correct',GO.Param('response','correct'));
				go.Experiment.Input.Set('incorrect',GO.Param('response','incorrect'));
			
			if ~notfalse(go.Experiment.Info.Get('go','prepared'))
				%prepare info
				go.Prepare(varargin{:});
				
				%practice?
					if isequal(ask('practice?','dialog',false,'choice',{'y','n'}),'y')
						go.Practice;
					end
			end
		end
		%----------------------------------------------------------------------%
		function End(go,varargin)
		%end the gridop object
			v	= varargin;
            
			go.Experiment.End(v{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
