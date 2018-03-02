%% Filter EEG
% extraction of freqs by alpha-theta 
signal = double(mX(1,:));

Hd = Theta_filter;

%% Alpha filter

sampleRate  = 1000; % Hz
lowEnd      = 7.5; % Hz
highEnd     = 12.5; % Hz
filterOrder = 2; % Filter order (e.g., 2 for a second-order Butterworth filter). Try other values too
[b, a]      = butter(filterOrder, [lowEnd highEnd]/(sampleRate/2)); % Generate filter coefficients
vAlpha      = filtfilt(b, a, inputData); % Apply filter to data using zero-phase filtering