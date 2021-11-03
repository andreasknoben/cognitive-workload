% Initialise numbers for matrices
nParts = 12;
nConds = 2;
nChans = 16;
% nTasks = 6;
nPowers = 5 + 1; % +1 for the EEG Engagement Index

% EEG matrices to store powers and index
disp("EEG matrices are now created")
EEG_baseline_control = zeros(nParts, nConds, nChans, nPowers);
EEG_baseline_exp = zeros(nParts, nConds, nChans, nPowers);
EEG_model_control = zeros(nParts, nConds, nChans, nPowers);
EEG_model_exp = zeros(nParts, nConds, nChans, nPowers);

% Folder declaration
dir_baseline_control = '/home/andreasknoben/Projects/Cognitive Workload/processed-data/baseline-control';
dir_baseline_exp = '/home/andreasknoben/Projects/Cognitive Workload/processed-data/baseline-exp';
dir_model_control = '/home/andreasknoben/Projects/Cognitive Workload/processed-data/model-control';
dir_model_exp = '/home/andreasknoben/Projects/Cognitive Workload/processed-data/model-exp';

% Loading files in the folder that end with .set
files_baseline_control = dir(dir_baseline_control + "/*.set");
files_baseline_exp = dir(dir_baseline_exp + "/*.set");
files_model_control = dir(dir_model_control + "/*.set");
files_model_exp = dir(dir_model_exp + "/*.set");

% Creating lists with file names
files_baseline_control = {files_baseline_control.name};
files_baseline_exp = {files_baseline_exp.name};
files_model_control = {files_model_control.name};
files_model_exp = {files_model_exp.name};

% Fill matrices with data
EEG_baseline_control = calc_EEG_matrix(EEG_baseline_control, dir_baseline_control, files_baseline_control);
EEG_baseline_exp = calc_EEG_matrix(EEG_baseline_exp, dir_baseline_exp, files_baseline_exp);
EEG_model_control = calc_EEG_matrix(EEG_model_control, dir_model_control, files_model_control);
EEG_model_exp = calc_EEG_matrix(EEG_model_exp, dir_model_exp, files_model_exp);

% Save variables in .mat files
save('EEG-baseline-control.mat', 'EEG_baseline_control');
save('EEG-baseline-treatment.mat', 'EEG_baseline_exp');
save('EEG-model-control.mat', 'EEG_model_control');
save('EEG-model-treatment.mat', 'EEG_model_exp');

% Function to calculate powers and engagement index
function matrix = calc_EEG_matrix(matrix, dir, files)
    % Initialise numbers for matrices
    nParts = 12;
    nConds = 2;
    nChans = 16;
    % nTasks = 6;
    nPowers = 5 + 1; % +1 for the EEG Engagement Index

    % Initialise EEGLAB
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    pop_editoptions('option_storedisk', 0);
    
    % Set initial condition counter to 2
    curr_cond = 2;
    
    % Loop over all files in directory
    for file = files
        % Extract participant number from file name
        file_str = string(file{1});
        part_str = extractBetween(file_str,5,7);
        part = str2num(part_str);
    
        % Set condition number
        if curr_cond == 2
            curr_cond = 1;
        else
            curr_cond = 2;
        end

        % Load dataset in EEGLAB
        EEG = pop_loadset('filepath', dir, 'filename', file);
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);

        % Set EEG variables
        data = EEG.data;
        Fs = EEG.srate;

        % Loop over participants
        for chan = 1:nChans
            [spectra, freqs] = spectopo(data(chan,:,:), 0, Fs, 'winsize', Fs, 'nfft', Fs);

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

            matrix(part, curr_cond, chan, 1) = deltaPower;
            matrix(part, curr_cond, chan, 2) = thetaPower;
            matrix(part, curr_cond, chan, 3) = alphaPower;
            matrix(part, curr_cond, chan, 4) = betaPower;
            matrix(part, curr_cond, chan, 5) = gammaPower;

            engagement_index = betaPower / (alphaPower + thetaPower);
            matrix(part, curr_cond, chan, 6) = engagement_index;
        end
    end
end
