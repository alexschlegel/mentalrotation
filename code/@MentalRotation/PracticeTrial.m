function res = PracticeTrial(mr,kPractice)
% MentalRotation.PracticeTrial
% 
% Description:	run a MentalRotation practice trial
% 
% Syntax:	res = mr.PracticeTrial(kPractice)
%
% In:
%	kPractice	- the practice trial number
% 
% Out:
% 	res	- a struct of results
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
res	= struct;

%get the mapping between button indices and test choices
	kButtonCorrect		= cell2mat(mr.Experiment.Input.Get('correct'));
	kButtonIncorrect	= cell2mat(mr.Experiment.Input.Get('incorrect'));

%get the trial parameters
	nRun	= MR.Param('exp','runsmr');
	nTrial	= MR.Param('trialperrun');
    
    trial	= mr.Experiment.Info.Get('mr','trial');
	
    bFlip = true;
    while bFlip==true
		kRun	= randi(nRun);
		kTrial	= randi(nTrial);
        bFlip	= trial.figure.flip(kRun,kTrial);
    end

%show the prompt
	res.prompt	= mr.ShowPrompt(kRun,kTrial);
	
	mr.Experiment.Show.Fixation;
%show the guide?
	if isodd(kPractice)
		mr.ShowGuide(kRun,kTrial);
	else
		mr.Experiment.Window.Flip;
		mr.Experiment.Input.WaitPressed('any');
	end
%show the test screen
	res.test	= mr.ShowTest(kRun,kTrial);
	
	mr.Experiment.Show.Fixation;
	mr.Experiment.Window.Flip;
%wait for a response
	[err,t,kResponse]	= mr.Experiment.Input.WaitPressed('response');
%process the response
	res.correct	= 	(res.test.correct  && ismember(kResponse,kButtonCorrect)) || ...
					(~res.test.correct && ismember(kResponse,kButtonIncorrect));
