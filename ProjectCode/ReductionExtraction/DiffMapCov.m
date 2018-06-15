%% This code operates diffusion maps over the mean covariances
load('meanCovs');
vScr  = vScore(:,3).';
vSubj = vScore(:,1).';
[ diffusion_matrix, diffusion_eig_vals , axes] = Diff_map(tMeanCov, vScore(:,1).',vScore(:,3).');

hlink = linkprop(axes,{'CameraPosition','CameraUpVector'});
rotate3d on
