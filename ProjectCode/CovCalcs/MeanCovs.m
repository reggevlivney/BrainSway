%% Clear
close all;
clear;
% clc;

%% Import Data
load('features.mat');

%% Calculates Rimannian Means of Cov matricies and take scores
Nelc                = size(tDataCov,1);
tMeanCov            = nan(Nelc,Nelc,0);
mMeanDetails        = nan(0,2);
vSubj               = unique(vScore(:,1));
vSess               = unique(vScore(:,2));

for ii = vSubj.'
    for ss = vSess.'
        idx                      = (mDetails(:,1) == ii) & (mDetails(:,2) == ss);
        if sum(idx)==0
            disp("not exists");
            continue;
        end
        mMeanDetails(end+1,:)    = [ii,ss];
        tMeanCov(:,:,end+1)      = RiemannianMean(tDataCov(:,:,idx));
        disp("Calculates Riemannian Mean for subject " + num2str(ii) + " in session " + num2str(ss));
    end
end
disp('Done!');


save('meanCovs.mat','tMeanCov','mMeanDetails','vScore');
