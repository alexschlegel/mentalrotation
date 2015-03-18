function Prepare(go)
% GridOp.Prepare
%
% Description: prepare to run a gridop experiment
%
% Syntax: go.Prepare()
%
% Updated: 2013-08-30
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase;

%run
	go.Experiment.Info.Set('go','run',1);
%trial info
	nRun	= GO.Param('exp','runs');
	nRep	= GO.Param('exp','reps');
	
	%condition order
	%stimuli are encoded as    1:R1, 2:R2, 3:P1, 4:P2
	%operations are encoded as 1:CW, 2:CCW, 3:H, 4:V
		[kS,kO] 	= ndgrid(1:4,1:4);
		kCondition	= kS + 10*kO;
		
		nCondition	= numel(kCondition);
		nTrialPer	= nCondition*nRep;
		
		order	= GenOrder(kCondition);
		
		go.Experiment.Info.Set('go',{'trial','input'},decget(order,0));
		go.Experiment.Info.Set('go',{'trial','op'},decget(order,1));
	%target location
		go.Experiment.Info.Set('go',{'trial','loc'},GenOrder(1:2));
	%target color
		go.Experiment.Info.Set('go',{'trial','col'},GenOrder(1:2));
	%target initial rotation
		go.Experiment.Info.Set('go',{'trial','rot'},GenOrder(0:3));
	%target initial flip
		go.Experiment.Info.Set('go',{'trial','flip'},GenOrder([0 'h' 'v']));
	%test correct
		go.Experiment.Info.Set('go',{'trial','test'},GenOrder([false true]));
%load the prompt images
	strDirImage	= DirAppend(go.Experiment.File.GetDirectory('code'),'@GridOp','image');
	cPathPrompt	= cellfun(@(p) PathUnsplit(strDirImage,p,'bmp'),{'cw','ccw','h','v'},'uni',false);
	
	go.prompt	= cellfun(@(f) ~imread(f),cPathPrompt,'uni',false);
	go.prompt	= cat(3,go.prompt{:});

%set the initial reward
	go.reward	= GO.Param('reward','base');

go.Experiment.Info.Set('go','prepared',true);


%------------------------------------------------------------------------------%
function order = GenOrder(k)
	n		= numel(k);
	nRepK	= ceil(nTrialPer/n);
	
	order	= blockdesign(k,nRepK,nRun);
	order	= order(:,1:nTrialPer);
end
%------------------------------------------------------------------------------%

end
