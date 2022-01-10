import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.io

import statsmodels.api as sm
from statsmodels.formula.api import ols

NPART = 42
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
    index = beta / (theta + alpha)
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
    
def run_anova(control_FE, treatment_FE, control_VB, treatment_VB, chan):
    '''
    Runs a two-way ANOVA on the data.
    Writes the results to a file results/anova.txt.

    Parameters:
        control_FE (array): array of EEG engagement indices for control, FE model for a specific channel
        treatment_FE (array): array of EEG engagement indices for treatment, FE model for a specific channel
        control_VB (array): array of EEG engagement indices for control, VB model for a specific channel
        treatment_VB (array): array of EEG engagement indices for treatment, VB model for a specific channel
        chan (int): index of current channel

    Returns:
        anova (anova_lm object): run anova
    '''

    data_df = pd.DataFrame({'condition': np.repeat(["control", "treatment"], 42),
        'model': np.repeat(["FE", "VB", "FE", "VB"], 21),
        'index': np.concatenate([control_FE, control_VB, treatment_FE, treatment_VB])})

    model = ols('index ~ C(condition) + C(model) + C(condition):C(model)', data=data_df).fit()
    anova = sm.stats.anova_lm(model, typ=2)

    with open('results/anova.txt', 'a') as resultsfile:
        resultsfile.write("\nANOVA results for channel {}\n".format(CHANS[chan]))
        resultsfile.write(str(anova))
        resultsfile.write("\n")
    return anova

def generate_boxplot(control_FE, treatment_FE, control_VB, treatment_VB, chan):
    '''
    Creates boxplots from the data.
    Saves the plots to the results folder.

    Parameters:
        control_FE (array): array of EEG engagement indices for control, FE model for a specific channel
        treatment_FE (array): array of EEG engagement indices for treatment, FE model for a specific channel
        control_VB (array): array of EEG engagement indices for control, VB model for a specific channel
        treatment_VB (array): array of EEG engagement indices for treatment, VB model for a specific channel
        chan (int): index of current channel

    Returns:
        fig (pyplot): created figure
    '''
    data = [control_FE, treatment_FE, control_VB, treatment_VB]

    fig, ax = plt.subplots(figsize = (5,5), nrows = 1, ncols = 1)
    bp = ax.boxplot(data, positions = [0.8, 1.5, 2.5, 3.2], patch_artist = True, widths = 0.6)

    colours = ['coral', 'orangered', 'lightskyblue', 'deepskyblue']
    for patch, colour in zip(bp['boxes'], colours):
        patch.set_facecolor(colour)

    plt.xticks([])
    plt.yticks(fontsize = 14)
    plt.title("Channel {}".format(CHANS[chan]), fontsize = 28)
    plt.savefig("results/plots/chan{}.png".format(CHANS[chan]))
    return fig

control = scipy.io.loadmat('powers/control.mat')
treatment = scipy.io.loadmat('powers/treatment.mat')

for iChan in range(NCHAN):
    chan_result_control_FE = np.zeros(int(NPART/2))
    chan_result_control_VB = np.zeros(int(NPART/2))
    chan_result_treatment_FE = np.zeros(int(NPART/2))
    chan_result_treatment_VB = np.zeros(int(NPART/2))

    for iPart in range(int(NPART/2)):
        eeg_ei_control_total_FE_controlled = calc_results(control["control_baseline_powers_FE"][iPart, iChan, :], control["control_total_powers_FE"][iPart, iChan, :])
        eeg_ei_control_total_VB_controlled = calc_results(control["control_baseline_powers_VB"][iPart, iChan, :], control["control_total_powers_VB"][iPart, iChan, :])
        eeg_ei_treatment_total_FE_controlled = calc_results(treatment["treatment_baseline_powers_FE"][iPart, iChan, :], treatment["treatment_total_powers_FE"][iPart, iChan, :])
        eeg_ei_treatment_total_VB_controlled = calc_results(treatment["treatment_baseline_powers_VB"][iPart, iChan, :], treatment["treatment_total_powers_VB"][iPart, iChan, :])

        chan_result_control_FE[iPart] = eeg_ei_control_total_FE_controlled
        chan_result_control_VB[iPart] = eeg_ei_control_total_VB_controlled
        chan_result_treatment_FE[iPart] = eeg_ei_treatment_total_FE_controlled
        chan_result_treatment_VB[iPart] = eeg_ei_treatment_total_VB_controlled

    figure = generate_boxplot(chan_result_control_FE, chan_result_treatment_FE, chan_result_control_VB, chan_result_treatment_VB, iChan)
    anova = run_anova(chan_result_control_FE, chan_result_treatment_FE, chan_result_control_VB, chan_result_treatment_VB, iChan)