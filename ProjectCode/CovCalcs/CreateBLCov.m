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
Nelc               = 40;  % Num of electrodes
vSessions          = 1:6;
vTime              = 10000:23000;
vElectordeIdx      = sort(randperm(62, Nelc));  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and take scores
% mData             = nan(D, 0);
tMeanCov            = nan(Nelc,Nelc,0);
mScore              = nan(0,3);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  Proccess in Time    %%%
%         mX = mX;       % no proccess in time
%         mX = fft(mX,[],2);
%         mX = EEG_BL_filter(mX);
%         mX = cat(1,mXb(:,1:end-tau,:),mXb(:,tau+1:end,:));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        mMeanDetails(end+1,:)     =   [ii,ss]; % [SubjectID,SessionNum,TrialNum]
        tMeanCov(:,:,end+1)       =   cov(mX(:,:).');
        mScore(end+1,:)           = [ii,ss,XlsFile(ii,ss+1)]; % [SubjectID,SessionNum,HDRS_SCORE]
    end
end
disp('Covariances successfully calculated!');
disp('HDRS Scores successfully saved!');