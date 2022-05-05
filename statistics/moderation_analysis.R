# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")
source("statistics/recode.R")

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


#' Creates scale variables out of the questionnaire answers, as done by Gemino (1999)
#' 
#' It first creates a rating variable from the RFK1 variable,
#' and adds up the RFK2 to RFK6 variables. 
#' Their z scores are computed and the mean of these is taken.
#' @param mod The model (FE or VB)
#' @return Returns the scale values for the specified model
#' 
scale_vars <- function(mod) {
  # Create rating and sum variables
  if (mod == "FE") {
    rating <- recoded.questionnaire$RFK.1
    count_sum <- recoded.questionnaire$RFK.2 + recoded.questionnaire$RFK.3 + recoded.questionnaire$RFK.4 + 
      recoded.questionnaire$RFK.5 + recoded.questionnaire$RFK.6
  } else if (mod == "VB") {
    rating <- recoded.questionnaire$BTK.1
    count_sum <- recoded.questionnaire$BTK.2 + recoded.questionnaire$BTK.3 + recoded.questionnaire$BTK.4 + 
      recoded.questionnaire$BTK.5 + recoded.questionnaire$BTK.6
  }
  
  # Convert rating and sum into z scores
  z_rating <- compute_z(rating)
  z_count_sum <- compute_z(count_sum)
  temp.df <- data.frame(rating = z_rating, count.sum <- z_count_sum)
  
  # Take row means of rating and sum z scores to end up with final scale values
  scale_var <- rowMeans(temp.df)
  return(scale_var)
}


#' Performs the moderation analysis by creating linear models
#' 
#' Creates a linear regression for each channel, model, and task to determine
#' whether there is an interaction effect of condition and moderator.
#' It writes the result to a file.
#' 
#' @param control Vector of control data
#' @param treatment Vector of treatment data
#' @param moderator Vector of data to be used as the moderator
#' @param mod The model
#' @param task The task
#' 
moderation_analysis <- function(control, treatment, moderator, mod, task) {
  # Create target output folder string
  output_file = paste("statistics/tests/moderation-analysis/", mod, "-", task, "-", "result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  
  # Run over channels, create linear model, and write to file
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


#' Runs the moderation analysis by providing the correct data each time
#' to the right functions.
#' 
run_moderation <- function() {
  eeg_data <- load_eeg()
  
  questionnaire <- read.csv("survey_analysis/extracted/questionnaire-answers.csv")
  recoded.questionnaire <- recode_questionnaire(questionnaire)
  
  scale_scores_FE <- scale_vars("FE")
  scale_scores_VB <- scale_vars("VB")
  
  tasks <- c("yesno", "open", "cloze")
  
  for (i in 1:length(tasks)) {
    listidx <- i + (i-1) * 3
    curr_task <- tasks[i]
    control_fe <- eeg_data[[listidx]]
    control_vb <- eeg_data[[listidx+2]]
    treatment_fe <- eeg_data[[listidx+1]]
    treatment_vb <- eeg_data[[listidx+3]]
    
    moderation_analysis(control_fe, treatment_fe, scale_scores_FE, "FE", curr_task)
    moderation_analysis(treatment_fe, treatment_vb, scale_scores_VB, "VB", curr_task)

  }
}

run_moderation()
