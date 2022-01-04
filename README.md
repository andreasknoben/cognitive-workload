# Cognitive Workload with Conceptual Models
This repository contains the code for the research project "Cognitive Workload Associated with Different Conceptual Modelling Approaches". It contains the survey evaluation code (Python) and the code to calculate the EEG engagement index (MATLAB and Python). Please refer to the appropriate sections for more information about these.

## EEG Processing
The `eeg-processing` folder contains the code necessary to process the EEG data. This section reviews the functions of each file.

### preprocess.m
The `preprocess.m` file is a MATLAB script that aims to preprocess the EEG data from the `data` folder and save it in a preprocessed format ready for use. It extracts the time and keyboard presses vectors and the actual EEG data and subsequently the 16 channels that are used. It applies a 0.5-60Hz bandpass filter (note: during extraction, the data should have already been filtered this way). It then runs ICA, plots the components and asks which to remove. After this removal, the dataset is repackaged and stored in the `processed-data` folder.

### chan_locs.elc
`chan_locs.elc` contains the locations of the channels used in this experiment.

## Question Evaluation
The `question-evaluation` folder contains the code that allows to check the questions automatically for as much as possible.

### answers
The `answers` subfolder contains the files with the correct answers according to Gemino (1999). These are provided in plain text files.

### evaluation.ipynb
The `evaluation.py` script allows to evaluate the answers given in the Qualtrics survey as automatic as possible. It loads the survey data file (CSV) and determines the participant's condition. For the yes/no questions, it inserts a 1 if the answer was correct and a 0 if the answer was incorrect. For the cloze test, it inserts a 1 if there is an exact match and leaves the word if not (to check manually for typos or synonyms). The problem-solving questions are left untouched. These results are then output to a new `results.csv` file.

## References
Gemino, A. C. (1999). _Empirical comparisons of system analysis modeling techniques_ (Doctoral dissertation, University of British Columbia).
