# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")


#' Creates a scores vector to get the scores in long format
#' 
#' Loops over all participants times two (since there are two scores, FE and VB for each),
#' and correctly assigns the FE and VB scores
#' @param fe_data Vector with the FE scores
#' @param vb_data Vector with the VB scores
#' @return Returns a vector containing the scores in long format
#' 
create_long_scores <- function(fe_data, vb_data) {
  long_scores <- vector(length = 116)
  j <- 1
  part <- 1
  for (i in 1:116) {
    if (j == 1) {
      long_scores[i] = fe_data[part]
      j <- 2
    } else if (j == 2) {
      long_scores[i] = vb_data[part]
      j <- 1
      part <- part + 1
    }
  }
  return(long_scores)
}


#' Converts the wide data provided into long format
#' 
#' Takes the scores data and makes sure it is entirely converted into long format,
#' to be used by statistical tests.
#' @param data Dataframe of scores data
#' @return Returns the scores data in long format, as a dataframe
#' 
create_long_form <- function(data) {
  long_df <- data.frame(part = rep(data$X, each = 2),
                        condition = rep(data$condition, each = 2),
                        model = rep(c("FE", "VB"), times = 58),
                        yesno = create_long_scores(data$FE.yesno, data$VB.yesno),
                        open.total = create_long_scores(data$FE.open.total, data$VB.open.total),
                        open.correct = create_long_scores(data$FE.open.correct, data$VB.open.correct),
                        cloze = create_long_scores(data$FE.cloze, data$VB.cloze))
  return(long_df)
}


#' Plots the scores obtained for each task and model
#' 
#' @param data The dataframe with the scores in long format
#' 
plot_scores <- function(data) {
  yn_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = yesno, fill = condition)) +
    labs(title = "Yes no questions",
         fill = "Condition") +
    xlab("Case") + 
    ylab("Score") + 
    theme(plot.title = element_text(size = 20),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(labels = c("LOEM", "HOEM"))
  
  ggsave("survey_analysis/results/yesno-scores.svg", plot = yn_plot, width = 8, height = 6)
  
  opent_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = open.total, fill = condition)) +
    labs(title = "Problem-solving questions (total)",
         fill = "Condition") +
    xlab("Case") + 
    ylab("Score") + 
    theme(plot.title = element_text(size = 20),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(labels = c("LOEM", "HOEM"))
  
  ggsave("survey_analysis/results/open-total-scores.svg", plot = opent_plot, width = 8, height = 6)
  
  openc_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = open.correct, fill = condition)) +
    labs(title = "Problem-solving questions (correct)",
         fill = "Condition") +
    xlab("Case") + 
    ylab("Score") + 
    theme(plot.title = element_text(size = 20),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(labels = c("LOEM", "HOEM"))
  
  ggsave("survey_analysis/results/open-correct-scores.svg", plot = openc_plot, width = 8, height = 6)
  
  cloze_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = cloze, fill = condition)) +
    labs(title = "Cloze test",
         fill = "Condition") +
    xlab("Case") + 
    ylab("Score") + 
    theme(plot.title = element_text(size = 20),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(labels = c("LOEM", "HOEM"))
  
  ggsave("survey_analysis/results/cloze-scores.svg", plot = cloze_plot, width = 8, height = 6)
}


#' Tests the supplied data for normality using the Shapiro-Wilk test
#' 
#' If the data is not normally distributed, returns 0
#' If the data is normally distributed, returns 1
#' @param data The data to be tested for normality (a vector)
#' @return Returns a 0 (not normal) or a 1 (normal)
#' 
normality <- function(data) {
  test <- shapiro.test(data)
  if (test$p.value < 0.05) {
    return(0)
  } else {
    return(1)
  }
}


#' Runs a statistical test on the provided task scores
#' 
#' If the normality is not violated, it runs a two-sided Welch's t-test,
#' if it is violated, it runs a Mann-Whitney U test - both of condition on scores.
#' @param task The task scores (vector)
#' @return Returns the statistical test that was run
#'
statistical_test <- function(task) {
  if (normality(task) == 1) {
    test <- t.test(task ~ task.scores$condition, var.equal = FALSE)
  } else {
    test <- wilcox.test(task ~ task.scores$condition)
  }
  return(test)
}


#' Does the function calls to run the statistical tests with the correct data
#' and writes the tests to files.
#' 
#' @param df The dataframe with all relative scores data
#' 
run_tests <- function(df) {
  output_file = "survey_analysis/results/statistical-test-abs.txt"
  cat(paste("FE yes/no", toString(statistical_test(df$FE.yesno)), sep = "\t"), file = output_file, sep = "\n", append = FALSE)
  cat(paste("VB yes/no", toString(statistical_test(df$VB.yesno)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("FE open correct", toString(statistical_test(df$FE.open.correct)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("VB open correct", toString(statistical_test(df$VB.open.correct)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("FE open total", toString(statistical_test(df$FE.open.total)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("VB open total", toString(statistical_test(df$VB.open.total)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("FE cloze", toString(statistical_test(df$FE.cloze)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("VB cloze", toString(statistical_test(df$VB.cloze)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
}

# Load the data and create long data
task.scores <- read.csv("survey_analysis/extracted/complete-task-scores.csv")
long <- create_long_form(task.scores)

# Plot the long data
plot_scores(long)

# Compute relative scores and perform statistical tests
# task.scores <- relative_scores(task.scores)
run_tests(task.scores)