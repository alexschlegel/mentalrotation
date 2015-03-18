function res = Trial(mr,kRun,kTrial,varargin)
% MentalRotation.Trial
% 
% Description:	run a MentalRotation trial
% 
% Syntax:	res = mr.Trial(kRun,kTrial,[tStart]=<now>,<options>)
% 
% In:
%	kRun	- the run number
% 	kTrial	- the trial number
%	tStart	- the start time, in TRs. if unspecified, the trial starts
%			  immediately and uses PTB.Now time to advance
%	<options:
%		prompttexture:	(<none>) the name of a texture holding the prompt
% 
% Out:
% 	res	- a struct of results
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[tStart,opt]	= ParseArgs(varargin,[],...
					'prompttexture'		, []	  ...
					);

bPractice			= isempty(tStart);
bFMRI				= isequal(mr.Experiment.Info.Get('experiment','context'),'fmri');
bShowPrompt			= isempty(opt.prompttexture);
bShowFixationTask	= bFMRI && mr.RunType(kRun)=='m';

res	= struct;

%get the mapping between button indices and test choices
	kButtonCorrect		= cell2mat(mr.Experiment.Input.Get('correct'));
	kButtonIncorrect	= cell2mat(mr.Experiment.Input.Get('incorrect'));

%set up the sequence
	t	= MR.Param('time');
	
	cSequence	=	{
						@ShowPrompt
						@ShowOperation
						@ShowTest
					};
	tSequence	=	cumsum([
						t.prompt
						t.operation
						t.test
					]);
	fWait			=	{
							@Wait_Default
							@Wait_Default
							@Wait_Response
						};
	
	if bPractice
		tSequence	= tSequence*t.tr;
		tStart		= PTB.Now;
		strTUnit	= 'ms';
	else
		strTUnit	= 'tr';
	end
%run the sequence
	bFirstWait	= true;
	
	if bPractice
		mr.Experiment.Scanner.StartScan;
	end
	
	kLastResponse	= NaN;
	[tStart,tEnd,tShow,bAbort,kResponse,tResponse]	= mr.Experiment.Show.Sequence(cSequence,tSequence,...
														'tunit'			, strTUnit			, ...
														'tstart'		, tStart			, ...
														'tbase'			, 'sequence'		, ...
														'fwait'			, fWait				, ...
														'fixation'		, true				, ...
														'fixation_task'	, bShowFixationTask	  ...
														);
	
	if bPractice
		mr.Experiment.Show.Blank('fixation',true);
		mr.Experiment.Window.Flip;
		
		mr.Experiment.Scanner.StopScan;
	end
	
	res.tstart		= tStart;
	res.tend		= tEnd;
	res.tshow		= tShow;
	res.abort		= bAbort;
	res.kresponse	= kResponse;
	res.tresponse	= tResponse;
	
	if ~isempty(res.kresponse)
		res.correct	= 	(res.test.correct  && ismember(res.kresponse{end},kButtonCorrect)) || ...
						(~res.test.correct && ismember(res.kresponse{end},kButtonIncorrect));
	else
		res.correct	= false;
	end

%get the fixation task results
	if bShowFixationTask
		[bShown,fPassed,bAbort,tShow,tResponse]	= mr.Experiment.Show.FixationTask.Result;
		
		res.fixation	= struct(...
							'shown'		, bShown	, ...
							'passed'	, fPassed	, ...
							'abort'		, bAbort	, ...
							'tshow'		, tShow		, ...
							'tresponse'	, tResponse	  ...
							);
	else
		res.fixation	= struct;
	end

%------------------------------------------------------------------------------%
function ShowPrompt(varargin)
	res.prompt	= mr.ShowPrompt(kRun,kTrial,'prompttexture',opt.prompttexture,varargin{:});
end
%------------------------------------------------------------------------------%
function ShowOperation(varargin)
	mr.Experiment.Show.Blank(varargin{:});
end
%------------------------------------------------------------------------------%
function ShowTest(varargin)
	res.test	= mr.ShowTest(kRun,kTrial,varargin{:});
end
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function [bAbort,kResponse,tResponse] = Wait_Default(tNow,tNext)
	bAbort		= false;
	kResponse	= [];
	tResponse	= [];
	
	if bFirstWait
	%wait longer during the first call, so log events, etc. can post
		mr.Experiment.Scheduler.Wait(PTB.Scheduler.PRIORITY_LOW);
		
		bFirstWait	= false;
	else
		mr.Experiment.Scheduler.Wait(PTB.Scheduler.PRIORITY_CRITICAL);
	end
end
%------------------------------------------------------------------------------%
function [bAbort,kResponse,tResponse] = Wait_Response(tNow,tNext)
	bAbort							= false;
	[dummy,dummy,dummy,kResponse]	= mr.Experiment.Input.DownOnce('response');
	
	tResponse	= conditional(isempty(kResponse),[],tNow);
	
	mr.Experiment.Scheduler.Wait(PTB.Scheduler.PRIORITY_CRITICAL);
end
%------------------------------------------------------------------------------%

end
