import pandas as pd

def import_survey(data_loc, n_subj):
    '''Loads survey data and extracts last N_SUBJ answers.
    
        Parameters:
            data_loc (String): String indicating the location of the raw survey data
            n_subj (int): Integer indicating the number of participants in the study

        Returns:
            subjects_data (pd.DataFrame): Dataframe containing the raw survey data for the actual participants
    '''

    survey_data = pd.read_csv(data_loc)
    subjects_data = survey_data.iloc[-n_subj:]
    print(f"[INFO] Length of extracted data is {len(subjects_data)}")
    return subjects_data

def determine_condition(ptc):
    '''Determines the condition a participant is in.
        - FL_71 -> control; FL_81 -> treatment
        - FL_51|FL_66 -> VB|FE (control)
        - FL_59|FL_75 -> VB|FE (treatment)

        Parameters:
            ptc (pd.DataFrame): Row for a particular participant from the survey data

        Returns:
            condition (str): The condition that the participant is in (control (LOEM) or treatment (HOEM))
            order (list): The order of models that the participant received (FE and VB)
    '''

    condition = ''
    order = []

    if ptc['FL_87_DO'] == 'FL_72':
        condition = 'control'
        if ptc['FL_72_DO'] == 'FL_51|FL_66':
            order = ['VB', 'FE']
        elif ptc['FL_72_DO'] == 'FL_66|FL_51':
            order = ['FE', 'VB']
    elif ptc['FL_87_DO'] == 'FL_81':
        condition = 'treatment'
        if ptc['FL_81_DO'] == 'FL_59|FL_75':
            order = ['VB', 'FE']
        elif ptc['FL_81_DO'] == 'FL_75|FL_59':
            order = ['FE', 'VB']

    return condition, order
