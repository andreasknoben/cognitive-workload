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
  cat("Statistics generated for the problem-solving questions", file = output, append = FALSE, sep = "\n")
  
  for (iChan in 1:NCHANS) {
    concat_data <- c(control[iChan], treatment[iChan])
    test_data <- data.frame(condition = rep(c("control", "treatment"), each = NPARTS/2),
                            indices = unlist(concat_data))
    
    if (CHANS[iChan] %in% norm_viol) {
      test = wilcox.test(indices ~ condition, data = test_data)
    } else {
      test = t.test(indices ~ condition, data = test_data, var.equal = FALSE, na.rm = TRUE)
    }
    cat(CHANS[iChan], file = output, append = TRUE, sep = "")
    cat(": \t", file = output, append = TRUE, sep = "")
    cat(toString(test), file = output, append = TRUE, sep = "\n")
  }
}

# Read files
open_control_FE <- read.csv("results/open/indices-control-FE.csv")
open_treatment_FE <- read.csv("results/open/indices-treatment-FE.csv")

#Output file
output_file = "results/open/stat_result.txt"

norm_violated = check_assumptions(open_control_FE, open_treatment_FE)
statistical_test(open_control_FE, open_treatment_FE, norm_violated, output_file)
