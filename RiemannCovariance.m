%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
% dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Preprocess data
vSubjectIdx = XlsFile(:,1);
        
Nelc       = 62;  % Num of electrodes to use
% num_of_sess      = 2;  % Num of sessions   
vSessions          = [5];
% vElectordeIdx    = randperm(62, num_of_elctd);  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and Riemann averages
% mData = nan(D, 0);
tDataCov   = nan(Nelc,Nelc,0);
vScore     = [];
vPowerMean = nan(Nelc,0);

for ii = 1 : Ns
    subject = vSubjectIdx(ii);
    
    for ss = vSessions
        disp(['Calculating for subject ' num2str(ii) ' of ' num2str(Ns) ...
            ', session ' num2str(ss)]);
        fileName = ['LICI_CSD-mat\session ', num2str(ss) ,'\', num2str(subject),'_', num2str(ss),'.mat']; %Get subject's data    

        if ~(exist([dirPath, fileName], 'file') == 2) %Some subjects don't have data
            vSubjectsInSession(vSubjectsInSession == subject) = [];
            continue;
        end
        load([dirPath, fileName]);

        mX          = data;
        Nt          = size(mX, 3);
        tCovXi      = nan(Nelc, Nelc, Nt);
        
        for tt = 1 : Nt
            tCovXi(:,:,tt) = cov(mX(:,:,tt)') + 10 * eye(Nelc);
%             min(eig(tCovXi(:,:,tt)))
%             max(eig(tCovXi(:,:,tt)))
%             figure; imagesc(tCovXi(:,:,tt)); colorbar;
%             figure; plot(eig(tCovXi(:,:,tt)))

        end
        
        mMeanXi               = RiemannianMean(tCovXi);
        vPowerMean(:,end+1) = mMeanXi(eye(Nelc)==1); 
        tDataCov(:,:,end+1)   = mMeanXi;
        vScore(end+1)         = XlsFile(ii,ss+1);
    end
    
end

%% Extract Classifications from XLS
vDHRS           = XlsFile(:,9)';
depressionThres = 0.5;
vIsDepressed    = vDHRS < depressionThres;
vRemove         = ismember(vSubjectIdx,vSubjectsInSession);
vIsDepressed    = vIsDepressed(vRemove);

%%
mX = CovsToVecs(tDataCov);

%%
mSvmData = [vIsDepressed;
            mX];

%% Riemannian Mean
tRMean      = nan(Nelc,2000,2000);
vDataSize   = size(tDataCov); 
for jj = 1:Nelc
            tRMean(jj,:,:) = RiemannianMean(reshape(tDataCov(jj,:,:,:),vDataSize(2:4)));
end

 