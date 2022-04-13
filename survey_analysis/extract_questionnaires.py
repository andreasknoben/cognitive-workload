import pandas as pd
import numpy as np
from load_data import import_survey

N_SUBJ = 58
DATA_LOC = "survey_data.csv"
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

def write_output(data):
    '''
    Creates the output dataframe using the appropriate function calls and writes it to questionnaire-answers.csv

        Parameters:
            data (pd.DataFrame): The raw survey data
    '''
    output = pd.DataFrame()

    output = save_cols(output, generate_cols(data, int, "Q113"), "age")
    output = save_cols(output, generate_cols(data, str, "Q114"), "gender")
    output = save_cols(output, generate_cols(data, str, "ERK", "DBK"), "erd.exp", "db.exp")
    output = save_cols(output, generate_cols(data, str, "BTK", "BTK_1", "BTK_2", "BTK_3", "BTK_4", "BTK_5"), 
                                                        "BTK.1", "BTK.2", "BTK.3", "BTK.4", "BTK.5", "BTK.6")
    output = save_cols(output, generate_cols(data, str, "RFK", "RPK_1", "RPK_2", "RPK_3", "RPK_4", "RPK_5"),
                                                        "RFK.1", "RFK.2", "RFK.3", "RFK.4", "RFK.5", "RFK.6")
    output = save_cols(output, generate_cols(data, str, "Understand1", "Understand2", "Use1", "Use2R", "Load1", "ENG1", "ENG2", "ENG3"),
                        "understand.1", "understand.2", "use.1", "use.2", "load", "eng.1", "eng.2", "eng.3")

    output.to_csv("extracted/questionnaire-answers.csv")

data = import_survey(DATA_LOC, N_SUBJ)
write_output(data)
