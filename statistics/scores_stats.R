library(ggplot2)

setwd("~/Nextcloud/Projects/cognitive-workload/")

create_long_scores <- function(fe_data, vb_data) {
  long_scores <- vector(length = 116)
  j <- 1
  part <- 1
  for (i in 1:116) {
    if (j == 1) {
      long_scores[i] = fe_data[part]
      j <- 2
    } else if (j == 2) {
      long_scores[i] = vb_data[part]
      j <- 1
      part <- part + 1
    }
  }
  return(long_scores)
}

create_long_form <- function(data) {
  
  long_df <- data.frame(part = rep(data$X, each = 2),
                        condition = rep(data$condition, each = 2),
                        model = rep(c("FE", "VB"), times = 58),
                        yesno = create_long_scores(data$FE.yesno, data$VB.yesno),
                        open.total = create_long_scores(data$FE.open.total, data$VB.open.total),
                        open.correct = create_long_scores(data$FE.open.correct, data$VB.open.correct),
                        cloze = create_long_scores(data$FE.cloze, data$VB.cloze))
  return(long_df)
}

plot_scores <- function(data) {
  yn_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = yesno, fill = condition)) +
    labs(title = "Yes no questions") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("statistics/plots/yesno-scores.svg")
  print(yn_plot)
  dev.off()
  
  opent_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = open.total, fill = condition)) +
    labs(title = "Problem-solving questions (total)") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("statistics/plots/open-total-scores.svg")
  print(opent_plot)
  dev.off()
  
  openc_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = open.correct, fill = condition)) +
    labs(title = "Problem-solving questions (correct)") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("statistics/plots/open-correct-scores.svg")
  print(openc_plot)
  dev.off()
  
  cloze_plot <- ggplot(data = data) + 
    geom_boxplot(aes(x = model, y = cloze, fill = condition)) +
    labs(title = "Cloze test") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("statistics/plots/cloze-scores.svg")
  print(cloze_plot)
  dev.off()
}

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
long <- create_long_form(task.scores)
plot_scores(long)

task.scores <- relative_scores(task.scores)
run_tests(task.scores)