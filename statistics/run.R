# Load libraries
library(ggplot2)

# Set working directory to /eeg_processing/ folder before starting!
setwd("~/Nextcloud/Projects/cognitive-workload/statistics")

# Load functions
source("statistics/eeg_stats.R")

# Set global variables (constant)
parts <- 58
chans <- 16
chan_labels <- c('Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz')

# Load full dataframe
data <- read.csv("complete-data.csv")
