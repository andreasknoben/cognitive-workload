% Pre-process EEG data
% Create folder variables
dir_control = "data/control";
dir_treatment = "data/treatment";

dir_control_processed = "processed-data/control";
dir_treatment_processed = "processed-data/treatment";

process_control = process_dir(dir_control, dir_control_processed);
process_treatment = process_dir(dir_treatment, dir_treatment_processed);

function processed = process_dir(data_dir, processed_dir)
    % process_dir() - Processes the raw EEG data by selecting the correct
    %                 channels, filtering (CURRENTLY NOT), and running ICA
    % Required inputs:
    %   data_dir        - Directory that contains raw EEG data
    %   processed_dir   - Target directory to store processed files

    % Initialise EEGLab
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    pop_editoptions('option_storedisk', 0);

    % Load channel locations
    chanlocs = struct('labels', { 'Fp1' 'Fp2' 'F3' 'Fz' 'F4' 'T7' 'C3' 'Cz' 'C4' 'T8' 'P3' 'Pz' 'P4' 'PO7' 'PO8' 'Oz'});
    EEG_chanlocs = pop_chanedit(chanlocs, 'load', 'chan_locs.elc');

    % Initialise channels, files, begin time variables
    channels = [1,2,6,7,8,14,15,16,17,18,24,25,26,28,31,32];
    files = {dir(data_dir + "/*.mat").name};
    begintime = 10;

    % Loop over files
    for file = files
        % Extract basic file data (name, path, data)
        filename = string(file{1});
        [subj, cond, mod] = process_filename(filename);
        filepath = strcat(data_dir, "/", file);
        disp(strcat("Loading file ", filepath));
        filedata = load(filepath).y;

        % Set up time indices to prepare for removal of first and last 10s
        time = filedata(1,:);
        endtime = time(end) - 10;
        begintime_m = time(find(abs(begintime - time) == min(abs(begintime - time))));
        endtime_m = time(find(abs(endtime - time) == min(abs(endtime - time))));
        begintime_i = find(time == begintime_m);
        endtime_i = find(time == endtime_m);

        % Extract keyboard presses
        keys = filedata(2,:);

        % Extract channels used in experiment
        if size(filedata,1) == 43
            eeg_file = filedata(3:34,:);
            eeg_data = eeg_file(channels,:);
        elseif size(filedata,1) == 27
            eeg_data = filedata(3:18,:);
        end

        % Remove first and last 10 seconds
        eeg_data = eeg_data(:,begintime_i:endtime_i);
        keys = keys(:,begintime_i:endtime_i);
        time = time(:,begintime_i:endtime_i);

        % Load EEG data into EEGLab (into EEG struct)
        EEG = pop_importdata('dataformat','array','data',eeg_data,'srate',250,'setname',file,'chanlocs',EEG_chanlocs);
        [ALLEEG EEG CURRENTSET ] = eeg_store(ALLEEG, EEG);

        % Remove specific channnels
        ch1rej = [21 22 23];
        ch26rej = [48 49 50 51];
        ch32rej = [18 29 30 31 32 33];
        if ismember(subj, ch1rej)
            EEG = pop_select(EEG, 'nochannel', 1);
        elseif ismember(subj, ch26rej)
            EEG = pop_select(EEG, 'nochannel', 13);
        elseif ismember(subj, ch32rej)
            EEG = pop_select(EEG, 'nochannel', 16);
        end

        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'hicutoff', 60);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'data-filtered-rejected');

        % Temporal rejection
        global rej;
        eegplot(EEG.data, 'srate', EEG.srate, 'command','global rej,rej=TMPREJ', 'eloc_file',EEG.chanlocs, 'winlength',10);
        uiwait;
        tmprej = eegplot2event(rej, -1);
        if ~isempty(tmprej)
            [EEG,~] = eeg_eegrej(EEG,tmprej(:,[3 4]));
            
            for iRej = 1:size(tmprej,1)
                rej_start = tmprej(iRej, 3);
                rej_stop = tmprej(iRej, 4);
                if strfind(keys(rej_start:rej_stop),[66 69]) ~= []
                    keys(rej_start-2:rej_start-1) = [66 69];
                end
                if strfind(keys(rej_start:rej_stop),[69 66]) ~= []
                    keys(rej_stop+1:rej_stop+2) = [69 66];
                end
                keys(rej_start:rej_stop) = [];
                time(rej_start:rej_stop) = [];
            end
        end

        if size(EEG.data,2) ~= size(keys,2) || size(EEG.data,2) ~= size(time,2) || size(keys,2) ~= size(time,2)
            error("Dimensions not the same after rejection");
        end

        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'data-filtered-rejected');

        % Run ICA
        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1);
        pop_eegplot(EEG, 0, 'winlength',10);
        pop_topoplot(EEG, 0, 1:16);
        EEG = pop_subcomp(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'data-filtered-icapruned'); % Now CURRENTSET= 2
        EEG = pop_reref( EEG, [], 'refstate',0);

        % Prepare EEG struct for storage
        proc_filename = strcat(processed_dir, "/", filename);
        EEG.timev = time;
        EEG.keyv = keys;

        % Store processed EEG data
        save(proc_filename, 'EEG')
        
    end
    processed = 1;
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