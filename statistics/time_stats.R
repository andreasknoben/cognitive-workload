# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")


#' Creates a dataframe storing the time taken to complete the given task
#' 
#' Loads the data statistics files and goes through them to store in new dataframe,
#' converting the given values (in seconds) to minutes
#' @param task String indicating the task to process
#' @return The dataframe with the times for a particular task
#' 
create_data <- function(task) {
  colname <- c(task)
  
  control_FE <- read.csv("eeg_processing/results/statistics/data-statistics/control_FE.csv")
  control_VB <- read.csv("eeg_processing/results/statistics/data-statistics/control_VB.csv")
  treatment_FE <- read.csv("eeg_processing/results/statistics/data-statistics/treatment_FE.csv")
  treatment_VB <- read.csv("eeg_processing/results/statistics/data-statistics/treatment_VB.csv")
  
  comb_data <- data.frame(condition = rep(c("control", "treatment"), each = 58),
                          model = rep(c("FE", "VB", "FE", "VB"), each = 29),
                          time = unlist(data.frame(control_FE[,colname]/60, control_VB[,colname]/60,
                                                   treatment_FE[,colname]/60, treatment_VB[,colname]/60)))
  return(comb_data)
}


#' Performs a statistical test on the time data
#' 
#' Checks the data for normality, and runs a Welch's independent t-test if the 
#' data is normally distributed; else, runs a Mann-Whitney U test
#' @param data The task time data
#' @return A string with the test results for FE and VB
#'
stat_test <- function(data) {
  # Create FE and VB data
  fe_data <- subset(data, model == "FE")
  vb_data <- subset(data, model == "VB")
  
  # Run tests
  if (normality(fe_data$time) == 1) {
    fe_test <- t.test(time ~ condition, data = fe_data, var.equal = FALSE)
  } else {
    fe_test <- wilcox.test(time ~ condition, data = fe_data)
  }
  
  if (normality(vb_data$time) == 1) {
    vb_test <- t.test(time ~ condition, data = vb_data, var.equal = FALSE)
  } else {
    vb_test <- wilcox.test(time ~ condition, data = vb_data)
  }
  
  # Return in one string
  return(paste(toString(fe_test), "\n\n", toString(vb_test), "\n\n"))
}


#' Creates boxplots of the time taken for a task, including models and conditions
#' 
#' Draws a red line where the soft limit timer was set to in the experiment;
#' saves the plot as well.
#' @param data The task time data
#' @param task String indicating the task for the filename
#' @param title String with the title for the plot
#' @param timer Number indicating how long the soft limit timer was set to
#' 
plot_timetaken <- function(data, task, title, timer) {
  plot <- ggplot(data = data) +
    geom_boxplot(aes(x = model, y = time, fill = condition), width = 0.75) + 
    geom_hline(aes(yintercept = timer, color = "line"),
               size = 1.2, alpha = 0.5) +
    labs(title = title,
         fill = "Condition",
         colour = element_blank()) +
    xlab("Case") + 
    ylab("Time (minutes)") + 
    theme(plot.title = element_text(size = 14),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(labels = c("LOEM", "HOEM")) +
    scale_color_discrete(labels = c("Timer"))
  
  ggsave(filename = paste("eeg_processing/results/statistics/data-statistics/", task, ".svg", sep = ""),
         plot = plot, device = "svg", width = 5, height = 4)
}

# Set output file for the statistical tests
output_file = "eeg_processing/results/statistics/data-statistics/statistics.txt"

# Plot and test yes-no questions time
yesno_data <- create_data("yesno")
plot_timetaken(yesno_data, "yesno", "Yes-no questions", 8)
cat(paste("Yes/no", stat_test(yesno_data), sep = "\t"), file = output_file, sep = "\n", append = FALSE)

# Plot and test problem-solving questions time
open_data <- create_data("open")
plot_timetaken(open_data, "open", "Problem-solving", 12)
cat(paste("Open", stat_test(open_data), sep = "\t"), file = output_file, sep = "\n", append = TRUE)

# Plot and test cloze test time
cloze_data <- create_data("cloze")
plot_timetaken(cloze_data, "cloze", "Cloze test", 7)
cat(paste("Cloze", stat_test(cloze_data), sep = "\t"), file = output_file, sep = "\n", append = TRUE)

