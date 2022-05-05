# Load helper file with libraries, functions, and working directory setting
source("statistics/stat_funcs.R")


#' Create a list of EEG dataframes
#' 
#' Loads the CSV files containing the EEG Engagement Indices from a list of
#' file names, and adds the imported dataframes together in a list
#' @return Returns a list with all the EEG Engagement Indices dataframes
#' 
load_eeg_data <- function() {
  # Create file lists
  yesno <- list.files("eeg_processing/data/indices/yesno", full.names = TRUE)
  open <- list.files("eeg_processing/data/indices/open", full.names = TRUE)
  cloze <- list.files("eeg_processing/data/indices/cloze", full.names = TRUE)
  
  # Add all data in list into one dataframe "eeg"
  eeg <- sapply(yesno, read.csv, simplify = FALSE, USE.NAMES = TRUE)
  eeg <- append(eeg, sapply(open, read.csv, simplify = FALSE, USE.NAMES = TRUE))
  eeg <- append(eeg, sapply(cloze, read.csv, simplify = FALSE, USE.NAMES = TRUE))
  names(eeg) <- c("yesno.control.FE", "yesno.control.VB", "yesno.treatment.FE", "yesno.treatment.VB",
                  "open.control.FE", "open.control.VB", "open.treatment.FE", "open.treatment.VB",
                  "cloze.control.FE", "cloze.control.VB", "cloze.treatment.FE", "cloze.treatment.VB")
  
  return(eeg)
}


#' Parses the order variable such that FE first gets a 1, VB first gets a zero
#' 
#' @param order The original vector with the order variable
#' @return Returns a vector with 1s where FE is first; 0s where VB is first
#' 
parse_order <- function(order) {
  first <- substr(order, 3, 4)
  first[first == "FE"] <- 1
  first[first == "VB"] <- 0
  return(first)
}


#' Generates the column names for the final dataframe
#' 
#' Generates column names with all combinations of models, tasks, and channels
#' @return Returns a vector with the column names
#' 
generate_eeg_colnames <- function() {
  mods <- c("fe", "vb")
  tasks <- c("yesno", "open", "cloze")
  chans <- c('Fp1', 'Fp2', 'F3', 'Fz', 'F4', 'T7', 'C3', 'Cz', 'C4', 'T8', 'P3', 'Pz', 'P4', 'PO7', 'PO8', 'Oz')

  colnames <- vector(length = length(mods) * length(tasks) * length(chans))
  i = 1
  for (mod in mods) {
    for (task in tasks) {
      for (chan in chans) {
        colname <- paste("eeg", chan, mod, task, sep = ".")
        colnames[i] <- colname
        i <- i + 1
      }
    }
  }
  return(colnames)
}


#' Creates a dataframe in wide format of all supplied data
#' 
#' @param eeg The EEG Engagement Indices dataframes list
#' @param scores The dataframe containing the scores on the tasks
#' @param question The dataframe containing the other questionnaire answers
#' @return Returns the dataframe containing all data in wide format
#' 
create_wide_data <- function(eeg, scores, question) {
  df <- data.frame(subj = c(1:58),
                   condition = scores$condition,
                   fe_first = parse_order(scores$order),
                   age = question$age,
                   gender = question$gender)
  
  eeg_colnames <- generate_eeg_colnames()
  df[,eeg_colnames] <- NA

  eeg_control <- do.call("cbind", eeg[c(1,2,5,6,9,10)])
  eeg_treatment <- do.call("cbind", eeg[c(3,4,7,8,11,12)])
  
  iControl <- 1
  iTreatment <- 1
  for (i in 1:nrow(df)) {
    if (df[i, "condition"] == "control") {
      df[i, eeg_colnames] <- eeg_control[iControl,]
      iControl <- iControl + 1
    } else {
      df[i, eeg_colnames] <- eeg_treatment[iTreatment,]
      iTreatment <- iTreatment + 1
    }
  }

  task_cols <- colnames(scores)[c(4:length(colnames(scores)))]
  df[,task_cols] <- scores[c(4:ncol(scores))]
  
  question_cols <- colnames(question)[c(4:length(colnames(question)))]
  df[,question_cols] <- question[c(4:ncol(question))]

  return(df)
}

# Load all data files: EEG Engagement Indices, task scores, questionnaire answers
eeg_index <- load_eeg_data()
task_scores <- read.csv("survey_analysis/extracted/complete-task_scores.csv")
questionnaire <- read.csv("survey_analysis/extracted/questionnaire-answers.csv")

# Create complete data and write to CSV
complete_data <- create_wide_data(eeg.index, task.scores, questionnaire)
write.csv(complete_data, "statistics/complete-data/complete-data.csv", row.names = FALSE)
