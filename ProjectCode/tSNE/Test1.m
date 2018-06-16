close all;
clear;

N  = 500;
d  = 3;
X1 = randn(3, N) + 3;
X2 = randn(3, N) - 3;

mX      = [X1, X2];
vLabels = [zeros(N, 1); ones(N, 1)];

mW  = squareform( pdist(mX') );
eps = 1 * median(mW(:));
mK  = exp(-mW.^2 / eps^2);
mA  = mK ./ sum(mK, 2);

% figure; scatter3(mX(1,:), mX(3,:), mPhi(4,:), 100, vLabels, 'Fill'); colorbar;

%%
[mPhi, mLam] = eig(mA);
mPhi         = real(mPhi);
mLam         = real(mLam);
%%
figure; scatter3(mPhi(:,2), mPhi(:,3), mPhi(:,4), 100, vLabels, 'Fill'); colorbar;

%%
figure;
mD           = mPhi * mLam.^20;
% mD = mPhi;
mY = TSNE(mD, vLabels, 3, [], 15);