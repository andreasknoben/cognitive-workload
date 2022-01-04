dir_data_control = 'processed-data/control';
dir_data_treatment = 'processed-data/treatment';
dir_results = 'powers';

[control_baseline_powers_FE, control_total_powers_FE, control_yesno_powers_FE, control_open_powers_FE, control_cloze_powers_FE, ...
    control_baseline_powers_VB, control_total_powers_VB, control_yesno_powers_VB, control_open_powers_VB, control_cloze_powers_VB] = calc_power_dir(dir_data_control);
[treatment_baseline_powers_FE, treatment_total_powers_FE, treatment_yesno_powers_FE, treatment_open_powers_FE, treatment_cloze_powers_FE, ...
    treatment_baseline_powers_VB, treatment_total_powers_VB, treatment_yesno_powers_VB, treatment_open_powers_VB, treatment_cloze_powers_VB] = calc_power_dir(dir_data_treatment);

save(strcat(dir_results, "/control.mat"), 'control_baseline_powers_FE', 'control_total_powers_FE', 'control_yesno_powers_FE', 'control_open_powers_FE', 'control_cloze_powers_FE', ...
    'control_baseline_powers_VB', 'control_total_powers_VB', 'control_yesno_powers_VB', 'control_open_powers_VB', 'control_cloze_powers_VB')

save(strcat(dir_results, "/treatment.mat"), 'treatment_baseline_powers_FE', 'treatment_total_powers_FE', 'treatment_yesno_powers_FE', 'treatment_open_powers_FE', 'treatment_cloze_powers_FE', ...
    'treatment_baseline_powers_VB', 'treatment_total_powers_VB', 'treatment_yesno_powers_VB', 'treatment_open_powers_VB', 'treatment_cloze_powers_VB')

function [baseline_powers_FE, total_powers_FE, yesno_powers_FE, open_powers_FE, cloze_powers_FE, ...
    baseline_powers_VB, total_powers_VB, yesno_powers_VB, open_powers_VB, cloze_powers_VB] = calc_power_dir(data_dir)
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    files = dir(data_dir + "/*.mat");
    n_subj = int8(length(files)/4);
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

    part = 0;
    for i = 1:length(files)
        part = part + 1;
        filename = fullfile(data_dir, files(i).name);
        data = load(filename);
        EEG = data.EEG;
        time = EEG.timev;
        keys = EEG.keyv;
        EEG_data = EEG.data;
        srate = EEG.srate;
        nChans = EEG.nbchan;

        [subj, cond, mod] = process_filename(files(i).name);

        if cond == "baseline"
            for chan = 1:nChans
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
        elseif cond == "model"
            [yesno, open, cloze, total] = extract_model_tasks(EEG_data, keys);
            for chan = 1:nChans
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
    powers = 1;
end

function [subj, cond, mod] = process_filename(filename)
    fn_string = string(filename);
    fn_char = char(filename);

    subj_str = extractBetween(fn_string,5,7);
    subj = str2num(subj_str);

    if fn_char(9) == "b"
        cond = "baseline";
    elseif fn_char(9) == "m"
        cond = "model";
    end

    if endsWith(fn_string, "FE.mat")
        mod = "FE";
    elseif endsWith(fn_string, "VB.mat")
        mod = "VB";
    end
end

function [thetaPower, alphaPower, betaPower] = calculate_powers(data, chan, Fs)
    [spectra, freqs] = spectopo(data(chan,:,:), 0, Fs, 'winsize', Fs, 'nfft', Fs);

     thetaIdx = find(freqs>4 & freqs<8);
     alphaIdx = find(freqs>8 & freqs<13);
     betaIdx  = find(freqs>13 & freqs<30);

     thetaPower = mean(10.^(spectra(thetaIdx)/10));
     alphaPower = mean(10.^(spectra(alphaIdx)/10));
     betaPower  = mean(10.^(spectra(betaIdx)/10));
end

function [yesno, open, cloze, total] = extract_model_tasks(data, keys)
    end_task_seq = [66 69];
    new_task_seq = [69 66];
    end_task_i = strfind(keys, end_task_seq);
    new_task_i = strfind(keys, new_task_seq);
    
    question_tasks = data(:,new_task_i(2):end_task_i(5));
    total = question_tasks(:,keys == 66);

    yesno = data(:,new_task_i(2):end_task_i(3));
    open = data(:,new_task_i(3):end_task_i(4));
    cloze = data(:,new_task_i(4):end_task_i(5));
end