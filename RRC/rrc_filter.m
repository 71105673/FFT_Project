% Created on 2025/07/02 by jihan

clc;

% fixed_mode = 0; % '0' = floating
fixed_mode = 1;   % '1' = fixed

[FileName, PathName] = uigetfile('*.txt', 'select the capture binary file');
[FID, message] = fopen(FileName, 'r');

if (fixed_mode)
    waveform = fscanf(FID, '%d', [1 Inf]);
else
    waveform = fscanf(FID, '%f', [1 Inf]);
end

Iwave = waveform(1, :);

figure;
pwelch(double(Iwave));
