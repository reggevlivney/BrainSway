%% Clear
close all;
clear;
% clc;

%% Import Data
dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
%dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
% dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Preprocess data
vSubjectIdx = XlsFile(:,1);
        
num_of_elctd       = 62;  % Num of electrodes to use
% num_of_sess        = 2;  % Num of sessions   
vSeesions          = [5];
% vElectordeIdx      = randperm(62, num_of_elctd);  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%%
% mData = nan(D, 0);
tDataCov = nan(num_of_elctd,num_of_elctd,0);
vScore   = [];

for ii = 1 : Ns
    ii
    subject = vSubjectIdx(ii);
    
    for ss = vSeesions
        fileName = ['LICI_CSD-mat\session ', num2str(ss) ,'\', num2str(subject),'_', num2str(ss),'.mat']; %Get subject's data    

        if ~(exist([dirPath, fileName], 'file') == 2) %Some subjects don't have data
            vSubjectsInSession(vSubjectsInSession == subject) = [];
            continue;
        end
        load([dirPath, fileName]);

        mX      = data;
        Nt      = size(mX, 3);
        tCovXi  = nan(num_of_elctd, num_of_elctd, Nt);
        for tt = 1 : Nt
            tCovXi(:,:,tt) = cov(mX(:,:,tt)') + 10 * eye(num_of_elctd);
%             min(eig(tCovXi(:,:,tt)))
%             max(eig(tCovXi(:,:,tt)))
%             figure; imagesc(tCovXi(:,:,tt)); colorbar;
%             figure; plot(eig(tCovXi(:,:,tt)))
        end
        
        mMeanXi = RiemannianMean(tCovXi);
        
        tDataCov(:,:,end+1) = mMeanXi;
        vScore(end+1)       = XlsFile(ii,ss+1);
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
tRMean      = nan(num_of_elctd,2000,2000);
vDataSize   = size(tDataCov); 
for jj = 1:num_of_elctd
            tRMean(jj,:,:) = RiemannianMean(reshape(tDataCov(jj,:,:,:),vDataSize(2:4)));
end

 