% Pre-process EEG data
% Create folder variables
dir_control = "data/control";
dir_treatment = "data/treatment";

dir_control_processed = "processed-data/control";
dir_treatment_processed = "processed-data/treatment";

% process_control = process_dir(dir_control, dir_control_processed);
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

%         % Filter EEG data with bandpass 0.5-60Hz
%         EEG = pop_eegfilt(EEG, 0.5, 60, [], [0]);
%         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'data-filtered'); % Now CURRENTSET= 2
%         EEG = pop_reref( EEG, [], 'refstate',0);

        % Run ICA
        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1);
        pop_eegplot(EEG, 0);
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