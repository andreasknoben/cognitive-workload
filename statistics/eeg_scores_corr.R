# Load helper file with libraries, functions, and working directory setting
source("statistics/stat_funcs.R")


#' 
plot_correlation <- function(df, mod, task, chan) {
  output <- paste("statistics/plots/correlation/", task, "/", sep = "")
  
  plot <- ggplot(data = na.omit(df), aes(x = score, y = index, color = factor(condition))) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE) +
    theme(legend.position = "none")
  
  ggsave(paste(output, mod, "-", task, "-", chan, ".svg", sep = ""), plot = plot, width = 3.25, height = 3.75)
}

calc_correlation <- function(df, scores, mod, task, chan) {
  output_file = paste("statistics/tests/correlation-eegscores/", mod, "-", task, "-", "result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  
  outcome <- scores
  predictors <- vector(length = NCHANS)
  for (i in 1:NCHANS) {
    name <- paste("eeg", CHANS[i], mod, task, sep = ".")
    predictors[i] <- name
  }
  
  frml <- paste("scores ~ ", paste(predictors, collapse = " + "), sep = "")
  frml <- as.formula(frml)
  
  model <- lm(formula = frml, data = df)
  output <- capture.output(summary(model))
  cat(output, file = output_file, append = TRUE, sep = "\n")
  return(model)
}

run_correlation <- function(data) {
  task_scores <- read.csv("survey_analysis/extracted/complete-task_scores.csv")
  task_scores <- relative_scores(task_scores)

  tasks <- c("yesno", "open", "cloze")
  mods <- c("fe", "vb")
  
  for (task in tasks) {
    for (mod in mods) {
       scores_colname <- paste(toupper(mod), task, "rel", sep = ".")
       corr <- calc_correlation(data, task_scores[,scores_colname], mod, task)
       
       for (iChan in 1:NCHANS) {
         ch <- CHANS[iChan]
         eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
         print(paste("Selecting", scores_colname, eeg_colname))
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
