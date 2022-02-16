% Extract subject number, condition, and model from filename
% as number, string, and string, resp.

function [subj, cond, mod] = process_filename(filename)
    % process_filename() - Process the passed filename to extract subject
    %                      number, condition, and model
    % Required inputs:
    %   filename - The name of the file (format: subjXXX-conditionMOD)

    % Convert filename to string and then to char
    fn_string = string(filename);
    fn_char = char(filename);

    % Extract subject number
    subj_str = extractBetween(fn_string, 5, 7);
    subj = str2num(subj_str);

    % Extract condition
    if fn_char(9) == "b"
        cond = "baseline";
    elseif fn_char(9) == "m"
        cond = "model";
    end

    % Extract model
    if endsWith(fn_string, "FE.mat")
        mod = "FE";
    elseif endsWith(fn_string, "VB.mat")
        mod = "VB";
    end
end