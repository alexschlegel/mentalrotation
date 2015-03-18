function Run(mr)
% MentalRotation.Run
%
% Description: do the next mentalrotation run
%
% Syntax: mr.Run
%
% Updated: 2014-02-07
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nRunMR	= MR.Param('exp','runsmr');
nRunHR	= MR.Param('exp','runshr');
nRun	= nRunMR + nRunHR;
tRun	= MR.Param('trrun');
nBlock	= MR.Param('blockperrun');

trBlock		= MR.Param('time','block');
trRest		= MR.Param('time','rest');
trFeedback	= MR.Param('time','feedback');
trWinnings	= MR.Param('time','winnings');

fNow	= @mr.Experiment.Scanner.TR;

%get the current run
	kRun	= mr.Experiment.Info.Get('mr','run');
	kRun	= ask('Next run','dialog',false,'default',kRun);

%what type of run are we on?
	bRunMR		= kRun<=nRunMR;
	
	fTrial		= @(varargin) mr.Trial(varargin{:},'mental',bRunMR);
	fInstruct	= conditional(bRunMR,@mr.InstructMentalRotation,@mr.InstructHandRotation);

%add to the log
	mr.Experiment.AddLog(['run ' num2str(kRun) ' start']); 

%add to info
	mr.Experiment.Info.Set('mr','run',kRun);

%perform the run
	%disable the keyboard
		ListenChar(2);
	%show a status
		fInstruct();
		mr.Experiment.Window.Flip('waiting for scanner');
		
		mr.Experiment.Scanner.StartScan(tRun);
	%let idle processes execute
		mr.Experiment.Scheduler.Wait;
	%do the run
		%set up the sequence
			cF			=	[	{@DoRest}
								repmat({@DoBlock; @DoRest},[nBlock 1])
							];
			tSequence	= 	cumsum([
								trRest
								repmat([trBlock; trRest],[nBlock 1])
							]) + 1;
		%execute the sequence
			kBlock		= 0;
			nCorrect	= 0;
			res			= cell(nBlock,1);
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
	
	kBlock	= kBlock + 1;
	
	%blank the screen
		mr.Experiment.Show.Blank;
		mr.Experiment.Window.Flip;
	
	mr.Experiment.Scheduler.Wait;
end
%------------------------------------------------------------------------------%
function tNow = DoBlock(tNow,tNext)
	mr.Experiment.AddLog(sprintf('block %d',kBlock));
	
	while fNow() < tNext
		res{kBlock}(end+1)	= fTrial(kRun, kBlock, tNow, ...
								'timeout'	, tNext	  ...
								);
		
		
	end
	
	%update the winnings
		nTrial		= numel(res{kBlock});
		nCorrect	= sum([res{kBlock}.correct]);
		dWinning	= nCorrect/nTrial*MR.Param('rewardperblock');
		mr.reward	= mr.reward + dWinning;
		
		mr.Experiment.AddLog(sprintf('end block %d (%d/%d correct)',kBlock,nCorrect,nTrial));
	
		ShowWinnings(nCorrect,nTrial,dWinning);
end
%------------------------------------------------------------------------------%
function ShowWinnings(nCorrect,nTrial,dWinning)
	strText	= sprintf('You got %d of %d correct (<color:green>+$s</color>)',nCorrect,nTrial,StringMoney(dWinning));
	
	mr.Experiment.Show.Text(strText);
	mr.Experiment.Window.Flip;
	
	tStart	= fNow();
	tEnd	= tStart + trWinnings;
	while fNow() < tEnd
		mr.Experiment.Scheduler.Wait(mr.Scheduler.PRIORITY_LOW);
	end
end
%------------------------------------------------------------------------------%

end
