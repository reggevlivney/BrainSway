%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
% dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Parameters of data (cut unwanted parts)
vSubjectIdx        = XlsFile(:,1);   
Nelc               = 45;  % Num of electrodes
Nelc2              = 2*Nelc;
vPreTime           = 1:800;
vPostTime          = 1201:2000;
vSessions          = 5;
vExcludedElcs      = [55];
vElectordeIdx      = sort(datasample(setdiff(1:62,vExcludedElcs),Nelc,...
                       'Replace',false)); % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;


%% Create Cov matricies and Riemann averages
% mData             = nan(D, 0);
tDataCov            = nan(Nelc2,Nelc2,0);
vScore              = [];
vPowerMean          = nan(Nelc2,0);
dimSubSpcMin        = Nelc2;
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
        mPreX                 = data(vElectordeIdx,vPreTime,:);
        mPostX                = data(vElectordeIdx,vPostTime,:);
        Nt                    = size(mPreX, 3);
        
        %%% Projection of mX to non-singular subspace
%        [mU, mS, ~]  = svd( mX(:,:,1) );
%        dimSubSpc    = sum(diag(mS)>1);
%        dimSubSpcMin = min([dimSubSpc,dimSubSpcMin]);
%        mUSubSpc     = mU(:,1:dimSubSpc);
%        
%        mXSubSpc     = nan( dimSubSpc , 2000 , Nt );
%           for tt = 1 : Nt
%                   mXSubSpc(:,:,tt) = mUSubSpc'*mX(:,:,tt);
%           end
          
          %%% Covariance calculation. To use code without projection,
          %%% uncomment these 2 lines and comment the projection code.
        dimSubSpc    = Nelc2;
        mXSubSpc     = [mPreX;mPostX];
        tCovXi       = nan(dimSubSpc, dimSubSpc, Nt);
        for tt = 1 : Nt
            tCovXi(:,:,tt)  = cov(mXSubSpc(:,:,tt)');
        end
        
        mMeanXi                                   = RiemannianMean(tCovXi);
        tDataCov(1:dimSubSpc,1:dimSubSpc,end+1)   = mMeanXi;
    end
    tDataCov = tDataCov(1:dimSubSpcMin,1:dimSubSpcMin,:);
end
disp('Done!');

%% Eigenvecs
kSubj = 8;
kVec = 3;
[mV,~]=eig(tDataCov(:,:,kSubj));
figure;
subplot(1,2,1);
scatterElectrodeMap(vElectordeIdx,mV(:,kVec))
subplot(1,2,2);
imagesc(mV); colorbar;

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

mtSNE           = mVDiff*mDDiff;
mtSNE           = tsne(mtSNE,vScore,10,23);
