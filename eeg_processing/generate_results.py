import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.io
import scipy.stats as stats

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
    
def run_anova(control_FE, treatment_FE, control_VB, treatment_VB, chan, dir):
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

    # data_df = pd.DataFrame({'condition': np.repeat(["control", "treatment"], 42),
    #    'model': np.repeat(["FE", "VB", "FE", "VB"], 21),
    #    'index': np.concatenate([control_FE, control_VB, treatment_FE, treatment_VB])})

    #model = ols('index ~ C(condition) + C(model) + C(condition):C(model)', data=data_df).fit()
    #anova = sm.stats.anova_lm(model, typ=2)

    test = stats.mannwhitneyu(control_FE, treatment_FE)

    with open('{}/mannwhitney.txt'.format(dir), 'a') as resultsfile:
        resultsfile.write("\nMann-Whitney results for channel {}\n".format(CHANS[chan]))
        resultsfile.write(str(test))
        resultsfile.write("\n")
    return test

def generate_boxplot(control_FE, treatment_FE, control_VB, treatment_VB, chan, dir):
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

    #data = [control_FE, treatment_FE, control_VB, treatment_VB]

    #fig, ax = plt.subplots(figsize = (5,5), nrows = 1, ncols = 1)
    #bp = ax.boxplot(data, positions = [0.8, 1.5, 2.5, 3.2], patch_artist = True, widths = 0.6)

    #colours = ['coral', 'orangered', 'lightskyblue', 'deepskyblue']
    #for patch, colour in zip(bp['boxes'], colours):
        #patch.set_facecolor(colour)

    #plt.xticks([])
    #plt.yticks(fontsize = 14)
    #plt.title("Channel {}".format(CHANS[chan]), fontsize = 28)
    #plt.savefig("{}/chan{}.png".format(dir, CHANS[chan]))
    #plt.close(fig)
    #return fig

    data = [control_FE, treatment_FE]

    fig, ax = plt.subplots(figsize = (3,4), nrows = 1, ncols = 1)
    bp = ax.boxplot(data, patch_artist = True, widths = 0.4, medianprops=dict(color="red", alpha=0.7))

    colours = ['skyblue', 'seagreen']
    for patch, colour in zip(bp['boxes'], colours):
        patch.set_facecolor(colour)

    plt.xticks([])
    plt.yticks(fontsize = 20)
    plt.title("{}".format(CHANS[chan]), fontsize = 28)
    plt.savefig("{}/chan{}.png".format(dir, CHANS[chan]), bbox_inches='tight')
    plt.close(fig)
    return fig

control = scipy.io.loadmat('powers/control.mat')
treatment = scipy.io.loadmat('powers/treatment.mat')

yesno_dir = 'results/yesno'
open_dir = 'results/open'
cloze_dir = 'results/cloze'
total_dir = 'results/total'

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
        if all(v == 0 for v in control["control_baseline_powers_FE"][iPart, iChan, :]):
            continue

        control_baseline_FE = control["control_baseline_powers_FE"][iPart, iChan, :]
        control_baseline_VB = control["control_baseline_powers_VB"][iPart, iChan, :]
        treatment_baseline_FE = treatment["treatment_baseline_powers_FE"][iPart, iChan, :]
        treatment_baseline_VB = treatment["treatment_baseline_powers_VB"][iPart, iChan, :]

        eeg_ei_control_yesno_FE_corrected = calc_results(control_baseline_FE, control["control_yesno_powers_FE"][iPart, iChan, :])
        eeg_ei_control_yesno_VB_corrected = calc_results(control_baseline_VB, control["control_yesno_powers_VB"][iPart, iChan, :])
        eeg_ei_treatment_yesno_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_yesno_powers_FE"][iPart, iChan, :])
        eeg_ei_treatment_yesno_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_yesno_powers_VB"][iPart, iChan, :])

        eeg_ei_control_open_FE_corrected = calc_results(control_baseline_FE, control["control_open_powers_FE"][iPart, iChan, :])
        eeg_ei_control_open_VB_corrected = calc_results(control_baseline_VB, control["control_open_powers_VB"][iPart, iChan, :])
        eeg_ei_treatment_open_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_open_powers_FE"][iPart, iChan, :])
        eeg_ei_treatment_open_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_open_powers_VB"][iPart, iChan, :])

        eeg_ei_control_cloze_FE_corrected = calc_results(control_baseline_FE, control["control_cloze_powers_FE"][iPart, iChan, :])
        eeg_ei_control_cloze_VB_corrected = calc_results(control_baseline_VB, control["control_cloze_powers_VB"][iPart, iChan, :])
        eeg_ei_treatment_cloze_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_cloze_powers_FE"][iPart, iChan, :])
        eeg_ei_treatment_cloze_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_cloze_powers_VB"][iPart, iChan, :])

        eeg_ei_control_total_FE_corrected = calc_results(control_baseline_FE, control["control_total_powers_FE"][iPart, iChan, :])
        eeg_ei_control_total_VB_corrected = calc_results(control_baseline_VB, control["control_total_powers_VB"][iPart, iChan, :])
        eeg_ei_treatment_total_FE_corrected = calc_results(treatment_baseline_FE, treatment["treatment_total_powers_FE"][iPart, iChan, :])
        eeg_ei_treatment_total_VB_corrected = calc_results(treatment_baseline_VB, treatment["treatment_total_powers_VB"][iPart, iChan, :])

        chan_result_control_yesno_FE.append(eeg_ei_control_yesno_FE_corrected)
        chan_result_control_yesno_VB.append(eeg_ei_control_yesno_VB_corrected)
        chan_result_treatment_yesno_FE.append(eeg_ei_treatment_yesno_FE_corrected)
        chan_result_treatment_yesno_VB.append(eeg_ei_treatment_yesno_VB_corrected)

        chan_result_control_open_FE.append(eeg_ei_control_open_FE_corrected)
        chan_result_control_open_VB.append(eeg_ei_control_open_VB_corrected)
        chan_result_treatment_open_FE.append(eeg_ei_treatment_open_FE_corrected)
        chan_result_treatment_open_VB.append(eeg_ei_treatment_open_VB_corrected)

        chan_result_control_cloze_FE.append(eeg_ei_control_cloze_FE_corrected)
        chan_result_control_cloze_VB.append(eeg_ei_control_cloze_VB_corrected)
        chan_result_treatment_cloze_FE.append(eeg_ei_treatment_cloze_FE_corrected)
        chan_result_treatment_cloze_VB.append(eeg_ei_treatment_cloze_VB_corrected)

        chan_result_control_total_FE.append(eeg_ei_control_total_FE_corrected)
        chan_result_control_total_VB.append(eeg_ei_control_total_VB_corrected)
        chan_result_treatment_total_FE.append(eeg_ei_treatment_total_FE_corrected)
        chan_result_treatment_total_VB.append(eeg_ei_treatment_total_VB_corrected)

    figure_yesno = generate_boxplot(chan_result_control_yesno_FE, chan_result_treatment_yesno_FE, chan_result_control_yesno_VB, chan_result_treatment_yesno_VB, iChan, yesno_dir)
    anova_yesno = run_anova(chan_result_control_yesno_FE, chan_result_treatment_yesno_FE, chan_result_control_yesno_VB, chan_result_treatment_yesno_VB, iChan, yesno_dir)

    figure_open = generate_boxplot(chan_result_control_open_FE, chan_result_treatment_open_FE, chan_result_control_open_VB, chan_result_treatment_open_VB, iChan, open_dir)
    anova_open = run_anova(chan_result_control_open_FE, chan_result_treatment_open_FE, chan_result_control_open_VB, chan_result_treatment_open_VB, iChan, open_dir)

    figure_cloze = generate_boxplot(chan_result_control_cloze_FE, chan_result_treatment_cloze_FE, chan_result_control_cloze_VB, chan_result_treatment_cloze_VB, iChan, cloze_dir)
    anova_cloze = run_anova(chan_result_control_cloze_FE, chan_result_treatment_cloze_FE, chan_result_control_cloze_VB, chan_result_treatment_cloze_VB, iChan, cloze_dir)

    figure_total = generate_boxplot(chan_result_control_total_FE, chan_result_treatment_total_FE, chan_result_control_total_VB, chan_result_treatment_total_VB, iChan, total_dir)
    anova_total = run_anova(chan_result_control_total_FE, chan_result_treatment_total_FE, chan_result_control_total_VB, chan_result_treatment_total_VB, iChan, total_dir)
