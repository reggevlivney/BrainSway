%% Clear
clear; clc; close all;
%% Include all relevant folders
addpath('RiemannianTools');
addpath('CovCalcs');
addpath('ReductionExtraction');
addpath('CovData');
addpath('tSNE');
addpath('Functions');

%% Import Data
% dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
 dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
% dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%%  Choose a subset of electrodes and time window
vSubjectIdx        = XlsFile(:,1);        
Nelc               = 40;  % Num of electrodes
vSessions          = 2:5;
vTime              = 1:2000;
tau                = 200; %time shift
vElectordeIdx      = sort(randperm(62, Nelc));  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;


%% Create Cov matricies and take scores
% mData             = nan(D, 0);
%tDataCov            = nan(Nelc,Nelc,0);
tDataCov            = nan(0,0,0);
mScore              = nan(0,3);
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
        mX             =   data(vElectordeIdx,vTime,:);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  Proccess in Time    %%%
        mX = mX;       % no proccess in time
%         mX = fft(mX,[],2);
%         mX = EEG_filter(mX);
%         mX = cat(1,mXb(:,1:end-tau,:),mXb(:,tau+1:end,:));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Nt              =   size(mX, 3);
        for hh = 1:Nt
            mDetails(end+1,:)     =   [ii,ss,hh]; % [SubjectID,SessionNum,TrialNum]
            tDataCov(:,:,end+1)   =   cov(mX(:,:,hh).');
        end
        mScore(end+1,:)           = [ii,ss,XlsFile(ii,ss+1)]; % [SubjectID,SessionNum,HDRS_SCORE]
    end
end
disp('Covariances successfully calculated!');
disp('HDRS Scores successfully saved!');

%%  Averaging
MeanCovs;

%% Use Baseline instead
CreateBLCov;
vScore = mScore(:,3);
%%  Parallel Transport
tPTCovs = covPT(tMeanCov,mMeanDetails(:,1));
%%  Distance Matrix
% mDists = cal_dist_mat(tMeanCov);
mDists = cal_dist_mat(tPTCovs);
%%  Manifold Learning - Diffusion Maps
mDiffX = diff_maps(mDists,3.5);

figure;
scatter3(mDiffX(:,1),mDiffX(:,2),mDiffX(:,3),40,vScore,'filled');
title("Diffusion Maps Colored by HDRS");
xlabel("\psi_1");
ylabel("\psi_2");
zlabel("\psi_3");

figure;
scatter3(mDiffX(:,1),mDiffX(:,2),mDiffX(:,3),40,mMeanDetails(:,1),'filled');
title("Diffusion Maps Colored by Subjects");
xlabel("\psi_1");
ylabel("\psi_2");
zlabel("\psi_3");

figure;
scatter3(mDiffX(:,1),mDiffX(:,2),mDiffX(:,3),40,mMeanDetails(:,2),'filled');
title("Diffusion Maps Colored by Sessions");
xlabel("\psi_1");
ylabel("\psi_2");
zlabel("\psi_3");

%%  Classify
mData = [mDiffX,mMeanDetails(:,2)];
%%  Regression
