import pandas as pd
import numpy as np
from load_data import import_survey

N_SUBJ = 58
DATA_LOC = "survey_data.csv"
pd.options.display.max_colwidth = 10000

def generate_cols(input_df, type, *cols):
    for col in cols:
        if type == str:
            yield input_df[col].astype(str).to_numpy()
        elif type == int:
            yield input_df[col].astype(int).to_numpy()
        else:
            TypeError("[ERROR] Passed an unsupported type")

def save_cols(target_df, g, *colnames):
    for i in range(len(colnames)):
        target_df[colnames[i]] = g.__next__()
    return target_df

def create_output(data):
    output = pd.DataFrame()

    output = save_cols(output, generate_cols(data, int, "Q113"), "age")
    output = save_cols(output, generate_cols(data, str, "Q114"), "gender")
    output = save_cols(output, generate_cols(data, str, "ERK", "DBK"), "erd_experience", "database_experience")
    output = save_cols(output, generate_cols(data, str, "BTK", "BTK_1", "BTK_2", "BTK_3", "BTK_4", "BTK_5"), 
                        "bustour_organising_exp", "taken_bustour", "worked_busdriver", "made_reservation_bustrip", "travelled_event", "organised_shorttrips")
    output = save_cols(output, generate_cols(data, str, "RFK", "RPK_1", "RPK_2", "RPK_3", "RPK_4", "RPK_5"),
                        "machrepair_organising_exp", "worked_mechanic", "worked_warehouse", "replaced_enginepart", "had_engineoverhaul", "organised_repairshop")
    output = save_cols(output, generate_cols(data, str, "Understand1", "Understand2", "Use1", "Use2R", "Load1", "ENG1", "ENG2", "ENG3"),
                        "understand_model", "read_erd", "erd_difficulty", "erd_frustrating", "conscious_effort", "eng_comprehension", "comprehend_task", "follow_training")

    output.to_csv("extracted/questionnaires.csv")

data = import_survey(DATA_LOC, N_SUBJ)
create_output(data)

