function [ mDiffX] = Diff_map(tDataCov , vSubjects, vScore ,vAxes)
% Runs diffusion maps on the input which is the data vector, in columns as
% a mtrix

mDists = cal_dist_mat(tDataCov);
%%
% Calculating the Kernel for each dimension in the images
eps          = 0.5*std(mDists(:));
mK           = exp(-(mDists.^2)/(2*eps^2));

% Calculating the diagonal matrix D
mD = diag(sum(mK,2));

mM = (mD^-1) * mK;
[mPsi,mLambda] = eig(mM);
[~,I] = sort(diag(mLambda),'descend');
mPsi = mPsi(:,I);
figure;
plot(diag(mLambda));
title("eigen values");
figure;
mDiffX = mM*mPsi;
scatter3(mDiffX(:,1),mDiffX(:,2),mDiffX(:,3),20,mData(:,1))

%% Plotting/Scattering the map after diffusion
%%  Scattering - colored by score
figure();
ax1 = subplot(1,2,1);
grid on;
scatter3(mV(:,vAxes(1)),mV(:,vAxes(2)),mV(:,vAxes(3)),50,vScore,'filled');
    colormap jet;
    colorbar;
    xlabel('\psi_2');
    ylabel('\psi_3');
    zlabel('\psi_4');
    title('Diffusion map - colored by score')
    
%%  Scattering - colored by subject
ax2 = subplot(1,2,2);
grid on;
scatter3(mV(:,vAxes(1)),mV(:,vAxes(2)),mV(:,vAxes(3)),50,vSubjects,'filled');
    colormap jet;
    colorbar;
    xlabel('\psi_2');
    ylabel('\psi_3');
    zlabel('\psi_4');
    title('Diffusion map - colored by subject')

axes = [ax1,ax2];


end

