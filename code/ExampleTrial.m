function res = Trial(mr,varargin)
% Trial
% 
% Description:	show on mental rotation trial
% 
% Syntax:	res = mr.Trial(<options>)
% 
% In:
%	<options>:
%		figure:     (<random>) the figure number to use (1-10)
%       rotate:     (<random>) true to rotate the figure 180 degrees
%       flip:       (<random>) true to flip the figure
%       operation:  (<random>) the operation ('l', 'r', 'f', or 'b'). 'n'
%                               to perform no operation
%       test:       (<random>) true if the test figure should be the
%                      correct result of the operation
% 
% Out:
% 	res     - a struct of results from the trial
% 
% Updated: 2013-09-24
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input arguments
opt	= ParseArgs(varargin,...
		'figure'	, randFrom(1:10,1)         , ...
		'rotate'	, randFrom([true,false],1) , ...
        'flip'      , randFrom([true false],1) , ...
        'operation' , randFrom('lrfb',1)       , ...
		'test'      , randFrom(1:10,1)           ...
		);

if isempty(opt.figure)
    opt.figure = randFrom(1:10);
end
    
%prepare the figures   
    imStart = MR.GetFigure(opt.figure, opt.rotate, opt.flip, opt.operation, opt.test);
    imTest = MR.GetFigure(opt.figure, opt.rotate, opt.flip, opt.operation, opt.test);

%show the prompt
    %show the starting figure
        ShowStartFigure;
    %show the operation prompt
        ShowOperation(opt.operation);
    %show the test figure
        ShowTestFigure;
    %flip the prompt
        tShow = mr.Experiment.Window.Flip;

%wait for the subject to respond
    [bResponse,tRespond] = WaitForResponse;

%process the response
    res = ProcessResponse;


    function ShowStartFigure()
        mr.Experiment.Show.Image(imStart,imPos,imSize);
    end
    
    function res = ProcessResponse()
        res.opt = opt;
        res.flip = bFlip;
        res.rotate = bRotate;
        res.tShow = tShow;
        res.tRespond = tRespond;
        res.tReaction = tRespond - tShow;
        
        %was the subject correct?
            res.correct = (bResponse && bTest) || (~bResponse && ~bTest);
    end
end
