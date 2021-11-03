new_task_seq = [66 69];
new_task_i = strfind(y(2,:), new_task_seq);
question_task_begin = new_task_i(2);
tasks_data = y(:,new_task_i(2):end);
active_tasks_data = tasks_data(:,tasks_data(2,:) == 66);

% Verification: should be 66
if unique(active_tasks_data(2)) == 66
    disp("Verification check passed")
else
    disp("Error - not all values equal to 66.")
end

channels = [1,2,6,7,8,14,15,16,17,18,24,25,26,28,31,32];
active_tasks_data_eeg = active_tasks_data(3:34,:);
active_tasks_data_eeg_sel = active_tasks_data_eeg(channels,:);