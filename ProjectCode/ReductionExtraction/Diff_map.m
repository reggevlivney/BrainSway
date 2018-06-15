function [ mV, mE , axes] = Diff_map(tDataCov , vSubjects, vScore)
% Runs diffusion maps on the input which is the data vector, in columns as
% a mtrix

mDists = cal_dist_mat(tDataCov);

% Calculating the Kernel for each dimension in the images
eps          = median(mDists(:));
mK           = exp(-(mDists.^2)/(2*eps^2));

% Calculating the diagonal matrix D
mD = diag( sum(mK, 2) );
sparse_mD = sparse(mD);     % Here's where I changed!!

% Calculating A, it's eigenvalues and eigenvectors for the diffusion
mA            = sparse_mD \ mK;     % and here I changed as well!
[mV , mE]     = eig(mA);
eigvec        = mV(:,2:4);

%% Plotting/Scattering the map after diffusion
%  Scattering - colored by score
figure();
ax1 = subplot(1,2,1);
grid on;
scatter3(mV(:,2),mV(:,3),mV(:,4),50,vScore,'filled');
    colormap jet;
    colorbar;
    xlabel('\psi_2');
    ylabel('\psi_3');
    zlabel('\psi_4');
    title('Diffusion map - colored by score')

% Scattering - colored by subject
ax2 = subplot(1,2,2);
grid on;
scatter3(mV(:,2),mV(:,3),mV(:,4),50,vSubjects,'filled');
    colormap jet;
    colorbar;
    xlabel('\psi_2');
    ylabel('\psi_3');
    zlabel('\psi_4');
    title('Diffusion map - colored by subject')

axes = [ax1,ax2];

end

