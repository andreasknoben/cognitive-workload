# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")

plot_timetaken <- function(task, title) {
  colname <- c(task)
  
  control_FE <- read.csv("eeg_processing/results/statistics/data-statistics/control_FE.csv")
  control_VB <- read.csv("eeg_processing/results/statistics/data-statistics/control_VB.csv")
  treatment_FE <- read.csv("eeg_processing/results/statistics/data-statistics/treatment_FE.csv")
  treatment_VB <- read.csv("eeg_processing/results/statistics/data-statistics/treatment_VB.csv")
  
  comb_data <- data.frame(condition = rep(c("control", "treatment"), each = 58),
                          model = rep(c("FE", "VB", "FE", "VB"), each = 29),
                          time = unlist(data.frame(control_FE[,colname]/60, control_VB[,colname]/60,
                                                   treatment_FE[,colname]/60, treatment_VB[,colname]/60)))
  
  plot <- ggplot(data = comb_data) +
    geom_boxplot(aes(x = model, y = time, fill = condition), width = 0.6) +
    labs(title = paste("Time taken:", title, sep = " "),
         fill = "Condition") +
    xlab("Case") + 
    ylab("Time (minutes)") + 
    theme(plot.title = element_text(size = 14),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(labels = c("LOEM", "HOEM"))
  
  ggsave(filename = paste("eeg_processing/results/statistics/data-statistics/", task, ".svg", sep = ""),
         plot = plot, device = "svg", width = 6, height = 4)
}

# Plot 1: yes/no, control FE vs treatment FE / control VB vs treatment VB
plot_timetaken("yesno", "yes-no questions")
plot_timetaken("open", "problem-solving questions")
plot_timetaken("cloze", "cloze test")
