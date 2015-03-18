function p = Param(varargin)
% GO.Param
% 
% Description:	get a gridop parameter
% 
% Syntax:	p = GO.Param(f1,...,fN)
% 
% In:
% 	fK	- the the Kth parameter field
% 
% Out:
% 	p	- the parameter value
%
% Example:
%	p = GO.Param('color','back');
% 
% Updated: 2013-08-30
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent P;

if isempty(P)
	%stimulus parameters
		P.color	= struct(...
					'back'	, [128 128 128]				, ...
					'fore'	, {{[255 255 255],[0 0 0]}}	, ...
					'text'	, [0 0 0]					  ...
					);
		P.shape	= struct(...
					'rect'	, {{[1 0 0 0; 1 1 1 1; 0 0 0 1; 0 0 0 1],[1 1 1 1; 0 1 0 0; 0 1 0 0; 0 1 0 0]}}	, ...
					'polar'	, {{[1 1 0 1; 1 1 0 1; 0 1 0 0; 0 1 0 0],[0 1 0 0; 0 1 1 1; 0 1 1 1; 0 1 1 1]}}	  ...
					);
		P.size	= struct(...
					'stim'		, 400	, ...
					'checker'	, 2		  ...
					);
	%timing
		P.time	= struct(...
					'tr'		, 2000	, ...
					'stimulus'	, 1		, ...
					'prompt'	, 0.125	, ...
					'operation'	, 5.875	, ...
					'test'		, 1		, ...
					'result'	, 1		, ...
					'rest'		, 2		, ...
					'prepost'	, 4		  ...
					);
	%experiment design
		P.exp	= struct(...
					'runs'	, 10	, ...
					'reps'	, 1		  ...
					);
	%text
		P.text	= struct(...
					'font'	, 'Helvetica'	, ...
					'size'	, 0.75			, ...
					'color'	, 'black'		  ...
					);
	%reward
		P.reward	= struct(...
						'base'		, 30	, ...
						'max'		, 45	, ...
						'penalty'	, 5		  ... %penalty is <- times the reward
						);
	%response buttons
		P.response	= struct(...
						'correct'	, 'left'	, ...
						'incorrect'	, 'right'	  ...
						);
end

p	= P;

for k=1:nargin
	v	= varargin{k};
	
	switch class(v)
		case 'char'
			switch v
				case 'trialperrun'
					p	= 4*4*P.exp.reps;
				case 'trtrial'
					p	= P.time.stimulus + P.time.prompt + P.time.operation + P.time.test;
				case 'trrest'
					p	= P.time.result + P.time.rest;
				case 'trrun'
					trTrial	= GO.Param('trtrial');
					trRest	= GO.Param('trrest');
					nTrial	= GO.Param('trialperrun');
					p	= 2*P.time.prepost + nTrial*trTrial + (nTrial-1)*trRest;
				case 'trtotal'
					p	= P.exp.runs*GO.Param('trrun');
				case 'trialtotal'
					p	= GO.Param('trialperrun')*P.exp.runs;
				case 'rewardpertrial'
					p	= (P.reward.max - P.reward.base)/GO.Param('trialtotal');
				case 'penaltypertrial'
					p	= GO.Param('rewardpertrial')*P.reward.penalty;
				otherwise
					p	= p.(v);
			end
		otherwise
			p	= p{v};
	end
end