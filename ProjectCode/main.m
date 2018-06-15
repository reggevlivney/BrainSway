addpath('RiemannianTools');
addpath('CovCalcs');
addpath('ReductionExtraction');
addpath('CovData');

%% Calculation of covariance;
CreateCov; 
MeanCovs;
DiffMapCov;

%% Variation with FFT of the signals;
CreateFFTCov; 
MeanCovs;
DiffMapCov;
subplot(1,2,1);
title("Diffusion Maps over The FFT Covs - Colored by Scores");
subplot(1,2,2);
title("Diffusion Maps over The FFT Covs - Colored by Subjects");

%% Variation with Baslines signals;


