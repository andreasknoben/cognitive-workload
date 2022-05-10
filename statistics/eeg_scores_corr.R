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
plot_correlation <- function(df, chan) {
  output <- "statistics/plots/correlation-eeg-scores/"
  
  plot <- ggplot(data = na.omit(df), aes(x = scores, y = index, color = factor(condition))) + 
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

  ggsave(paste(output, chan, ".svg", sep = ""), plot = plot, width = 5, height = 5)
}


#' Creates the linear models and runs the regression
#' 
#' This function creates a linear model for the control and treatment conditions
#' and also calls the appropriate plotting functions.
#' @param df Dataframe with all data
#' @param scores Dataframe containing the relative scores
#' 
create_regression <- function(df, scores) {
  output_file <- "statistics/tests/correlation-eeg-scores.txt"
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  df$comb_scores <- rowMeans(scores[c("FE.yesno.rel", "VB.yesno.rel",
                                      "FE.open.rel",  "VB.open.rel",
                                      "FE.cloze.rel", "FE.cloze.rel")])
  
  predictors <- vector(length = NCHANS)
  
  for (i in 1:NCHANS) {
    chan <- CHANS[i]
    
    comb_colname <- paste("eeg", chan, "fe", sep = "_")
    predictors[i] <- comb_colname

    source_colnames <- c(paste("eeg", chan, "fe", "yesno", sep = "."),
                         paste("eeg", chan, "fe", "open", sep = "."),
                         paste("eeg", chan, "fe", "cloze", sep = "."))
    
    df[,comb_colname] <- rowMeans(df[,source_colnames])
    
    plotdata <- data.frame(condition = df$condition, scores = df$comb_scores, index = df[,comb_colname])
    plot_correlation(plotdata, chan)
  }
  
  regformula <- paste("comb_scores ~ ", paste(predictors, collapse = " + "), sep = "")
  regformula <- as.formula(regformula)
  
  control_df <- subset(df, condition == "control")
  treatment_df <- subset(df, condition == "treatment")

  # Check using complete pairwise obs!
  control_mod <- lm(formula = regformula, data = control_df)
  control_output <- capture.output(summary(control_mod))
  control_assumptions <- capture.output(gvlma(control_mod))  
  cat(control_output, file = output_file, append = TRUE, sep = "\n")
  cat(control_assumptions, file = output_file, append = TRUE, sep = "\n")
  
  treatment_mod <- lm(formula = regformula, data = treatment_df)
  treatment_output <- capture.output(summary(treatment_mod))
  treatment_assumptions <- capture.output(gvlma(treatment_mod))
  cat(treatment_output, file = output_file, append = TRUE, sep = "\n")
  cat(treatment_assumptions, file = output_file, append = TRUE, sep = "\n")
}


all_data <- read.csv("statistics/complete-data/complete-data.csv")
task_scores <- read.csv("survey_analysis/extracted/complete-task-scores.csv")
task_scores <- relative_scores(task_scores)

create_regression(all_data, task_scores)
