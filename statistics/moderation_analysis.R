setwd("~/Nextcloud/Projects/cognitive-workload/")

source("statistics/stat_funcs.R")
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

run_moderation <- function() {
  eeg_data <- load_eeg()
  
  questionnaire <- read.csv("survey_analysis/extracted/questionnaire-answers.csv")
  recoded.questionnaire <- recode_questionnaire(questionnaire)
  
  scale.scores.FE <- scale_vars("FE")
  scale.scores.VB <- scale_vars("VB")
  
  View(scale.scores.FE)
  
  i <- 1
  
  while (i < length(eeg_data)) {
    if (i <= 4) {
      curr_task <- "yesno"
    } else if (i > 4 & i <= 8) {
      curr_task <- "open"
    } else {
      curr_task <- "cloze"
    }
    
    if (i <= 2 | i == 5 | i == 6 | i == 9 | i == 10) {
      curr_mod <- "FE"
    } else {
      curr_mod <- "VB"
    }
    
    print(paste("[INFO] Processing", curr_task, curr_mod, sep = " "))
    
    control_data <- eeg_data[[i]]
    treatment_data <- eeg_data[[i+1]]
    
    if (curr_mod == "FE") {
      moderation_analysis(control_data, treatment_data, scale.scores.FE, curr_mod, curr_task)
    } else if (curr_mod == "VB") {
      moderation_analysis(control_data, treatment_data, scale.scores.VB, curr_mod, curr_task)
    }
    
    
    i <- i + 2
  }
}

run_moderation()
