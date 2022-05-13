library("gvlma")

# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")


#' Creates a scatterplot of the task scores and EEG Engagement Indices
#' 
#' First creates a scatterplot of scores on x and indices on y (by condition),
#' then draws a line through it as the linear model would. These plots are saved to disk.
#' @param df Dataframe with data for plotting
#' @param chan String indicating the channel to be processed
#' 
plot_correlation <- function(df, chan) {
  output <- "statistics/plots/correlation-eeg-scores/"
  
  plot <- ggplot(data = na.omit(df), aes(x = scores, y = index, color = factor(condition))) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE, formula = y ~ x) +
    labs(title = chan) +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 20),
          axis.text.y = element_text(size = 20),
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
  
  df$FE.yesno.z <- compute_z(df$FE.yesno)
  df$VB.yesno.z <- compute_z(df$VB.yesno)
  df$FE.open.correct.z <- compute_z(df$FE.open.correct)
  df$VB.open.correct.z <- compute_z(df$VB.open.correct)
  df$FE.open.total.z <- compute_z(df$FE.open.total)
  df$VB.open.total.z <- compute_z(df$VB.open.total)
  df$FE.cloze.z <- compute_z(df$FE.cloze)
  df$VB.cloze.z <- compute_z(df$VB.cloze)
  
  df$comb_scores <- rowMeans(df[c("FE.yesno.z", "VB.yesno.z",
                                  "FE.open.correct.z",  "VB.open.correct.z",
                                  "FE.open.total.z", "FE.open.total.z",
                                  "FE.cloze.z", "FE.cloze.z")])
  
  predictors <- vector(length = NCHANS)
  
  for (i in 1:NCHANS) {
    chan <- CHANS[i]
    
    comb_colname <- paste("eeg", chan, sep = "_")
    predictors[i] <- comb_colname

    source_colnames <- c(paste("eeg", chan, "fe", "yesno", sep = "."),
                         paste("eeg", chan, "fe", "open", sep = "."),
                         paste("eeg", chan, "fe", "cloze", sep = "."),
                         paste("eeg", chan, "vb", "yesno", sep = "."),
                         paste("eeg", chan, "vb", "open", sep = "."),
                         paste("eeg", chan, "vb", "cloze", sep = "."))
    
    df[,comb_colname] <- rowMeans(df[,source_colnames])
    
    plotdata <- data.frame(condition = df$condition, scores = df$comb_scores, index = df[,comb_colname])
    plot_correlation(plotdata, chan)
  }
  
  regformula <- paste("comb_scores ~ ", paste(predictors, collapse = " + "), sep = "")
  regformula <- as.formula(regformula)

  control_df <- subset(df, condition == "control")
  treatment_df <- subset(df, condition == "treatment")

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

# Load data and call function
all_data <- read.csv("statistics/complete-data/complete-data.csv")
create_regression(all_data)
