dir_data_control = 'processed-data/control';
dir_data_treatment = 'processed-data/treatment';

result = verify_files(dir_data_control);
result = verify_files(dir_data_treatment);

function result = verify_files(data_dir)
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    files = dir(data_dir + "/*.mat");

    for i = 1:length(files)
        filename = fullfile(data_dir, files(i).name);
        data = load(filename);
        EEG = data.EEG;
        events = EEG.event;

        disp(strcat("Processing ", filename))
        [subj, cond, mod] = process_filename(files(i).name);
        
        if cond == "model"
            begins = [];
            ends = [];
            
            for i = 1:length(EEG.event)
                if EEG.event(i).type == "begin"
                    begins = [begins EEG.event(i).latency];
                elseif EEG.event(i).type == "end"
                    ends = [ends EEG.event(i).latency];
                end
            end
            
            if length(begins) ~= 5
                disp(strcat("5 beginnings expected, found ", num2str(length(begins))));
            elseif length(ends) ~= 5
                disp(strcat("5 endings expected, found ", num2str(length(ends))));
            end
        end
    end
    result = 1;
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