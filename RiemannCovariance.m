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
        
Nelc               = 62;  % Num of electrodes
vSessions          = 5;
% vElectordeIdx    = randperm(62, num_of_elctd);  % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and Riemann averages
% mData = nan(D, 0);
tDataCov   = nan(Nelc,Nelc,0);
vScore     = [];
vPowerMean = nan(Nelc,0);
dimSubSpcMin = Nelc;
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
        
        mX          = data;
        Nt          = size(mX, 3);
        
        %%% Projection of mX to non-singular subspace
       [mU, mS, ~]  = svd( mX(:,:,1) );
       dimSubSpc    = sum(diag(mS)>1);
       dimSubSpcMin = min([dimSubSpc,dimSubSpcMin]);
       mUSubSpc     = mU(:,1:dimSubSpc);
       
       mXSubSpc     = nan( dimSubSpc , 2000 , Nt );
          for tt = 1 : Nt
                  mXSubSpc(:,:,tt) = mUSubSpc'*mX(:,:,tt);
          end
          
          %%% Covariance calculation. To use code without projection,
          %%% uncomment these 2 lines and comment the projection code.
%         dimSubSpc    = Nelc;
%         mXSubSpc     = mX;
        tCovXi       = nan(dimSubSpc, dimSubSpc, Nt);
        tCorrXi      = nan(dimSubSpc, dimSubSpc, Nt);
        for tt = 1 : Nt
            tCovXi(:,:,tt)  = cov(mXSubSpc(:,:,tt)');
            tCorrXi(:,:,tt)  = corrcoef(mXSubSpc(:,:,tt)');
%           min(eig(tCorrXi(:,:,tt)))
%           max(eig(tCorrXi(:,:,tt)))
%           figure; imagesc(tCorrXi(:,:,tt)); colorbar;
%           figure; plot(eig(tCorrXi(:,:,tt)))
        end
        
        mMeanXi                         = RiemannianMean(tCovXi);
        vPowerMean(1:dimSubSpc,end+1)   = diag(mMeanXi); 
        
        tDataCov(1:dimSubSpc,1:dimSubSpc,end+1)   = mMeanXi;
        vScore(end+1)                             = XlsFile(ii,ss+1);
    end
    tDataCov = tDataCov(1:dimSubSpcMin,1:dimSubSpcMin,:);
end
disp('Done!');
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

 