function p = Param(varargin)
% MR.Param
% 
% Description:	get a mentalrotation parameter
% 
% Syntax:	p = MR.Param(f1,...,fN)
% 
% In:
% 	fK	- the the Kth parameter field
% 
% Out:
% 	p	- the parameter value
%
% Example:
%	p = MR.Param('color','back');
% 
% Updated: 2013-08-30
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global SIZE_MULTIPLIER;
persistent P;

if isempty(SIZE_MULTIPLIER)
	SIZE_MULTIPLIER	= 1;
end

if isempty(P)
	%stimulus parameters
		P.color	= struct(...
					'back'		, [128 128 128]	, ...
					'fore'		, [0 0 0]		, ...
					'prompt'	, [0 0 0 192]	, ...
					'text'		, [0 0 0]		  ...
					);
		P.size	= structfun2(@(s) s*SIZE_MULTIPLIER,struct(...
					'stim'			, 8		, ...
					'prompt'		, 2		  ...
					));
		P.stim	= struct(...
					'figures'	, 8		, ...
					'op'		, 'lrbf'	  ...
					);
	%timing
		P.time	= struct(...
					'tr'			, 2000	, ...
					'prompt'		, 3		, ...
					'operation'		, 1		, ...
					'test'			, 1		, ...
					'feedback'		, 1		, ...
					'rest'			, 4		  ...
					);
	%experiment design
		P.exp	= struct(...
					'runsmr'			, 10	, ...
                    'runshr'			, 3		, ...
                    'runs'              , 13    , ...
					'reps'				, 4		, ...
					'practicetrials'	, 100	  ...
					);
	%text
		P.text	= struct(...
					'font'	, 'Helvetica'			, ...
					'size'	, 0.75*SIZE_MULTIPLIER	  ...
					);
	%reward
		P.reward	= struct(...
						'base'		, 20	, ...
						'max'		, 40	, ...
						'penalty'	, 5		  ... %penalty is <- times the reward
						);
	%response buttons
		P.response	= struct(...
						'correct'	, 'left'	, ...
						'incorrect'	, 'right'	  ...
						);
	%fixation task
		P.fixation	= struct(...
						'rate'		, 1/2	, ...
						'response'	, 'up'	  ...
						);
	
	%movies
		P.movie	= struct(...
					'size'		, 8	, ...
					'offset'	, 8	  ...
					);
    %scheme
        P.analysis = struct(...
                    'scheme' , 'operation' ...
                    );
end

p	= P;

for k=1:nargin
	v	= varargin{k};
	
	switch class(v)
		case 'char'
			switch v
				case 'runs'
					p	= P.exp.runsmr + P.exp.runshr;
				case 'sizemultiplier'
					p	= SIZE_MULTIPLIER;
				case 'trialperrun'
					p	= numel(P.stim.op)*P.exp.reps;
				case 'trtrial'
					p	= P.time.prompt + P.time.operation + P.time.test;
				case 'trrest'
					p	= P.time.feedback + P.time.rest;
				case 'trrestpre'
					p	= P.time.feedback + P.time.rest; 
				case 'trrestpost'
					p	= P.time.feedback + P.time.rest - 1; % scan ends 1 tr early
				case 'trrun'
					nTrial	= MR.Param('trialperrun');
					
					p	= MR.Param('trrestpre') + nTrial*MR.Param('trtrial') + (nTrial-1)*MR.Param('trrest') + MR.Param('trrestpost');
				case 'trtotal'
					p	= MR.Param('exp','runs')*MR.Param('trrun');
				case 'trun'
					p	= MR.Param('trrun')*P.time.tr/1000/60;
				case 'ttotal'
					p	= MR.Param('trtotal')*P.time.tr/1000/60;
				case 'trialtotal'
					p	= MR.Param('trialperrun')*MR.Param('exp','runs');
				case 'trialmrtotal'
					p	= MR.Param('trialperrun')*MR.Param('exp','runsmr');
				case 'rewardpertrial'
					p	= (P.reward.max - P.reward.base)/MR.Param('trialmrtotal');
				case 'penaltypertrial'
					p	= MR.Param('rewardpertrial')*P.reward.penalty;
                case 'scheme'
                    p = {P.analysis.scheme};
				otherwise
					if isfield(p,v)
						p	= p.(v);
					else
						p	= [];
						return
					end
			end
		otherwise
			if iscell(p)
				p	= p{v};
			else
				p	= [];
				return;
			end
	end
end
