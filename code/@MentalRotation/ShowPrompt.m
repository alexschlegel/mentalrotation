function sPrompt = ShowPrompt(mr,kRun,kTrial,varargin)
% MentalRotation.ShowPrompt
% 
% Description:	show the subject the input figure and operation
% 
% Syntax:	mr.ShowTrialPrompt(kRun,kTrial,<options>)
% 
% In:
%	kRun	- the current run
%	kTrial	- the current trial
%	<options>
%		prompttexture:	(<none>) specify the prompt texture handle/name if the
%						prompt was actually shown already onto a temporary
%						texture
%		window:			(<default>) the name of the window on which to show the
%						prompt
%
% Out:
%	sPrompt	- a struct of info about the prompt
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'prompttexture'	, []	, ...
		'window'		, []	  ...
		);

%get the trial parameters
	trial	= mr.Experiment.Info.Get('mr','trial');
	
	%input figure
		sPrompt.figure.id		= trial.figure.id(kRun,kTrial);
		sPrompt.figure.flip		= trial.figure.flip(kRun,kTrial);
		sPrompt.figure.rot180	= trial.figure.rot180{kRun,kTrial};
	%operation
		sPrompt.operation		= trial.operation(kRun,kTrial);
		sPrompt.prompt.location	= trial.prompt.location(kRun,kTrial);

%make sure we have a blank screen
	mr.Experiment.Show.Blank('window',opt.window);

%should we just copy the prompt texture?
	if ~isempty(opt.prompttexture)
		mr.Experiment.Show.Texture(opt.prompttexture,'window',opt.window);
		return;
	end

%show the figure
	if mr.RunType(kRun)=='m'
		mr.ShowFigure(sPrompt.figure.id,...
				'flip'		, sPrompt.figure.flip	, ...
				'rot180'	, sPrompt.figure.rot180	, ...
				'window'	, opt.window			  ...
				);
	end

%show the operation prompt
	ops				= MR.Param('stim','op');
	nOp				= numel(ops);
	bOpPrompt		= ops==sPrompt.operation;
	opDistractor	= randomize(ops(~bOpPrompt));
	
	kDistractorLocation								= 1:nOp;
	kDistractorLocation(sPrompt.prompt.location)	= [];
	
	op							= char(zeros(1,nOp));
	op(sPrompt.prompt.location)	= sPrompt.operation;
	op(kDistractorLocation)		= opDistractor;
	
	szFont	= MR.Param('size','prompt');
	
	strPrompt	= sprintf('<size:%d><color:prompt>%s\\n%d</color></size>',szFont,upper(op),sPrompt.prompt.location);
	mr.Experiment.Show.Text(strPrompt,[0 szFont/3],'window',opt.window);
