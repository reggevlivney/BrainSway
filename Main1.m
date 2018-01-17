close all
clear

addpath('./tSNE_matlab/');

%%
dirPath = 'C:\Users\Oryair\Desktop\Workarea\BrainSway\';
mExcel  = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);

vSubjects     = mExcel(:,1);
idx           = 15;
vSubjects     = vSubjects(idx);
Ns            = length(vSubjects);
mSessionScore = mExcel(idx,2:7);

%%
Covs        = nan(62, 62, 0);
% Covs        = nan(61, 61, 0);
vLabel      = nan(0);
vS          = nan(0);
v           = [];
for ii = 1 : Ns
    ii
    subjectName = vSubjects(ii);
    Covsi       = nan(62, 62, 0);
    for ss = 2 : 5
        fileName = [dirPath, 'LICI_CSD-mat\session ', num2str(ss), '\', num2str(subjectName), '_', num2str(ss), '.mat'];
        try
            load(fileName)
        catch
            continue
        end

        numEpochs = size(data, 3);
        for ee = 1 : numEpochs
%             mX              = data(:,1150:end-50,ee) / 1e3;
            mX              = data(:,:,ee);
%             mX              = mX - mean(mX, 2);
%             mX              = mX ./ std(mX, [], 2);
            mC               = cov(mX'); + 0.01*eye(62);
            [U, V]           = eig(mC);
            V                = diag(max(diag(V), 0.001));
            mC               = U * diag(sqrt(diag(V)));
            mC               = mC * mC';
            v(end+1)         = min(eig(mC));
            Covsi(:,:,end+1) = mC;
            vLabel(end+1)    = mSessionScore(ii,ss);
            vS(end+1)        = ii;
        end
    end
    if ii == 1
        M1   = RiemannianMean(Covsi);
        Covs = Covsi;
    else
        M2 = RiemannianMean(Covsi);
        for cc = 1 : size(Covsi, 3)
            cc
            Covs(:,:,end+1) = SchildLadder(M2, M1, Covsi(:,:,cc));   %-- Schild Ladder
        end
    end
end
figure; plot(v);

%%
mX = CovsToVecs(Covs);

%%
figure; Y2 = TSNE(mX', vLabel, 2, [], 40);

%%
figure; scatter(Y2(:,1), Y2(:,2), 100, vS,     'Fill');
figure; scatter(Y2(:,1), Y2(:,2), 100, vLabel, 'Fill');

%%
% figure; imagesc(mC); colorbar;
% figure; stem(eig(mC));
% figure; plot(mX');
% figure; plot(std(mX, [], 2));