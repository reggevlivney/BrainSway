%% This code operates diffusion maps over the mean covariances
[ diffusion_matrix, diffusion_eig_vals , axes] = Diff_map(tMeanCov, vScore(:,1).',vScore(:,3).');

hlink = linkprop(axes,{'CameraPosition','CameraUpVector'});
rotate3d on