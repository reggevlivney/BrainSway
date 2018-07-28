function [ mDiffX] = diff_maps(mDists,vScore)
% Runs diffusion maps on the input which is the data vector, in columns as
% a mtrix
% Calculating the Kernel for each dimension in the images
eps          = std(mDists(:));
mK           = exp(-(mDists.^2)/(2*eps^2));
mK           = mK;
% Calculating the diagonal matrix D
mD = diag(sum(mK,2));

mM = mK / mD;
[mPsi,mLambda] = eig(mM,'nobalance');
[~,I] = sort(diag(mLambda),'descend');
mPsi = mPsi(:,I);
figure;
lambda = diag(mLambda);
lambda = lambda(I);
plot(lambda);
title("Eigenvalues");
mDiffX = real(mPsi*diag(lambda));
end

