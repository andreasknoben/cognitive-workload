library("gvlma")

# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")


#' Creates a scatterplot of the task scores and EEG Engagement Indices
#' 
#' First creates a scatterplot of scores on x and indices on y (by condition),
#' then draws a line through it as the linear model would. These plots are saved to disk.
#' @param df Dataframe with data for plotting
#' @param mod String indicating the model to be processed
#' @param task String indicating the task to be processed
#' @param chan String indicating the channel to be processed
#' 
plot_correlation <- function(df, mod, task, chan) {
  output <- paste("statistics/plots/correlation-eeg-scores/", task, "/", sep = "")
  
  plot <- ggplot(data = na.omit(df), aes(x = score, y = index, color = factor(condition))) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE) +
    labs(title = chan) +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 18),
          axis.text.y = element_text(size = 18),
          plot.title = element_text(size = 26, hjust = 0.5),
          legend.position = "none"
    )

  ggsave(paste(output, mod, "-", task, "-", chan, ".svg", sep = ""), plot = plot, width = 5, height = 5)
}


#' Runs a linear regression of channels on scores
#' 
#' Creates a linear model with all channels as predictors for a task/model
#' and prints the output to a file, where 1 is control and 2 is treatment (in file)
#' @param df Dataframe with all data
#' @param mod String indicating the model to be processed
#' @param task String indicating the task to be processed
#' @return Returns the models created (one for control, one for treatment)
#' 
create_regression <- function(df, scores, mod, task) {
  # Create target output folder and file
  output_file = paste("statistics/tests/correlation-eeg-scores/", mod, "-", task, "-", "result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  
  # Create outcome and predictor variables
  df$tscores <- scores
  predictors <- vector(length = NCHANS)
  for (i in 1:NCHANS) {
    name <- paste("eeg", CHANS[i], mod, task, sep = ".")
    predictors[i] <- name
  }
  
  control_df <- subset(df, condition == "control")
  treatment_df <- subset(df, condition == "treatment")
  
  frml <- paste("tscores ~ ", paste(predictors, collapse = " + "), sep = "")
  frml <- as.formula(frml)
  
  # Run linear model and write results to file
  # models <- df %>% group_by(condition) %>% do(model = lm(formula = frml, data = df))
  # output <- capture.output(lapply(models$model, summary))
  # cat(output, file = output_file, append = TRUE, sep = "\n")
  control_model <- lm(formula = frml, data = control_df, na.action = na.omit)
  output <- capture.output(summary(control_model))
  cat(output, file = output_file, append = TRUE, sep = "\n")
  
  # Write linear model assumptions to file
  # assumptions <- capture.output(lapply(models$model, gvlma))
  # cat(assumptions, file = output_file, append = TRUE, sep = "\n")
  return(control_model)
}


#' Helper function to run the correlation
#' 
#' Creates the required dataframes, then loops over tasks and mods to call the
#' functions with the correct arguments; then loops over channels to create plots.
#' @param data The dataframe with all data
#' 
run_correlation <- function(data) {
  # Load task scores file and create relative scores
  task_scores <- read.csv("survey_analysis/extracted/complete-task-scores.csv")
  task_scores <- relative_scores(task_scores)

  # Loop over tasks and models, and run the regression
  tasks <- c("yesno", "open", "cloze")
  mods <- c("fe", "vb")
  
  for (task in tasks) {
    for (mod in mods) {
       scores_colname <- paste(toupper(mod), task, "rel", sep = ".")
       corr <- create_regression(data, task_scores[,scores_colname], mod, task)
       
       # Loop over channels to create plots
       for (iChan in 1:NCHANS) {
         ch <- CHANS[iChan]
         eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
         plotdata <- data.frame(condition = data$condition,
                                index = data[,eeg_colname],
                                score = task_scores[,scores_colname])
         
         plot_correlation(plotdata, mod, task, ch)
       }
    }
  }
}

all_data <- read.csv("statistics/complete-data/complete-data.csv")
run_correlation(all_data)
