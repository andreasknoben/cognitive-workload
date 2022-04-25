setwd("~/Nextcloud/Projects/cognitive-workload/")

relative_scores <- function(scores) {
  scores$FE.yesno.rel <- scores$FE.yesno / 11
  scores$VB.yesno.rel <- scores$VB.yesno / 10
  scores$FE.open.rel <- scores$FE.open.correct / scores$FE.open.total
  scores$VB.open.rel <- scores$VB.open.correct / scores$VB.open.total
  scores$FE.cloze.rel <- scores$FE.cloze / 45
  scores$VB.cloze.rel <- scores$VB.cloze / 45
  
  return(scores)
}

normality <- function(data) {
  test <- shapiro.test(data)
  print(test)
  if (test$p.value < 0.05) {
    return(0)
  } else {
    return(1)
  }
}

statistical_test <- function(task, mod, taskstr) {
  if (normality(task) == 1) {
    test <- t.test(task ~ task.scores$condition, var.equal = FALSE)
  } else {
    test <- wilcox.test(task ~ task.scores$condition)
  }
  return(test)
}

run_tests <- function(df) {
  output_file = "survey_analysis/results/statistical-test.txt"
  cat(paste("FE yes/no", toString(statistical_test(df$FE.yesno.rel)), sep = "\t"), file = output_file, sep = "\n", append = FALSE)
  cat(paste("VB yes/no", toString(statistical_test(df$VB.yesno.rel)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("FE open", toString(statistical_test(df$FE.open.rel)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("VB open", toString(statistical_test(df$VB.open.rel)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("FE cloze", toString(statistical_test(df$FE.cloze.rel)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
  cat(paste("VB cloze", toString(statistical_test(df$VB.cloze.rel)), sep = "\t"), file = output_file, sep = "\n", append = TRUE)
}

task.scores <- read.csv("survey_analysis/extracted/complete-task_scores.csv")
task.scores <- relative_scores(task.scores)
run_tests(task.scores)