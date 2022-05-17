# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")
source("statistics/recode.R")


#' Put pre-experiment questionnaire data in long format
#' 
#' @param data Dataframe containing the required data (subj, condition, questions; e.g., all data)
#' @param domain String indicating the domain to be processed: either "bus" or "machine"
#' @return Returns a dataframe with the subj number, condition, and extracted questions in long format
#' 
long_preq <- function(data, domain) {
  if (domain == "bus") {
    btk26_data <- c(data$BTK.2, data$BTK.3, data$BTK.4, data$BTK.5, data$BTK.6)
    btk_df <- data.frame(subj = rep(data$subj, times = 5),
                         condition = rep(data$condition, times = 5),
                         question = rep(c("BTK.2", "BTK.3", "BTK.4", "BTK.5", "BTK.6"), each = 58),
                         BTK = btk26_data)
    return(btk_df)
  } else if (domain == "machine") {
    rfk26_data <- c(data$RFK.2, data$RFK.3, data$RFK.4, data$RFK.5, data$RFK.6)
    rfk_df <- data.frame(subj = rep(data$subj, times = 5),
                         condition = rep(data$condition, times = 5),
                         question = rep(c("RFK.2", "RFK.3", "RFK.4", "RFK.5", "RFK.6"), each = 58),
                         RFK = rfk26_data)
    return(rfk_df)
  }
}


#' Creates plots for the BTK1/RFK1 questions from the pre-experiment questionnaire
#' 
#' After creating the plot, it stores an svg image in the indicated location
#' @param data Dataframe containing the data to be plotted, namely the relative frequencies of answers
#' @param filename String indicating where to store the plot
#' @param title String indicating the title of the plot
#'  
create_preq_plot <- function(data, filename, title) {
  plot <- ggplot(data = data, aes(x = Var1, y = Freq, fill = Var1)) + 
    geom_bar(stat = "identity", width = 0.6) +
    coord_flip() +
    scale_x_discrete(limits = rev) +
    labs(title = title) +
    ylab("Frequency") + 
    ylim(c(0, 1)) +
    theme(plot.title = element_text(size = 18),
          axis.text.y = element_text(size = 16),
          axis.text.x = element_text(size = 16),
          axis.title.y = element_blank(),
          axis.title.x = element_text(size = 16),
          legend.position = "none")
    
  ggsave(filename, plot = plot, device = "svg", width = 7.5, height = 5)
}


#' Function to plot the BTK (bus tour) pre-experiment questionnaire questions
#' 
#' First creates relative frequencies and calls the create_preq_plot function to plot BTK1,
#' then creates a long version of the BTK2-BTK6 data, creates relative frequencies of these,
#' and plots them. It saves the plot in the indicated location.
#' @param data Dataframe containing all data
#'
plot_btk <- function(data) {
  # Create relative frequencies and prepare the data to plot BTK1
  btk1 <- table(data$BTK.1)
  btk1_rel <- btk1 / length(data$BTK.1)
  btk1_rel <- as.data.frame(btk1_rel)
  btk1_rel$Var1 <- factor(btk1_rel$Var1, levels=c("Very low", "Low", "Somewhat low",
                                                  "Neither low nor high", "Somewhat high",
                                                  "High", "Very high"))
  btk1_rel[6,] <- list("High", 0.)
  btk1_rel[7,] <- list("Very high", 0)
  
  # Plot relative frequencies of the answers to BTK1
  create_preq_plot(btk1_rel, "survey_analysis/results/pre-experiment/btk1.svg",
                   "Knowledge: organise bus tour company")
  
  # Prepare data to plot BTK2 to BTK6
  long_btk <- long_preq(data, "bus")
  btk_26 <- table(long_btk$question, long_btk$BTK)
  btk_26 <- as.data.frame(btk_26)
  
  axislabels <- c(paste("BTK", "6", sep = ""), paste("BTK", "5", sep = ""), paste("BTK", "4", sep = ""),
                  paste("BTK", "3", sep = ""), paste("BTK", "2", sep = ""))
  
  btk_26$rel.freq <- btk_26$Freq / aggregate(Freq ~ Var1, FUN = sum, data = btk_26)$Freq
  
  # Plot relative frequencies of the answers to each question
  btk26plot <- ggplot(data = btk_26, aes(x = Var1, y = rel.freq, fill = Var2)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.6) +
    coord_flip() +
    labs(title = "Domain knowledge: bus trips",
         fill = "Answer") +
    xlab("Question") + 
    ylab("Frequency") + 
    ylim(c(0, 1)) +
    theme(plot.title = element_text(size = 18),
          axis.text = element_text(size = 16),
          axis.title = element_text(size = 16),
          legend.text = element_text(size = 16),
          legend.title = element_text(size = 18)) +
    scale_fill_discrete(breaks = c("Yes", "No")) + 
    scale_x_discrete(labels = axislabels, limits = rev)
  
  ggsave("survey_analysis/results/pre-experiment/btk26.svg", plot = btk26plot, device = "svg", width = 6, height = 5)
}


#' Function to plot the RFK (machinery repair) pre-experiment questionnaire questions
#' 
#' First creates relative frequencies and calls the create_preq_plot function to plot RFK1,
#' then creates a long version of the RFK2-RFK6 data, creates relative frequencies of these,
#' and plots them. It saves the plot in the indicated location.
#' @param data Dataframe containing all data
#'
plot_rfk <- function(data) {
  # Create relative frequencies and prepare the data to plot RFK1
  rfk1 <- table(data$RFK.1)
  rfk1_rel <- rfk1 / length(data$RFK.1)
  rfk1_rel <- as.data.frame(rfk1_rel)
  rfk1_rel$Var1 <- factor(rfk1_rel$Var1, levels=c("Very Low", "Low", "Somewhat low",
                                                  "Neither low nor high", "Somewhat high",
                                                  "High", "Very high"))
  rfk1_rel[6,] <- list("High", 0.)
  rfk1_rel[7,] <- list("Very high", 0)
  
  # Plot relative frequencies of the answers to RFK1
  create_preq_plot(rfk1_rel, "survey_analysis/results/pre-experiment/rfk1.svg",
                   "Knowledge: organise machinery repair")
  
  # Prepare data to plot RFK2 to RFK6
  long_rfk <- long_preq(data, "machine")
  rfk_26 <- table(long_rfk$question, long_rfk$RFK)
  rfk_26 <- as.data.frame(rfk_26)
  
  axislabels <- c(paste("RFK", "6", sep = ""), paste("RFK", "5", sep = ""), paste("RFK", "4", sep = ""),
                  paste("RFK", "3", sep = ""), paste("RFK", "2", sep = ""))
  
  rfk_26$rel.freq <- rfk_26$Freq / aggregate(Freq ~ Var1, FUN = sum, data = rfk_26)$Freq
  
  # Plot relative frequencies of the answers to each question
  rfk26plot <- ggplot(data = rfk_26, aes(x = Var1, y = rel.freq, fill = Var2)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.6) +
    coord_flip() +
    labs(title = "Domain knowledge: machinery repair",
         fill = "Answer") +
    xlab("Question") + 
    ylab("Frequency") + 
    ylim(c(0, 1)) +
    theme(plot.title = element_text(size = 18),
          axis.text = element_text(size = 16),
          axis.title = element_text(size = 16),
          legend.text = element_text(size = 16),
          legend.title = element_text(size = 18)) +
    scale_fill_discrete(breaks = c("Yes", "No")) + 
    scale_x_discrete(labels = axislabels, limits = rev)
  
  ggsave("survey_analysis/results/pre-experiment/rfk26.svg", plot = rfk26plot, device = "svg", width = 6, height = 5)
}


#' Creates plots for the post-experiment questionnaire questions
#' 
#' After creating the plot, it stores an svg image in the indicated location
#' @param data Dataframe containing the data to be plotted, namely the relative frequencies of answers
#' @param filename String indicating where to store the plot
#' @param title String indicating the title of the plot
#' 
create_postq_plot <- function(data, filename, title) {
  # Prepare the data to be plotted
  likert_levels <- c("Strongly disagree", "Disagree", "Somewhat disagree", "Neither agree nor disagree",
                     "Somewhat agree", "Agree", "Strongly agree")
  data <- as.data.frame(data)
  data$Var2 <- factor(data$Var2, levels = likert_levels)
  data$Var1 <- factor(data$Var1, levels = c("treatment", "control"))
  
  # Create plot
  plot <- ggplot(data = data, aes(x = Var2, y = Freq, fill = Var1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.6) +
    coord_flip() +
    scale_x_discrete(limits=rev) +
    labs(title = title,
         fill = "Condition") +
    xlab("Answer") + 
    ylab("Frequency") + 
    ylim(c(0, 0.5)) +
    theme(plot.title = element_text(size = 18),
          axis.text = element_text(size = 16),
          axis.title = element_text(size = 16),
          legend.text = element_text(size = 16),
          legend.title = element_text(size = 18)) +
    scale_fill_discrete(labels = c("HOEM", "LOEM")) +
    guides(fill = guide_legend(reverse = TRUE))
  
  ggsave(filename = paste("survey_analysis/results/post-experiment/", filename, ".svg", sep = ""),
         plot = plot, device = "svg", width = 8, height = 4)
}


#' Helper unction to plot the post-experiment questionnaire question
#' 
#' Creates relative frequencies for each question and then calls the function.
#' @param data Dataframe containing all data
#'
plot_postq <- function(data) {
  understand1 <- table(data$condition, data$understand.1)
  understand1_rel <- understand1 / length(data$understand.1)
  create_postq_plot(understand1_rel, "understand1", "(1) Understanding easy")
  
  understand2 <- table(data$condition, data$understand.2)
  understand2_rel <- understand2 / length(data$understand.2)
  create_postq_plot(understand2_rel, "understand2", "(2) Easy to read ERDs")
  
  use1 <- table(data$condition, data$use.1)
  use1_rel <- use1 / length(data$use.1)
  create_postq_plot(use1_rel, "use1",  "(3) Easy to use ERDs")
  
  use2 <- table(data$condition, data$use.2)
  use2_rel <- use2 / length(data$use.2)
  create_postq_plot(use2_rel, "use2", "(4) Frustrating to use")
  
  load <- table(data$condition, data$load)
  load_rel <- load / length(data$load)
  create_postq_plot(load_rel, "load", "(5) Little effort required")
  
  data$eng.1[data$eng.1 == "nan"] <- NA
  eng1 <- table(data$condition, data$eng.1, useNA = "no")
  eng1_rel <- eng1 / length(data$eng.1)
  create_postq_plot(eng1_rel, "eng1", "(6) Confident in Eng. comprehension")
  
  data$eng.2[data$eng.2 == "nan"] <- NA
  eng2 <- table(data$condition, data$eng.2)
  eng2_rel <- eng2 / length(data$eng.2)
  create_postq_plot(eng2_rel, "eng2", "(7) Could comprehend Qs")
  
  data$eng.3[data$eng.3 == "nan"] <- NA
  eng3 <- table(data$condition, data$eng.3)
  eng3_rel <- eng3 / length(data$eng.3)
  create_postq_plot(eng3_rel, "eng3", "(8) Could follow training video")
}


#' Runs a statistical test on the given condition and question data
#' 
#' First checks the normality assumption and then runs a Mann-Whitney U test if
#' the normality assumption is violated; else, it runs a Welch's independent t-test
#' @param condition Dataframe column (vector) giving the conditions
#' @param measure Dataframe column (vector) giving the data for a particular question
#' @return Returns the test that was run (either Mann-Whitney or t-test)
#' 
stat_test <- function(condition, measure) {
  if (normality(measure) == 0) {
    test <- wilcox.test(measure ~ condition, na.action = "na.omit")
  } else {
    test <- t.test(measure ~ condition, var.equal = FALSE, na.action = "na.omit")
  }

  return(test)
}


#' Runs the statistical tests for the post-experiment questionnaire
#' 
#' Recodes the questionnaire and creates scores for each aspect that the post-
#' experiment questionnaire is measuring (understanding, using, load, English),
#' then calls statistical tests with these scores and prints them to a file.
#' @param data Dataframe containing all data
#' 
postq_stats <- function(data) {
  # Recode questionnaire and create output file
  recoded_q <- recode_questionnaire(data)
  output_file = "statistics/tests/post-experiment-q.txt"
  cat(paste("Statistics generated at", Sys.time(), sep = " "), file = output_file, append = FALSE, sep = "\n")
  
  # Create scores for understanding, using, and English
  recoded_q$understand <- recoded_q$understand.1 + recoded_q$understand.2
  recoded_q$use <- recoded_q$use.1 + recoded_q$use.2
  recoded_q$english <- recoded_q$eng.1 + recoded_q$eng.2 + recoded_q$eng.3
  
  # Call statistical tests
  understand <- stat_test(data$condition, recoded_q$understand)
  use <- stat_test(data$condition, recoded_q$use)
  load <- stat_test(data$condition, recoded_q$load)
  english <- stat_test(data$condition, recoded_q$english)
  
  # Print tests to file
  cat(paste("Understand:", toString(understand), sep = "\n"), file = output_file, append = TRUE, sep = "\n")
  cat(paste("Use:", toString(use), sep = "\n"), file = output_file, append = TRUE, sep = "\n")
  cat(paste("Load:", toString(load), sep = "\n"), file = output_file, append = TRUE, sep = "\n")
  cat(paste("English:", toString(english), sep = "\n"), file = output_file, append = TRUE, sep = "\n")
}

# Load all data
all_data <- read.csv("statistics/complete-data/complete-data.csv")

# Function calls
plot_btk(all_data)
plot_rfk(all_data)
plot_postq(all_data)
postq_stats(all_data)
