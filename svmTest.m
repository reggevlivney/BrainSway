%% SVM Test Code
% This code prepares the data for perfoming SVM.
%% Clear
close all;
clear;

%% Run preprocess.m before running this file

%% Extract Classifications from XLS
vDHRS=XlsFile( : ,9 )';
depressionThres = 0.5;
vIsDepressed = vDHRS < depressionThres;
vRemove = ismember(vSubjectIdx,vSubjectsInSession);
vIsDepressed = vIsDepressed(vRemove);
