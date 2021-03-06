function y = betaFilter(x)
%DOFILTER Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 9.4 and DSP System Toolbox 9.6.
% Generated on: 29-Jul-2018 01:27:55

%#codegen

% To generate C/C++ code from this function use the codegen command.
% Type 'help codegen' for more information.

persistent Hd;

if isempty(Hd)
    
    % The following code was used to design the filter coefficients:
    %
    % Fstop1 = 14;    % First Stopband Frequency
    % Fpass1 = 16;    % First Passband Frequency
    % Fpass2 = 31;    % Second Passband Frequency
    % Fstop2 = 33;    % Second Stopband Frequency
    % Astop1 = 60;    % First Stopband Attenuation (dB)
    % Apass  = 1;     % Passband Ripple (dB)
    % Astop2 = 80;    % Second Stopband Attenuation (dB)
    % Fs     = 2000;  % Sampling Frequency
    %
    % h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, ...
    %                      Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
    %
    % Hd = design(h, 'ellip', ...
    %     'MatchExactly', 'both', ...
    %     'SystemObject', true);
    
    Hd = dsp.BiquadFilter( ...
        'Structure', 'Direct form II', ...
        'SOSMatrix', [1 -1.98940036536689 1 1 -1.989686529706 ...
        0.999153779219233; 1 -1.99774189488396 1 1 -1.99703525009677 ...
        0.999562370462723; 1 -1.98882265643113 1 1 -1.98792636949359 ...
        0.997007829820079; 1 -1.9978588541065 1 1 -1.9957575499498 ...
        0.99838783010651; 1 -1.98675610419668 1 1 -1.98560050203485 ...
        0.993767381503099; 1 -1.99819373934062 1 1 -1.99335261045747 ...
        0.996270053879091; 1 -1.97592780995294 1 1 -1.9836828693633 ...
        0.990313424617861; 1 -1.99900873923694 1 1 -1.98929131145544 ...
        0.992873178244098; 1 0 -1 1 -1.98492347008935 0.989792724452995], ...
        'ScaleValues', [0.395845850013122; 0.395845850013122; ...
        0.741207431653518; 0.741207431653518; 0.505294334925965; ...
        0.505294334925965; 0.186967696812865; 0.186967696812865; ...
        0.023446032237928; 1]);
end

s = double(x);
y = step(Hd,s);

