addpath('RiemannianTools');
addpath('CovCalcs');
addpath('ReductionExtraction');
addpath('CovData');
addpath('tSNE');
vAxes = [2,3,4];
%% Calculation of covariance;

% CreateCov;    need to evaluate just once and save
% save('CovData\trialCovs.mat','tDataCov','mDetails','vScore');
load('CovData\trialCovs.mat');

% MeanCovs;     need to evaluate just once and save
% save('CovData\MeanCovs.mat','tMeanCov','mMeanDetails','vScore');
load('CovData\MeanCovs.mat');

DiffMapCov;
subplot(1,2,1);
set(gca,'FontSize',18);
subplot(1,2,2);
set(gca,'FontSize',18);

TSNE(diffusion_matrix, vScore(:,3), 3, 91, 10)
title("tSNE after Diffusion Maps");
mClass = [diffusion_matrix,vScore(:,[1,2]),vScore(:,4)<=0.5];

%% Variation with FFT of the signals;
% CreateFFTCov;   % need to evaluate just once and save
% save('CovData\trialFFTCovs.mat','tDataCov','mDetails','vScore');
load('CovData\trialFFTCovs.mat');

% MeanCovs;       % need to evaluate just once and save
% save('CovData\MeanFFTCovs.mat','tMeanCov','mMeanDetails','vScore');
load('CovData\MeanFFTCovs.mat');

DiffMapCov;
subplot(1,2,1);
title("Diffusion Maps, FFT Covs - Colored by Scores");
set(gca,'FontSize',16);
subplot(1,2,2);
title("Diffusion Maps, FFT Covs - Colored by Subjects");
set(gca,'FontSize',16);

%% Variation with Baselines signals;
% CreateBLCov;   % need to evaluate just once and save
% save('CovData\MeanBLCovs.mat','tMeanCov','mMeanDetails','vScore');
load('CovData\MeanBLCovs.mat');

DiffMapCov;
subplot(1,2,1);
title("Diffusion Maps, Baseline Covs - Colored by Scores");
set(gca,'FontSize',16);
subplot(1,2,2);
title("Diffusion Maps, Baseline Covs - Colored by Subjects");
set(gca,'FontSize',16);

%% Taking the time of the pulse
% vTime = [500:1500] - only the peak region
% CreateSegCov;    %need to evaluate just once and save
% save('CovData\trialSegCovs.mat','tDataCov','mDetails','vScore');
load('CovData\trialSegCovs.mat');

% MeanCovs;     %need to evaluate just once and save
% save('CovData\MeanSegCovs.mat','tMeanCov','mMeanDetails','vScore');
load('CovData\MeanSegCovs.mat');
DiffMapCov;
subplot(1,2,1);
title("Diffusion Maps, Seg Covs - Colored by Scores");
set(gca,'FontSize',16);
subplot(1,2,2);
title("Diffusion Maps, Seg Covs - Colored by Subjects");
set(gca,'FontSize',16);

%% Diffusion maps after Parallel Transport

load('CovData\MeanCovs.mat');
tMeanCov = covPT(tMeanCov,mMeanDetails);
Axes = [1 2 3];
DiffMapCov;
subplot(1,2,1);
set(gca,'FontSize',18);
subplot(1,2,2);
set(gca,'FontSize',18);

TSNE(diffusion_matrix, vScore(:,3), 3, 91, 10)
title("tSNE after Diffusion Maps");
mClass = [diffusion_matrix,vScore(:,[1,2]),vScore(:,4)<=0.5];
