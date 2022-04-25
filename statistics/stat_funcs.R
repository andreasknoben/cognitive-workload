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
  
  return(eeg_data)
}