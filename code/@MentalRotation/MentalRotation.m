classdef MentalRotation < PTB.Object
% MentalRotation
%
% Description:	the mentalrotation experiment object 
%
% Syntax: mr = MentalRotation(<options>)
%
%			subfunctions:
%				Start(<options>):	start the object
%				End:				end the object
%               Prepare:            prepare necessary info
%               Run:                execute a mentalrotation run
%
% In:
% 	<options>:
%       debug:		(0) the debug level
%
% Out: 
%
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		Experiment;
		
		%running reward total
			reward;
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
		function mr = MentalRotation(varargin)
			mr	= mr@PTB.Object([],'mentalrotation');
			
			mr.argin	= varargin;
			
			%parse the inputs
			opt = ParseArgs(varargin,...
				'input'			, []	, ...
				'session'		, []	, ...
				'disable_key'	, false	, ...
                'fullscreen'    , []    , ...
				'debug'			, 0 	  ...
				);
			if isempty(opt.session)
				opt.session	= conditional(opt.debug==2,1,2);
			end
			
			opt.name			= 'mentalrotation';
			opt.context			= switch2(opt.session,1,'psychophysics',2,'fmri');
			opt.input_scheme	= 'lrud';
			opt.tr				= MR.Param('time','tr');
			
			%window
				opt.background	= MR.Param('color','back');
				opt.text_color	= MR.Param('color','text');
				opt.text_size	= MR.Param('text','size');
				opt.text_family	= MR.Param('text','font');
			
			%extra subject info
				opt.subject_info	=	{
											conditional(opt.debug==2,'minimal','basic')
											{'group','subject group',{'1' '2'},'number'}
										};
			
			%fixation task
				opt.fixation_task_response	= MR.Param('fixation','response');
				opt.fixation_task_rate		= MR.Param('fixation','rate');
			
			%options for PTB.Experiment object
			cOpt = Opt2Cell(opt);
			
			%initialize the experiment
			mr.Experiment	= PTB.Experiment(cOpt{:});
			
			%set the session
			mr.Experiment.Info.Set('mr','session',opt.session);
			
			%start
			mr.Start;
		end
		%----------------------------------------------------------------------%
		function Start(mr,varargin)
		%start the mentalrotation object
			mr.argin	= append(mr.argin,varargin);
			
			if ~notfalse(mr.Experiment.Info.Get('mr','prepared'))
				%prepare info
				mr.Prepare(varargin{:});
			end
		end
		%----------------------------------------------------------------------%
		function End(mr,varargin)
		%end the mentalrotation object
			v	= varargin;
            
			mr.Experiment.End(v{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
