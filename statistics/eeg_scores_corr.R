library("ggplot2")
library("dplyr")

setwd("~/Nextcloud/Projects/cognitive-workload/")

source("statistics/stat_funcs.R")

plot_correlation <- function(df, mod, task, chan) {
  output <- paste("statistics/plots/correlation/", "/", sep = "")
  
  plot <- ggplot(data = na.omit(df), aes(x = score, y = index, color = factor(condition))) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE)
  
  ggsave(paste(output, mod, "-", task, "-", chan, ".svg", sep = ""), plot = plot, width = 7, height = 5)
}

calc_correlation <- function(df, mod, task, chan) {
  View(df)
  out <- capture.output(df %>%
                          group_by(condition) %>%
                          summarize(r = cor(index, score, use = "complete.obs")))
  
  return(out)
}

run_correlation <- function(data) {
  task_scores <- read.csv("survey_analysis/extracted/complete-task_scores.csv")
  task_scores <- relative_scores(task_scores)

  tasks <- c("yesno", "open", "cloze")
  mods <- c("fe", "vb")
  
  for (task in tasks) {
    for (mod in mods) {
       scores_colname <- paste(toupper(mod), task, "rel", sep = ".")
       output_file = paste("statistics/tests/correlation-eegscores/", mod, "-", task, "-", "result.txt", sep = "")
       cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
       for (iChan in 1:NCHANS) {
         ch <- CHANS[iChan]
         eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
         print(paste("Selecting", scores_colname, eeg_colname))
         plotdata <- data.frame(condition = data$condition,
                                index = data[,eeg_colname],
                                score = task_scores[,scores_colname])
         
         corr <- calc_correlation(plotdata, mod, task, ch)
         cat(CHANS[iChan], file = output_file, append = TRUE, sep = "")
         cat(": \t", file = output_file, append = TRUE, sep = "")
         cat(corr, file = output_file, append = TRUE, sep = "\n")
         
         plot_correlation(plotdata, mod, task, ch)
       }
    }
  }
}

all_data <- read.csv("statistics/complete-data/complete-data.csv")
run_correlation(all_data)