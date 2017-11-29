%% Get xls File and data directory
close all
clear

%dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\'; %Or's path
dirPath = 'C:\Users\DELL\Desktop\Data for P4\'; %Reggev's path
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);


%% Preprocess data
vSubjectIdx = XlsFile(:,1);
        
cutoff             = 400; % No point in saving empty frequencies
num_of_elctd       = 10;  % Num of electrodes to use
vElectordeIdx      = randperm(62, num_of_elctd);  % Pick random electrodes
D                  = cutoff * num_of_elctd; %Length of feature vector
Ns                 = length(vSubjectIdx); %Number of subjects
vSubjectsInSession = vSubjectIdx;

mData = nan(D, 0);
for ii = 1 : Ns
% for ii = 1 : 1
    ii 
    subject  = vSubjectIdx(ii);
    fileName = ['LICI_CSD-mat\session 2\', num2str(subject), '_2.mat'];%Get subject's data

    
    if ~(exist([dirPath, fileName], 'file') == 2) %Some subjects don't have data
        vSubjectsInSession(vSubjectsInSession==subject) = [];
        continue;
    end
    load([dirPath, fileName]);
    
    mX      = data;
    mXF     = fft(mX, [], 2);
    mXfAbs  = abs(mXF); %This will cancel time-shift effects
    mXfMean = mean(mXfAbs, 3);
    
    mDatai  = mXfMean(vElectordeIdx,1:cutoff); %Use only some electrodes, cut freqs

%     figure; plot( fftshift(mXfAbs(1:10,:,1)') ); ax(1) = gca;
%     figure; plot( fftshift(mXfMean(1:10,:))' );  ax(2) = gca;
%     linkaxes(ax, 'xy');
    
    mData(:,end+1) = mDatai(:);
    %mData is a matrix, where each column is an example, and each row is a
    %feature
end
clearvars -except D dirPath mData Ns num_of_elctd vSubjectIdx XlsFile...
                  vSubjectsInSession