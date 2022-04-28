library("ggplot2")

setwd("~/Nextcloud/Projects/cognitive-workload/")

source("statistics/stat_funcs.R")

plot_correlation <- function(df, mod, task, chan) {
  output <- paste("statistics/plots/correlation-nasatlx/", "/", sep = "")
  
  plot <- ggplot(data = na.omit(df), aes(x = score, y = index, color = factor(condition))) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE)
  
  ggsave(paste(output, mod, "-", task, "-", chan, ".svg", sep = ""), plot = plot, width = 7, height = 5)
}

calc_correlation <- function(df, mod, task, chan) {
  out <- capture.output(df %>%
                          group_by(condition) %>%
                          summarize(cor = cor(index, score, use = "complete.obs")))
  
  return(out)
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
      output_file = paste("statistics/tests/correlation-subj/", mod, "-", task, "-", "result.txt", sep = "")
      cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
      if (mod == "fe") {
        for (iChan in 1:NCHANS) {
          ch <- CHANS[iChan]
          eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
          plotdata <- data.frame(condition = data_fe_ntlx$condition,
                                 index = data_fe_ntlx[,eeg_colname],
                                 score = nasatlx_fe)
          
          corr <- calc_correlation(plotdata, mod, task, ch)
          cat(CHANS[iChan], file = output_file, append = TRUE, sep = "")
          cat(": \t", file = output_file, append = TRUE, sep = "")
          cat(corr, file = output_file, append = TRUE, sep = "\n")
          
          plot_correlation(plotdata, mod, task, ch)
        }
      } else if (mod == "vb") {
        for (iChan in 1:NCHANS) {
          ch <- CHANS[iChan]
          eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
          plotdata <- data.frame(condition = data_vb_ntlx$condition,
                                 index = data_vb_ntlx[,eeg_colname],
                                 score = nasatlx_vb)
          
          corr <- calc_correlation(plotdata, mod, task, ch)
          cat(CHANS[iChan], file = output_file, append = TRUE, sep = "")
          cat(": \t", file = output_file, append = TRUE, sep = "")
          cat(corr, file = output_file, append = TRUE, sep = "\n")
          
          plot_correlation(plotdata, mod, task, ch)
      }
      
      }
    }
  }
}

all_data <- read.csv("statistics/complete-data/complete-data.csv")
run_correlation(all_data)