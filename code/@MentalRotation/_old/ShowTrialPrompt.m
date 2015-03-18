function locPrompt = ShowTrialPrompt(mr,op,varargin)
% MentalRotation.ShowTrialPrompt
% 
% Description:	prompt the subject with the input figure, operation, and test
%				output figure
% 
% Syntax:	locPrompt = mr.ShowTrialPrompt(op,<options>)
% 
% In:
% 	op	- the operation to prompt
%	<options>
%		figure:			(<none>) the id of the figure to show
%		flip:			(false) true to flip the figure
%		rot180:			([]) the rotation to apply (see MR.GetFigure)
%		testcorrect:	(true) true if the test should be the correct output
%		window:			(<default>) the name of the window on which to show the
%						prompt
%
% Out:
%	locPrompt	- the location of the prompted operation
% 
% Updated: 2014-02-07
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'figure'		, []	, ...
		'flip'			, false	, ...
		'rot180'		, []	, ...
		'testcorrect'	, true	, ...
		'window'		, []	  ...
		);

s		= MR.Param('size');
txtSize	= MR.Param('text','size');

%show the operation prompt
	ops			= randomize(MR.Param('stim','op'));
	locPrompt	= find(ops==op);
	
	%prompt distance
		xPrompt	= s.prompt_offset*[-1 0 1 0];
		yPrompt	= s.prompt_offset*[0 -1 0 1] + txtSize/3;
	%show the prompts
		
		for kP=1:4
			strPrompt	= sprintf('<size:%d>%s</size>',txtSize,upper(ops(kP)));
			mr.Experiment.Show.Text(strPrompt,[xPrompt(kP) yPrompt(kP)],'window',opt.window);
		end
	%show the arrow
		im	= imrotate(mr.arrow,(1-locPrompt)*90);
		
		mr.Experiment.Show.Image(im,[],s.arrow,'window',opt.window);
%show the figures
	if ~isempty(opt.figure)
		%show the input figure
			pIn		= [-s.stim_offset 0];
			imFigIn	= MR.GetFigure(opt.figure,...
							'flip'		, opt.flip		, ...
							'rot180'	, opt.rot180	  ...
							);
			
			mr.Experiment.Show.Image(imFigIn,pIn,s.stim,'window',opt.window);
		%show the test figure
			pTest		= [s.stim_offset 0];
			bTestFlip	= conditional(opt.testcorrect,opt.flip,~opt.flip);
			
			imFigTest	= MR.GetFigure(opt.figure,...
							'operation'	, op			, ...
							'flip'		, bTestFlip		, ...
							'rot180'	, opt.rot180	  ...
							);
			
			mr.Experiment.Show.Image(imFigTest,pTest,s.stim,'window',opt.window);
	end
