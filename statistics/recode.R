library(dplyr)

questionnaire <- read.csv("survey_analysis/extracted/questionnaire-answers.csv")

recode_yesno <- function(col) {
  recoded_col <- recode(col, No = 0, Yes = 1)
  return(recoded_col)
}

recode_likert <- function(col, term) {
  if (term == "high") {
    recoded_col <- recode(col, 'Very low' = 1, 'Low' = 2, 'Somewhat low' = 3, 'Neither low nor high' = 4,
                          'Somewhat high' = 5, 'High' = 6, 'Very high' = 7, 'Very Low' = 1, .default = NA_real_)
  } else if (term == "agree") {
    recoded_col <- recode(col, 'Strongly disagree' = 1, 'Disagree' = 2, 'Somewhat disagree' = 3, 'Neither agree nor disagree' = 4,
                          'Somewhat agree' = 5, 'Agree' = 6, 'Strongly agree' = 7, .default = NA_real_)
  }
  
  return(recoded_col)
}

recode_questionnaire <- function(qdf) {
  recoded <- data.frame(age = qdf$age)
  recoded$gender <- recode(qdf$gender, Female = 0, Male = 1)
  recoded$erd.exp <- recode_yesno(qdf$erd.exp)
  recoded$db.exp <- recode_likert(qdf$db.exp, "high")
  recoded$BTK.1 <- recode_likert(qdf$BTK.1, "high")
  recoded$BTK.2 <- recode_yesno(qdf$BTK.2)
  recoded$BTK.3 <- recode_yesno(qdf$BTK.3)
  recoded$BTK.4 <- recode_yesno(qdf$BTK.4)
  recoded$BTK.5 <- recode_yesno(qdf$BTK.5)
  recoded$BTK.6 <- recode_yesno(qdf$BTK.6)
  recoded$RFK.1 <- recode_likert(qdf$RFK.1, "high")
  recoded$RFK.2 <- recode_yesno(qdf$RFK.2)
  recoded$RFK.3 <- recode_yesno(qdf$RFK.3)
  recoded$RFK.4 <- recode_yesno(qdf$RFK.4)
  recoded$RFK.5 <- recode_yesno(qdf$RFK.5)
  recoded$RFK.6 <- recode_yesno(qdf$RFK.6)
  recoded$understand.1 <- recode_likert(qdf$understand.1, "agree")
  recoded$understand.2 <- recode_likert(qdf$understand.2, "agree")
  recoded$use.1 <- recode_likert(qdf$use.1, "agree")
  recoded$use.2 <- recode_likert(qdf$use.2, "agree")
  recoded$load <- recode_likert(qdf$load, "agree")
  recoded$eng.1 <- recode_likert(qdf$eng.1, "agree")
  recoded$eng.2 <- recode_likert(qdf$eng.2, "agree")
  recoded$eng.3 <- recode_likert(qdf$eng.3, "agree")
  
  return(recoded)
}

recoded.questionnaire <- recode_questionnaire(questionnaire)
