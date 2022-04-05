import pandas as pd

def import_survey(data_loc, n_subj):
    '''Loads survey data and extracts last N_SUBJ answers.'''

    survey_data = pd.read_csv(data_loc)
    subjects_data = survey_data.iloc[-n_subj:]
    print(f"[INFO] Length of extracted data is {len(subjects_data)}")
    return subjects_data
