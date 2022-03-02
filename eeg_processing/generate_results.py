import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.io

NPART = 58
NCHAN = 16
NPOWS = 3
CHANS = ['Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz']

def calc_eeg_engagementindex(powers):
    '''
    Calculates the EEG Engagement Index given the theta, alpha, and beta power.

    Parameters:
        powers (list): list of theta (0), alpha (1), and beta (2) powers

    Returns:
        index (float): EEG Engagement Index according to beta/(theta+alpha)
    '''

    theta, alpha, beta = powers[0], powers[1], powers[2]
    if theta < 0:
        ValueError("theta less than 0")
    elif alpha < 0:
        ValueError("alpha less than 0")
    elif beta < 0:
        ValueError("beta less than 0")
    index = beta / (theta + alpha)
    if index < 0:
        ValueError("index less than 0")
    return index

def calc_results(baseline, task):
    '''
    Calculates the baseline-corrected EEG Engagement Index.

    Parameters:
        baseline (list): list of band powers for specific channel and participant and condition
        task (list): list of band powers for specific channel and participant and condition

    Returns:
        eeg_ei_controlled (float): EEG engagement index of task minus EEG engagement index of baseline
    '''

    eeg_ei_baseline = calc_eeg_engagementindex(baseline)
    eeg_ei_task = calc_eeg_engagementindex(task)
    eeg_ei_controlled = eeg_ei_task - eeg_ei_baseline
    return eeg_ei_controlled

def create_dataframes():
    '''
    Creates the dataframes in which the EEG Engagement Indices will be stored.

    Returns:
        list of dataframes (list): list containing four empty dataframes with channel names
    '''

    df_control_FE = pd.DataFrame(columns = CHANS)
    df_treatment_FE = pd.DataFrame(columns = CHANS)
    df_control_VB = pd.DataFrame(columns = CHANS)
    df_treatment_VB = pd.DataFrame(columns = CHANS)
    return [df_control_FE, df_treatment_FE, df_control_VB, df_treatment_VB]

def update_dataframes(dfs, control_FE, treatment_FE, control_VB, treatment_VB, chan):
    '''
    Insert data for particular channel into the appropriate dataframe.

    Parameters:
        dfs (list): list of dataframes the data should be written to
        control_FE (list): control FE engagement indices
        treatment_FE (list): treatment FE engagement indices
        control_VB (list): control VB engagement indices
        treatment_VB (list): treatment VB engagement indices
        chan (int): channel index

    Returns:
        list of dataframes (list): list containing the updated dataframes
    '''

    chan_name = str(CHANS[chan])
    df_control_FE, df_treatment_FE, df_control_VB, df_treatment_VB = dfs[0], dfs[1], dfs[2], dfs[3]

    df_control_FE[chan_name] = control_FE
    df_treatment_FE[chan_name] = treatment_FE
    df_control_VB[chan_name] = control_VB
    df_treatment_VB[chan_name] = treatment_VB

    return [df_control_FE, df_treatment_FE, df_control_VB, df_treatment_VB]

def write_dfs_to_file(df_list, dirs):
    labels = ["control-FE", "treatment-FE", "control-VB", "treatment-VB"]

    for i in range(len(df_list)):
        curr_dir = dirs[i]
        for j in range(len(df_list[i])):
            df_list[i][j].to_csv('{}/indices-{}.csv'.format(curr_dir, labels[j]), index = False)

def compute_eeis(dfs_yesno, dfs_open, dfs_cloze, dfs_total):
    for iChan in range(NCHAN):
        chan_result_control_yesno_FE = []
        chan_result_control_yesno_VB = []
        chan_result_treatment_yesno_FE = []
        chan_result_treatment_yesno_VB = []

        chan_result_control_open_FE = []
        chan_result_control_open_VB = []
        chan_result_treatment_open_FE = []
        chan_result_treatment_open_VB = []

        chan_result_control_cloze_FE = []
        chan_result_control_cloze_VB = []
        chan_result_treatment_cloze_FE = []
        chan_result_treatment_cloze_VB = []

        chan_result_control_total_FE = []
        chan_result_control_total_VB = []
        chan_result_treatment_total_FE = []
        chan_result_treatment_total_VB = []

        for iPart in range(int(NPART/2)):
            if np.isnan(control["control_baseline_powers_FE"][iPart, iChan, 0]):
                print("Control NaN for participant {}, channel {}".format(iPart+1, CHANS[iChan]))

                chan_result_control_yesno_FE.append(np.nan)
                chan_result_control_yesno_VB.append(np.nan)
                
                chan_result_control_open_FE.append(np.nan)
                chan_result_control_open_VB.append(np.nan)
                
                chan_result_control_cloze_FE.append(np.nan)
                chan_result_control_cloze_VB.append(np.nan)
                
                chan_result_control_total_FE.append(np.nan)
                chan_result_control_total_VB.append(np.nan)            
                
                continue

            control_baseline_FE = control["control_baseline_powers_FE"][iPart, iChan, :]
            control_baseline_VB = control["control_baseline_powers_VB"][iPart, iChan, :]

            eeg_ei_control_yesno_FE_corrected = calc_results(control_baseline_FE, control["control_yesno_powers_FE"][iPart, iChan, :])
            eeg_ei_control_yesno_VB_corrected = calc_results(control_baseline_VB, control["control_yesno_powers_VB"][iPart, iChan, :])
            
            eeg_ei_control_open_FE_corrected = calc_results(control_baseline_FE, control["control_open_powers_FE"][iPart, iChan, :])
            eeg_ei_control_open_VB_corrected = calc_results(control_baseline_VB, control["control_open_powers_VB"][iPart, iChan, :])
            
            eeg_ei_control_cloze_FE_corrected = calc_results(control_baseline_FE, control["control_cloze_powers_FE"][iPart, iChan, :])
            eeg_ei_control_cloze_VB_corrected = calc_results(control_baseline_VB, control["control_cloze_powers_VB"][iPart, iChan, :])
            
            eeg_ei_control_total_FE_corrected = calc_results(control_baseline_FE, control["control_total_powers_FE"][iPart, iChan, :])
            eeg_ei_control_total_VB_corrected = calc_results(control_baseline_VB, control["control_total_powers_VB"][iPart, iChan, :])
            
            chan_result_control_yesno_FE.append(eeg_ei_control_yesno_FE_corrected)
            chan_result_control_yesno_VB.append(eeg_ei_control_yesno_VB_corrected)
            
            chan_result_control_open_FE.append(eeg_ei_control_open_FE_corrected)
            chan_result_control_open_VB.append(eeg_ei_control_open_VB_corrected)
            
            chan_result_control_cloze_FE.append(eeg_ei_control_cloze_FE_corrected)
            chan_result_control_cloze_VB.append(eeg_ei_control_cloze_VB_corrected)
            
            chan_result_control_total_FE.append(eeg_ei_control_total_FE_corrected)
            chan_result_control_total_VB.append(eeg_ei_control_total_VB_corrected)

        for iPart in range(int(NPART/2)):
            if np.isnan(treatment["treatment_baseline_powers_FE"][iPart, iChan, 0]):
                print("Treatment NaN for participant {}, channel {}".format(iPart+1, CHANS[iChan]))

                chan_result_treatment_yesno_FE.append(np.nan)
                chan_result_treatment_yesno_VB.append(np.nan)

                chan_result_treatment_open_FE.append(np.nan)
                chan_result_treatment_open_VB.append(np.nan)

                chan_result_treatment_cloze_FE.append(np.nan)
                chan_result_treatment_cloze_VB.append(np.nan)

                chan_result_treatment_total_FE.append(np.nan)
                chan_result_treatment_total_VB.append(np.nan)
                
                continue

            treatment_baseline_FE = treatment["treatment_baseline_powers_FE"][iPart, iChan, :]
            treatment_baseline_VB = treatment["treatment_baseline_powers_VB"][iPart, iChan, :]

            eeg_ei_treatment_yesno_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_yesno_powers_FE"][iPart, iChan, :])
            eeg_ei_treatment_yesno_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_yesno_powers_VB"][iPart, iChan, :])

            eeg_ei_treatment_open_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_open_powers_FE"][iPart, iChan, :])
            eeg_ei_treatment_open_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_open_powers_VB"][iPart, iChan, :])

            eeg_ei_treatment_cloze_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_cloze_powers_FE"][iPart, iChan, :])
            eeg_ei_treatment_cloze_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_cloze_powers_VB"][iPart, iChan, :])

            eeg_ei_treatment_total_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_total_powers_FE"][iPart, iChan, :])
            eeg_ei_treatment_total_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_total_powers_VB"][iPart, iChan, :])

            chan_result_treatment_yesno_FE.append(eeg_ei_treatment_yesno_FE_corrected)
            chan_result_treatment_yesno_VB.append(eeg_ei_treatment_yesno_VB_corrected)

            chan_result_treatment_open_FE.append(eeg_ei_treatment_open_FE_corrected)
            chan_result_treatment_open_VB.append(eeg_ei_treatment_open_VB_corrected)

            chan_result_treatment_cloze_FE.append(eeg_ei_treatment_cloze_FE_corrected)
            chan_result_treatment_cloze_VB.append(eeg_ei_treatment_cloze_VB_corrected)

            chan_result_treatment_total_FE.append(eeg_ei_treatment_total_FE_corrected)
            chan_result_treatment_total_VB.append(eeg_ei_treatment_total_VB_corrected)

        dfs_yesno = update_dataframes(dfs_yesno, chan_result_control_yesno_FE, chan_result_treatment_yesno_FE, chan_result_control_yesno_VB, chan_result_treatment_yesno_VB, iChan)
        dfs_open = update_dataframes(dfs_open, chan_result_control_open_FE, chan_result_treatment_open_FE, chan_result_control_open_VB, chan_result_treatment_open_VB, iChan)
        dfs_cloze = update_dataframes(dfs_cloze, chan_result_control_cloze_FE, chan_result_treatment_cloze_FE, chan_result_control_cloze_VB, chan_result_treatment_cloze_VB, iChan)
        dfs_total = update_dataframes(dfs_total, chan_result_control_total_FE, chan_result_treatment_total_FE, chan_result_control_total_VB, chan_result_treatment_total_VB, iChan)
    
    return [dfs_yesno, dfs_open, dfs_cloze, dfs_total]

control = scipy.io.loadmat('powers/control.mat')
treatment = scipy.io.loadmat('powers/treatment.mat')

yesno_dir = 'results/yesno'
open_dir = 'results/open'
cloze_dir = 'results/cloze'
total_dir = 'results/total'

dfs_yesno = create_dataframes()
dfs_open = create_dataframes()
dfs_cloze = create_dataframes()
dfs_total = create_dataframes()

result_dfs = compute_eeis(dfs_yesno, dfs_open, dfs_cloze, dfs_total)
write_dfs_to_file(result_dfs, [yesno_dir, open_dir, cloze_dir, total_dir])
