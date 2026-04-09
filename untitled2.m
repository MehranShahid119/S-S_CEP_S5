%% ---------------------------
% WIFI SIGNAL SIMULATION FOR HELIX ANTENNA
%% ---------------------------

% Assume your helix antenna object is already in the workspace
% e.g., helix_ant

% 1) Simulation parameters
fs = 100e6;          % Sampling frequency (must be >2x bandwidth)
T = 50e-6;           % Total simulation time
t = 0:1/fs:T-1/fs;   % Time vector
N = length(t);

% 2) Baseband Wi-Fi-like signal (simulate 2.4 GHz channel)
f_baseband = 2e6;    % Baseband frequency (2 MHz for demo)
rx = cos(2*pi*f_baseband*t) + 0.5*sin(2*pi*1.5e6*t);  % simple 2-tone signal

% Optional: add noise
rx = rx + 0.1*randn(size(rx));

%% ---------------------------
% 3) DC Offset Removal
%% ---------------------------
rx_dc = rx - mean(rx);

%% ---------------------------
% 4) Optional Bandpass Filter
%% ---------------------------
fc = f_baseband;
bw = 4e6;  % 4 MHz bandwidth

bpFilt = designfilt('bandpassfir', ...
    'StopbandFrequency1', fc - bw*1.5, ...
    'PassbandFrequency1', fc - bw, ...
    'PassbandFrequency2', fc + bw, ...
    'StopbandFrequency2', fc + bw*1.5, ...
    'SampleRate', fs);

rx_filt = filter(bpFilt, rx_dc);

%% ---------------------------
% 5) Amplitude Normalization
%% ---------------------------
rx_norm = rx_filt ./ (max(abs(rx_filt)) + eps);

%% ---------------------------
% 6) FFT Spectrum
%% ---------------------------
FFTsig = fftshift(fft(rx_norm));
freqAxis = linspace(-fs/2, fs/2, N);

figure; 
plot(freqAxis/1e6, abs(FFTsig)/N);  % frequency in MHz
xlabel("Frequency (MHz)");
ylabel("Normalized Magnitude");
title("FFT Spectrum of Simulated Wi-Fi Signal");
grid on;

%% ---------------------------
% 7) Power Spectral Density (Welch)
%% ---------------------------
figure;
pwelch(rx_norm, hamming(2048), 1024, 2048, fs, 'centered');
title("Power Spectral Density of Simulated Wi-Fi Signal");

%% ---------------------------
% 8) Signal Power, Noise Power, SNR
%% ---------------------------
f_signal = [fc-bw/2, fc+bw/2];  % signal band
signalPower = bandpower(rx_norm, fs, f_signal);
totalPower = bandpower(rx_norm, fs, [0 fs/2]);
noisePower = totalPower - signalPower;
SNR = 10*log10(signalPower / noisePower);

fprintf("Estimated SNR = %.2f dB\n", SNR);

%% ---------------------------
% 9) Time-Domain Plot
%% ---------------------------
figure;
plot(t*1e6, rx_norm);  % time in microseconds
xlabel('Time (\mus)');
ylabel('Normalized Amplitude');
title('Time-Domain Wi-Fi Baseband Signal');
grid on;
