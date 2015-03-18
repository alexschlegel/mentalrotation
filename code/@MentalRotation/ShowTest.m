function sTest = ShowTest(mr,kRun,kTrial,varargin)
% MentalRotation.ShowTest
% 
% Description:	show the test screen
% 
% Syntax:	sTest = mr.ShowTest(kRun,kTrial,<options>)
% 
% In:
%	kRun	- the current run
%	kTrial	- the current trial
%	<options>
%		window:	(<default>) the name of the window on which to show the test
% 
% Out:
% 	sTest	- a struct of info about the test screen
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'window'	, []	  ...
		);

%get the trial parameters
	trial	= mr.Experiment.Info.Get('mr','trial');
	
	%test
		sTest.correct	= trial.test.correct(kRun,kTrial);
	%input figure
		bFlip	= trial.figure.flip(kRun,kTrial);
		
		sTest.figure.id		= trial.figure.id(kRun,kTrial);
		sTest.figure.flip	= conditional(sTest.correct,bFlip,~bFlip);
		sTest.figure.rot180	= trial.figure.rot180{kRun,kTrial};
	%operation
		sTest.operation		= trial.operation(kRun,kTrial);

%make sure we have a blank screen
	mr.Experiment.Show.Blank('window',opt.window);
%show the test figure
	if mr.RunType(kRun)=='m'
		mr.ShowFigure(sTest.figure.id,...
				'operation'	, sTest.operation		, ...
				'flip'		, sTest.figure.flip		, ...
				'rot180'	, sTest.figure.rot180	, ...
				'window'	, opt.window			  ...
				);
	end
