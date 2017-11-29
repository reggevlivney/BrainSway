%% Clear
clear;clc;close all;
%% Import data
subjects=[203,204,206,207,208,210,211,212,213,214,215,226,229,230,231,...
          232,239,242,244,245,248,249,250];
num_subj=length(subjects);
len=10*300; %Length of input vectors
inputdata=zeros(len,num_subj);
for ii=1:num_subj
    in=load(strcat(num2str(subjects(ii)),'_2_proc.mat'),'findata'); %Load mat file
    inputdata(:,ii)=in.findata;
end
clear in ii

%% PCA preprocessing
% Set mean to 0
mean_vec=mean(inputdata,2);
inputdata=inputdata-kron(mean_vec,ones(1,num_subj));
% Set variance to 1
var_vec=mean(inputdata.^2,2);
inputdata=inputdata./kron(sqrt(var_vec),ones(1,num_subj));

%% Actual PCA
cov_mat=zeros(len);
for ii=1:num_subj
    cov_mat=cov_mat+(1/num_subj)*inputdata(:,ii)*inputdata(:,ii)';
end
%%
[V,D]=eig(cov_mat);
%%
y=V'*inputdata;
%%
plot(abs(y));
%%
real_data=[23,14,33,24,26,29,31,21,21,25,21,24,27,19,24,27,22,16,22,20,13,20,33];
scatter(real_data,y(1,:));

%% Kernel PCA
eps=1e2;
K_mat=zeros(num_subj);
for ii=1:num_subj
    for jj=1:ii
        K_mat(ii,jj)=exp(norm(inputdata(:,ii)-inputdata(:,jj))/eps);
        K_mat(jj,ii)=K_mat(ii,jj);
    end
end
one_n=(1/len)*ones(num_subj);
K_mat_sft=K_mat-2*one_n*K_mat+one_n*K_mat*one_n;
%% 
[aa,DD]=eig(K_mat_sft);

%%
Ys=zeros(len,num_subj);
for jj=1
    for ii=1:num_subj
        Ys(jj,ii)=Ys(jj,ii)+aa(jj,ii)*K_mat(jj,ii);
    end
end
scatter(real_data,abs(Ys(1,:)));