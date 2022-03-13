import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from load_data import import_survey

N_SUBJ = 58
DATA_LOC = "survey_data.csv"
pd.options.display.max_colwidth = 10000

def construct_yes_no_correct():
    '''Constructs from the answer files the correct yes no answers
    in a dictionary (two lists).'''

    answers = dict()

    with open("answers/VB_yesno.txt") as ansfile:
        ans = ansfile.readlines()
        ans = [a.strip() for a in ans]
        answers["VB"] = ans

    with open("answers/FE_yesno.txt") as ansfile:
        ans = ansfile.readlines()
        ans = [a.strip() for a in ans]
        answers["FE"] = ans

    return answers

def construct_cloze_correct():
    '''Constructs from the answer files the correct cloze answers
    in a dictionary (two lists).'''

    answers = {"VB": [], "FE": []}

    with open("answers/VB_cloze.txt") as ansfile:
        VB_answers = ansfile.readlines()
        for q in VB_answers:
            ans = q.split(",")
            ans = [a.strip() for a in ans]
            answers["VB"].append(ans)

    with open("answers/FE_cloze.txt") as ansfile:
        FE_answers = ansfile.readlines()
        for q in FE_answers:
            ans = q.split(",")
            ans = [a.strip() for a in ans]
            answers["FE"].append(ans)

    return answers


def extract_answers(data):
    '''Extracts answers to each part from the survey data.'''

    yes_no_answers = dict()
    yes_no_answers["VB"] = data["VB_C1":"VB_C12"]
    yes_no_answers["FE"] = data["FAC_1":"FAC_12"]

    problem_solving_answers = dict()
    problem_solving_answers["VB"] = data["VB_P1":"VB_P5"]
    problem_solving_answers["FE"] = data["FE_P1":"FE_P5"]

    cloze_answers = dict()
    try:
        cloze_answers["VB"] = data["Q86"].split(";")
    except:
        cloze_answers["VB"] = []
        print("[WARNING] NaN or other non-string entry detected")

    try:
        cloze_answers["FE"] = data["Q88"].split(";")
    except:
        cloze_answers["FE"] = []
        print("[WARNING] NaN or other non-string entry detected")

    return yes_no_answers, problem_solving_answers, cloze_answers

def check_yes_no(correct, answers):
    '''Checks the answers given to the yes/no questions.'''
    scores = {"VB": [], "FE": []}

    for i in range(len(correct["VB"])):
        if correct["VB"][i] == "u":
            scores["VB"].append(1)
        elif answers["VB"][i].lower() == correct["VB"][i].lower():
            scores["VB"].append(1)
        else:
            scores["VB"].append(0)

    for i in range(len(correct["FE"])):
        if correct["FE"][i] == "u":
            scores["FE"].append(1)
        elif answers["FE"][i].lower() == correct["FE"][i].lower():
            scores["FE"].append(1)
        else:
            scores["FE"].append(0)

    return scores

def check_cloze(correct, answers):
    '''Checks the answers given on the cloze test.'''

    scores = {"VB": [], "FE": []}

    if len(answers["VB"]) == 0 or len(answers["FE"]) == 0:
        return {"VB": [np.nan], "FE": [np.nan]}

    for i in range(len(correct["VB"])):
        if str(answers["VB"][i]).lower() in correct["VB"][i]:
            scores["VB"].append(1)
        elif str(answers["VB"][i]).lower() == '':
            scores["VB"].append(0)
        else:
            scores["VB"].append(answers["VB"][i])

    for i in range(len(correct["FE"])):
        if str(answers["FE"][i]).lower() in correct["FE"][i]:
            scores["FE"].append(1)
        elif str(answers["FE"][i]).lower() == '':
            scores["FE"].append(0)
        else:
            scores["FE"].append(answers["FE"][i])
            
    return scores

def determine_condition(ptc):
    '''Determines the condition a participant is in.
    - FL_71 -> control; FL_81 -> treatment
    - FL_51|FL_66 -> VB|FE (control)
    - FL_59|FL_75 -> VB|FE (treatment)'''

    condition = ""
    order = []

    if ptc["FL_87_DO"] == "FL_72":
        condition = "control"
        if ptc["FL_72_DO"] == "FL_51|FL_66":
            order = ["VB", "FE"]
        elif ptc["FL_72_DO"] == "FL_66|FL_51":
            order = ["FE", "VB"]
    elif ptc["FL_87_DO"] == "FL_81":
        condition = "treatment"
        if ptc["FL_81_DO"] == "FL_59|FL_75":
            order = ["VB", "FE"]
        elif ptc["FL_81_DO"] == "FL_75|FL_59":
            order = ["FE", "VB"]

    return condition, order

# Loading the data
data = import_survey(DATA_LOC, N_SUBJ)

# Constructing the correct answers
yes_no_correct = construct_yes_no_correct()
cloze_correct = construct_cloze_correct()

# Dataframe in which results will be stored
results = pd.DataFrame(columns = ["condition", "order", "VB-yes-no", "VB-problem-solving", "VB-cloze", "FE-yes-no", "FE-problem-solving", "FE-cloze"],
                        index = range(1, N_SUBJ+1))

for i in data.index:
    # Determine participant
    part = i - 23
    print("[INFO] Processing participant {}, index {}...".format(part, i))

    # Determine condition of participant
    cond, order = determine_condition(data.loc[i])

    # Extract answers from participant
    yes_no_answers, problem_solving_answers, cloze_answers = extract_answers(data.loc[i])

    # Compute scores from extracted answers
    score_yn = check_yes_no(yes_no_correct, yes_no_answers)
    score_cloze = check_cloze(cloze_correct, cloze_answers)  
    
    # Insert scores in dataframe
    results.iloc[part] = [cond, order, score_yn["VB"], problem_solving_answers["VB"], score_cloze["VB"], score_yn["FE"], problem_solving_answers["FE"], score_cloze["FE"]]

# Write results to CSV
results.to_csv("results.csv")