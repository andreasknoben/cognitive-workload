dir_control = "data/control";
dir_treatment = "data/treatment";

statistics = generate_statistics(dir_control);
writematrix(statistics, 'results/data_statistics.csv');

function statistics = generate_statistics(data_dir)
    files = dir(data_dir + "/*.mat");
    statistics = zeros(length(files)/2,4);

    j = 0;
    for i = 1:length(files)
        filename = fullfile(data_dir, files(i).name);
        data = load(filename).y;
        disp(strcat("Processing ", filename))
        keys = data(2,:);
        
        [subj, cond, mod] = process_filename(files(i).name);
        
        if cond == "model"
            j = j + 1;
            [yesno open cloze total] = extract_model_tasks(keys);
            t_yesno = length(yesno) / 250;
            t_open = length(open) / 250;
            t_cloze = length(cloze) / 250;
            t_total = length(total) / 250;

            statistics(j, 1) = t_yesno;
            statistics(j, 2) = t_open;
            statistics(j, 3) = t_cloze;
            statistics(j, 4) = t_total;
        end
    end
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

function [yesno, open, cloze, total] = extract_model_tasks(keys)
    end_task_seq = [66 69];
    new_task_seq = [69 66];
    end_task_i = strfind(keys, end_task_seq);
    new_task_i = strfind(keys, new_task_seq);

    if length(end_task_i) ~= 5
        if length(new_task_i) == 4
            question_tasks = data(:,new_task_i(2):end);
            question_keys = keys(:,new_task_i(2):end);
            total = question_tasks(:,question_keys(1,:) == 66);

            yesno = data(:,new_task_i(2):end_task_i(3));
            open = data(:,new_task_i(3):end_task_i(4));
            cloze = data(:,new_task_i(4):end);
        elseif length(new_task_i) == 5 && new_task_i(end) == 425574
            question_tasks = data(:,new_task_i(2):end_task_i(5));
            question_keys = keys(:,new_task_i(2):end_task_i(5));
            total = question_tasks(:,question_keys(1,:) == 66);

            yesno = data(:,new_task_i(2):end_task_i(3));
            open = data(:,new_task_i(3):end_task_i(4));
            cloze = data(:,new_task_i(4):end_task_i(5));
        else
            error("Amount of new task beginnings not equal to 4");
        end
    elseif length(end_task_i) == 5
        question_keys = keys(:,new_task_i(2):end_task_i(5));
        total = question_keys(question_keys == 66);

        yesno = keys(:,new_task_i(2):end_task_i(3));
        open = keys(:,new_task_i(3):end_task_i(4));
        cloze = keys(:,new_task_i(4):end_task_i(5));
    else
        error("Amount of task endings not equal to 4 or 5");
    end
end