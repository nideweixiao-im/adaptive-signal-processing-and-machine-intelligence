clear; close all; init;
%% Initialisation
% sampling frequency
fSample = 1e3;
% sampling time
t = 0: 1 / fSample: (1 - 1 / fSample);
% number of samples
nSamples = length(t);
% white Gaussian noise with power 1
wgn = randn(1, nSamples);
% frequencies of sine waves
freqSine = [80 150];
% noisy sinusoidal signal
noisySine = sin(2 * pi * freqSine(1) * t) + sin(2 * pi * freqSine(2) * t) + randn(1, nSamples);
% filtered WGN
a = 1; b = [1 1];
wgnFilter = filter(b, a, wgn);
% signal set
signal = [wgn; noisySine; wgnFilter];
label = ["white Gaussian noise", "noisy sinusoidal", "filtered white Gaussian noise"];
nSignals = size(signal, 1);
%% Biased and unbiased ACF
acfUnbiased = cell(nSignals, 1);
acfBiased = cell(nSignals, 1);
psdAcfUnbiased = cell(nSignals, 1);
psdAcfBiased = cell(nSignals, 1);
for iSignal = 1: nSignals
    % biased and unbiased autocorrelation
    [acfUnbiased{iSignal}, lag] = xcorr(signal(iSignal, :), 'unbiased');
    acfBiased{iSignal} = xcorr(signal(iSignal, :), 'biased');
    % shift back to original frequency -> FFT -> zero-frequency shift
    psdAcfUnbiased{iSignal} = real(fftshift(fft(ifftshift(acfUnbiased{iSignal}))));
    psdAcfBiased{iSignal} = real(fftshift(fft(ifftshift(acfBiased{iSignal}))));
end
%% ACF plots
for iSignal = 1: nSignals
    figure;
    plot(lag, acfUnbiased{iSignal});
    hold on;
    plot(lag, acfBiased{iSignal});
    grid on; grid minor;
    legend('Unbiased', 'Biased');
    title(sprintf("Correlogram of %s", label(iSignal)));
    xlabel('Lag (sample)');
    ylabel('Autocorrelation function');
end
%% PSD plots
for iSignal = 1: nSignals
    figure;
    plot(lag, psdAcfUnbiased{iSignal});
    hold on;
    plot(lag, psdAcfBiased{iSignal});
    grid on; grid minor;
    legend('Unbiased', 'Biased');
    title(sprintf("ACF spectral estimation of %s", label(iSignal)));
    xlabel('Lag (sample)');
    ylabel('Power spectral density');
end
