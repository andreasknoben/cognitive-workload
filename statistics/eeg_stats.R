# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")

#' Check the data for normality
#'
#' For each channel, tests the channel data for normality using a Shapiro-Wilk test.
#' If normality is violated, the channel is added to a vector.
#' @param control The vector with control data
#' @param treatment The vector with treatment data
#' @return Returns a vector with the channels for which normality is violated
#' 
check_assumptions <- function(control, treatment) {
  norm_viol <- vector()

  for (iChan in 1:NCHANS) {
    control_data <- control[iChan][!is.na(control[iChan])]
    if (normality(control_data) == 0) {
      norm_viol <- c(norm_viol, CHANS[iChan])
    }
    
    treatment_data <- treatment[iChan][!is.na(treatment[iChan])]
    if (normality(treatment_data) == 0) {
      norm_viol <- c(norm_viol, CHANS[iChan])
    }
  }
  return(norm_viol)
}


#' Run the appropriate statistical test on the data
#'
#' For each channel, perform
#'    a. Welch's independent t-test if normality is not violated;
#'    b. Mann-Whitney U test if normality is violated.
#' Prints the test results into a target file.
#' @param control The vector with control data
#' @param treatment The vector with treatment data
#' @param norm_viol Vector with channels for which normality is violated
#' @param output Output folder
#' 
statistical_test <- function(control, treatment, norm_viol, task, mod) {
  output_file = paste("eeg_processing/results/statistics/statistical-tests/", mod, "-", task, "-", "result.txt", sep = "")
  cat(paste("Statistics generated at", Sys.time(), sep = " "), file = output_file, append = FALSE, sep = "\n")
  
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    test_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    
    if (CHANS[iChan] %in% norm_viol) {
      test <- wilcox.test(indices ~ condition, data = test_data, na.action = "na.omit")
    } else {
      test <- t.test(indices ~ condition, data = test_data, var.equal = FALSE, na.action = "na.omit")
    }

    cat(CHANS[iChan], file = output_file, append = TRUE, sep = "")
    cat(": \t", file = output_file, append = TRUE, sep = "")
    cat(toString(test), file = output_file, append = TRUE, sep = "\n")
  }
}


#' Plots the EEG Engagement Indices
#'
#' For each channel, it creates a boxplot showing the control and treatment groups.
#' It saves these plots in the target folder.
#' @param control_fe The vector with control FE data
#' @param treatment The vector with treatment FE data
#' @param control_vb The vector with control VB data
#' @param treatment_vb The vector with treatment VB data
#' @param task String indicating the task to be processed
#' 
plot_data <- function(control_fe, treatment_fe, control_vb, treatment_vb, task) {
  # Create string with target output folder
  output_loc <- paste("eeg_processing/results/plots/", task, "/", sep = "")
  
  # Create svg plot for each channel
  for (iChan in 1:NCHANS) {
    concat_data <- c(control_fe[iChan], control_vb[iChan], treatment_fe[iChan], treatment_vb[iChan])
    plt_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS),
                           model = rep(c("FE", "VB", "FE", "VB"), each = NPARTS/2),
                           indices = unlist(concat_data))
    
    plot <- ggplot(data = na.omit(plt_data)) +
      geom_boxplot(aes(x = model, y = indices, fill = condition), width = 0.8) +
      labs(title = CHANS[iChan]) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_text(size = 30),
            axis.text.y = element_text(size = 26),
            plot.title = element_text(size = 36, hjust = 0.5),
            legend.position = "none"
            )
    
    ggsave(paste(output_loc, "chan", CHANS[iChan], ".svg", sep=""), plot = plot, width = 5, height = 5)
  }
}


#' Plots EEG Engagement Index course over the three tasks
#' 
#' Generates a plot for each channel with the course of the EEG Engagement Index
#' for each condition and model combination.
#' @param eeg A list containing all EEG dataframes.
#' 
time_plots <- function(eeg) {
  for (iChan in 1:NCHANS) {
    # Plot mean for yesno, open, cloze
    plt_data <- data.frame(condition = rep(c("Control FE", "Control VB", "Treatment FE", "Treatment VB"), each = 3),
                           task = factor(rep(c("Yes/no", "Problem-solving", "Cloze"), times = 4), levels = c("Yes/no", "Problem-solving", "Cloze")),
                           index = c(mean(unlist(eeg[[1]][iChan]), na.rm = TRUE), mean(unlist(eeg[[5]][iChan]), na.rm = TRUE), mean(unlist(eeg[[9]][iChan]), na.rm = TRUE),
                                     mean(unlist(eeg[[2]][iChan]), na.rm = TRUE), mean(unlist(eeg[[6]][iChan]), na.rm = TRUE), mean(unlist(eeg[[10]][iChan]), na.rm = TRUE),
                                     mean(unlist(eeg[[3]][iChan]), na.rm = TRUE), mean(unlist(eeg[[7]][iChan]), na.rm = TRUE), mean(unlist(eeg[[11]][iChan]), na.rm = TRUE),
                                     mean(unlist(eeg[[4]][iChan]), na.rm = TRUE), mean(unlist(eeg[[8]][iChan]), na.rm = TRUE), mean(unlist(eeg[[12]][iChan]), na.rm = TRUE)))
    
    plot <- ggplot(data = plt_data, aes(x = task, y = index, group = condition, color = condition)) +
      geom_point() + 
      geom_line(size = 1.5) +
      geom_point(size = 1.5) +
      labs(title = CHANS[iChan]) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.text.y = element_text(size = 20),
            plot.title = element_text(size = 28, hjust = 0.5),
            legend.position = "none") + 
      scale_color_manual(values = c("seagreen2", "seagreen4", "deepskyblue2", "deepskyblue4"))
    
    ggsave(paste("eeg_processing/results/plots/time/chan", CHANS[iChan], ".svg", sep=""), plot = plot, width = 3.25, height = 3.75)
  }
}


#' Runs the EEG statistics with the correct data
#' 
run <- function() {
  eeg_data <- load_eeg()
  tasks <- c("yesno", "open", "cloze")
  
  time_plots(eeg_data)

  for (i in 1:length(tasks)) {
    listidx <- i + (i-1) * 3
    
    curr_task <- tasks[i]
    control_fe <- eeg_data[[listidx]]
    control_vb <- eeg_data[[listidx+2]]
    treatment_fe <- eeg_data[[listidx+1]]
    treatment_vb <- eeg_data[[listidx+3]]
    
    norm_violated_fe <- check_assumptions(control_fe, treatment_fe)
    statistical_test(control_fe, treatment_fe, norm_violated_fe, curr_task, "FE")
    
    norm_violated_vb <- check_assumptions(control_vb, treatment_vb)
    statistical_test(control_vb, treatment_vb, norm_violated_vb, curr_task, "VB")
    
    plot_data(control_fe, treatment_fe, control_vb, treatment_vb, curr_task)
  }
}

run()
