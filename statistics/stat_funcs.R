# Load libraries
library("dplyr")
library("ggplot2")

# Set working directory
setwd("~/Nextcloud/Projects/cognitive-workload/")

# Set global variables (constant)
NPARTS <- 58
NCHANS <- 16
CHANS <- c('Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz')


#' Loads the files containing the EEG Engagement Indices
#' 
#' Loads all files one by one and then puts all dataframes in a list
#' @return Returns a list of dataframes with EEG Engagement Indices
#'
load_eeg <- function() {
  yesno_control_FE <- read.csv("eeg_processing/data/indices/yesno/indices_control_FE.csv")
  yesno_control_VB <- read.csv("eeg_processing/data/indices/yesno/indices_control_VB.csv")
  yesno_treatment_FE <- read.csv("eeg_processing/data/indices/yesno/indices_treatment_FE.csv")
  yesno_treatment_VB <- read.csv("eeg_processing/data/indices/yesno/indices_treatment_VB.csv")
  
  open_control_FE <- read.csv("eeg_processing/data/indices/open/indices_control_FE.csv")
  open_control_VB <- read.csv("eeg_processing/data/indices/open/indices_control_VB.csv")
  open_treatment_FE <- read.csv("eeg_processing/data/indices/open/indices_treatment_FE.csv")
  open_treatment_VB <- read.csv("eeg_processing/data/indices/open/indices_treatment_VB.csv")
  
  cloze_control_FE <- read.csv("eeg_processing/data/indices/cloze/indices_control_FE.csv")
  cloze_control_VB <- read.csv("eeg_processing/data/indices/cloze/indices_control_VB.csv")
  cloze_treatment_FE <- read.csv("eeg_processing/data/indices/cloze/indices_treatment_FE.csv")
  cloze_treatment_VB <- read.csv("eeg_processing/data/indices/cloze/indices_treatment_VB.csv")
  
  eeg_data <- list(yesno_control_FE, yesno_treatment_FE,
                   yesno_control_VB, yesno_treatment_VB,
                   open_control_FE, open_treatment_FE,
                   open_control_VB, open_treatment_VB,
                   cloze_control_FE, cloze_treatment_FE,
                   cloze_control_VB, cloze_treatment_VB)
  
  names(eeg_data) <- c("yesno_control_FE", "yesno_treatment_FE",
                       "yesno_control_VB", "yesno_treatment_VB",
                       "open_control_FE", "open_treatment_FE",
                       "open_control_VB", "open_treatment_VB",
                       "cloze_control_FE", "cloze_treatment_FE",
                       "cloze_control_VB", "cloze_treatment_VB")
  
  return(eeg_data)
}


#' Computes the relative scores by dividing by the total number of answers
#' 
#' @param scores The dataframe with the task scores
#' @return Returns the relative scores for each task
#'
relative_scores <- function(scores) {
  scores$FE.yesno.rel <- scores$FE.yesno / 11
  scores$VB.yesno.rel <- scores$VB.yesno / 10
  scores$FE.open.rel <- scores$FE.open.correct / scores$FE.open.total
  scores$VB.open.rel <- scores$VB.open.correct / scores$VB.open.total
  scores$FE.cloze.rel <- scores$FE.cloze / 45
  scores$VB.cloze.rel <- scores$VB.cloze / 45
  
  return(scores)
}

#' Compute z scores given a vector of data
#' 
#' Calculates z scores according to (x - mean(x)) / (sd(x))
#' @param data Data to calculate z scores of
#' @return Returns a vector with z scores
#' 
compute_z <- function(data) {
  z = (data - mean(data)) / sd(data)
  return(z)
}
