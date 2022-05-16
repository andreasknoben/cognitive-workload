% Calculates EEG Engagement Indices and stores them to CSV files

% Set constants
NPART = 58;     % Number of participants
NCHAN = 16;     % Number of channels
NPOWS = 3;      % Number of powers to be calculated
CHANS = ["Fp1" "Fp2" "F3" "Fz" "F4" "T7" "C3" "Cz" "C4" "T8" "P3" "Pz" "P4" "PO7" "PO8" "Oz"];

result = fill_matrices(NCHAN, NPART, CHANS);
write_to_files(result);

function structure = create_matrices(NPART, NCHAN)
    % create_matrices() - Creates a structure with matrices for all conditions
    % Required inputs:
    %   NPART   - Number of participants
    %   NCHAN   - Number of channels

    control_FE = zeros(NPART/2, NCHAN);
    treatment_FE = zeros(NPART/2, NCHAN);
    control_VB = zeros(NPART/2, NCHAN);
    treatment_VB = zeros(NPART/2, NCHAN);
    structure = struct('control_FE', control_FE, 'treatment_FE', treatment_FE, ...
                       'control_VB', control_VB, 'treatment_VB', treatment_VB);
end

function index = perform_calc(powers)
    % perform_calc  - Calculates EEG Engagement Index for given powers
    %
    % Required inputs:
    %   powers  - Array of theta, alpha, and beta powers (in that order)

    theta = powers(1);
    alpha = powers(2);
    beta = powers(3);

    % Checks whether no powers are negative
    if theta < 0
        error("[ERROR] Theta less than 0");
    end
    if alpha < 0
        error("[ERROR] Alpha less than 0");
    end
    if beta < 0
        error("[ERROR] Beta less than 0");
    end

    % Calculate EEG Engagement Index (Pope et al., 1995)
    index = beta / (alpha + theta);
    if index < 0
        error("[ERROR] EEG Engagement Index less than 0");
    end
end

function corr_index = baseline_correct(baseline, task)
    % baseline_correct()    - Baseline-corrects EEG Engagement Index
    %
    % Required inputs:
    %   baseline    - The baseline EEG Engagement Index
    %   task        - The task EEG Engagement Index

    index_baseline = perform_calc(baseline);
    index_task = perform_calc(task);
    corr_index = index_task - index_baseline;
end

function results = fill_matrices(NCHAN, NPART, CHANS)
    % fill_matrices()   - Fills the matrices with EEG Engagement Indices
    %
    % Required inputs:
    %   NCHAN   - Number of channels
    %   NPART   - Number of participants
    %   CHANS   - EEG channel names

    yesno = create_matrices(NPART, NCHAN);
    open = create_matrices(NPART, NCHAN);
    cloze = create_matrices(NPART, NCHAN);
    total = create_matrices(NPART, NCHAN);

    control_powers = load('data/powers/control.mat');
    treatment_powers = load('data/powers/treatment.mat');

    % Loop over channels
    for iChan = 1:NCHAN
        % Loop over control participants
        for iPart = 1:NPART/2
            % If the powers are NaN (meaning the channel was rejected),
            % insert NaN everywhere.
            % Else, insert EEG Engagement Index.
            if isnan(control_powers.control_baseline_powers_FE(iPart, iChan, :))
                disp(strcat("[INFO] (control) NaN for participant ", num2str(iPart), ", channel ", CHANS(iChan)));

                yesno.control_FE(iPart, iChan) = nan;
                yesno.control_VB(iPart, iChan) = nan;
                open.control_FE(iPart, iChan) = nan;
                open.control_VB(iPart, iChan) = nan;
                cloze.control_FE(iPart, iChan) = nan;
                cloze.control_VB(iPart, iChan) = nan;
                total.control_FE(iPart, iChan) = nan;
                total.control_VB(iPart, iChan) = nan;

                continue
            else
                control_baseline_FE = control_powers.control_baseline_powers_FE(iPart, iChan, :);
                control_baseline_VB = control_powers.control_baseline_powers_VB(iPart, iChan, :);

                yesno.control_FE(iPart, iChan) = baseline_correct(control_baseline_FE, control_powers.control_yesno_powers_FE(iPart, iChan, :));
                yesno.control_VB(iPart, iChan) = baseline_correct(control_baseline_VB, control_powers.control_yesno_powers_VB(iPart, iChan, :));
                open.control_FE(iPart, iChan) = baseline_correct(control_baseline_FE, control_powers.control_open_powers_FE(iPart, iChan, :));
                open.control_VB(iPart, iChan) = baseline_correct(control_baseline_VB, control_powers.control_open_powers_VB(iPart, iChan, :));
                cloze.control_FE(iPart, iChan) = baseline_correct(control_baseline_FE, control_powers.control_cloze_powers_FE(iPart, iChan, :));
                cloze.control_VB(iPart, iChan) = baseline_correct(control_baseline_VB, control_powers.control_cloze_powers_VB(iPart, iChan, :));
                total.control_FE(iPart, iChan) = baseline_correct(control_baseline_FE, control_powers.control_total_powers_FE(iPart, iChan, :));
                total.control_VB(iPart, iChan) = baseline_correct(control_baseline_VB, control_powers.control_total_powers_VB(iPart, iChan, :));
            end
        end

        % Loop over treatment participants
        for iPart = 1:NPART/2
            if isnan(treatment_powers.treatment_baseline_powers_FE(iPart, iChan, :))
                disp(strcat("[INFO] (treatment) NaN for participant ", num2str(iPart), "channel ", CHANS(iChan)));

                yesno.treatment_FE(iPart, iChan) = nan;
                yesno.treatment_VB(iPart, iChan) = nan;
                open.treatment_FE(iPart, iChan) = nan;
                open.treatment_VB(iPart, iChan) = nan;
                cloze.treatment_FE(iPart, iChan) = nan;
                cloze.treatment_VB(iPart, iChan) = nan;
                total.treatment_FE(iPart, iChan) = nan;
                total.treatment_VB(iPart, iChan) = nan;

                continue
            else
                treatment_baseline_FE = treatment_powers.treatment_baseline_powers_FE(iPart, iChan, :);
                treatment_baseline_VB = treatment_powers.treatment_baseline_powers_VB(iPart, iChan, :);

                yesno.treatment_FE(iPart, iChan) = baseline_correct(treatment_baseline_FE, treatment_powers.treatment_yesno_powers_FE(iPart, iChan, :));
                yesno.treatment_VB(iPart, iChan) = baseline_correct(treatment_baseline_VB, treatment_powers.treatment_yesno_powers_VB(iPart, iChan, :));
                open.treatment_FE(iPart, iChan) = baseline_correct(treatment_baseline_FE, treatment_powers.treatment_open_powers_FE(iPart, iChan, :));
                open.treatment_VB(iPart, iChan) = baseline_correct(treatment_baseline_VB, treatment_powers.treatment_open_powers_VB(iPart, iChan, :));
                cloze.treatment_FE(iPart, iChan) = baseline_correct(treatment_baseline_FE, treatment_powers.treatment_cloze_powers_FE(iPart, iChan, :));
                cloze.treatment_VB(iPart, iChan) = baseline_correct(treatment_baseline_VB, treatment_powers.treatment_cloze_powers_VB(iPart, iChan, :));
                total.treatment_FE(iPart, iChan) = baseline_correct(treatment_baseline_FE, treatment_powers.treatment_total_powers_FE(iPart, iChan, :));
                total.treatment_VB(iPart, iChan) = baseline_correct(treatment_baseline_VB, treatment_powers.treatment_total_powers_VB(iPart, iChan, :));
            end
        end
    end
    % Collect results in struct
    results = struct('yesno', yesno, 'open', open, 'cloze', cloze, 'total', total);
end

function written = write_to_files(results)
    % write_to_files()  - Writes results struct to CSV files
    %
    % Required inputs:
    %   results - Struct containing the structs with results for each
    %             condition, i.e.,
    %               results (struct)
    %                |
    %                |--task (struct)
    %                    |
    %                    |-- condition (matrix)

    task_dirs = ["data/indices/yesno/" "data/indices/open/" "data/indices/cloze/" "data/indices/total/"];
    labels = ["control_FE" "treatment_FE" "control_VB" "treatment_VB"];
    col_names = {'Fp1' 'Fp2' 'F3' 'Fz' 'F4' 'T7' 'C3' 'Cz' 'C4' 'T8' 'P3' 'Pz' 'P4' 'PO7' 'PO8' 'Oz'};
    outer = fieldnames(results);
    for i = 1:numel(outer)
        task = results.(outer{i});
        inner = fieldnames(task);
        for j = 1:numel(inner)
            cond = task.(inner{j});
            tbl = array2table(cond);
            tbl.Properties.VariableNames(1:16) = col_names;

            target = strcat(task_dirs(i), "indices_", labels(j), ".csv");
            writetable(tbl, target);
        end
    end
    written = 1;
end
