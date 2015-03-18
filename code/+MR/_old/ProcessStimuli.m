function ProcessStimuli()
% MR.ProcessStimuli
% 
% Description:	process the image stimuli for display during an experiment
% 
% Syntax:	MR.ProcessStimuli
% 
% Updated: 2014-02-07
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase

strDirStim		= DirAppend(strDirBase,'stimuli');
strDirStimRaw	= DirAppend(strDirStim,'raw');
strDirStimProc	= DirAppend(strDirStim,'processed');

%find the files to process
	cPathRaw	= FindFilesByExtension(strDirStimRaw,'png','subdir',true);
	nPath		= numel(cPathRaw);
%get the output file names
	lenDirRaw	= numel(strDirStimRaw);
	cPathProc	= cellfun(@(f) [strDirStimProc f(lenDirRaw+1:end)],cPathRaw,'uni',false);

%process them
	progress(nPath,'label','processing stimuli');
	for kP=1:nPath
		im	= im2double(imread(cPathRaw{kP}));
		im	= ProcessStimulus(im);
		
		CreateDirPath(PathGetDir(cPathProc{kP}));
		imwrite(im,cPathProc{kP});
		
		progress;
	end
	
%------------------------------------------------------------------------------%
function im = ProcessStimulus(im)
	msk	= im2mask(im);
    sz = size(msk);
	
	im	= cat(3,im(:,:,1),msk,zeros(sz));
end
%------------------------------------------------------------------------------%

end