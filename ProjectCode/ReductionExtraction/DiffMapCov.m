%% This code operates diffusion maps over the mean covariances
load('meanCovs');
tMeanCovEX          = tMeanCov;
vScoreEX            = vScore;
tMeanCovEX(:,:,89)  = []; % Remember to erase this later!
vScoreEX(89,:)      = []; % ditto
[ diffusion_matrix, diffusion_eig_vals , axes] = Diff_map(tMeanCovEX, vScoreEX(:,1).',vScoreEX(:,3).',vAxes);

hlink = linkprop(axes,{'CameraPosition','CameraUpVector'});
rotate3d on