close all
clear

dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\';
XlsFile = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);


%%
vSubjectIdx = XlsFile(:,1);
        
cutoff        = 400; % No point in saving empty frequencies
num_of_elctd  = 10;  % Num of electrodes to use
vElectordeIdx = randperm(62, num_of_elctd);  % Num of electrodes to use
D             = cutoff * num_of_elctd;
Ns            = length(vSubjectIdx);

mData = nan(D, 0);
for ii = 1 : Ns
% for ii = 1 : 1
    ii
    subject  = vSubjectIdx(ii);
    fileName = ['LICI_CSD-mat\session 2\', num2str(subject), '_2.mat'];
    
    if ~(exist([dirPath, fileName], 'file') == 2)
        continue;
    end
    load([dirPath, fileName]);
    
    mX      = data;
    mXF     = fft(mX, [], 2);
    mXfAbs  = abs(mXF); %This will cancel time-shift effects
    mXfMean = mean(mXfAbs, 3);
    
    mDatai  = mXfMean(vElectordeIdx,1:cutoff);

%     figure; plot( fftshift(mXfAbs(1:10,:,1)') ); ax(1) = gca;
%     figure; plot( fftshift(mXfMean(1:10,:))' );  ax(2) = gca;
%     linkaxes(ax, 'xy');
    
    mData(:,end+1) = mDatai(:);
%     cutdata = meandata(1:num_of_elctd,1:cutoff);
%     findata=cutdata(:); %Straighten to one vector
%     save(strcat('processed/',num2str(ii),'_2_proc.mat'),'findata');
end