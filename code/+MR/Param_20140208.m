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
					'back'	, [128 128 128]	, ...
					'fore'	, [0 0 0]		, ...
					'text'	, [0 0 0]		  ...
					);
		P.size	= structfun2(@(s) s*SIZE_MULTIPLIER,struct(...
					'stim'			, 6		, ...
					'stim_offset'	, 4		, ...
					'prompt_offset'	, 1		, ...
					'arrow'			, 0.5	  ...
					));
		P.stim	= struct(...
					'figures'	, 10		, ...
					'op'		, 'lrbf'	  ...
					);
	%timing
		P.time	= struct(...
					'tr'		, 2000	, ...
					'block'		, 15	, ...
					'rest'		, 5		, ...
					'feedback'	, 0.5	, ...
					'winnings'	, 1		  ...
					);
	%experiment design
		P.exp	= struct(...
					'runsmr'	, 10	, ...
                    'runshr'    , 2		, ...
					'reps'	    , 2		  ...
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
						'incorrect'	, 'right'	, ...
						'fixation'	, 'up'		  ...
						);
end

p	= P;

for k=1:nargin
	v	= varargin{k};
	
	switch class(v)
		case 'char'
			switch v
				case 'runs'
					p	= MR.Param('exp','runsmr') + MR.Param('exp','runshr');
				case 'sizemultiplier'
					p	= SIZE_MULTIPLIER;
				case 'trrun'
					nBlockPer	= MR.Param('blockperrun');
					trBlock		= MR.Param('time','block');
					trRest		= MR.Param('time','rest');
					
					p	= trRest + (trBlock + trRest)*nBlockPer;
				case 'trtotal'
					p	= MR.Param('runs')*MR.Param('trrun');
				case 'trun'
					p	= MR.Param('trrun')*MR.Param('time','tr')/1000/60;
				case 'ttotal'
					p	= MR.Param('trtotal')*MR.Param('time','tr')/1000/60;
				case 'blockperrun'
					p	= numel(MR.Param('stim','op'))*MR.Param('exp','reps');
				case 'blocktotal'
					p	= MR.Param('blockperrun')*MR.Param('runs');
				case 'rewardperblock'
					p	= (P.reward.max - P.reward.base)/MR.Param('blocktotal');
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
