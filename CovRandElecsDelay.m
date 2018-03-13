%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
%  dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Parameters of data (cut unwanted parts)
vSubjectIdx        = XlsFile(:,1);   
Nelc               = 45;  % Num of electrodes
vSessions          = 5;
vExcludedElcs      = [55];
vElectordeIdx      = sort(datasample(setdiff(1:62,vExcludedElcs),Nelc,...
                       'Replace',false)); % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;


%% Create Cov matricies and Riemann averages
% mData             = nan(D, 0);
tDataCov            = nan(Nelc,Nelc,0);
tDataExCov          = nan(Nelc,Nelc,0);
vScore              = [];
dimSubSpcMin        = Nelc;
vSessionOfCov       = [];
vSubjectOfCov       = [];
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
        
        vSessionOfCov(end+1)  =   ss;
        vSubjectOfCov(end+1)  =   ii;
        vScore(end+1)         =   XlsFile(ii,ss+1);
        mX                    = data(vElectordeIdx,:,:);
        mPreX                 = data(vElectordeIdx,1:1999,:);
        mPostX                = data(vElectordeIdx,2:2000,:);
        Nt                    = size(mPreX, 3);
        
          %%% Covariance calculation. To use code without projection,
          %%% uncomment these 2 lines and comment the projection code.
        dimSubSpc    = Nelc;
        tExCovXi       = nan(dimSubSpc, dimSubSpc, Nt);
        tCovXi       = nan(dimSubSpc, dimSubSpc, Nt);
        for tt = 1 : Nt
            tExCovXi(:,:,tt)  = mPreX(:,:,tt)*mPostX(:,:,tt)'/1999;
        end
        
        for tt = 1 : Nt
            tCovXi(:,:,tt)  = cov(mX(:,:,tt)');
        end
        mMeanExXi                                 = mean(tExCovXi,3);
        mMeanXi                                   = RiemannianMean(tCovXi);
        tDataExCov(1:dimSubSpc,1:dimSubSpc,end+1) = mMeanExXi;
        tDataCov(1:dimSubSpc,1:dimSubSpc,end+1)   = mMeanXi;
    end
    tDataCov   = tDataCov(1:dimSubSpcMin,1:dimSubSpcMin,:);
    tDataExCov = tDataExCov(1:dimSubSpcMin,1:dimSubSpcMin,:);
end
disp('Done!');

% %% Eigenvecs
% kSubj = 1;
% kVec = 3;
% [mV,~]=eig(tDataCov(:,:,kSubj));
% figure;
% subplot(1,2,1);
% scatterElectrodeMap(vElectordeIdx,mV(vElectordeIdx,kVec))
% subplot(1,2,2);
% imagesc(mV); colorbar;

%% Make Diffusion Map and Parallel Transport calculations
%%% Create W distances matrix. Make sure to use only one session!
Nmats   =   size(tDataCov,3);
mDists  =   zeros(Nmats,Nmats);
for ii = 1:Nmats
    for jj = ii+1:Nmats
        mDists(ii,jj) = RiemannianDist(tDataCov(:,:,ii),tDataCov(:,:,jj));
        mDists(jj,ii) = mDists(ii,jj);
    end
end
eDiff        = mean(mDists(mDists~=0));
mDistsDiff   = exp(-mDists.^2/eDiff^2);
[mVDiff,mDDiff] = eig(mDistsDiff);

for ii = 1:Nmats
    for jj = ii+1:Nmats
        A             = tDataExCov(:,:,ii)-tDataExCov(:,:,jj);
        mExDists(ii,jj) = trace(A.'*A);
        mExDists(jj,ii) = mExDists(ii,jj);
    end
end
eExDiff        = mean(mExDists(mExDists~=0));
mExDistsDiff   = exp(-mExDists.^2/eExDiff^2);
[mExVDiff,mExDDiff] = eig(mExDistsDiff);

mtSNE           = [mVDiff*mDDiff,mExVDiff*mExDDiff]
mtSNE           = TSNE(mtSNE,vScore,10,23);
