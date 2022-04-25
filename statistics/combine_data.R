setwd("~/Nextcloud/Projects/cognitive-workload/")

eeg_data <- function() {
  yesno <- list.files("eeg_processing/data/indices/yesno", full.names = TRUE)
  open <- list.files("eeg_processing/data/indices/open", full.names = TRUE)
  cloze <- list.files("eeg_processing/data/indices/cloze", full.names = TRUE)
  
  eeg <- sapply(yesno, read.csv, simplify = FALSE, USE.NAMES = TRUE)
  eeg <- append(eeg, sapply(open, read.csv, simplify = FALSE, USE.NAMES = TRUE))
  eeg <- append(eeg, sapply(cloze, read.csv, simplify = FALSE, USE.NAMES = TRUE))
  names(eeg) <- c("yesno.control.FE", "yesno.control.VB", "yesno.treatment.FE", "yesno.treatment.VB",
                  "open.control.FE", "open.control.VB", "open.treatment.FE", "open.treatment.VB",
                  "cloze.control.FE", "cloze.control.VB", "cloze.treatment.FE", "cloze.treatment.VB")
  
  return(eeg)
}

parse_order <- function(order) {
  first <- substr(order, 3, 4)
  first[first == "FE"] <- 1
  first[first == "VB"] <- 0
  return(first)
}

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
        colnames[i] = colname
        i = i + 1
      }
    }
  }
  return(colnames)
}

create_wide_data <- function(eeg, scores, question) {
  df <- data.frame(subj = c(1:58),
                   condition = scores$condition,
                   fe.first = parse_order(scores$order),
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
      iControl = iControl + 1
    } else {
      df[i, eeg_colnames] <- eeg_treatment[iTreatment,]
      iTreatment = iTreatment + 1
    }
  }

  task_cols <- colnames(scores)[c(4:length(colnames(scores)))]
  df[,task_cols] <- scores[c(4:ncol(scores))]
  
  question_cols <- colnames(question)[c(4:length(colnames(question)))]
  df[,question_cols] <- question[c(4:ncol(question))]

  return(df)
}

eeg.index <- eeg_data()
task.scores <- read.csv("survey_analysis/extracted/complete-task_scores.csv")
questionnaire <- read.csv("survey_analysis/extracted/questionnaire-answers.csv")

complete.data <- create_wide_data(eeg.index, task.scores, questionnaire)
write.csv(complete.data, "statistics/complete-data/complete-data.csv", row.names = FALSE)
