# Set working directory to /eeg_processing/ folder before starting!
setwd("~/Nextcloud/Projects/cognitive-workload/eeg_processing/")

# Set global variables
NPARTS <- 58
NCHANS <- 16
CHANS <- c('Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz')

check_assumptions <- function(control, treatment) {
  # Check assumptions
  viol <- vector()
  
  for(iChan in 1:NCHANS) {
    control_data <- control[iChan][!is.na(control[iChan])]
    shapiro_test <- shapiro.test(control_data)
    if(shapiro_test$p.value < 0.05) {
      print(paste("Normality of channel ", CHANS[iChan], " violated"))
      viol <- c(viol, CHANS[iChan])
    }
    
    treatment_data <- treatment[iChan][!is.na(treatment[iChan])]
    shapiro_test <- shapiro.test(treatment_data)
    if(shapiro_test$p.value < 0.05) {
      print(paste("Normality of channel ", CHANS[iChan], " violated"))
      viol <- c(viol, CHANS[iChan])
    }
    
    concat_data <- c(control[iChan], treatment[iChan])
    test_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    
    levene_test <- leveneTest(indices ~ condition, data = test_data)
    if (levene_test[3] < 0.05) {
      print(paste("Homogeneity of variance violated for channel ", CHANS[iChan]))
      viol <- c(viol, CHANS[iChan])
    }
  }
  return(viol)
}

statistical_test <- function(control, treatment, violated) {
  for (iChan in 1:NCHANS) {
    if (CHANS[iChan] %in% violated) {
      # Non-parametric
    } else {
      # Parametric
    }
  }
}

# Read files
yesno_control_FE <- read.csv("results/yesno/indices-control-FE.csv")
yesno_treatment_FE <- read.csv("results/yesno/indices-treatment-FE.csv")
yesno_control_VB <- read.csv("results/yesno/indices-control-VB.csv")
yesno_treatment_VB <- read.csv("results/yesno/indices-treatment-VB.csv")

open_control_FE <- read.csv("results/open/indices-control-FE.csv")
open_treatment_FE <- read.csv("results/open/indices-treatment-FE.csv")
open_control_VB <- read.csv("results/open/indices-control-VB.csv")
open_treatment_VB <- read.csv("results/open/indices-treatment-VB.csv")

cloze_control_FE <- read.csv("results/cloze/indices-control-FE.csv")
cloze_treatment_FE <- read.csv("results/cloze/indices-treatment-FE.csv")
cloze_control_VB <- read.csv("results/cloze/indices-control-VB.csv")
cloze_treatment_VB <- read.csv("results/cloze/indices-treatment-VB.csv")

total_control_FE <- read.csv("results/total/indices-control-FE.csv")
total_treatment_FE <- read.csv("results/total/indices-treatment-FE.csv")
total_control_VB <- read.csv("results/total/indices-control-VB.csv")
total_treatment_VB <- read.csv("results/total/indices-treatment-VB.csv")

