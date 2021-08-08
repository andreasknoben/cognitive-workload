engagement_indices = 1:32

data = EEG.data;
Fs = EEG.srate;

for x = 1:32
    [spectra, freqs] = spectopo(data(x,:,:), 0, Fs, 'winsize', Fs, 'nfft', Fs);

    deltaIdx = find(freqs>1 & freqs<4);
    thetaIdx = find(freqs>4 & freqs<8);
    alphaIdx = find(freqs>8 & freqs<13);
    betaIdx  = find(freqs>13 & freqs<30);
    gammaIdx = find(freqs>30 & freqs<80);

    deltaPower = mean(10.^(spectra(deltaIdx)/10));
    thetaPower = mean(10.^(spectra(thetaIdx)/10));
    alphaPower = mean(10.^(spectra(alphaIdx)/10));
    betaPower  = mean(10.^(spectra(betaIdx)/10));
    gammaPower = mean(10.^(spectra(gammaIdx)/10));
    
    engagement_index = betaPower / (alphaPower + thetaPower);
    engagement_indices(x) = engagement_index;
end

engagement_indices