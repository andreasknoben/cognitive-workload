import pandas as pd
import numpy as np
from survey_funcs import import_survey, determine_condition

N_SUBJ = 58
DATA_LOC = 'survey_data.csv'
pd.options.display.max_colwidth = 10000

def generate_cols(input_df, type, *cols):
    '''
    Generator function that extracts the specified columns from the raw survey data

        Parameters:
            input_df (pd.DataFrame): pandas dataframe containing the raw survey data
            type (object): The type of the information in the specified columns
            cols (str): The name(s) of the columns to be extracted from the raw survey data
    '''
    for col in cols:
        if type == str:
            yield input_df[col].astype(str).to_numpy()
        elif type == int:
            yield input_df[col].astype(int).to_numpy()
        else:
            TypeError("[ERROR] Passed an unsupported type")

def save_cols(target_df, g, *colnames):
    '''
    Inserts the specified columns into the target dataframe with specified column names.

        Parameters:
            target_df (pd.DataFrame): pandas dataframe into which the extracted columns are stored
            g (generator): generator associated with the specified columns
            colnames (str): The name(s) of the columns in the target dataframe

        Returns:
            target_df (pd.DataFrame): The updated target pandas dataframe
    '''
    for i in range(len(colnames)):
        target_df[colnames[i]] = g.__next__()
    return target_df

def process_nasatlx(df):
    '''
    Processes the NASA-TLX columns and creates a new dataframe with the data. It handles the missing data.

        Parameters:
            df (pd.DataFrame): pandas dataframe with the original data

        Returns:
            nasatlx (pd.DataFrame): pandas dataframe with the NASA-TLX data
    '''
    nasatlx_colnames = ["fe.nasatlx.1", "fe.nasatlx.2", "fe.nasatlx.3", "fe.nasatlx.4", "fe.nasatlx.5", "vb.nasatlx.1", "vb.nasatlx.2", "vb.nasatlx.3", "vb.nasatlx.4", "vb.nasatlx.5"]
    nasatlx = pd.DataFrame(columns = nasatlx_colnames)

    nasatlx_1_cols = ['Q107_4', 'Q117_4', 'Q108_1', 'Q109_1', 'Q110_4']
    nasatlx_2_cols = ['Q95_1',  'Q96_1',  'Q97_1',  'Q98_1',  'Q99_1']

    for i in df.index:
        part = i - 23
        cond, order = determine_condition(df.loc[i])
        if cond == "control":
            if order[1] == "FE":
                nasatlx.loc[part, nasatlx_colnames[:5]] = df.loc[i, nasatlx_1_cols].astype(int).to_numpy()
                nasatlx.loc[part, nasatlx_colnames[5:]] = [np.nan] * 5
            elif order[1] == "VB":
                nasatlx.loc[part, nasatlx_colnames[:5]] = [np.nan] * 5
                nasatlx.loc[part, nasatlx_colnames[5:]] = df.loc[i, nasatlx_1_cols].astype(int).to_numpy()
        elif cond == "treatment":
            nasatlx.loc[part, nasatlx_colnames[:5]] = df.loc[i, nasatlx_1_cols].astype(int).to_numpy()
            nasatlx.loc[part, nasatlx_colnames[5:]] = df.loc[i, nasatlx_2_cols].astype(int).to_numpy()

    return nasatlx

def write_output(data):
    '''
    Creates the output dataframe using the appropriate function calls and writes it to questionnaire-answers.csv

        Parameters:
            data (pd.DataFrame): The raw survey data
    '''
    output = pd.DataFrame()

    output = save_cols(output, generate_cols(data, int, 'Q113'), 'age')
    output = save_cols(output, generate_cols(data, str, 'Q114'), 'gender')
    output = save_cols(output, generate_cols(data, str, 'ERK', 'DBK'), 'erd.exp', 'db.exp')
    output = save_cols(output, generate_cols(data, str, 'BTK', 'BTK_1', 'BTK_2', 'BTK_3', 'BTK_4', 'BTK_5'), 
                                                        'BTK.1', 'BTK.2', 'BTK.3', 'BTK.4', 'BTK.5', 'BTK.6')
    output = save_cols(output, generate_cols(data, str, 'RFK', 'RPK_1', 'RPK_2', 'RPK_3', 'RPK_4', 'RPK_5'),
                                                        'RFK.1', 'RFK.2', 'RFK.3', 'RFK.4', 'RFK.5', 'RFK.6')
    output = save_cols(output, generate_cols(data, str, 'Understand1', 'Understand2', 'Use1', 'Use2R', 'Load1', 'ENG1', 'ENG2', 'ENG3'),
                        'understand.1', 'understand.2', 'use.1', 'use.2', 'load', 'eng.1', 'eng.2', 'eng.3')
    output = pd.concat([output, process_nasatlx(data)], axis = 1)

    output.to_csv('extracted/questionnaire-answers.csv')

# Load data and run functions
data = import_survey(DATA_LOC, N_SUBJ)
write_output(data)
