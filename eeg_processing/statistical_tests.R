# Load libraries
library(ggplot2)

# Set working directory to /eeg_processing/ folder before starting!
setwd("~/Nextcloud/Projects/cognitive-workload/eeg_processing/")

# Set global variables
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
check_assumptions <- function(control, treatment) {
  # Check assumptions
  norm_viol <- vector()

  for(iChan in 1:NCHANS) {
    control_data <- control[iChan][!is.na(control[iChan])]
    shapiro_test <- shapiro.test(control_data)
    if(shapiro_test$p.value < 0.05) {
      print(paste("[INFO] (control) Normality of channel ", CHANS[iChan], " violated, p = ", shapiro_test$p.value))
      norm_viol <- c(norm_viol, CHANS[iChan])
    }
    
    treatment_data <- treatment[iChan][!is.na(treatment[iChan])]
    shapiro_test <- shapiro.test(treatment_data)
    if(shapiro_test$p.value < 0.05) {
      print(paste("[INFO] (treatment) Normality of channel ", CHANS[iChan], " violated, p = ", shapiro_test$p.value))
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
statistical_test <- function(control, treatment, norm_viol, output) {
  output_file = paste(output, "stat_result.txt", sep = "")
  cat("Statistics generated", file = output_file, append = FALSE, sep = "\n")
  
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    test_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    
    if (CHANS[iChan] %in% norm_viol) {
      test = wilcox.test(indices ~ condition, data = test_data, na.action = "na.omit")
    } else {
      test = t.test(indices ~ condition, data = test_data, var.equal = FALSE, na.action = "na.omit")
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
plot_data <- function(control, treatment, output) {
  # Create svg plot for each channel
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    plt_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    
    plot <- ggplot(data = na.omit(plt_data)) +
      geom_boxplot(aes(x = condition, y = indices),
                   fill = c("#56B4E9", "#009E73")) +
      labs(title = CHANS[iChan]) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.text.y = element_text(size = 20),
            plot.title = element_text(size = 28, hjust = 0.5))
    
    svg(paste(output, "chan", CHANS[iChan], ".svg", sep=""), width = 3.25, height = 3.75)
    print(plot)
    dev.off()
  }
}

# Read files
control_data <- read.csv("results/cloze/indices-control-FE.csv")
treatment_data <- read.csv("results/cloze/indices-treatment-FE.csv")

# Output folder
output_dir = "results/cloze/"

subsample = TRUE
samplesize = 30

if(subsample) {
  control_data <- head(control_data, samplesize/2)
  treatment_data <- head(treatment_data, samplesize/2)
  NPARTS = samplesize
}

# Call functions
norm_violated = check_assumptions(control_data, treatment_data)
statistical_test(control_data, treatment_data, norm_violated, output_dir)
plot_data(control_data, treatment_data, output_dir)
