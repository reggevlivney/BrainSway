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
Nelc               = 1;  % Num of electrodes
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

iiDist              = nan(Ns,length(vSessions));
iiScore             = nan(Ns,length(vSessions));

ffAvg               = nan(Ns,4*length(vSessions)); 

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
        p_data = load([dirPath, fileName]);     % Data with pulse
        disp(['Calculating for subject ' num2str(ii) ' of ' num2str(Ns) ...
            ', session ' num2str(ss)]);
        
        try
            fileName    = ['Exp_EC\mat\Exp_EC_5013', num2str(subject), '_', num2str(ss), '.mat']; %Get subject's data    
            b_data      = load([dirPath, fileName]);     % Data without pulse
        catch 
            try
                            fileName    = ['Exp_EC\mat\Exp_EC_5213', num2str(subject), '_', num2str(ss), '.mat']; %Get subject's data    
                            b_data      = load([dirPath, fileName]);     % Data without pulse
            catch
            % Nothing to do
            end
        end
        
        mBaseX                =     b_data.data(5,10000:23000,:);

        ffAvg(ii,4*(ss-1) - 3)     =     mean(alpha_filter(mBaseX).^2);
        ffAvg(ii,4*(ss-1) - 2)     =     mean(beta_filter(mBaseX).^2);
        ffAvg(ii,4*(ss-1) - 1)     =     mean(theta_filter(mBaseX).^2);
        ffAvg(ii,4*(ss-1))         =     mean(delta_filter(mBaseX).^2);
        
        iiScore(ii,ss-1)   =   XlsFile(ii,ss+1);
        
    end

end
disp('Done!');

%% Calculate Riemannian Distances

mRegii = [ffAvg,iiScore];

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

