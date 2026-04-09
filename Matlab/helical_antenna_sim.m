%% ---------------------------
% FULL SIGNAL ANALYSIS FOR HELIX ANTENNA
%% ---------------------------

% 1) Create or load the antenna object
% Example: helix antenna
helix_ant = helix;  % user-defined helix antenna
% You can adjust properties:
% helix_ant.Turns = 12;
% helix_ant.TurnSpacing = 0.028;
% helix_ant.Radius = 0.02;

% 2) Define simulation parameters
fs = 10e6;             % Sampling frequency (baseband, Hz)
T = 1e-3;              % Total simulation time (seconds)
t = 0:1/fs:T-1/fs;     % Time vector
N = length(t);

% 3) Simulate a received signal (baseband approximation)
f_sig = 2e6;  % 2 MHz signal (baseband) for demo
rx = sin(2*pi*f_sig*t);  % Simulated sinusoidal "received" signal

%% ---------------------------
% 4) DC Offset Removal
%% ---------------------------
rx_dc = rx - mean(rx);

%% ---------------------------
% 5) Optional Bandpass Filter
%% ---------------------------
% Only needed if you want to filter a baseband range
fc = 2e6;   % center frequency in Hz
bw = 1e6;   % bandwidth in Hz

bpFilt = designfilt('bandpassfir', ...
    'StopbandFrequency1', fc - bw*1.5, ...
    'PassbandFrequency1', fc - bw, ...
    'PassbandFrequency2', fc + bw, ...
    'StopbandFrequency2', fc + bw*1.5, ...
    'SampleRate', fs);

rx_filt = filter(bpFilt, rx_dc);

%% ---------------------------
% 6) Amplitude Normalization
%% ---------------------------
rx_norm = rx_filt ./ (max(abs(rx_filt)) + eps);

%% ---------------------------
% 7) FFT Spectrum
%% ---------------------------
FFTsig = fftshift(fft(rx_norm));
freqAxis = linspace(-fs/2, fs/2, N);

figure; 
plot(freqAxis, abs(FFTsig)/N);
xlabel("Frequency (Hz)");
ylabel("Normalized Magnitude");
title("FFT Spectrum of Antenna Signal");
grid on;

%% ---------------------------
% 8) Power Spectral Density (Welch)
%% ---------------------------
figure;
pwelch(rx_norm, hamming(2048), 1024, 2048, fs, 'centered');
title("Power Spectral Density (Welch)");

%% ---------------------------
% 9) Signal Power, Noise Power, SNR
%% ---------------------------
% Signal band
f_signal = [fc-bw/2, fc+bw/2];  % Hz

% Signal power in the band
signalPower = bandpower(rx_norm, fs, f_signal);

% Total power over entire frequency range
totalPower = bandpower(rx_norm, fs, [0 fs/2]);

% Noise power = total - signal
noisePower = totalPower - signalPower;

% SNR in dB
SNR = 10*log10(signalPower / noisePower);

fprintf("Estimated SNR = %.2f dB\n", SNR);


%% ---------------------------
% 10) Time-Domain Plot
%% ---------------------------
figure;
plot(t, rx_norm);
xlabel('Time (s)');
ylabel('Normalized Amplitude');
title('Time-Domain Signal Simulated at Antenna Feed');
grid on;
