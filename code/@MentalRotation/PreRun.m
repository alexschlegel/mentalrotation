function PreRun(mr)
% MentalRotation.PreRun
% 
% Description:	practice the task before the first fMRI run
% 
% Syntax:	mr.PreRun()
% 
% Updated: 2014-02-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the mapping between button indices and test choices
	kButtonCorrect		= cell2mat(mr.Experiment.Input.Get('correct'));
	kButtonIncorrect	= cell2mat(mr.Experiment.Input.Get('incorrect'));
	strButtonCorrect	= MR.Param('response','correct');
	strButtonIncorrect	= MR.Param('response','incorrect');

chrLog	= {'<color:red>N</color>','<color:green>Y</color>'};

nRun	= MR.Param('exp','runsmr');
nTrial	= MR.Param('trialperrun');

bTest	= isequal(mr.Experiment.Info.Get('experiment','context'),'fmri') && mr.Experiment.Info.Get('experiment','debug')==2;

bContinue	= true;
while bContinue
	%do the trial
		kRun	= randi(nRun);
		kTrial	= randi(nTrial);
		
		res	= mr.Trial(kRun,kTrial);
	%show the prompt
		strResponse	= conditional(res.correct,'<color:green>Yes!</color>','<color:red>No!</color>');
		mr.Experiment.Show.Text(sprintf('%s\\n\\nAgain (%s=yes, %s=no)?',strResponse,strButtonCorrect,strButtonIncorrect));
		mr.Experiment.Window.Flip;
	%wait for a response
		if bTest
			%so we get the simulated keypresses
			mr.Experiment.Scanner.StartScan;
		end
		
		[err,t,kResponse]	= mr.Experiment.Input.WaitPressed('response'); 
		bContinue			= ismember(kButtonCorrect,kResponse);
		
		if bTest
			%so we get the simulated keypresses
			mr.Experiment.Scanner.StopScan;
		end
end

%blank the screen
	mr.Experiment.Show.Blank;
	mr.Experiment.Window.Flip;
