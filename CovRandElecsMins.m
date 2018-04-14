%% Clear
close all;
clear;
% clc;

%% Import Data
%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
  dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
%dirPath = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Parameters of data (cut unwanted parts)
vSubjectIdx        = XlsFile(:,1);   
Nelc               = 45;  % Num of electrodes
vPostTime          = 1030:1400;
vSessions          = 5;
vExcludedElcs      = [55];
vElectordeIdx      = sort(datasample(setdiff(1:62,vExcludedElcs),Nelc,...
                       'Replace',false)); % Pick random electrodes
Ns                 = length(vSubjectIdx); %Number of subjects
Npeaks             = 3; %Number of peaks to look for
vSubjectsInSession = vSubjectIdx;

%% Create Cov matricies and Riemann averages
tDataCov            = nan(Npeaks,Nelc,0);
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
        
        vSessionOfCov(end+1)  =   ss;
        vSubjectOfCov(end+1)  =   ii;
        vScore(end+1)         =   XlsFile(ii,ss+1);
        mPostX                =   data(vElectordeIdx,vPostTime,:);
        Nt                    =   size(mPostX, 3);
        
        mPostX                =   permute(mPostX,[2 1 3]);
        mMaxInd               =   nan(Npeaks,Nelc,Nt);
        mMaxInd2              =   nan(Npeaks,Nelc);
        mMaxInd3              =   nan(Npeaks,Nelc);
        Nfiltlength           =   20;
        vFilt                 =   (1/Nfiltlength)*ones(Nfiltlength);
        for ee = 1:Nelc
            for tt = 1:Nt
                vMeasure                 =   abs(mPostX(:,ee,tt));
                vMeasure                 =   imfilter(vMeasure,vFilt);
                [vMaxValAll,vMaxIndAll]  =   findpeaks(vMeasure);
                [~,vOrder]               =   sort(vMaxValAll,'descend');
                vOrder                   =   sort(vOrder(1:Npeaks),'ascend');
                mMaxInd(:,ee,tt)         =   vMaxIndAll(vOrder);
            end
        end
        
        for nn = 1:Npeaks
            for ee = 1:Nelc
               [vHist,vBins]    =   histcounts(mMaxInd(nn,ee,:),'BinWidth',1);
               [Nmax,nMax]      =   max(flip(vHist));
               mMaxInd2(nn,ee)  =   vBins(length(vHist)+1-nMax);
               mMaxInd3(nn,ee)  =   Nmax;
            end
        end
        tDataCov(:,:,end+1)   =   mMaxInd2;
    end
end
disp('Done!');

%% Prepare for Regression Training
tData2 = reshape(tDataCov,[180,23])';
tData2  = [tData2 , vScore'];
