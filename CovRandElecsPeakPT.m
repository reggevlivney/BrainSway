%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
   dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
%   dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Parameters of data (cut unwanted parts)
vSubjectIdx        = XlsFile(:,1);   
Nelc               = 30;  % Num of electrodes
vPeakTime          = 1020:1300;
vSessions          = 2:5;
vExcludedElcs      = [55];
vElectordeIdx      = sort(datasample(setdiff(1:62,vExcludedElcs),Nelc,...
                       'Replace',false)); % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;


%% Create Cov matricies and Riemann averages
% mData             = nan(D, 0);
tDataCov            = nan(Nelc,Nelc,0);
vScore              = [];
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
        
        vSessionOfCov(end+1)  =     ss;
        vSubjectOfCov(end+1)  =     ii;
        vScore(end+1)         =     XlsFile(ii,ss+1);
        mX                    =     data(vElectordeIdx,vPeakTime,:);
        Nt                    =     size(mX, 3);
        
        tCovXi       = nan(Nelc, Nelc, Nt);
        for tt = 1 : Nt
            tCovXi(:,:,tt)  = cov(mX(:,:,tt)');
        end
        
        mMeanXi                                   = RiemannianMean(tCovXi);
        tDataCov(1:Nelc,1:Nelc,end+1)   = mMeanXi;
    end
end
disp('Done!');

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
mtSNE           = TSNE(mtSNE,vScore,3,Nmats);

%% Parallel Transport
tMeanCovs = nan(Nelc,Nelc,Ns);
for ii = 1:Ns
    tMeanCovs(:,:,ii) = RiemannianMean(tDataCov(:,:,vSubjectOfCov==ii));
    disp(num2str(ii));
end

tTotalMean = RiemannianMean(tMeanCovs);
tDataCov2 = tDataCov;
NLt = size(tDataCov,3);
mB = tMeanCovs(:,:,1);
for jj = 1:NLt
    mAinv               = pinv(tMeanCovs(:,:,vSubjectOfCov(jj)));
    mE                  = (mB*mAinv)^(0.5);
    tDataCov2(:,:,jj)   = mE*tDataCov(:,:,jj)*mE';
    disp(num2str(jj));
end