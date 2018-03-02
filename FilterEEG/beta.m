function vBeta = beta(vSignal)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    sampleRate  = 1000; % Hz
    lowEnd      = 16; % Hz
    highEnd     = 31; % Hz
    filterOrder = 5; % Filter order (e.g., 2 for a second-order Butterworth filter). Try other values too
    [b, a]      = butter(filterOrder, [lowEnd highEnd]/(sampleRate/2)); % Generate filter coefficients
    vBeta       = filtfilt(b, a, double(vSignal)); % Apply filter to data using zero-phase filtering
end

