dir_control = 'data/control';
dir_treatment = 'data/treatment';

dir_control_processed = 'processed-data/control';
dir_treatment_processed = 'processed-data/treatment';

first_task_seq = [0 66];
new_task_seq = [69 66];
end_task_seq = [66 69];

process_control = process_dir(dir_control, dir_control_processed);

function processed = process_dir(data_dir, processed_dir)
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    pop_editoptions('option_storedisk', 0);

    chanlocs = struct('labels', { 'fp1' 'fp2' 'f3' 'fz' 'f4' 't7' 'c3' 'cz' 'c4' 't8' 'p3' 'pz' 'p4' 'po7' 'po8' 'oz'});
    EEG_chanlocs = pop_chanedit(chanlocs);

    channels = [1,2,6,7,8,14,15,16,17,18,24,25,26,28,31,32];
    files = {dir(data_dir + "/*.mat").name};

    for file = files
        filepath = strcat(data_dir, "/", file);
        disp(strcat("Loading file ", filepath))
        filedata = load(filepath).y;
        time = filedata(1,:);
        keys = filedata(2,:);
        if size(filedata,1) == 43
            eeg_file = filedata(3:34,:);
            eeg_data = eeg_file(channels,:);
        elseif size(filedata,1) == 27
            eeg_data = filedata(3:18,:);
        end

        EEG = pop_importdata('dataformat','array','data',eeg_data,'srate',250,'setname',file,'chanlocs',EEG_chanlocs);
        data = EEG.data;
        Fs = EEG.srate;

        [ALLEEG EEG CURRENTSET ] = eeg_store(ALLEEG, EEG);

        EEG = pop_eegfilt(EEG, 0.5, 60);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'data-filtered'); % Now CURRENTSET= 2
        EEG = pop_reref( EEG, [], 'refstate',0);

        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1);
        pop_eegplot(EEG, 0);
        pop_topoplot(EEG, 0);
        EEG = pop_subcomp(EEG);
        
    end
    processed = 0;
end