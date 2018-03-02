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
Nelc               = 40;  % Num of electrodes
vSessions          = 5;
vExcludedElcs      = [55];
vElectordeIdx      = sort(datasample(setdiff(1:62,vExcludedElcs),Nelc,...
                       'Replace',false)); % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;


%% Create Cov matricies and Riemann averages
% mData             = nan(D, 0);
tDataCov            = nan(Nelc,Nelc,0);
vScore              = [];
vPowerMean          = nan(Nelc,0);
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
        
        mX          = data(vElectordeIdx,:,:);
        Nt          = size(mX, 3);

        dimSubSpc    = Nelc;
        mXSubSpc     = nan(2*dimSubSpc, 2000, Nt);
        for hh = 1:Nt
            for jj = 1:Nelc
                mXSubSpc(2*jj-1,:,hh)       = alpha(mX(jj,:,hh));
                mXSubSpc(2*jj,:,hh)         = beta(mX(jj,:,hh));
            end 
        end
        tCovXi       = nan(2*dimSubSpc, 2*dimSubSpc, Nt);
        for tt = 1 : Nt
            tCovXi(:,:,tt)  = cov(mXSubSpc(:,:,tt)');
        end
        
        mMeanXi                                         = RiemannianMean(tCovXi);
        tDataCov(1:2*dimSubSpc,1:2*dimSubSpc,end+1)     = mMeanXi;
    end
    tDataCov = tDataCov(1:2*dimSubSpcMin,1:2*dimSubSpcMin,:);
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
mtSNE           = TSNE(mtSNE,vScore>=17,10,23);
