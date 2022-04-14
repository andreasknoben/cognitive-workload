# Cognitive Workload with Conceptual Models
This repository contains the code for the research project "Cognitive Workload Associated with Different Conceptual Modelling Approaches". It contains the survey evaluation code (Python) and the code to calculate the EEG engagement index (MATLAB and R). Please refer to the appropriate sections for more information about these.

## EEG Processing
The `eeg-processing` folder contains the code necessary to process the EEG data. This section reviews the functions of each file.

### calc_index.m
The `calc.index.m` script takes the `.mat` files created by `calc_power.m`, in which the powers are stored. It calculates the EEG Engagement Indices for each participant and channel and puts them in the appropriate conditions. The indices are exported to CSV files in the `results` folders.

### calc_power.m
The `calc_power.m` file is a MATLAB script that runs through the processed EEG data from the `processed-data` folder and calculates theta, alpha, and beta frequency band powers. It determines the participant, condition, and model, and then fills a new matrix with the powers for each of these. It does this using the `spectopo()` function from EEGLAB. Finally, it stores these powers into a `.mat` file in the `powers` folder.

### chan_locs.elc
`chan_locs.elc` contains the locations of the channels used in this experiment.

### data_statistics.m
`data_statistics.m` allows to generate basic data statistics from the raw EEG data. At the moment, it extracts the time taken to perform tasks and stores these in the `results` folder.

### preprocess.m
The `preprocess.m` file is a MATLAB script that aims to preprocess the EEG data from the `data` folder and save it in a preprocessed format ready for use. It extracts the time and keyboard presses vectors, which are converted to EEGLAB events, and the actual EEG data and subsequently the 16 channels that are used. It applies a 0.5-60Hz bandpass filter (note: during extraction, the data should have already been filtered this way). Then, temporal rejection is done, after which it then runs ICA, plots the components and asks which to remove. After this removal, the dataset is repackaged and stored in the `processed-data` folder.

### process_filename.m
The `process_filename.m` file is a function that is used by multiple other scripts to extract subject, model, and condition from the filename.

## Statistics

### eeg_stats.R
The `statistical_tests.R` file is an R script that runs on the EEG Engagement Indices. It checks normality for each channel. If the normality assumption is violated, it runs a Mann-Whitney U test to compare the LOEM and HOEM groups. If the normality assumption is not violated, it runs a Welch independent samples t-test. The results are stored in the respective folder for the task in the `results` folder.

## Survey analysis
The `survey-analysis` folder contains the code that allows to check the questions automatically for as much as possible.

### answers
The `answers` subfolder contains the files with the correct answers according to Gemino (1999). These are provided in plain text files.

### extract_questionnaires.py
The `extract_questionnaires.py` script extracts the specified columns from the raw survey data, and extracts: 1) the pre-experiment questionnaire, which collected demographics and pre-experiment ERD and domain knowledge; 2) NASA-TLX for each model; 3) the post-experiment questionnaire asking about the experience the participant had in the experiment. It exports these items to a new CSV file.

### load_data.py
Data loader function: this loads the specified survey data and returns the last _N_ rows of it (where _N_ corresponds to the number of participants).

### task_evaluation.py
The `task_evaluation.py` script allows to evaluate the answers given in the Qualtrics survey as automatic as possible. It loads the survey data file (CSV) and determines the participant's condition. For the yes/no questions, it inserts a 1 if the answer was correct and a 0 if the answer was incorrect. For the cloze test, it inserts a 1 if there is an exact match and leaves the word if not (to check manually for typos or synonyms). The problem-solving questions are left untouched. These results are then output to a new `results.csv` file.

## References
Gemino, A. C. (1999). _Empirical comparisons of system analysis modeling techniques_ (Doctoral dissertation, University of British Columbia).
