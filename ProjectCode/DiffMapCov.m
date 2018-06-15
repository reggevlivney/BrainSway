%% This code operates diffusion maps over the mean covariances
load('meanCovs');
dat_lengths = [2,4,6,8,10];
[ diffusion_matrix, diffusion_eig_vals ] = Diff_map(tMeanCov, dat_lengths, vScore(:,1).',vScore(:,3).');