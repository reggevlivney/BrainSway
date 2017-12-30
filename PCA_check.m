%% Get xls File and data directory
close all
clear

%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
%dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
dirPath = 'D:\BrainSwayData\'
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

%% Preprocess data
vSubjectIdx = XlsFile(:,1);
        
% cutoff             = 400; % No point in saving empty frequencies
num_of_elctd       = 62;  % Num of electrodes to use
vElectordeIdx      = randperm(62, num_of_elctd);  % Pick random electrodes
% D                  = cutoff * num_of_elctd; %Length of feature vector
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;
vSessions          = [2 3 4 5];
pca_dim            = 2;

% mData = nan(D, 0);

%% Perform PCA (time)
mPCA = nan(num_of_elctd,0);
for ii = 1 : Ns
    ii 
    subject  = vSubjectIdx(ii);
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
    
    mX                      = data(vElectordeIdx,:,:);
    mXMean                  = mean(mX,3);
    [coeff,score,latent]    = pca(mXMean);
    mPCA(:,end+1)           = sum(abs(score(:,1:pca_dim)),2);
    end
end

%% Scatter the principal electrodes
vTimePCAMean    =    mean(mPCA,2);
scatterElectrodeMap(vElectordeIdx,vTimePCAMean);
title('Principal Electrodes - Time analysis');


%% Perform PCA (freq)
mPCAf = nan(num_of_elctd,0); 

for ii = 1 : Ns
    ii 
    subject  = vSubjectIdx(ii);
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
    
    mX                      = data(vElectordeIdx,:,:);
    mXF     = fft(mX, [], 2);
    mXfAbs  = abs(mXF); %This will cancel time-shift effects
    mXfMean = mean(mXfAbs, 3);
    [coeff,score,latent]    = pca(mXfMean);
    mPCAf(:,end+1)          = sum(abs(score(:,1:pca_dim)),2);
    end
end

%% Scatter the principal electrodes
vFreqPCAMean    =    mean(mPCAf,2);
scatterElectrodeMap(vElectordeIdx,vFreqPCAMean);
title('Principal Electrodes - Frequency analysis');

%% Perform PCA - without the peak (time)
mPCA    = nan(num_of_elctd,0);
scores  = zeros(num_of_elctd,pca_dim)
tmin    = 500;
tmax    = 1500;

for ii = 1 : Ns
    ii 
    subject  = vSubjectIdx(ii);
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
    
    mX                      = data(vElectordeIdx,:,:);
    mX                      = mX(:,[1:tmin,tmax:size(mX,2)],:);
    mXMean                  = mean(mX,3);
    [coeff,score,latent]    = pca(mXMean);
    mPCA(:,end+1)           = sum(abs(score(:,1:pca_dim)),2);
    scores                  = scores + abs(score(:,1:pca_dim));
    end
end

%% Scatter the principal electrodes
vTimePCAMean    =    mean(mPCA,2);
scatterElectrodeMap(vElectordeIdx,vTimePCAMean);
title('Principal Electrodes - Time analysis without the peak');
%% Scatter by groups
[~,I]           =    maxk(scores,5);
vGroups         =    zeros(1,num_of_elctd);
for ii = 1:pca_dim
    vGroups(I(:,ii))  =    vGroups(I(:,ii)) + ii;
end
scatterElectrodeMap(vElectordeIdx,vGroups);
title('Principal groups - Time analysis without the peak');