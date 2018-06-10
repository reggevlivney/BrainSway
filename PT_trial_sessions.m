%% Clear
close all;
clear;
% clc;

%% Import Data
% dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
  dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
% dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Preprocess data
vSubjectIdx        = XlsFile(:,1);        
Nelc               = 40;  % Num of electrodes
vSessions          = 2:5;
vElectordeIdx      = sort(randperm(62, Nelc));  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
% Ns                 = 10; %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and Riemann averages
tDataCov            = nan(Nelc,Nelc,0);
mDetails            = nan(0,3);
mMeanCovDetails     = nan(0,3);
tTrialsMeanCov       = nan(Nelc,Nelc,0);

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
        
        mX          = data(vElectordeIdx,1200:end,:);
        Nt          = size(mX, 3);
        for hh = 1:Nt
            mDetails(end+1,:)     =   [ii,ss,hh];
            tDataCov(:,:,end+1)   =   cov(mX(:,:,hh).');
        end
        mMeanCovDetails(end+1,:)      = [ii,ss,XlsFile(ii,ss+1)];
        idx                       = find(mDetails(:,1) == ii & mDetails(:,2) == ss);
        tTrialsMeanCov(:,:,end+1) = RiemannianMean(tDataCov(:,:,idx));
    end
end
disp('Done!');

%% Parallel Transport by Subject
% Riemannian Mean
nSess           =   length(vSessions);
tMeanCov        =   nan(Nelc,Nelc,Ns);
vMeanDetails    =   nan(1,Ns);
for ii = 1 : Ns
    ss                  =   ii;
    disp("Riemannian Mean over subject " + num2str(ss));
    vMeanDetails(ii)    =   ss;
    vSubjIdx            =   find(mMeanCovDetails(:,1) == ss);
    tMeanCov(:,:,ii)    =   RiemannianMean(tTrialsMeanCov(:,:,vSubjIdx));
end

% Total Riemannian Mean
mMeanMeanCov = RiemannianMean(tMeanCov);

% Parallel Transport
% figure;

tPTDataCov           = nan(Nelc,Nelc,size(tTrialsMeanCov,3));
mMeanMinusSquareRoot = mMeanMeanCov^(-1/2);
for ii = 1 : Ns
    ss = ii;
    E = ( mMeanMeanCov / tMeanCov(:,:,ii) )^(1/2);
    vSubjIdx            =   find(mMeanCovDetails(:,1) == ss);
    for jj = vSubjIdx'
        tPTDataCov(:,:,jj) = (E * tTrialsMeanCov(:,:,jj)) * E.';
    end
end

%% Parallel Transport by Session
% Riemannian Mean
nSess           =   length(vSessions);
tMeanCov        =   nan(Nelc,Nelc,nSess);
vMeanDetails    =   nan(1,nSess);
 for ii = 1 : nSess
     ss                  =   vSessions(ii);
    disp("Riemannian Mean over session " + num2str(ss));
    vMeanDetails(ii)    =   ss;
    vSessIdx            =   find(mMeanCovDetails(:,2) == ss);
    tMeanCov(:,:,ii)    =   RiemannianMean(tTrialsMeanCov(:,:,vSessIdx));
end

% Total Riemannian Mean
mMeanMeanCov = RiemannianMean(tMeanCov);

% Parallel Transport

% figure;

tPTDataCov           = nan(Nelc,Nelc,size(tTrialsMeanCov,3));
mMeanMinusSquareRoot = mMeanMeanCov^(-1/2);
for ii = 1 : nSess
    ss = vSessions(ii);
    E = ( mMeanMeanCov / tMeanCov(:,:,ii) )^(1/2);
    vSessIdx            =   find(mMeanCovDetails(:,2)==ss);
    for jj = vSessIdx'
        tPTDataCov(:,:,jj) = E * tTrialsMeanCov(:,:,jj) * E.';
    end
end
%% CovToVecs and PCA
mPTVecs    = CovsToVecs(tPTDataCov).';
[coeff, mDPTVecs] = pca(mPTVecs);
% mDPTVecs = mPTVecs*coeff; 

mVecs  = CovsToVecs(tTrialsMeanCov).';
[coeff, mDVecs] = pca(mVecs);
% mDVecs = mVecs*coeff; 
%% Figures
figure; % Color by session number
    subplot(1,2,2);
        mDPTVecs = mDPTVecs(:,1:3);
        scatter3(mDPTVecs(:,1), mDPTVecs(:,2), mDPTVecs(:,3), 100, mMeanCovDetails(:,2), 'Fill');
        title("Sessions Scattering: after PT and PCA 3");
    subplot(1,2,1);
        mDVecs = mDVecs(:,1:3);
        scatter3(mDVecs(:,1), mDVecs(:,2), mDVecs(:,3), 100, mMeanCovDetails(:,2), 'Fill');
        title("Sessions Scattering: PCA 3");

mC = lines(Ns);
figure; % Color by subject number
    subplot(1,2,2);
        scatter3(mDPTVecs(:,1), mDPTVecs(:,2), mDPTVecs(:,3), 100, mC(mMeanCovDetails(:,1),:), 'Fill'); colorbar;
        title("Subjects Scattering: after PT and PCA 3");
    subplot(1,2,1);
        scatter3(mDVecs(:,1), mDVecs(:,2), mDVecs(:,3), 100, mC(mMeanCovDetails(:,1),:), 'Fill'); colorbar;
        title("Subjects Scattering: PCA 3");

figure; % Color by score
    subplot(1,2,2);
        scatter3(mDPTVecs(:,1), mDPTVecs(:,2), mDPTVecs(:,3), 100, mMeanCovDetails(:,3), 'Fill'); colorbar;
        title("Subjects Scattering: after PT and PCA 3");
    subplot(1,2,1);
        scatter3(mDVecs(:,1), mDVecs(:,2), mDVecs(:,3), 100, mMeanCovDetails(:,3), 'Fill'); colorbar;
        title("Subjects Scattering: PCA 3");

%% Data for classifier
Data = [mPTVecs, mMeanCovDetails(:,2)];