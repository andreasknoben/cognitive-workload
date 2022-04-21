import numpy as np
import pandas as pd
from load_data import import_survey

N_SUBJ = 58
DATA_LOC = 'survey_data.csv'
pd.options.display.max_colwidth = 10000

def construct_yes_no_correct():
    '''Constructs from the answer files the correct yes no answers in a dictionary (two lists).
    
        Returns:
            answers (dict): Dictionary containing the yes/no answers to both cases.
    '''

    answers = dict()

    with open('answers/FE-yesno.txt') as ansfile:
        ans = ansfile.readlines()
        ans = [a.strip() for a in ans]
        answers['FE'] = ans

    with open('answers/VB-yesno.txt') as ansfile:
        ans = ansfile.readlines()
        ans = [a.strip() for a in ans]
        answers['VB'] = ans

    return answers


def construct_cloze_correct():
    '''Constructs from the answer files the correct cloze answers in a dictionary (two lists).

        Returns:
            answers (dict): Dictionary containing the cloze answers to both cases.
    '''

    answers = {'FE': [], 'VB': []}

    with open('answers/FE-cloze.txt') as ansfile:
        FE_answers = ansfile.readlines()
        for q in FE_answers:
            ans = q.split(',')
            ans = [a.strip() for a in ans]
            answers['FE'].append(ans)

    with open('answers/VB-cloze.txt') as ansfile:
        VB_answers = ansfile.readlines()
        for q in VB_answers:
            ans = q.split(',')
            ans = [a.strip() for a in ans]
            answers['VB'].append(ans)

    return answers


def extract_ptc_answers(data):
    '''Extracts the answers to each task from the raw survey data.

        Parameters:
            data (pd.DataFrame): pandas dataframe containing the raw survey data

        Returns:
            yes_no_answers (dict): Dictionary containing the extracted yes/no answers for both cases
            problem_solving_answers (dict): Dictionary containing the extracted problem-solving answers for both cases
            cloze_answers (dict): Dictionary containing the extracted cloze test answers for both cases (in a list)
    '''

    yes_no_answers = dict()
    yes_no_answers['FE'] = data['FAC_1':'FAC_12']
    yes_no_answers['VB'] = data['VB_C1':'VB_C12']

    problem_solving_answers = dict()
    problem_solving_answers['FE'] = data['FE_P1':'FE_P5']
    problem_solving_answers['VB'] = data['VB_P1':'VB_P5']

    cloze_answers = dict()
    try:
        cloze_answers_FE = data['Q88'].split(';')
        cloze_answers['FE'] = [a.strip() for a in cloze_answers_FE[:-1]]
    except:
        cloze_answers['FE'] = []
        print("[WARNING] NaN or other non-string entry detected")

    try:
        cloze_answers_VB = data['Q86'].split(';')
        cloze_answers['VB'] = [a.strip() for a in cloze_answers_VB[:-1]]
    except:
        cloze_answers['VB'] = []
        print("[WARNING] NaN or other non-string entry detected")

    return yes_no_answers, problem_solving_answers, cloze_answers


def check_yes_no(correct, answers):
    '''Checks the answers given to the yes/no questions and creates a list of 1 (correct) and 0 (incorrect)

        Parameters:
            correct (dict): Dictionary of the correct answers for both cases
            answers (dict): Dictionary of the extracted answers for both cases

        Returns:
            scores (dict): Dictionary of lists of correct/incorrect (1/0) answers for both cases
    '''
    scores = {'FE': [], 'VB': []}

    for i in range(len(correct['FE'])):
        if correct['FE'][i] == 'u':
            scores['FE'].append(1)
        elif answers['FE'][i].lower() == correct['FE'][i].lower():
            scores['FE'].append(1)
        else:
            scores['FE'].append(0)

    for i in range(len(correct['VB'])):
        if correct['VB'][i] == 'u':
            scores['VB'].append(1)
        elif answers['VB'][i].lower() == correct['VB'][i].lower():
            scores['VB'].append(1)
        else:
            scores['VB'].append(0)    

    return scores

def check_cloze(correct, answers):
    '''Checks the answers given on the cloze test and creates a list of 1 (correct), 0 (no answer), and original answer (default)

        Parameters:
            correct (dict): Dictionary of the correct answers for both cases
            answers (dict): Dictionary of the extracted answers for both cases

        Returns:
            scores (dict): Dictionary of lists of correct/incorrect (1/0) answers for both cases
    '''

    scores = {'FE': [], 'VB': []}
    fe, vb = True, True

    if len(answers['FE']) == 0:
        scores['FE'] = [np.nan]
        fe = False

    if len(answers['VB']) == 0:
        scores['VB'] = [np.nan]
        vb = False

    if fe:
        for i in range(len(correct['FE'])):
            if str(answers['FE'][i]).lower() in correct['FE'][i]:
                scores['FE'].append(1)
            elif str(answers['FE'][i]).lower() == '':
                scores['FE'].append(0)
            else:
                scores['FE'].append(answers['FE'][i])

    if vb:
        for i in range(len(correct['VB'])):
            if str(answers['VB'][i]).lower() in correct['VB'][i]:
                scores['VB'].append(1)
            elif str(answers['VB'][i]).lower() == '':
                scores['VB'].append(0)
            else:
                scores['VB'].append(answers['VB'][i])
            
    return scores

def write_results(data, results_df, yncorrect, clozecorrect):
    '''Writes the CSV file with the extracted answers to the questions to task-results.csv
    
        Parameters:
            data (pd.DataFrame): raw survey data
            results_df (pd.DataFrame): the dataframe in which the extracted answers are stored
            yncorrect (dict): The correct answers on the yes/no questions for both cases
            clozecorrect (dict): The correct answers on the cloze test for both cases
    '''
    for i in data.index:
        part = i - 23
        cond, order = determine_condition(data.loc[i])

        yes_no_answers, problem_solving_answers, cloze_answers = extract_ptc_answers(data.loc[i])

        score_yn = check_yes_no(yncorrect, yes_no_answers)
        score_cloze = check_cloze(clozecorrect, cloze_answers)  
        
        results_df.iloc[part] = [cond, order, score_yn['FE'], problem_solving_answers['FE'], score_cloze['FE'], 
                              score_yn['VB'], problem_solving_answers['VB'], score_cloze['VB']]

    results_df.to_csv('extracted/task-results.csv')

def write_scores(data, scores_df, yncorrect):
    '''Writes the CSV file with the yes/no scores and empty columns to store scores in, to task-scores.csv

        Parameters:
            data (pd.DataFrame): raw survey data
            scores_df (pd.DataFrame): the dataframe in which the scores are stored
            yncorrect (dict): The correct answers on the yes/no questions for both cases
    '''

    write = False

    confirm_write = input("Do you also want to rewrite the scores file? Modifications will be lost. [y/n]")
    if confirm_write.lower() == 'y':
        write = True
        print("[INFO] Scores file will be written")
    elif confirm_write.lower() == 'n':
        write = False
        print("[INFO] Scores file will not be written")

    if write:
        for i in data.index:
            part = i - 23
            cond, order = determine_condition(data.loc[i])

            yes_no_answers, _, _ = extract_ptc_answers(data.loc[i])

            score_yn = check_yes_no(yncorrect, yes_no_answers)
            sum_score_yn = {'FE': np.sum(score_yn['FE']), 'VB': np.sum(score_yn['VB'])}
            
            scores_df.iloc[part] = [cond, order, sum_score_yn['FE'], '', '', '', sum_score_yn['VB'], '', '', '']

        scores_df.to_csv('extracted/task-scores.csv')

data = import_survey(DATA_LOC, N_SUBJ)

yes_no_correct = construct_yes_no_correct()
cloze_correct = construct_cloze_correct()

results = pd.DataFrame(columns = ['condition', 'order', 'FE.yesno', 'FE.open', 'FE.cloze',
                                  'VB.yesno', 'VB.open', 'VB.open' 'VB.cloze'], index = range(1, N_SUBJ+1))
scores = pd.DataFrame(columns = ['condition', 'order', 'FE.yesno', 'FE.open.total', 'FE.open.correct', 'FE.cloze',
                                 'VB.yesno', 'VB.open.total', 'VB.open.correct', 'VB.cloze'], index = range(1, N_SUBJ+1))

write_results(data, results, yes_no_correct, cloze_correct)
write_scores(data, scores, yes_no_correct)
