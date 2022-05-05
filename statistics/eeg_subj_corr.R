# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")

plot_correlation <- function(df, mod, task, chan) {
  output <- paste("statistics/plots/correlation-nasatlx/", task, "/", sep = "")
  
  plot <- ggplot(data = na.omit(df), aes(x = score, y = index, color = factor(condition))) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE) + 
    theme(legend.position = "none")
  
  ggsave(paste(output, mod, "-", task, "-", chan, ".svg", sep = ""), plot = plot, width = 3.25, height = 3.75)
}

calc_correlation <- function(df, ntlx, mod, task, chan) {
  output_file = paste("statistics/tests/correlation-subj/", mod, "-", task, "-", "result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  
  outcome <- ntlx
  predictors <- vector(length = NCHANS)
  for (i in 1:NCHANS) {
    name <- paste("eeg", CHANS[i], mod, task, sep = ".")
    predictors[i] <- name
  }
  
  frml <- paste("outcome ~ ", paste(predictors, collapse = " + "), sep = "")
  frml <- as.formula(frml)
  
  model <- lm(formula = frml, data = df)
  output <- capture.output(summary(model))
  cat(output, file = output_file, append = TRUE, sep = "\n")
  return(model)
}

run_correlation <- function(data) {
  begin_fe <- which(colnames(data) == "fe.nasatlx.1")
  end_fe <- which(colnames(data) == "fe.nasatlx.5")
  begin_vb <- which(colnames(data) == "vb.nasatlx.1")
  end_vb <- which(colnames(data) == "vb.nasatlx.5")
  
  data_fe_ntlx <- data[complete.cases(data[,c(begin_fe:end_fe)]),]
  data_vb_ntlx <- data[complete.cases(data[,c(begin_vb:end_vb)]),]
  
  nasatlx_fe <- data_fe_ntlx$fe.nasatlx.1 + data_fe_ntlx$fe.nasatlx.2 + data_fe_ntlx$fe.nasatlx.3 +
    data_fe_ntlx$fe.nasatlx.4 + data_fe_ntlx$fe.nasatlx.5
  
  nasatlx_vb <- data_vb_ntlx$vb.nasatlx.1 + data_vb_ntlx$vb.nasatlx.2 + data_vb_ntlx$vb.nasatlx.3 +
    data_vb_ntlx$vb.nasatlx.4 + data_vb_ntlx$vb.nasatlx.5
  
  tasks <- c("yesno", "open", "cloze")
  mods <- c("fe", "vb")
  
  for (task in tasks) {
    for (mod in mods) {
      if (mod == "fe") {
        model <- calc_correlation(data_fe_ntlx, nasatlx_fe, mod, task, ch)
        for (iChan in 1:NCHANS) {
          ch <- CHANS[iChan]
          eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
          plotdata <- data.frame(condition = data_fe_ntlx$condition,
                                 index = data_fe_ntlx[,eeg_colname],
                                 score = nasatlx_fe)
          
          plot_correlation(plotdata, mod, task, ch)
        }
      } else if (mod == "vb") {
        model <- calc_correlation(data_vb_ntlx, nasatlx_vb, mod, task, ch)
        for (iChan in 1:NCHANS) {
          ch <- CHANS[iChan]
          eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
          plotdata <- data.frame(condition = data_vb_ntlx$condition,
                                 index = data_vb_ntlx[,eeg_colname],
                                 score = nasatlx_vb)
          
          plot_correlation(plotdata, mod, task, ch)
      }
      
      }
    }
  }
}

all_data <- read.csv("statistics/complete-data/complete-data.csv")
run_correlation(all_data)
