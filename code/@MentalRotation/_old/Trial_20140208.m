function res = Trial(mr,kRun,kBlock,varargin)
% MentalRotation.Trial
% 
% Description:	run a MentalRotation trial
% 
% Syntax:	res = mr.Trial(kRun,kBlock,[tStart]=<now>,<options>)
% 
% In:
%	kRun	- the run number
% 	kBlock	- the block number
%	tStart	- the start time, in TRs. if unspecified, the trial starts
%			  immediately and uses PTB.Now time to advance
%	<options:
%		mental:		(true) true if this is a mental rotation trial (as opposed
%					to hand rotation)
%		timeout:	(<none>) the TR time at which the trial should abort
% 
% Out:
% 	res	- a struct of results
% 
% Updated: 2014-02-07
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[tStart,opt]	= ParseArgsOpt(varargin,[],...
					'mental'	, true	, ...
					'timeout'	, inf	  ...
					);

chrOp	= MR.Param('stim','op');

bPractice	= isempty(tStart);
if bPractice
	fNow		= @PTB.Now;
	tFeedback	= MR.Param('time','feedback')*1000;
else
	fNow		= @mr.Experiment.Scanner.TR;
	tFeedback	= MR.Param('time','feedback');
end

res.t.start	= fNow();

%get the mapping between button indices and test choices
	kButtonCorrect		= cell2mat(mr.Experiment.Input.Get('correct'));
	kButtonIncorrect	= cell2mat(mr.Experiment.Input.Get('incorrect'));

%get/generate the trial parameters
	trial	= mr.Experiment.Info.Get('mr','trial');
	
	%input figure
		res.figure.id		= randi(MR.Param('stim','figures'));
		res.figure.flip		= rand<0.5;
		res.figure.rot180	= rand<0.5;
	%operation
		res.operation		= trial.op(kRun,kBlock);
		res.prompt_location	= randi(4);
	%output
		res.test.correct	= rand<0.5;

%show the prompt
	ShowPrompt;
%wait for the response
	WaitResponse;
%show the feedback
	ShowFeedback;

res.t.end	= fNow();

%------------------------------------------------------------------------------%
function ShowPrompt(varargin)
	res.prompt_location	= mr.ShowTrialPrompt(res.operation,...
							'figure'		, conditional(opt.mental,res.figure.id,[])	, ...
							'flip'			, res.figure.flip							, ...
							'rot180'		, res.figure.rot180							, ...
							'testcorrect'	, res.test.correct							  ...
							);
	
	mr.Experiment.Window.Flip;
end
%------------------------------------------------------------------------------%
function WaitResponse()
	res.t.response	= [];
	res.correct		= NaN;
	
	tResponse	= [];
	while fNow() < opt.timeout
		[dummy,dummy,dummy,kResponse]	= mr.Experiment.Input.DownOnce('response');
		
		if ~isempty(kResponse)
			res.t.response	= fNow();
			
			res.correct	= 	(res.test.correct  && ismember(kResponse,kButtonCorrect)) || ...
							(~res.test.correct && ismember(kResponse,kButtonIncorrect));
			
			return;
		end
		
		mr.Experiment.Scheduler.Wait(PTB.Scheduler.PRIORITY_CRITICAL);
	end
end
%------------------------------------------------------------------------------%
function ShowFeedback()
	strFeedback	= conditional(res.correct,'Yes!','No!');
	strColor	= conditional(res.correct,'green','red');
	
	strText	= sprintf('<color:%s>%s</color>',strFeedback,strColor); 
	
	mr.Experiment.Show.Text(strText);
	mr.Experiment.Window.Flip;
	
	tStart	= fNow();
	tEnd	= min(tStart + tFeedback,opt.timeout);
	while fNow() < tEnd
		mr.Experiment.Scheduler.Wait(PTB.Scheduler.PRIORITY_LOW);
	end
end
%------------------------------------------------------------------------------%

end
