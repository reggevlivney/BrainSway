%% Clear
close all;
clear;
% clc;

%% Import Data
% dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
% dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Preprocess data
vSubjectIdx        = XlsFile(:,1);        
Nelc               = 10;  % Num of electrodes
vSessions          = 2:5;
vTime              = 1:2000;
vElectordeIdx      = sort(randperm(62, Nelc));  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and take scores
% mData             = nan(D, 0);
tDataCov            = nan(Nelc,Nelc,0);
vScore              = nan(0,3);

mDetails            = nan(0,3);

for ii = 1 : Ns
    subject = vSubjectIdx(ii);
    for ss = vSessions
        fileName = ['LICI_CSD-mat\session ', num2str(ss) ,'\', num2str(subject),'_', num2str(ss),'.mat']; %Get subject's data    
        if ~(exist([dirPath, fileName], 'file') == 2) %Some subjects don't have data
            vSubjectsInSession(vSubjectsInSession == subject) = [];
            disp(['Missing data for subject ' num2str(ii) ' of '...
             num2str(Ns) ', session ' num2str(ss)]);
            continue;
        end
        load([dirPath, fileName]);
        disp(['Calculating for subject ' num2str(ii) ' of ' num2str(Ns) ...
            ', session ' num2str(ss)]);
        mX              =   fft(data(vElectordeIdx,vTime,:),[],2);
        Nt              =   size(mX, 3);
        for hh = 1:Nt
            mDetails(end+1,:)     =   [ii,ss,hh]; % [SubjectID,SessionNum,TrialNum]
            tDataCov(:,:,end+1)   =   cov(mX(:,:,hh).');
        end
        vScore(end+1,:)           = [ii,ss,XlsFile(ii,ss+1)]; % [SubjectID,SessionNum,HDRS_SCORE]
    end
end
disp('Covariances successfully calculated!');
disp('HDRS Scores successfully saved!');