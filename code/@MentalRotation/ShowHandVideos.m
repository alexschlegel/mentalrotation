function ShowHandVideos(mr)
%movie group
	%get the movie parameters
    global strDirBase;
    
    key = PTB.Device.Input.Keyboard(mr.Experiment);
    
    for k=1:4
        rot = 'lrbf';
        strMotion = rot(k);
        strDirMovie	= DirAppend(strDirBase,'hand_videos');
		strPathMovie	= PathUnsplit(strDirMovie,strMotion,'MP4');
		
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
					bMovie	= mr.Experiment.Show.Movie.ShowFrame([],[0 0],movie.size);
				%subject response?
					%bEnd	= mr.Experiment.Input.DownOnce('any');
                    bEnd = key.Pressed('any');
			end
			
			mr.Experiment.Show.Movie.Close;
        end
    end
    
    key.End;
    delete(key);
    
    mr.Experiment.Show.Blank;
    mr.Experiment.Window.Flip;
end
