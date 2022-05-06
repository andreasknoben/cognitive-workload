library("gvlma")

# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")


#' Creates a scatterplot of the NASA-TLX scores and EEG Engagement Indices
#' 
#' First creates a scatterplot of scores on x and indices on y (by condition),
#' then draws a line through it as the linear model would. These plots are saved to disk.
#' @param df Dataframe with data for plotting
#' @param mod String indicating the model to be processed
#' @param task String indicating the task to be processed
#' @param chan String indicating the channel to be processed
#' 
plot_correlation <- function(df, mod, task, chan) {
  output <- paste("statistics/plots/correlation-nasatlx/", task, "/", sep = "")
  
  plot <- ggplot(data = na.omit(df), aes(x = score, y = index, color = factor(condition))) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE) + 
    theme(legend.position = "none")
  
  ggsave(paste(output, mod, "-", task, "-", chan, ".svg", sep = ""), plot = plot, width = 3.25, height = 3.75)
}


#' Runs a linear regression of channels on NASA-TLX scores
#' 
#' Creates a linear model with all channels as predictors for a task/model
#' and prints the output to a file, where 1 is control and 2 is treatment (in file)
#' @param df Dataframe with all data
#' @param mod String indicating the model to be processed
#' @param task String indicating the task to be processed
#' @return Returns the models created (one for control, one for treatment)
#' 
create_regression <- function(df, ntlx, mod, task) {
  # Create target output folder and file
  output_file = paste("statistics/tests/correlation-subj/", mod, "-", task, "-", "result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  
  # Create outcome and predictor variables
  outcome <- ntlx
  predictors <- vector(length = NCHANS)
  for (i in 1:NCHANS) {
    name <- paste("eeg", CHANS[i], mod, task, sep = ".")
    predictors[i] <- name
  }
  
  frml <- paste("outcome ~ ", paste(predictors, collapse = " + "), sep = "")
  frml <- as.formula(frml)
  
  # Run linear model and write results to file
  models <- df %>% group_by(condition) %>% do(model = lm(formula = frml, data = df))
  output <- capture.output(lapply(models$model, summary))
  cat(output, file = output_file, append = TRUE, sep = "\n")
  
  # Write linear model assumptions to file
  assumptions <- capture.output(lapply(models$model, gvlma))
  cat(assumptions, file = output_file, append = TRUE, sep = "\n")
  return(models)
}


#' Helper function to run the correlation
#' 
#' Extracts the NASA-TLX for each model, creates the required dataframes, 
#' then loops over tasks and mods to call the functions with the correct arguments,
#' then loops over channels to create plots.
#' @param data The dataframe with all data
#' 
run_correlation <- function(data) {
  # Extract FE and VB NASA-TLX scores
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
  
  # Loop over tasks and models to run the appropriate regression models,
  # also loop over channels to create correlation plots
  tasks <- c("yesno", "open", "cloze")
  mods <- c("fe", "vb")
  
  for (task in tasks) {
    for (mod in mods) {
      if (mod == "fe") {
        model <- create_regression(data_fe_ntlx, nasatlx_fe, mod, task)
        for (iChan in 1:NCHANS) {
          ch <- CHANS[iChan]
          eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
          plotdata <- data.frame(condition = data_fe_ntlx$condition,
                                 index = data_fe_ntlx[,eeg_colname],
                                 score = nasatlx_fe)
          
          plot_correlation(plotdata, mod, task, ch)
        }
      } else if (mod == "vb") {
        model <- create_regression(data_vb_ntlx, nasatlx_vb, mod, task)
        for (iChan in 1:NCHANS) {
          ch <- CHANS[iChan]
          eeg_colname <- paste("eeg", ch, mod, task, sep = ".")
          plotdata <- data.frame(condition = data_vb_ntlx$condition,
                                 index = data_vb_ntlx[,eeg_colname],
                                 score = nasatlx_vb)
          
          plot_correlation(plotdata, mod, task, ch)
        }
      } else {
        stop("[ERROR] Got unexpected model string")
      }
    }
  }
}

all_data <- read.csv("statistics/complete-data/complete-data.csv")
run_correlation(all_data)
