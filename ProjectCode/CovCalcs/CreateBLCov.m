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
vTime              = 10000:23000;
vElectordeIdx      = sort(randperm(62, Nelc));  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and take scores
% mData             = nan(D, 0);
tMeanCov            = nan(Nelc,Nelc,0);
vScore              = nan(0,4);
mMeanDetails            = nan(0,2);

for ii = 1 : Ns
    subject = vSubjectIdx(ii);
    for ss = vSessions
        disp(['Calculating for subject ' num2str(ii) ' of ' num2str(Ns) ...
            ', session ' num2str(ss)]);
        
         try
            fileName    = ['Exp_EC\mat\Exp_EC_5013', num2str(subject), '_', num2str(ss), '.mat']; %Get subject's data    
            b_data      = load([dirPath, fileName]);     % Data without pulse
        catch 
            try
                            fileName    = ['Exp_EC\mat\Exp_EC_5213', num2str(subject), '_', num2str(ss), '.mat']; %Get subject's data    
                            b_data      = load([dirPath, fileName]);     % Data without pulse
            catch
            % Nothing to do
            end
        end
        
        mX                        =   b_data.data(vElectordeIdx,vTime);
        mMeanDetails(end+1,:)     =   [ii,ss]; % [SubjectID,SessionNum,TrialNum]
        tMeanCov(:,:,end+1)       =   cov(mX(:,:).');
        vScore(end+1,:)           = [ii,ss,XlsFile(ii,ss+1),XlsFile(ii,9)]; % [SubjectID,SessionNum,HDRS_SCORE,dHDRS]
    end
end
disp('Covariances successfully calculated!');
disp('HDRS Scores successfully saved!');