dir_data_control = 'processed-data/control';
dir_data_treatment = 'processed-data/treatment';

% result = verify_files(dir_data_control);
result = verify_files(dir_data_treatment);

function result = verify_files(data_dir)
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    files = dir(data_dir + "/*.mat");

    for i = 1:length(files)
        filename = fullfile(data_dir, files(i).name);
        data = load(filename);
        EEG = data.EEG;

        eegplot(EEG.data, 'srate', EEG.srate, 'eloc_file', EEG.chanlocs, 'winlength', 10, 'events', EEG.event);
        uiwait
    end
    result = 1;
end