function Practice(mr)
% MentalRotation.Practice
% 
% Description:	practice the task
% 
% Syntax:	mr.Practice()
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

nPractice	= MR.Param('exp','practicetrials');
kPractice	= 0;
bCorrect	= [];

nCriterion	= 10;
chrLog		= {'<color:red>N</color>','<color:green>Y</color>'};

bContinue	= true;
while bContinue
	kPractice	= kPractice + 1;
    
	mr.Experiment.Show.Instructions(sprintf('Trial %d',kPractice),'next','start');
	
	res			= mr.PracticeTrial(kPractice);
	strResponse	= conditional(res.correct,'<color:green>Yes!</color>','<color:red>No!</color>');
	
	bCorrect(end+1)	= res.correct;
	
	nCount		= min(nCriterion,numel(bCorrect));
	bCorrectC	= bCorrect(end-nCount+1:end);
	nCorrectC	= sum(bCorrectC);
	
	strPerformance	= sprintf(plural(nCount,'You were correct on %d of the last %d trial{,s}.'),nCorrectC,nCount);
	strLog			= sprintf('History: %s (%d total)',join(arrayfun(@(k) chrLog{k},double(bCorrectC)+1,'uni',false),' '),kPractice);
	strResult		= [strResponse '\n\n' strPerformance '\n' strLog];
	
	if kPractice >= nPractice
		yn			= mr.Experiment.Show.Prompt([strResult '\n\nAgain?'],'choice',{'y','n'});
		bContinue	= isequal(yn,'y');
	else
		mr.Experiment.Show.Instructions(strResult);
	end
end

%save the results
	mr.Experiment.Info.Set('mr','practice_record',bCorrect);
