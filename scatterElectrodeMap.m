function [] = scatterElectrodeMap(vElectrodeHeat)
%scatterElectrodeMap Plots a scatter map of the electrodes with given
%values
%   Insert values of electrode "heat" in vElectrodeHeat. A plot shaped like
%   the brain will show the values on a 3d scatter plot. 
%   NOTE: Make sure chanlocs62.mat is in the working folder!
load chanlocs62.mat chanlocs;
locs=[chanlocs.X;chanlocs.Y;chanlocs.Z];
figure; scatter3(locs(1,:),locs(2,:),locs(3,:),100,vElectrodeHeat,'Fill');
colorbar; 
vElcText = num2str((1:length(vElectrodeHeat))');
text(1.1*locs(1,:),1.1*locs(2,:),1.1*locs(3,:),vElcText);
end

