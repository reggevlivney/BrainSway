%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
 dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
%dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);
addpath('tSNE_matlab\');
%% Parameters of data (cut unwanted parts)
vSubjectIdx        = XlsFile(:,1);   
Nelc               = 45;  % Num of electrodes
vSessions          = 5;
vExcludedElcs      = [55];
vElectordeIdx      = sort(datasample(setdiff(1:62,vExcludedElcs),Nelc,...
                       'Replace',false)); % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;
NGradFiltSize             = 10;


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
        [~,mdX,~]             = gradient(data(vElectordeIdx,:,:));
        Nt                    = size(mX, 3);
        
        dimSubSpc    = Nelc;
        tExCovXi       = nan(2*dimSubSpc, 2*dimSubSpc, Nt);
        
        for tt = 1 : Nt
            tExCovXi(:,:,tt)  = cov([mX(:,:,tt);mdX(:,:,tt)]');
        end
        mMeanExXi                                 = mean(tExCovXi,3);
        tDataExCov(1:2*dimSubSpc,1:2*dimSubSpc,end+1) = mMeanExXi;
    end
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
Nmats   =   size(tDataExCov,3);
mExDists  =   zeros(Nmats,Nmats);

for ii = 1:Nmats
    for jj = ii+1:Nmats
        A               = tDataExCov(:,:,ii)-tDataExCov(:,:,jj);
        mExDists(ii,jj) = trace(A.'*A);
        mExDists(jj,ii) = mExDists(ii,jj);
    end
end
eExDiff        = mean(mExDists(mExDists~=0));
mExDistsDiff   = exp(-mExDists.^2/eExDiff^2);
[mExVDiff,mExDDiff] = eig(mExDistsDiff);

mtSNE           = [mExVDiff*mExDDiff];
mtSNE           = TSNE(mtSNE,vScore,3,23);
