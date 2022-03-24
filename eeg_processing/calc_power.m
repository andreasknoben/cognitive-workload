% Calculate spectral powers from pre-processed data

% Create folder variables
dir_data_control = 'processed-data/control';
dir_data_treatment = 'processed-data/treatment';
dir_results = 'powers';

% Function calls and saving data
[control_baseline_powers_FE, control_total_powers_FE, control_yesno_powers_FE, control_open_powers_FE, control_cloze_powers_FE, ...
    control_baseline_powers_VB, control_total_powers_VB, control_yesno_powers_VB, control_open_powers_VB, control_cloze_powers_VB] = calc_power_dir(dir_data_control);

save(strcat(dir_results, "/control.mat"), 'control_baseline_powers_FE', 'control_total_powers_FE', 'control_yesno_powers_FE', 'control_open_powers_FE', 'control_cloze_powers_FE', ...
    'control_baseline_powers_VB', 'control_total_powers_VB', 'control_yesno_powers_VB', 'control_open_powers_VB', 'control_cloze_powers_VB')

[treatment_baseline_powers_FE, treatment_total_powers_FE, treatment_yesno_powers_FE, treatment_open_powers_FE, treatment_cloze_powers_FE, ...
    treatment_baseline_powers_VB, treatment_total_powers_VB, treatment_yesno_powers_VB, treatment_open_powers_VB, treatment_cloze_powers_VB] = calc_power_dir(dir_data_treatment);

save(strcat(dir_results, "/treatment.mat"), 'treatment_baseline_powers_FE', 'treatment_total_powers_FE', 'treatment_yesno_powers_FE', 'treatment_open_powers_FE', 'treatment_cloze_powers_FE', ...
    'treatment_baseline_powers_VB', 'treatment_total_powers_VB', 'treatment_yesno_powers_VB', 'treatment_open_powers_VB', 'treatment_cloze_powers_VB')

function [baseline_powers_FE, total_powers_FE, yesno_powers_FE, open_powers_FE, cloze_powers_FE, ...
    baseline_powers_VB, total_powers_VB, yesno_powers_VB, open_powers_VB, cloze_powers_VB] = calc_power_dir(data_dir)
    % calc_power_dir() - Process the pre-processed EEG data to extract
    %                    theta, alpha, and beta powers
    % Required inputs:
    %   data_dir    - Directory containing the preprocessed files

    % Initialise EEGLAB and file/subject variables
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    files = dir(data_dir + "/*.mat");
    n_subj = int8(length(files)/4);

    % Create zeros matrices to store data
    baseline_powers_FE = zeros(n_subj, 16, 3);
    total_powers_FE = zeros(n_subj, 16, 3);
    yesno_powers_FE = zeros(n_subj, 16, 3);
    open_powers_FE = zeros(n_subj, 16, 3);
    cloze_powers_FE = zeros(n_subj, 16, 3);

    baseline_powers_VB = zeros(n_subj, 16, 3);
    total_powers_VB = zeros(n_subj, 16, 3);
    yesno_powers_VB = zeros(n_subj, 16, 3);
    open_powers_VB = zeros(n_subj, 16, 3);
    cloze_powers_VB = zeros(n_subj, 16, 3);

    % Loop over files
    part = 0;
    curr_subj = 0;
    for i = 1:length(files)
        % Extract needed data
        prev_subj = curr_subj;
        filename = fullfile(data_dir, files(i).name);
        data = load(filename);
        EEG = data.EEG;
        EEG_data = EEG.data;
        events = EEG.event;
        srate = EEG.srate;

        disp(strcat("[INFO] Processing ", filename))
        [subj, cond, mod] = process_filename(files(i).name);

        % Reject known bad channels
        ch1rej = [21 22 23];
        ch2rej = [52];
        % ch15rej = [52];
        ch18rej = [51 55];
        ch26rej = [46 47 48 49 50 51];
        ch28rej = [31];
        % ch32rejextra = [23 31]
        ch32rej = [8 11 16 18 28 29 30 32 33];

        if ismember(subj, ch1rej)
            ptc23proc = false;
            if size(EEG_data, 1) == 16
                EEG_data = vertcat(zeros(size(EEG_data(1,:))), EEG_data(2:16,:));
            elseif size(EEG_data, 1) == 15
                EEG_data = vertcat(zeros(size(EEG_data(1,:))), EEG_data(1:15,:));
            elseif size(EEG_data, 1) == 14
                EEG_data = vertcat(zeros(size(EEG_data(1,:))), EEG_data(1:14,:), zeros(size(EEG_data(1,:))));
                ptc23proc = true;
            else
                error(strcat("[ERROR] Something is wrong with the size of the EEG data for", filename));
            end
            if subj == 23 && ptc23proc == false
                EEG_data = vertcat(EEG_data(1:15,:), zeros(size(EEG_data(1,:))));
                ptc23proc = true;
            end
        elseif ismember(subj, ch2rej)
            ptc52proc = false;
            if size(EEG_data, 1) == 16
                EEG_data = vertcat(EEG_data(1,:), zeros(size(EEG_data(1,:))), EEG_data(3:16,:));
            elseif size(EEG_data, 1) == 15
                EEG_data = vertcat(EEG_data(1,:), zeros(size(EEG_data(1,:))), EEG_data(2:15,:));
            elseif size(EEG_data, 1) == 14
                EEG_data = vertcat(EEG_data(1,:), zeros(size(EEG_data(1,:))), EEG_data(2:5,:), zeros(size(EEG_data(1,:))), EEG_data(6:14,:));
                ptc52proc = true;
            else
                error(strcat("[ERROR] Something is wrong with the size of the EEG data for", filename));
            end
            if subj == 52 && ptc52proc == false
                EEG_data = vertcat(EEG_data(1:6,:), zeros(size(EEG_data(1,:))), EEG_data(8:16,:));
                ptc52proc = true;
            end
        elseif ismember(subj, ch18rej)
            if size(EEG_data, 1) == 16
                EEG_data = vertcat(EEG_data(1:9,:), zeros(size(EEG_data(1,:))), EEG_data(11:16,:));
            elseif size(EEG_data, 1) == 15
                EEG_data = vertcat(EEG_data(1:9,:), zeros(size(EEG_data(1,:))), EEG_data(10:15,:));
            else
                error(strcat("[ERROR] Something is wrong with the size of the EEG data for", filename));
            end
        elseif ismember(subj, ch26rej)
            if size(EEG_data, 1) == 16
                EEG_data = vertcat(EEG_data(1:12,:), zeros(size(EEG_data(1,:))), EEG_data(14:16,:));
            elseif size(EEG_data, 1) == 15
                EEG_data = vertcat(EEG_data(1:12,:), zeros(size(EEG_data(1,:))), EEG_data(13:15,:));
            else
                error(strcat("[ERROR] Something is wrong with the size of the EEG data for", filename));
            end
        elseif ismember(subj, ch28rej)
            ptc31proc = false;
            if size(EEG_data, 1) == 16
                EEG_data = vertcat(EEG_data(1:13,:), zeros(size(EEG_data(1,:))), EEG_data(15:16,:));
            elseif size(EEG_data, 1) == 15
                EEG_data = vertcat(EEG_data(1:13,:), zeros(size(EEG_data(1,:))), EEG_data(14:15,:));
            elseif size(EEG_data, 1) == 14
                EEG_data = vertcat(EEG_data(1:13,:), zeros(size(EEG_data(1,:))), EEG_data(14,:), zeros(size(EEG_data(1,:))));
                ptc31proc = true;
            else
                error(strcat("[ERROR] Something is wrong with the size of the EEG data for", filename));
            end
            if subj == 31 && ptc31proc == false
                EEG_data = vertcat(EEG_data(1:15,:), zeros(size(EEG_data(1,:))));
                ptc31proc = true;
            end
        elseif ismember(subj, ch32rej)
            EEG_data = vertcat(EEG_data(1:15,:), zeros(size(EEG_data(1,:))));
        end

        % Check whether the processed data contains 16 channels
        if size(EEG_data, 1) ~= 16
            error("[ERROR] Channel-rejection-processed EEG data does not contain 16 channels");
        end

        % Update participant counter if needed
        curr_subj = subj;
        if curr_subj ~= prev_subj
            part = part + 1;
        end

        % Check condition, loop over channels and assign spectral power
        %   a) NaN if channel is all zero (if bad channel)
        %   b) Band power if channel is good
        if cond == "baseline"
            for chan = 1:16
                all_zero = all(EEG_data(chan,:) == 0);
                if all_zero
                    if mod == "FE"
                        baseline_powers_FE(part,chan,1:3) = NaN;
                    elseif mod == "VB"
                        baseline_powers_VB(part,chan,1:3) = NaN;
                    end
                end
                if ~all_zero
                    [thetaPower, alphaPower, betaPower] = calculate_powers(EEG_data, chan, srate);
                    if mod == "FE"
                        baseline_powers_FE(part, chan, 1) = thetaPower;
                        baseline_powers_FE(part, chan, 2) = alphaPower;
                        baseline_powers_FE(part, chan, 3) = betaPower;
                    elseif mod == "VB"
                        baseline_powers_VB(part, chan, 1) = thetaPower;
                        baseline_powers_VB(part, chan, 2) = alphaPower;
                        baseline_powers_VB(part, chan, 3) = betaPower;
                    end
                end
            end
        elseif cond == "model"
            [yesno, open, cloze, total] = extract_model_tasks(EEG_data, events, subj);
            for chan = 1:16
                all_zero = all(EEG_data(chan,:) == 0);
                if all_zero
                    if mod == "FE"
                        yesno_powers_FE(part,chan,1:3) = NaN;
                        open_powers_FE(part,chan,1:3) = NaN;
                        cloze_powers_FE(part,chan,1:3) = NaN;
                        total_powers_FE(part,chan,1:3) = NaN;
                    elseif mod == "VB"
                        yesno_powers_VB(part,chan,1:3) = NaN;
                        open_powers_VB(part,chan,1:3) = NaN;
                        cloze_powers_VB(part,chan,1:3) = NaN;
                        total_powers_VB(part,chan,1:3) = NaN;
                    end
                end
                if ~all_zero
                    [thetaPower, alphaPower, betaPower] = calculate_powers(yesno, chan, srate);
                    if mod == "FE"
                        yesno_powers_FE(part, chan, 1) = thetaPower;
                        yesno_powers_FE(part, chan, 2) = alphaPower;
                        yesno_powers_FE(part, chan, 3) = betaPower;
                    elseif mod == "VB"
                        yesno_powers_VB(part, chan, 1) = thetaPower;
                        yesno_powers_VB(part, chan, 2) = alphaPower;
                        yesno_powers_VB(part, chan, 3) = betaPower;
                    end
    
                    [thetaPower, alphaPower, betaPower] = calculate_powers(open, chan, srate);
                    if mod == "FE"
                        open_powers_FE(part, chan, 1) = thetaPower;
                        open_powers_FE(part, chan, 2) = alphaPower;
                        open_powers_FE(part, chan, 3) = betaPower;
                    elseif mod == "VB"
                        open_powers_VB(part, chan, 1) = thetaPower;
                        open_powers_VB(part, chan, 2) = alphaPower;
                        open_powers_VB(part, chan, 3) = betaPower;
                    end
    
                    [thetaPower, alphaPower, betaPower] = calculate_powers(cloze, chan, srate);
                    if mod == "FE"
                        cloze_powers_FE(part, chan, 1) = thetaPower;
                        cloze_powers_FE(part, chan, 2) = alphaPower;
                        cloze_powers_FE(part, chan, 3) = betaPower;
                    elseif mod == "VB"
                        cloze_powers_VB(part, chan, 1) = thetaPower;
                        cloze_powers_VB(part, chan, 2) = alphaPower;
                        cloze_powers_VB(part, chan, 3) = betaPower;
                    end
    
                    [thetaPower, alphaPower, betaPower] = calculate_powers(total, chan, srate);
                    if mod == "FE"
                        total_powers_FE(part, chan, 1) = thetaPower;
                        total_powers_FE(part, chan, 2) = alphaPower;
                        total_powers_FE(part, chan, 3) = betaPower;
                    elseif mod == "VB"
                        total_powers_VB(part, chan, 1) = thetaPower;
                        total_powers_VB(part, chan, 2) = alphaPower;
                        total_powers_VB(part, chan, 3) = betaPower;
                    end
                end
            end
        end
    end
end

function [thetaPower, alphaPower, betaPower] = calculate_powers(data, chan, Fs)
    % calculate_powers() - Calculates theta, alpha, and beta band powers
    % Required inputs:
    %   data    - The EEG data
    %   chan    - The channel over which the powers are to be calculated
    %   Fs      - The sampling rate

    [spectra, freqs] = spectopo(data(chan,:), 0, Fs, 'plot', 'off');

    % Frequencies: theta 4-8 Hz; alpha 8-13 Hz; beta 13-30 Hz
    thetaIdx = find(freqs>4 & freqs<8);
    alphaIdx = find(freqs>8 & freqs<13);
    betaIdx  = find(freqs>13 & freqs<30);

    thetaPower = mean(10.^(spectra(thetaIdx)/10));
    alphaPower = mean(10.^(spectra(alphaIdx)/10));
    betaPower  = mean(10.^(spectra(betaIdx)/10));

    % Check: are the powers non-zero?
    if thetaPower < 0
        error("[ERROR] Theta power less than 0")
    end
    if alphaPower < 0
        error("[ERROR] Alpha power less than 0")
    end
    if betaPower < 0
        error("[ERROR] Beta power less than 0")
    end
end

function [yesno, open, cloze, total] = extract_model_tasks(data, events, subj)
    % extract_model_tasks() - Extracts the subtasks from the data using
    %                         EEGLAB events
    % Required inputs:
    %   data    - The EEG data
    %   events  - The EEGLAB events
    %   subj    - The subject number

    begins = [];
    ends = [];

    % Assemble vectors storing the task-begin and task-end latencies
    for i = 1:length(events)
        if events(i).type == "begin"
            begins = [begins events(i).latency];
        elseif events(i).type == "end"
            ends = [ends events(i).latency];
        end
    end
    
    % Construct task EEG data
    if length(begins) ~= 5 && (subj ~= 10 && subj ~= 55)
        error(strcat("[ERROR] 5 beginnings expected, got ", num2str(length(begins))));
    elseif length(ends) ~= 5 && length(ends) ~= 6 && (subj ~= 10 && subj ~= 55)
        error(strcat("[ERROR] 5 or 6 endings expected, got ", num2str(length(ends))));
    elseif length(begins) == 4 && subj == 55
        yesno = data(:,begins(2):ends(2));
        open = data(:,begins(3):ends(3));
        cloze = data(:,begins(4):ends(4));
        total = data(:,[begins(2):ends(2), begins(3):ends(3), begins(4):ends(4)]);
    else
        yesno = data(:,begins(3):ends(3));
        open = data(:,begins(4):ends(4));
        cloze = data(:,begins(5):ends(5));
        total = data(:,[begins(3):ends(3), begins(4):ends(4), begins(5),ends(5)]);
    end
end
