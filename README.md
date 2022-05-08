# Cognitive Workload with Conceptual Models
This repository contains the code for the research project "Cognitive Workload Associated with Different Conceptual Modelling Approaches". It contains the code to (pre-)process the EEG data (MATLAB), to extract answers from the survey (Python), and code to perform statistical analyses and visualisations on the available data (R). Please refer to the appropriate sections for more information about these.

## EEG Processing
The `eeg-processing` folder contains the code necessary to (pre-)process the EEG data. This section reviews the functions of each file.

### calc_index.m
The `calc.index.m` script takes the `.mat` files created by `calc_power.m`, in which the powers are stored. It calculates the EEG Engagement Indices for each participant and channel and puts them in the appropriate conditions. The indices are exported to CSV files in the `data/indices` folder.

### calc_power.m
The `calc_power.m` file is a MATLAB script that runs through the processed EEG data from the `processed-data` folder and calculates theta, alpha, and beta frequency band powers. It determines the participant, condition, and model, and then fills a new matrix with the powers for each of these. It does this using the `spectopo()` function from EEGLAB. It converts the relative powers output by this function to absolute powers. Finally, it stores these powers into a `.mat` file in the `data/powers` folder.

### chan_locs.elc
`chan_locs.elc` contains the locations of the channels used in this experiment in ASA electrode format (.elc).

### data_statistics.m
`data_statistics.m` allows to generate basic data statistics from the raw EEG data. At the moment, it extracts the time taken to perform tasks and stores these in the `results/statistics/data_statistics` folder.

### preprocess.m
The `preprocess.m` file is a MATLAB script that aims to preprocess the EEG data from the `data/raw` folder and save it in a preprocessed format ready for use. It extracts the time and keyboard presses vectors, which are converted to EEGLAB events, and the actual EEG data and subsequently the 16 channels that are used. It applies a 0.5-60Hz bandpass filter (note: during extraction, the data should have already been filtered this way). Then, temporal rejection is done, after which it then runs ICA, plots the components and asks which to remove. After this removal, the dataset is repackaged and stored in the `data/processed` folder.

### process_filename.m
The `process_filename.m` file is a function that is used by multiple other scripts to extract subject, model, and condition from the filename.

## Statistics
The `statistics` folder contains the code for the statistical analyses and visualisations.

### combine_data.R
The `combine_data.R` file combines the EEG Engagement Indices, task scores, and questionnaire answers into one data file.

### eeg_scores_corr.R
The `eeg_scores_corr.R` file statistically analyses whether there is a correlation between the EEG Engagement Indices and the task scores. It creates multiple linear regression models to test this. Furthermore, it visualises the correlation by creating a scatterplot with a line drawn through it.

### eeg_stats.R
The `statistical_tests.R` file aims to compare the EEG Engagement Indices between the LOEM and HOEM groups. It checks normality for each channel. If the normality assumption is violated, it runs a Mann-Whitney U test to compare the LOEM and HOEM groups. If the normality assumption is not violated, it runs a Welch independent samples t-test. The results are stored in the respective folder for the task in the results folder. Furthermore, it also creates boxplots as a way of visualising the EEG Engagement Indices for each task, model, and channel.

### eeg_subj_corr.R
The `eeg_subj_corr.R` file statistically analyses whether there is a correlation between the EEG Engagement Indices and the NASA-TLX answers. It creates multiple linear regression models to test this. Furthermore, it visualises the correlation by creating a scatterplot with a line drawn through it.

### moderation_analysis.R
The `moderation_analysis.R` file aims to find out whether there is a moderation effect of pre-experiment domain knowledge on the EEG Engagement Indices. It does this by creating multiple linear models and testing for the interaction effect of condition * moderator on the indices.

### recode.R
The `recode.R` recodes the answers given to the questionnaire. It converts a yes-no scale into 1 and 0 (resp.), and also assigns appropriate numbers to the Likert scales present in the survey.

### scores_stats.R
The `scores_stats.R` file aims to compare the task scores between the LOEM and HOEM groups. It checks normality for each channel. If the normality assumption is violated, it runs a Mann-Whitney U test to compare the LOEM and HOEM groups. If the normality assumption is not violated, it runs a Welch independent samples t-test. The results are stored in `survey_analysis/results` folder. Furthermore, boxplots are created to visualise the scores obtained.

### stat_funcs.R
The `stat_funcs.R` file contains a few functions that are used by multiple R files. The `load_eeg()` function loads the EEG files and creates a list of dataframes. The `relative_scores()` function creates relative scores out of the original task scores.

## Survey analysis
The `survey-analysis` folder contains the code that allows to check the questions automatically for as much as possible.

### answers
The `answers` subfolder contains the files with the correct answers according to Gemino (1999). These are provided in plain text files.

### extract_questionnaires.py
The `extract_questionnaires.py` script extracts the specified columns from the raw survey data, and extracts: 1) the pre-experiment questionnaire, which collected demographics and pre-experiment ERD and domain knowledge; 2) NASA-TLX for each model; 3) the post-experiment questionnaire asking about the experience the participant had in the experiment. It exports these items to a new CSV file.

### survey_funcs.py
The `survey_funcs.py` file contains a few functions shared by other files. It contains `import_survey()`, which is a data loader function: this loads the specified survey data and returns the last _N_ rows of it (where _N_ corresponds to the number of participants). Furthermore, it contains the `determine_condition()` function, which returns the condition a participant is in and the order in which they got the models.

### task_evaluation.py
The `task_evaluation.py` script allows to evaluate the answers given in the Qualtrics survey as automatic as possible. It loads the survey data file (CSV) and determines the participant's condition. For the yes/no questions, it inserts a 1 if the answer was correct and a 0 if the answer was incorrect. For the cloze test, it inserts a 1 if there is an exact match and leaves the word if not (to check manually for typos or synonyms). The problem-solving questions are left untouched. These results are then output to a new `task-results.csv` file and a `task-scores.csv` file (which automatically computes scores as much as possible).

## References
Gemino, A. C. (1999). _Empirical comparisons of system analysis modeling techniques_ (Doctoral dissertation, University of British Columbia).
