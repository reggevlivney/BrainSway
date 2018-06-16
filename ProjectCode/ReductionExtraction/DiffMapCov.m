%% This code operates diffusion maps over the mean covariances
load('meanCovs');
tMeanCov(:,:,89) = []; % Remember to erase this later!
vScore(89,:)     = []; % ditto
[ diffusion_matrix, diffusion_eig_vals , axes] = Diff_map(tMeanCov, vScore(:,1).',vScore(:,3).',vAxes);

hlink = linkprop(axes,{'CameraPosition','CameraUpVector'});
rotate3d on