function Prepare(mr,varargin)
% MentalRotation.Prepare
%
% Description: prepare to run a mentalrotation experiment
%
% Syntax: mr.Prepare()
%
% Updated: 2014-02-07
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase;

%load the stimuli
	MR.GetFigure;

kSession	= mr.Experiment.Info.Get('mr','session');

%response buttons
	kCorrect	= MR.Param('response','correct');
	kIncorrect	= MR.Param('response','incorrect');
	kFixation	= MR.Param('response','fixation');
	mr.Experiment.Input.Set('response',{kCorrect,kIncorrect});
	mr.Experiment.Input.Set('correct',kCorrect);
	mr.Experiment.Input.Set('incorrect',kIncorrect);
	mr.Experiment.Input.Set('fixation',kFixation);
%run
	mr.Experiment.Info.Set('mr','run',1);
	mr.Experiment.Info.Set('mr','result',cell(MR.Param('exp','runs'),1));
%trial info
	nRun		= MR.Param('exp','runs');
	nRep		= MR.Param('exp','reps');
	
	ops		= MR.Param('stim','op');
	nOp		= numel(ops);
	nFigure	= MR.Param('stim','figures');
	
	nTrialPer	= nOp*nRep;
	
	mr.Experiment.Info.Set('mr',{'trial','figure','id'},GenOrder(1:nFigure));
	mr.Experiment.Info.Set('mr',{'trial','figure','flip'},GenOrder([true false]));
	mr.Experiment.Info.Set('mr',{'trial','figure','rot180'},GenOrder({'lr','bf','no'}));
	mr.Experiment.Info.Set('mr',{'trial','operation'},GenOrder(ops));
	mr.Experiment.Info.Set('mr',{'trial','prompt','location'},GenOrder(1:nOp));
	mr.Experiment.Info.Set('mr',{'trial','test','correct'},GenOrder([true false]));
%set the initial reward
	mr.reward	= MR.Param('reward','base');
%prompt color
	mr.Experiment.Color.Set('prompt',MR.Param('color','prompt'));

mr.Experiment.Info.Set('mr','prepared',true);


%------------------------------------------------------------------------------%
function order = GenOrder(k)
	n		= numel(k);
	nRep	= ceil(nTrialPer/n);
	
	order	= blockdesign(k,nRep,nRun);
	order	= order(:,1:nTrialPer);
end
%------------------------------------------------------------------------------%

end
