%% Clear
close all;
clear;
clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
% dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Preprocess data
vSubjectIdx = XlsFile(:,1);
        
Nelc               = 40;  % Num of electrodes
vSessions          = 1:6;
vElectordeIdx      = sort(randperm(62, Nelc));  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and Riemann averages
% mData             = nan(D, 0);
tDataCov            = nan(Nelc,Nelc,0);
vScore              = [];
vSessionOfCov       = [];
for ii = 1 : Ns
    subject = vSubjectIdx(ii);
    
    for ss = vSessions
        fileName1 = ['baseline\mat\Exp_EC_5013', num2str(subject),'_', num2str(ss),'.mat']; %Get subject's data    
        fileName2 = ['baseline\mat\Exp_EC_5213', num2str(subject),'_', num2str(ss),'.mat'];
        if ~(exist([dirPath, fileName1], 'file') == 2) && ...
           ~(exist([dirPath, fileName2], 'file') == 2) %Some subjects don't have data
            
            vSubjectsInSession(vSubjectsInSession == subject) = [];
            disp(['Missing data for subject ' num2str(ii) ' of '...
             num2str(Ns) ', session ' num2str(ss)]);
            continue;
        end
        if (exist([dirPath, fileName1], 'file') == 2)
            fileName = fileName1;
        else
            fileName = fileName2;
        end
        
        load([dirPath, fileName]);
        disp(['Calculating for subject ' num2str(ii) ' of ' num2str(Ns) ...
            ', session ' num2str(ss)]);
        
        vSessionOfCov(end+1)  =   ss;
        
        mXp         = data(vElectordeIdx,1:1000*floor(size(data,2)/1000));
        mX          = nan(Nelc,2000,0);
        loc         = 1;
        while (loc+1999< size(mXp,2))
            mX(:,:,end+1) = mXp(:,loc:loc+1999);
            loc = loc + 1000;
        end
        
        mX          = abs(fft(mX,[],2));
        mY          = repmat(sum(mX.^2,2),[1,2000]);
        mX          = mX./mY;
        Nt          = size(mX, 3);
        tCovXi       = nan(Nelc, Nelc, Nt);
        for tt = 1 : Nt
            tCovXi(:,:,tt)  = cov(mX(:,:,tt)');
        end
        
        mMeanXi                         = RiemannianMean(tCovXi);        
        tDataCov(1:Nelc,1:Nelc,end+1)   = mMeanXi;
        vScore(end+1)                             = XlsFile(ii,ss+1);
    end
end
disp('Done!');

%% Eigenvecs
kSubj = 8;
kVec = 2;
[mV,~]=eig(tDataCov(:,:,kSubj));
figure;
subplot(1,2,1);
scatterElectrodeMap(vElectordeIdx,mV(:,kVec))
subplot(1,2,2);
imagesc(mV); colorbar;

%% Projection of covs to 2d subspace
t2dCovs = nan(2,2,size(tDataCov,3));
for ss = 1:size(tDataCov,3)
    [mV,mD]           =   eig(tDataCov(:,:,ss));
    mV1               =   inv(mV);
    t2dCovs(:,:,ss)   =   mV(1:2,:)*mD*mV1(:,1:2);
end
mCovVecs=CovsToVecs(t2dCovs);
scatter3(mCovVecs(1,:),mCovVecs(2,:),mCovVecs(3,:),...
    50,vScore,'Fill');
zlabel({'\psi_3'});
ylabel({'\psi_2'});
xlabel({'\psi_1'});
title({'Covariances plotted as vectors, with random electrodes chosen'});
colorbar;
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

 