setwd("~/Nextcloud/Projects/cognitive-workload/")

source("statistics/recode.R")

# Set global variables (constant)
NPARTS <- 58
NCHANS <- 16
CHANS <- c('Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz')

compute_z <- function(data) {
  z = (data - mean(data)) / sd(data)
  return(z)
}

scale_vars <- function(mod) {
  if (mod == "FE") {
    rating <- recoded.questionnaire$RFK.1
    count_sum <- recoded.questionnaire$RFK.2 + recoded.questionnaire$RFK.3 + recoded.questionnaire$RFK.4 + 
      recoded.questionnaire$RFK.5 + recoded.questionnaire$RFK.6
  } else if (mod == "VB") {
    rating <- recoded.questionnaire$BTK.1
    count_sum <- recoded.questionnaire$BTK.2 + recoded.questionnaire$BTK.3 + recoded.questionnaire$BTK.4 + 
      recoded.questionnaire$BTK.5 + recoded.questionnaire$BTK.6
  }
  
  
  z_rating <- compute_z(rating)
  z_count_sum <- compute_z(count_sum)
  temp.df <- data.frame(rating = z_rating, count.sum <- z_count_sum)
  
  scale_var <- rowMeans(temp.df)
  return(scale_var)
}

moderation_analysis <- function(control, treatment, moderator, mod, task) {
  output_file = paste("statistics/tests/moderation-analysis/", mod, "-", task, "-", "result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    test_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    model <- lm(test_data$indices ~ test_data$condition * moderator)
    out <- capture.output(summary(model))
    cat(CHANS[iChan], file = output_file, append = TRUE, sep = "")
    cat(": \t", file = output_file, append = TRUE, sep = "")
    cat(out, file = output_file, append = TRUE, sep = "\n")
  }
}

# Read files
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

questionnaire <- read.csv("survey_analysis/extracted/questionnaire-answers.csv")
recoded.questionnaire <- recode_questionnaire(questionnaire)

scale.scores.FE <- scale_vars("FE")
scale.scores.VB <- scale_vars("VB")
moderation_analysis(yesno_control_FE, yesno_treatment_FE, scale.scores.FE, "FE", "yesno")
moderation_analysis(yesno_control_VB, yesno_treatment_VB, scale.scores.FE, "VB", "yesno")
moderation_analysis(open_control_FE, open_treatment_FE, scale.scores.FE, "FE", "open")
moderation_analysis(open_control_VB, open_treatment_VB, scale.scores.VB, "VB", "open")
moderation_analysis(cloze_control_FE, cloze_treatment_FE, scale.scores.VB, "FE", "cloze")
moderation_analysis(cloze_control_VB, cloze_treatment_VB, scale.scores.VB, "VB", "cloze")
