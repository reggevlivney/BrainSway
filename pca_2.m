%% Clear
close all;
clear;

%% Run preprocess.m before running this file

%% Import data
% subjects=[203,204,206,207,208,210,211,212,213,214,215,226,229,230,231,...
%           232,239,242,244,245,248,249,250];
% Ns=length(subjects);
%D=Ns*300; %Length of input vectors
% mX=zeros(len,num_subj);
% for ii=1:num_subj
%     in=load(strcat(num2str(subjects(ii)),'_2_proc.mat'),'findata'); %Load mat file
%     mX(:,ii)=in.findata;
% end
% clear in ii

%% PCA preprocessing
% Set mean to 0
% mX    = inputdata;
mX    = mData;
vMean = mean(mX, 2);
mX    = mX - vMean;

% % Set variance to 1
% vStd = std(mX, [], 2);
% mX   = mX ./ vStd;

%% Actual PCA
mCov = mX * mX';
% cov_mat=zeros(len);
% for ii=1:num_subj
%     cov_mat=cov_mat+(1/num_subj)*mX(:,ii)*mX(:,ii)';
% end
%%
[V, D] = eig(mCov);
%%
mY = V' * mX;
%%
plot(abs(mY));
%%
%real_data=[23,14,33,24,26,29,31,21,21,25,21,24,27,19,24,27,22,16,22,20,13,20,33];
vRealData=XlsFile(:,3);
scatter(real_data,mY(1,:));

%%
figure; scatter3(mY(1,:), mY(2,:), mY(3,:), 100, vRealData', 'Fill'); colorbar;

%% Kernel PCA
eps=1e2;
K_mat=zeros(Ns);
for ii=1:Ns
    for jj=1:ii
        K_mat(ii,jj)=exp(norm(mX(:,ii)-mX(:,jj))/eps);
        K_mat(jj,ii)=K_mat(ii,jj);
    end
end
one_n=(1/D)*ones(Ns);
K_mat_sft=K_mat-2*one_n*K_mat+one_n*K_mat*one_n;
%% 
[aa,DD]=eig(K_mat_sft);

%%
Ys=zeros(D,Ns);
for jj=1
    for ii=1:Ns
        Ys(jj,ii)=Ys(jj,ii)+aa(jj,ii)*K_mat(jj,ii);
    end
end
scatter(real_data,abs(Ys(1,:)));