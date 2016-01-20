% Analysis_20160120_Control_Behavioral
% reviewer 2 wants to see training by rotation interaction effects
% Updated: 2016-01-20
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%create directory for analysis results
	strNameAnalysis	= '20160120_control_behavioral';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo	= MR.SubjectInfo;

%test for training x rotation interaction
	g			= ifo.subject.group;
	nSubject	= numel(g);
	
	kRotation	= reshape(ifo.operation(:,1:10,:),nSubject,[]);
	bCorrect	= reshape(ifo.correct(:,1:10,:),nSubject,[]);
	
	rot	= unique(kRotation(:));
	
	acc	= arrayfun(@(s) arrayfun(@(r) mean(bCorrect(s,kRotation(s,:)==r)),rot),(1:nSubject)','uni',false);
	acc	= cat(2,acc{:})';
	
	accNonMotor	= acc(g==1,:);
	accMotor	= acc(g==2,:);
	
	[p,table]	= anova_rm({accNonMotor accMotor},'off');


%save the results
	strPathOut	= PathUnsplit(strDirOut,'result','mat');
	save(strPathOut,'res');
