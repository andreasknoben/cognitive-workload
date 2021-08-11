nParts = 60;
nChans = 32;
nTasks = 6;
nPowers = 5 + 1; % +1 for the EEG Engagement Index

EEG_cond1 = zeros(nParts, nTasks, nChans, nPowers);
EEG_cond2 = zeros(nParts, nTasks, nChans, nPowers);

engagement_indices = 1:32;

data = EEG.data;
Fs = EEG.srate;

part = 1
task = 1

for part = 1:nParts
    for chan = 1:nChans
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

        EEG_cond1(part, task, chan, 1) = deltaPower;
        EEG_cond1(part, task, chan, 2) = thetaPower;
        EEG_cond1(part, task, chan, 3) = alphaPower;
        EEG_cond1(part, task, chan, 4) = betaPower;
        EEG_cond1(part, task, chan, 5) = gammaPower;

        engagement_index = betaPower / (alphaPower + thetaPower);
        % engagement_indices(chan) = engagement_index;
        EEG_cond1(part, task, chan, 6) = engagement_index;
    end
end

% engagement_indices