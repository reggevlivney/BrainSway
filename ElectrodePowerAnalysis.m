%%
%We calculated the variance of each electrode.
vPowerMean=abs(vPowerMean);
figure; imagesc(abs(vPowerMean)); colorbar; 
title('The variance of each electrode');
%%
%This will show the variance of each electrode in each subject. As can be
%seen, some electrodes are very strong compared to others, specifically
%electrode 61 of subject 11. Additionally,  for some subjects, all 
%electrodes were less powerful, relatively. It could be better to see 
%the log of the powers:
figure; imagesc(log(vPowerMean)); colorbar;
title('The log of the variance of each electrode');
%%
%We shall calculate the relative power of each electrode compared to others
%in the same subject:
vRelativePower = vPowerMean./mean( vPowerMean, 1 );
figure; imagesc(vRelativePower); colorbar;
title('The relative power of each electrode');
figure; imagesc(log(vRelativePower)); colorbar;
title('The log of the relative power of each electrode');
%%
%And then, to see of some electrodes are more powerful than the others, we
%shall average this on all the subjects.
vElectrodePower=mean( vRelativePower, 2);
%% 
%Let's see a histogram of the electrode powers.
figure; hist(vElectrodePower);
title('Histogram of the relative power of each electrode');
%%
%Lets plot the electrode powers compared to the location in the head, using
%the function we created,scatterElectrodeMap:
vElectordeIdx=1:62;
scatterElectrodeMap(vElectordeIdx,vElectrodePower);
title('Electrode relative power map');