# Load libraries
library(ggplot2)

# Set working directory to /eeg_processing/ folder before starting!
setwd("~/Nextcloud/Projects/cognitive-workload/eeg_processing/")

# Set global variables
NPARTS <- 58
NCHANS <- 16
CHANS <- c('Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz')

check_assumptions <- function(control, treatment) {
  # Check assumptions
  norm_viol <- vector()

  for(iChan in 1:NCHANS) {
    control_data <- control[iChan][!is.na(control[iChan])]
    shapiro_test <- shapiro.test(control_data)
    if(shapiro_test$p.value < 0.05) {
      print(paste("(control) Normality of channel ", CHANS[iChan], " violated"))
      norm_viol <- c(norm_viol, CHANS[iChan])
    }
    
    treatment_data <- treatment[iChan][!is.na(treatment[iChan])]
    shapiro_test <- shapiro.test(treatment_data)
    if(shapiro_test$p.value < 0.05) {
      print(paste("(treatment) Normality of channel ", CHANS[iChan], " violated"))
      norm_viol <- c(norm_viol, CHANS[iChan])
    }
  }
  return(norm_viol)
}

statistical_test <- function(control, treatment, norm_viol, output) {
  output_file = paste(output, "stat_result.txt",sep="")
  cat("Statistics generated for the problem-solving questions", file = output_file, append = FALSE, sep = "\n")
  
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    test_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    
    if (CHANS[iChan] %in% norm_viol) {
      test = wilcox.test(indices ~ condition, data = test_data)
    } else {
      test = t.test(indices ~ condition, data = test_data, var.equal = FALSE, na.rm = TRUE)
    }
    cat(CHANS[iChan], file = output_file, append = TRUE, sep = "")
    cat(": \t", file = output_file, append = TRUE, sep = "")
    cat(toString(test), file = output_file, append = TRUE, sep = "\n")
  }
}

plot_data <- function(control, treatment, output) {
  layout <- "
  ######OO####PP######
  ######OO####PP######
  #####LL##MM##NN#####
  #####LL##MM##NN#####
  #AA##BB##CC##DD##EE#
  #AA##BB##CC##DD##EE#
  #####FF##GG##HH#####
  #####FF##GG##HH#####
  ####II###JJ###KK####
  ####II###JJ###KK####
  "
  
  plots <- vector('list', NCHANS)
  
  for (iChan in 1:NCHANS) {
    i <- iChan
    concat_data <- c(control[iChan], treatment[iChan])
    plot_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    plot <- ggplot(data = plot_data) +
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
open_control_FE <- read.csv("results/open/indices-control-FE.csv")
open_treatment_FE <- read.csv("results/open/indices-treatment-FE.csv")

#Output folder
output_dir = "results/open/"

norm_violated = check_assumptions(open_control_FE, open_treatment_FE)
statistical_test(open_control_FE, open_treatment_FE, norm_violated, output_dir)
plot_data(open_control_FE, open_treatment_FE, output_dir)
