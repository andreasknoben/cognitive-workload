% Generate some basic data statistics from the raw EEG data

% Set folder variables
dir_control = "data/raw/control";
dir_treatment = "data/raw/treatment";

% Create statistics and write to file
[control_statistics_FE, control_statistics_VB] = generate_statistics(dir_control);
write_to_file(control_statistics_FE, 'results/statistics/data_statistics/control_FE.csv');
write_to_file(control_statistics_VB, 'results/statistics/data_statistics/control_VB.csv');

[treatment_statistics_FE, treatment_statistics_VB] = generate_statistics(dir_treatment);
write_to_file(treatment_statistics_FE, 'results/statistics/data_statistics/treatment_FE.csv');
write_to_file(treatment_statistics_VB, 'results/statistics/data_statistics/treatment_VB.csv');

function [statistics_FE, statistics_VB] = generate_statistics(data_dir)
    % generate_statistics() - Generate some basic data statistics
    %
    % Required inputs:
    %   data_dir    - Directory containing the raw EEG files

    % Generate file list, prepare matrices
    files = dir(data_dir + "/*.mat");
    statistics_FE = zeros(length(files)/4, 5);
    statistics_VB = zeros(length(files)/4, 5);
    Fs = 250;

    % Loop over all files
    cFE = 0;
    cVB = 0;
    for i = 1:length(files)
        % Extract basic file information
        filename = fullfile(data_dir, files(i).name);
        data = load(filename).y;
        disp(strcat("[INFO] Processing ", filename))
        keys = data(2,:);
        
        [subj, cond, mod] = process_filename(files(i).name);
        
        % If the file contains model EEG, extract statistics
        if cond == "model"
            [yesno, open, cloze, total] = extract_model_tasks(keys, subj);

            % Compute druation of tasks
            t_yesno = length(yesno) / Fs;
            t_open = length(open) / Fs;
            t_cloze = length(cloze) / Fs;
            t_total_m = length(total) / Fs;
            t_total_s = t_yesno + t_open + t_cloze;

            % Write times into appropriate matrix
            if mod == "FE"
                cFE = cFE + 1;
                statistics_FE(cFE, 1) = t_yesno;
                statistics_FE(cFE, 2) = t_open;
                statistics_FE(cFE, 3) = t_cloze;
                statistics_FE(cFE, 4) = t_total_m;
                statistics_FE(cFE, 5) = t_total_s;
            elseif mod == "VB"
                cVB = cVB + 1;
                statistics_VB(cVB, 1) = t_yesno;
                statistics_VB(cVB, 2) = t_open;
                statistics_VB(cVB, 3) = t_cloze;
                statistics_VB(cVB, 4) = t_total_m;
                statistics_VB(cVB, 5) = t_total_s;
            end
        end
    end
end

function [yesno, open, cloze, total] = extract_model_tasks(keys, subj)
    % extract_model_tasks() - Extracts the subtasks from the data using
    %                         the keyboard press vector
    % Required inputs:
    %   keys    - The keypress vector
    %   subj    - Number of currently processed subject
    
    % Set up begin/end task sequences, find these beginnings/ends
    end_task_seq = [66 69];
    new_task_seq = [69 66];
    end_task_i = strfind(keys, end_task_seq);
    new_task_i = strfind(keys, new_task_seq);

    % Extract intervals where tasks are being done
    if length(end_task_i) ~= 5 && subj ~= 10
        if length(new_task_i) == 4
            total = keys(:,new_task_i(2):end);
            yesno = keys(:,new_task_i(2):end_task_i(3));
            open = keys(:,new_task_i(3):end_task_i(4));
            cloze = keys(:,new_task_i(4):end);
        elseif length(new_task_i) == 5 && new_task_i(end) == 425574
            total = keys(:,new_task_i(2):end_task_i(5));
            yesno = keys(:,new_task_i(2):end_task_i(3));
            open = keys(:,new_task_i(3):end_task_i(4));
            cloze = keys(:,new_task_i(4):end_task_i(5));
        else
            error("[ERROR] Amount of new task beginnings not equal to 4");
        end
    elseif length(end_task_i) == 5 || subj == 10
        total = keys(:,new_task_i(2):end_task_i(5));
        yesno = keys(:,new_task_i(2):end_task_i(3));
        open = keys(:,new_task_i(3):end_task_i(4));
        cloze = keys(:,new_task_i(4):end_task_i(5));
    else
        error("Amount of task endings not equal to 4 or 5");
    end

    % Final filtering
    total = total(total == 66);
    yesno = yesno(yesno == 66);
    open = open(open == 66);
    cloze = cloze(cloze == 66);
end

function written = write_to_file(data, target)
    % write_to_file()   - Writes data matrix to target file
    %
    % Required inputs:
    %   data    - The data to be written
    %   target  - The target file
    
    col_names = {'yesno', 'open', 'cloze', 'total_extracted', 'total_summed'};
    tbl = array2table(data);
    tbl.Properties.VariableNames(1:5) = col_names;
    writetable(tbl, target);
    written = 1;
end
