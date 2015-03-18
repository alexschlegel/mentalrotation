function varargout = GetFigure(varargin)
% MR.GetFigure
% 
% Description:	
% 
% Syntax:	MR.GetFigure (first call)
%			im = MR.GetFigure(id,<options>)
% 
% In:
% 	id	- the figure id
%	<options>:
%		operation:	(<none>) the operation to perform on the image. one of 'l',
%					'r', 'b', or 'f'.
%		flip:		(false) true to flip the figure
%		rot180:		(<none>) 'lr' to rotate 180 degrees along the L/R axis, or
%					'bf' to rotate 180 degrees along the B/F axes
% 
% Out:
% 	im	- the image
% 
% Updated: 2014-02-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase;
persistent im;

if isempty(im)
	status('loading stimuli...');
	
	strDirStim	= DirAppend(strDirBase,'stimuli');
	nFigure		= 8;
	
	%stimulus parameters
		cOp	= {'l','r','b','f','n'};
		nOp	= numel(cOp);
		
		cFlip	= {'flip','orig'};
		nFlip	= numel(cFlip);
		
		cRot	= {'rotlr','rotbf','rotno'};
		nRot	= numel(cRot);
	
	%load each figure
		im	= repmat({dealstruct(cFlip{:},dealstruct(cRot{:},dealstruct(cOp{:},[])))},[nFigure 1]);
		
		for kF=1:nFigure
			strFigure	= StringFill(kF,2);
			
			strDirFigure	= DirAppend(strDirStim,strFigure);
			
			for kL=1:nFlip
				strFlip	= cFlip{kL};
				
				strDirFlip	= DirAppend(strDirFigure,strFlip);
				
				for kR=1:nRot
					strRot	= cRot{kR};
					
					strDirRot	= DirAppend(strDirFlip,strRot);
					
					for kO=1:nOp
						strOp	= cOp{kO};
						
						[rotLR,rotBF]	= MR.Operate(strOp);
						
						strPathIm	= PathUnsplit(strDirRot,sprintf('%d_%d',rotLR,rotBF),'png');
						
						im{kF}.(strFlip).(strRot).(strOp)	= LoadFigure(strPathIm);
					end
				end
			end
		end
end

if nargout
%user wants an image
	[id,opt]	= ParseArgs(varargin,1,...
					'operation'	, 'n'	, ...
					'flip'		, false	, ...
					'rot180'	, 'no'	  ...
					);
	
	%get the flip specifier
		strFlip	= conditional(opt.flip,'flip','orig');
	
	%get the pre-rotation specifier
		str180	= ['rot' opt.rot180];
	
	varargout{1}	= im{id}.(strFlip).(str180).(opt.operation);
end

%------------------------------------------------------------------------------%
function im = LoadFigure(strPathIm)
	im	= imread(strPathIm);
    
    msk = im(:,:,1)==0 | im(:,:,2)~=0;
    
    im = cat(3,im,255*msk);
end
%------------------------------------------------------------------------------%

end
