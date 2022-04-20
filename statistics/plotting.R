setwd("~/Nextcloud/Projects/cognitive-workload/statistics/")

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
  View(long_df)
  return(long_df)
}

plot_scores <- function(data) {
  yn_plot <- ggplot(data = data, aes(x = condition, y = yesno, fill = model)) + 
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Yes no questions", fill = "Model") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("plots/yesno-scores.svg")
  print(yn_plot)
  dev.off()
  
  opent_plot <- ggplot(data = data, aes(x = condition, y = open.total, fill = model)) + 
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Problems-solving (total)", fill = "Model") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("plots/open-total-scores.svg")
  print(opent_plot)
  dev.off()
  
  openc_plot <- ggplot(data = data, aes(x = condition, y = open.correct, fill = model)) + 
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Problems-solving (correct)", fill = "Model") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("plots/open-correct-scores.svg")
  print(openc_plot)
  dev.off()
  
  cloze_plot <- ggplot(data = data, aes(x = condition, y = cloze, fill = model)) + 
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Cloze test", fill = "Model") +
    xlab("Condition") + 
    ylab("Score")
  
  svg("plots/cloze-scores.svg")
  print(cloze_plot)
  dev.off()
}

long <- create_long_form(complete.task_scores)
plot_scores(long)