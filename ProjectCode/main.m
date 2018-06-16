addpath('RiemannianTools');
addpath('CovCalcs');
addpath('ReductionExtraction');
addpath('CovData');
addpath('tSNE');
addpath('Functions');

vAxes = [2,3,4];
%% Calculation of covariance;

% CreateCov;    need to evaluate just once and save
% save('CovData\trialCovs.mat','tDataCov','mDetails','vScore');
load('CovData\trialCovs.mat');

% MeanCovs;     need to evaluate just once and save
% save('CovData\MeanCovs.mat','tMeanCov','mMeanDetails','vScore');
load('CovData\MeanCovs.mat');
vAxes = [2,3,4];
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


% Parallel Transport with given subjects.
tMeanCov = covPT(tMeanCov,mMeanDetails(:,1));
vAxes = [5 3 4];
DiffMapCov;
subplot(1,2,1);
set(gca,'FontSize',18);
title("Diffusion Maps after PT - Colored by Scores");
subplot(1,2,2);
set(gca,'FontSize',18);
title("Diffusion Maps after PT - Colored by Subject");
figure;
scatter3(diffusion_matrix(:,vAxes(1)),diffusion_matrix(:,vAxes(2)),diffusion_matrix(:,vAxes(3)),50,vScore(:,2),'Fill');
title("Diffusion Maps after PT - Colored by Session");

TSNE(diffusion_matrix, vScore(:,2), 3, 91, 5);
title("TSNE after Parallel Transport"); 

mClassPT = [diffusion_matrix, vScore(:,1),vScore(:,2),vScore(:,4)<=0.5]; % matrix for the classification learner

%% Other Procedures
%% ploting covariance matrix;
load('trialCovs');
nSess   =   5;
nSubj   =   2;
nTrial  =   4;
printcov(tDataCov,mDetails,nSubj,nSess,nTrial)

%% Check If a Matrix is Inversible
if( rcond(mat) < 1e-12 )
    disp("This matrix doesn't look Inversible");
else
    disp("You can inverse this!");
end
    
%% Print two random correative  and two non-correlative elctrodes

CreateCor;

%%
cov_id      = randperm(size(tDataCov,3),1);
Nelc        = size(tDataCov,1);
cov         = tDataCov(:,:,cov_id);
[covMin,Imin]    = min(abs(cov(:)));
cov         = cov - eye(Nelc);
[covMax,Imax]    = max(abs(cov(:)));

dirPath             = 'D:\BrainSwayData\';                  %Matan's Path
XlsFile             = xlsread([dirPath, 'clinicalHDRS-2.xlsx']);
vSubjectIdx         = XlsFile(:,1); 
subject             = vSubjectIdx(mDetails(cov_id,1));
ss                  = mDetails(cov_id,2);
hh                  = mDetails(cov_id,3);

        fileName = ['LICI_CSD-mat\session ', num2str(ss) ,'\', num2str(subject),'_', num2str(ss),'.mat']; %Get subject's data    
        if (exist([dirPath, fileName], 'file') == 2) %Some subjects don't have data
            load([dirPath, fileName]);
        end
        
figure;
subplot(2,1,1);
[i,j]       = ind2sub([Nelc,Nelc],Imax);
mX          =   data([i,j],1:2000,hh);
plot(mX.');
tt = title("Signals from Electrodes: " + num2str(i) + " , " + num2str(j));
grid on;
yt = ylabel("Amp");
xt = xlabel("Time [mSec]");
lt = legend(["Electrode " + num2str(i); "Electrode " + num2str(j)]);
tt.FontSize = 18;
xt.FontSize = 16;
yt.FontSize = 16;
lt.FontSize = 14;

subplot(2,1,2);
[i,j]       =   ind2sub([Nelc,Nelc],Imin);
mX          =   data([i,j],1:2000,hh);
plot(mX.');
tt = title("Signals from Electrodes: " + num2str(i) + " , " + num2str(j));
grid on;
yt = ylabel("Amp");
xt = xlabel("Time [mSec]");
lt = legend(["Electrode " + num2str(i); "Electrode " + num2str(j)]);
tt.FontSize = 18;
xt.FontSize = 16;
yt.FontSize = 16;
lt.FontSize = 14;

%% Trying work with the correlation coefficient
CreateCor;
vAxes = [2,3,4];
tDataCov(tDataCov<1e-5) = 0 ;
tDataCov                = 1000*tDataCov;
MeanCovs;
DiffMapCov;
subplot(1,2,1);
set(gca,'FontSize',18);
subplot(1,2,2);
set(gca,'FontSize',18);

% Parallel Transport with given subjects.
tMeanCov = covPT(tMeanCov,mMeanDetails(:,1));
vAxes = [5 3 4];
DiffMapCov;
subplot(1,2,1);
set(gca,'FontSize',18);
title("Diffusion Maps after PT - Colored by Scores");
subplot(1,2,2);
set(gca,'FontSize',18);
title("Diffusion Maps after PT - Colored by Subject");
figure;
scatter3(diffusion_matrix(:,vAxes(1)),diffusion_matrix(:,vAxes(2)),diffusion_matrix(:,vAxes(3)),50,vScore(:,2),'Fill');
title("Diffusion Maps after PT - Colored by Session");

figure;
TSNE([diffusion_matrix,vScoreEX(:,1),vScoreEX(:,2)], vScoreEX(:,4)<0.5, 3, 90, 30);
title("TSNE after Parallel Transport"); 

