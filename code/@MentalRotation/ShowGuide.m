function ShowGuide(mr,kRun,kTrial)
% MentalRotation.ShowGuide
% 
% Description:	show the helper for the specified trial and wait for a responses
% 
% Syntax:	mr.ShowGuide(kRun,kTrial)
% 
% In:
% 	kRun	- the current run
%	kTrial	- the current trial
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%subject group
	group	= mr.Experiment.Info.Get('subject','group');
%get the trial parameters
	trial	= mr.Experiment.Info.Get('mr','trial');
	
	%input figure
		id		= trial.figure.id(kRun,kTrial);
		bFlip	= trial.figure.flip(kRun,kTrial);
		rot180	= trial.figure.rot180{kRun,kTrial};
	%operation
		op		= trial.operation(kRun,kTrial);

%get the current window contents
	
	
switch mr.Experiment.Subject.Get('group')
	case 1
		ShowGuide1;
	case 2
		ShowGuide2;
	otherwise
		error('wtf group?');
end

%------------------------------------------------------------------------------%
function ShowGuide1()
%movie group
	%get the movie parameters
		strPathMovie	= MR.GetMoviePath(id,op,...
							'flip'		, bFlip		, ...
							'rot180'	, rot180	  ...
							);
		
		%***until the movies get made
			%cPathMovie		= mr.Experiment.Info.Get('show',{'cute','path'});
			%strPathMovie	= cPathMovie{randi(numel(cPathMovie))};
		
		movie	= MR.Param('movie');
	%play it until we get a response button pressed
		bEnd	= false;
		
		mr.Experiment.Window.Store;
		while ~bEnd
			mr.Experiment.Show.Movie.Open(strPathMovie);
			mr.Experiment.Show.Movie.Play;
			
			bMovie	= true;
			while ~bEnd && bMovie
				%flip the previous frame
					mr.Experiment.Window.Flip;
				%show the next frame
					mr.Experiment.Window.Recall;
					bMovie	= mr.Experiment.Show.Movie.ShowFrame([],[0 movie.offset],movie.size);
				%subject response?
					bEnd	= mr.Experiment.Input.DownOnce('any');
			end
			
			mr.Experiment.Show.Movie.Close;
		end
end
%------------------------------------------------------------------------------%
function ShowGuide2()
%model group
	mr.Experiment.Show.Text('guided',[0 MR.Param('movie','offset')]);
	mr.Experiment.Window.Flip;
	
	WaitResponse;
end
%------------------------------------------------------------------------------%
function WaitResponse()
	mr.Experiment.Input.WaitPressed('any');
end
%------------------------------------------------------------------------------%

end
