%% Clear
close all; clear; clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
%dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);


%% Preprocess data
vSubjectIdx = XlsFile(:,1);
        
num_of_elctd       = 1;  % Num of electrodes to use
num_of_sess        = 1;  % Num of sessions   
vElectordeIdx      = randperm(62, num_of_elctd);  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

% mData = nan(D, 0);
tXCov = nan(num_of_elctd,2000,2000);
tDataCov = nan(num_of_elctd,2000,2000,0);

for ii = 1 : Ns
% for ii = 1 : 1
    subject  = vSubjectIdx(ii);
    for kk = 1:num_of_sess
        fileName = ['LICI_CSD-mat\session ', num2str(kk+1) ,'\', num2str(subject),'_', num2str(kk+1),'.mat'];%Get subject's data    

        if ~(exist([dirPath, fileName], 'file') == 2) %Some subjects don't have data
            vSubjectsInSession(vSubjectsInSession==subject) = [];
            continue;
        end
        load([dirPath, fileName]);

        mX      = data;
        mXMean  = mean(mX,3);
        mX      = mX - mXMean;

        for jj = 1:num_of_elctd
            tXCov(jj,:,:) =  permute(permute(mX(vElectordeIdx(jj),:,:),[2,3,1])*permute(mX(vElectordeIdx(jj),:,:),[3,2,1]),[3, 1, 2]);
        end

        tDataCov(:,:,:,end+1) = tXCov;
    end
end

%% Riemannian Mean
tRMean      = nan(num_of_elctd,2000,2000);
vDataSize   = size(tDataCov); 
for jj = 1:num_of_elctd
            tRMean(jj,:,:) = RiemannianMean(reshape(tDataCov(jj,:,:,:),vDataSize(2:4)));
end

 