# Load libraries
library(ggplot2)

source("statistics/stat_funcs.R")

# Set working directory
setwd("~/Nextcloud/Projects/cognitive-workload/")

# Set global variables (constant)
NPARTS <- 58
NCHANS <- 16
CHANS <- c('Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz')


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

  for(iChan in 1:NCHANS) {
    control_data <- control[iChan][!is.na(control[iChan])]
    shapiro_test <- shapiro.test(control_data)
    if(shapiro_test$p.value < 0.05) {
      norm_viol <- c(norm_viol, CHANS[iChan])
    }
    
    treatment_data <- treatment[iChan][!is.na(treatment[iChan])]
    shapiro_test <- shapiro.test(treatment_data)
    if(shapiro_test$p.value < 0.05) {
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
  output_file = paste("eeg_processing/results/statistics/statistical_tests/", mod, "-", task, "-", "result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    test_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    
    if (CHANS[iChan] %in% norm_viol) {
      test <- wilcox.test(indices ~ condition, data = test_data, na.action = "na.omit", conf.int = TRUE)
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
#' @param control The vector with control data
#' @param treatment The vector with treatment data
#' @param output Output folder
#' 
plot_data <- function(control, treatment, task, mod) {
  output <- paste("eeg_processing/results/plots/", task, "/", sep = "")
  # Create svg plot for each channel
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    plt_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                           indices = unlist(concat_data))
    
    plot <- ggplot(data = na.omit(plt_data)) +
      geom_boxplot(aes(x = condition, y = indices),
                   fill = c("#458aff", "#009E73")) +
      labs(title = CHANS[iChan]) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.text.y = element_text(size = 20),
            plot.title = element_text(size = 28, hjust = 0.5))
    
    ggsave(paste(output, mod, "-chan", CHANS[iChan], ".svg", sep=""), plot = plot, width = 3.25, height = 3.75)
  }
}


#' Plots EEG Engagement Index course over the three tasks
#' 
#' Generates a plot for each channel with the course of the EEG Engagement Index
#' for each condition and model combination.
#' @param yn|open|cloze_c|t_FE|VB Data for a task/condition/model
time_plots <- function(yn_c_FE, yn_c_VB, yn_t_FE, yn_t_VB,
                       open_c_FE, open_c_VB, open_t_FE, open_t_VB,
                       cloze_c_FE, cloze_c_VB, cloze_t_FE, cloze_t_VB) {
  for (iChan in 1:NCHANS) {
    # Plot mean for yesno, open, cloze
    plt_data <- data.frame(condition = rep(c("Control FE", "Control VB", "Treatment FE", "Treatment VB"), each = 3),
                           task = factor(rep(c("Yes/no", "Problem-solving", "Cloze"), times = 4), levels = c("Yes/no", "Problem-solving", "Cloze")),
                           index = c(mean(unlist(yn_c_FE[iChan]), na.rm = TRUE), mean(unlist(open_c_FE[iChan]), na.rm = TRUE), mean(unlist(cloze_c_FE[iChan]), na.rm = TRUE),
                                     mean(unlist(yn_c_VB[iChan]), na.rm = TRUE), mean(unlist(open_c_VB[iChan]), na.rm = TRUE), mean(unlist(cloze_c_VB[iChan]), na.rm = TRUE),
                                     mean(unlist(yn_t_FE[iChan]), na.rm = TRUE), mean(unlist(open_t_FE[iChan]), na.rm = TRUE), mean(unlist(cloze_t_FE[iChan]), na.rm = TRUE),
                                     mean(unlist(yn_t_VB[iChan]), na.rm = TRUE), mean(unlist(open_t_VB[iChan]), na.rm = TRUE), mean(unlist(open_t_VB[iChan]), na.rm = TRUE)))
    
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
    
    ggsave(paste("eeg_processing/plots/time/chan", CHANS[iChan], ".svg", sep=""), plot = plot, width = 3.25, height = 3.75)
  }
}

run <- function() {
  eeg_data <- load_eeg()
  
  i <- 1

  while (i < length(eeg_data)) {
    if (i <= 4) {
      curr_task <- "yesno"
    } else if (i > 4 & i <= 8) {
      curr_task <- "open"
    } else {
      curr_task <- "cloze"
    }
    
    if (i <= 2 | i == 5 | i == 6 | i == 9 | i == 10) {
      curr_mod <- "FE"
    } else {
      curr_mod <- "VB"
    }
    
    print(paste("[INFO] Processing", curr_task, curr_mod, sep = " "))
    
    control_data <- eeg_data[[i]]
    treatment_data <- eeg_data[[i+1]]
    
    norm_violated <- check_assumptions(control_data, treatment_data)
    statistical_test(control_data, treatment_data, norm_violated, curr_task, curr_mod)
    plot_data(control_data, treatment_data, curr_task, curr_mod)
    
    i <- i + 2
  }
}

run()

# time_plots(yesno_control_FE, yesno_control_VB, yesno_treatment_FE, yesno_treatment_VB,
#           open_control_FE, open_control_VB, open_treatment_FE, open_treatment_VB,
#           cloze_control_FE, cloze_control_VB, cloze_treatment_FE, cloze_treatment_VB)
