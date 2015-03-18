function Run(mr)
% MentalRotation.Run
%
% Description: do the next mentalrotation run
%
% Syntax: mr.Run
%
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nRun	= MR.Param('exp','runs');
tRun	= MR.Param('trrun');
nTrial	= MR.Param('trialperrun');

trTrial		= MR.Param('trtrial');
trFeedback	= MR.Param('time','feedback');
trRest		= MR.Param('time','rest');


%get the current run
	kRun	= mr.Experiment.Info.Get('mr','run');
	kRun	= ask('Next run','dialog',false,'default',kRun);

%add to the log
	mr.Experiment.AddLog(['run ' num2str(kRun) ' start']); 

%add to info
	mr.Experiment.Info.Set('mr','run',kRun);

%perform the run
	%disable the keyboard
		ListenChar(2);
	%prepare the run
		mr.Experiment.Show.Blank;
		mr.Experiment.Window.Flip('waiting for scanner');
		
		mr.Experiment.Scanner.StartScan(tRun);
	%let idle processes execute
		mr.Experiment.Scheduler.Wait;
	%open the prompt texture
		mr.Experiment.Window.OpenTexture('prompt');
	%do the run
		%set up the sequence
			cF			=	[	{@DoRest}
								repmat({@DoTrial; @DoFeedback; @DoRest},[nTrial 1])
							];
			tSequence	= 	cumsum([
								trFeedback+trRest
								repmat([trTrial; trFeedback; trRest],[nTrial 1])
							]) + 1;
		%execute the sequence
			kTrial		= 0;
			nCorrect	= 0;
			res			= [];
			[tStart,tEnd,tSequenceActual]	= mr.Experiment.Sequence.Linear(cF,tSequence,'tstart',1,'tbase','absolute');
		%save the results
			result			= mr.Experiment.Info.Get('mr','result');
			result{kRun}	= [result{kRun} res];
			mr.Experiment.Info.Set('mr','result',result);
	%scanner stopped
		mr.Experiment.Scanner.StopScan;
	%blank the screen
		mr.Experiment.Show.Text('<color:red><size:3>RELAX!</size></color>');
		mr.Experiment.Window.Flip;
	%close the prompt texture
		mr.Experiment.Window.CloseTexture('prompt');
	%enable the keyboard
		ListenChar(1);


%add to the log
	mr.Experiment.AddLog(['run ' num2str(kRun) ' end']);
%save
	mr.Experiment.Info.Save;

%increment run or end
	if kRun < nRun
		mr.Experiment.Info.Set('mr','run',kRun+1);
	else
		if isequal(ask('End experiment?','dialog',false,'choice',{'y','n'}),'y')
			mr.End;
		else
			disp('*** Remember to mr.End ***');
		end
	end

%------------------------------------------------------------------------------%
function tNow = DoRest(tNow,tNext)
	mr.Experiment.AddLog('rest');
	
	%blank the screen
		mr.Experiment.Show.Blank;
		mr.Experiment.Window.Flip;
	%prepare the next prompt
		if kTrial<nTrial
			kTrial	= kTrial + 1;
			
			mr.ShowPrompt(kRun,kTrial,'window','prompt');
		end
	
	mr.Experiment.Scheduler.Wait;
end
%------------------------------------------------------------------------------%
function tNow = DoTrial(tNow,tNext)
	%execute the trial
		mr.Experiment.AddLog(['trial ' num2str(kTrial)]);
		
		resCur	= mr.Trial(kRun,kTrial,tNow,...
					'prompttexture','prompt'	  ...
					);
		
		if isempty(res)
			res	= resCur;
		else
			res(end+1)	= resCur;
		end
end
%------------------------------------------------------------------------------%
function tNow = DoFeedback(tNow,tNext)
	if mr.RunType(kRun)=='m'
		%add a log message
			nCorrect	= nCorrect + res(end).correct;
			strCorrect	= conditional(res(end).correct,'y','n');
			strTally	= [num2str(nCorrect) '/' num2str(kTrial)];
		
		mr.Experiment.AddLog(['feedback (' strCorrect ', ' strTally ')']);
		
		%get the message and change in winnings
			if res(end).correct
				strFeedback	= 'Yes!';
				strColor	= 'green';
				dWinning	= MR.Param('rewardpertrial');
			else
				strFeedback	= 'No!';
				strColor	= 'red';
				dWinning	= -MR.Param('penaltypertrial');
			end
		%update the winnings
			mr.reward	= max(mr.reward + dWinning,MR.Param('reward','base'));
		
		strRewardCur	= StringMoney(dWinning,'sign',true);
		strRewardTotal	= StringMoney(mr.reward);
		strText			= sprintf('<color:%s>%s (%s)</color>\\n\\nCurrent total: %s',strColor,strFeedback,strRewardCur,strRewardTotal); 
	else
		strRewardTotal	= StringMoney(mr.reward);
		strText	= sprintf('<color:red>Stop</color>\\n\\nCurrent total: %s',strRewardTotal);
	end
	
	mr.Experiment.Show.Text(strText);
	mr.Experiment.Window.Flip;
end
%------------------------------------------------------------------------------%

end
