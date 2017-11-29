subjects=[203,204,206,207,208,210,211,212,213,214,215,226,229,230,231,...
          232,239,242,244,245,248,249,250];
cutoff=300; % No point in saving empty frequencies
num_of_elctd=10; % Num of electrodes to use
for ii=subjects
    load(strcat(num2str(ii),'_2.mat')); %Load mat file
    fftdata=fft(data,[],2); %fft on the time component
    fftdata=abs(fftdata); %This will cancel time-shift effects
    fftdata=permute(fftdata,[3,2,1]);
    meandata=mean(fftdata); %Average on all experiments for one electrode
    meandata=permute(meandata,[3,2,1]);
    cutdata=meandata(1:num_of_elctd,1:cutoff);
    findata=cutdata(:); %Straighten to one vector
    save(strcat('processed/',num2str(ii),'_2_proc.mat'),'findata');
end