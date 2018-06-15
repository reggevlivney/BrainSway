%% This code operates diffusion maps over the mean covariances
load('meanCovs');
vScr  = vScore(:,3).';
vSubj = vScore(:,1).';
[ diffusion_matrix, diffusion_eig_vals , axes] = Diff_map(tMeanCov, vScore(:,1).',vScore(:,3).');

hlink = linkprop(axes,{'CameraPosition','CameraUpVector'});
rotate3d on

reduced_mat = diffusion_matrix(:,2:4);
[~,reduced_mat] = pca(reduced_mat);

figure();
ax21 = subplot(1,2,1);
grid on;
scatter(reduced_mat(:,3),reduced_mat(:,2),50,vScr,'filled');
    colormap jet;
    colorbar;
    xlabel('\psi_1');
    ylabel('\psi_2');
    title('Diffusion map - colored by score')

% Scattering - colored by subject
ax22 = subplot(1,2,2);
grid on;
scatter(reduced_mat(:,3),reduced_mat(:,2),50,vSubj,'filled');
    colormap jet;
    colorbar;
    xlabel('\psi_1');
    ylabel('\psi_2');
    title('Diffusion map - colored by subject')

axes2 = [ax21,ax22];
hlink = linkprop(axes2,{'CameraPosition','CameraUpVector'});
rotate3d on