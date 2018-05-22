%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
 dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
%dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Preprocess data
vSubjectIdx = XlsFile(:,1);        
Nelc               = 10;  % Num of electrodes
vSessions          = 2:5;
vElectordeIdx      = sort(randperm(62, Nelc));  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and Riemann averages
% mData             = nan(D, 0);
tDataCov            = nan(Nelc,Nelc,0);
vScore              = [];
vPowerMean          = nan(Nelc,0);
dimSubSpcMin        = Nelc;
vSessionOfCov       = [];

mDetails            = nan(0,3);
mTrialsMean         = nan(0,2);
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
        mX          = data(vElectordeIdx,:,:);
        Nt          = size(mX, 3);
        dimSubSpc    = Nelc;
        mXSubSpc     = mX;
        for hh = 1:Nt
            mDetails(end+1,:)     =   [ii,ss,hh];
            tDataCov(:,:,end+1)   =   cov(mXSubSpc(:,:,hh).');
        end
        mTrialsMean(end+1,:)     =   [ii,ss];
        idx                      =   find(mDetails(:,1) == ii & mDetails(:,2) == ss);
        tTrialsMeanCov(:,:,end+1)    =   RiemannianMean(tDataCov(:,:,idx));
    end
end
disp('Done!');
%% Riemannian Mean
nSess           =   length(vSessions);
tMeanCov        =   nan(Nelc,Nelc,nSess);
vMeanDetails    =   nan(1,nSess);
for ii = 1:nSess
    ss                  =   vSessions(ii);
    disp("Riemannian Mean over session " + num2str(ss));
    vMeanDetails(ii)    =   ss;
    vSessIdx            =   find(mTrialsMean(:,2) == ss);
    tMeanCov(:,:,ii)    =   RiemannianMean(tTrialsMeanCov(:,:,vSessIdx));
end

%% Total Riemannian Mean
mMeanMeanCov = RiemannianMean(tMeanCov);

%% Parallel Transport
tPTDataCov = nan(Nelc,Nelc,size(tTrialsMeanCov,3));
for ii = 1:nSess
    ss = vSessions(ii);
    E = (mMeanMeanCov/tMeanCov(:,:,ii))^0.5;
    vSessIdx            =   find(mTrialsMean(:,2)==ss);
    for jj = vSessIdx.'
        tPTDataCov(:,:,jj) = (E*tTrialsMeanCov(:,:,jj)*(E.'));
        tPTDataCov(:,:,jj) = logm((mMeanMeanCov^(-0.5))*tPTDataCov(:,:,jj)*(mMeanMeanCov^(-0.5)));
    end
end

%% Figures
figure;
subplot(1,2,2);
mPTVecs = CovsToVecs(tPTDataCov).';
coeff  = pca(mPTVecs);
mDPTVecs = mPTVecs*coeff; 
mDPTVecs = mDPTVecs(:,1:3);
scatter3(mDPTVecs(:,1),mDPTVecs(:,2),mDPTVecs(:,3),20,mTrialsMean(:,2),'filled');
title("Sessions Scattering: after PT and PCA 3");
subplot(1,2,1);
mVecs  = CovsToVecs(tTrialsMeanCov).';
coeff  = pca(mVecs);
mDVecs = mVecs*coeff; 
mDVecs = mDVecs(:,1:3);
scatter3(mDVecs(:,1),mDVecs(:,2),mDVecs(:,3),20,mTrialsMean(:,2),'filled');
title("Sessions Scattering: PCA 3");

figure;
subplot(1,2,2);
scatter3(mDPTVecs(:,1),mDPTVecs(:,2),mDPTVecs(:,3),20,mTrialsMean(:,1),'filled');
title("Subjects Scattering: after PT and PCA 3");
subplot(1,2,1);
scatter3(mDVecs(:,1),mDVecs(:,2),mDVecs(:,3),20,mTrialsMean(:,1),'filled');
title("Subjects Scattering: PCA 3");

%% Make Diffusion Map and Parallel Transport calculations
%%% Create W distances matrix. Make sure to use only one session!
Nmats   =   size(tPTDataCov,3);
mDists  =   zeros(Nmats,Nmats);
for ii = 1:Nmats
    for jj = ii+1:Nmats
        mDists(ii,jj) = RiemannianDist(tPTDataCov(:,:,ii),tPTDataCov(:,:,jj));
        mDists(jj,ii) = mDists(ii,jj);
    end
end
eDiff        = mean(mDists(mDists~=0));
mDistsDiff   = exp(-mDists.^2/eDiff^2);

[mVDiff,mDDiff] = eig(mDistsDiff);

mtSNE           = mVDiff*mDDiff;
mtSNE           = TSNE(mtSNE,vScore,3,Nmats);
