%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
%   dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Parameters of data (cut unwanted parts)
vSubjectIdx        = XlsFile(:,1);   
Nelc               = 10;  % Num of electrodes
vBaseTime          = [1:500,1501:2000];
vPeakTime          = 501:1500;
vSessions          = 2:5;
vExcludedElcs      = [55];
vElectordeIdx      = sort(datasample(setdiff(1:62,vExcludedElcs),Nelc,...
                       'Replace',false)); % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;


%% Create Cov matricies and Riemann averages
% mData             = nan(D, 0);
tPeakCov            = nan(Nelc,Nelc,0);
tBaseCov            = nan(Nelc,Nelc,0);

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
        
        vSessionOfCov(end+1)  =     ss;
        vSubjectOfCov(end+1)  =     ii;
        vScore(end+1)         =     XlsFile(ii,ss+1);
        mPeakX                =     data(vElectordeIdx,vPeakTime,:);
        mBaseX                =     data(vElectordeIdx,vBaseTime,:);
        Nt                    =     size(mPeakX, 3);

        dimSubSpc        = Nelc;
        tPeakCovXi       = nan(dimSubSpc, dimSubSpc, Nt);
        tBaseCovXi       = nan(dimSubSpc, dimSubSpc, Nt);

%         for tt = 1:Nt
%             tPeakCov(1:dimSubSpc,1:dimSubSpc,end+1)   = cov(mPeakX(:,:,tt)');
%             tBaseCov(1:dimSubSpc,1:dimSubSpc,end+1)   = cov(mBaseX(:,:,tt)');
%             vScore(end+1)                             = XlsFile(ii,ss+1);
%         end

       
        for tt = 1 : Nt
            tPeakCovXi(:,:,tt)  = cov(mPeakX(:,:,tt)');
            tBaseCovXi(:,:,tt)  = cov(mBaseX(:,:,tt)');
        end
        
        mPeakMeanXi             = RiemannianMean(tPeakCovXi);
        mBaseMeanXi             = RiemannianMean(tBaseCovXi);        
        tPeakCov(1:dimSubSpc,1:dimSubSpc,end+1)   = mPeakMeanXi;
        tBaseCov(1:dimSubSpc,1:dimSubSpc,end+1)   = mBaseMeanXi;
        
    end
    tPeakCov = tPeakCov(1:dimSubSpcMin,1:dimSubSpcMin,:);
    tBaseCov = tBaseCov(1:dimSubSpcMin,1:dimSubSpcMin,:);

end
disp('Done!');

%% Calculate Riemannian Distances
n           =   size(tBaseCov,3);
% zeroCov     =   eye(Nelc);
vDist       =   nan(1,23);
% vBase       =   nan(1,23);
% vPeak       =   nan(1,23);

for ii = 1:n
    vDist(ii)    =   RiemannianDist(tPeakCov(:,:,ii),tBaseCov(:,:,ii));
%     vBase(ii)    =   RiemannianDist(zeroCov,tBaseCov(:,:,ii));
%     vPeak(ii)    =   RiemannianDist(zeroCov,tPeakCov(:,:,ii));
end

mReg = [vDist;vScore];

 %% Make Diffusion Map and Parallel Transport calculations
% %%% Create W distances matrix. Make sure to use only one session!
% Nmats   =   size(tPeakCov,3);
% mDists  =   zeros(Nmats,Nmats);
% for ii = 1:Nmats
%     for jj = ii+1:Nmats
%         mDists(ii,jj) = RiemannianDist(tPeakCov(:,:,ii),tPeakCov(:,:,jj));
%         mDists(jj,ii) = mDists(ii,jj);
%     end
% end
% eDiff        = mean(mDists(mDists~=0));
% mDistsDiff   = exp(-mDists.^2/eDiff^2);
% 
% [mVDiff,mDDiff] = eig(mDistsDiff);
% 
% mtSNE           = mVDiff*mDDiff;
% mtSNE           = TSNE(mtSNE,vScore,10,Nmats);
