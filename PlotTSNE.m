close all
% clear

addpath('./tSNE_matlab/');

mX = [];
vC = [];
for ii = 1 : 3
    mX = cat(2, mX, randn(50, 100) + ii);
    vC = cat(2, vC, ii*ones(1, 100));
end

figure; TSNE(mX', vC, 3, [], 10);