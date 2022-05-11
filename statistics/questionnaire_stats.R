# Set working directory and load helper file with libraries, functions
setwd("~/Nextcloud/Projects/cognitive-workload/")
source("statistics/stat_funcs.R")

all_data <- read.csv("statistics/complete-data/complete-data.csv")

long_preq <- function(data, domain) {
  if (domain == "bus") {
    btk26_data <- c(data$BTK.2, data$BTK.3, data$BTK.4, data$BTK.5, data$BTK.6)
    btk_df <- data.frame(subj = rep(data$subj, times = 5),
                         condition = rep(data$condition, times = 5),
                         question = rep(c("BTK.2", "BTK.3", "BTK.4", "BTK.5", "BTK.6"), each = 58),
                         BTK = btk26_data)
    return(btk_df)
  } else if (domain == "machine") {
    rfk26_data <- c(data$RFK.2, data$RFK.3, data$RFK.4, data$RFK.5, data$RFK.6)
    rfk_df <- data.frame(subj = rep(data$subj, times = 5),
                         condition = rep(data$condition, times = 5),
                         question = rep(c("RFK.2", "RFK.3", "RFK.4", "RFK.5", "RFK.6"), each = 58),
                         RFK = rfk26_data)
    return(rfk_df)
  }
  
}

plot_btk <- function(data) {
  btk1 <- table(data$BTK.1)
  btk1_rel <- btk1 / length(data$BTK.1)
  btk1_rel <- as.data.frame(btk1_rel)
  btk1_rel$Var1 <- factor(btk1_rel$Var1, levels=c("Very low", "Low", "Somewhat low",
                                                  "Neither low nor high", "Somewhat high",
                                                  "High", "Very high"))
  btk1_rel[6,] <- list("High", 0.)
  btk1_rel[7,] <- list("Very high", 0)

  btk1plot <- ggplot(data = btk1_rel, aes(x = Var1, y = Freq, fill = Var1)) + 
    geom_bar(stat = "identity", width = 0.6) +
    coord_flip() +
    scale_x_discrete(limits=rev) +
    labs(title = "Level of knowledge of organising a bus tour company") +
    xlab("Answer") + 
    ylab("Frequency") + 
    ylim(c(0, 1)) +
    theme(plot.title = element_text(size = 14),
          axis.text.y = element_text(size = 12),
          axis.text.x = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.position = "none")
  ggsave("survey_analysis/results/pre-experiment/btk1.svg", plot = btk1plot, device = "svg", width = 7.5, height = 5)
  
  long_btk <- long_preq(data, "bus")
  btk_26 <- table(long_btk$question, long_btk$BTK)
  btk_26 <- as.data.frame(btk_26)
  
  btk_26$rel.freq <- btk_26$Freq / aggregate(Freq ~ Var1, FUN = sum, data = btk_26)$Freq
  
  btk26plot <- ggplot(data = btk_26, aes(x = Var1, y = rel.freq, fill = Var2)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.6) +
    coord_flip() +
    scale_x_discrete(limits=rev) +
    labs(title = "Pre-experiment domain knowledge: bus trips",
         fill = "Answer") +
    xlab("Question") + 
    ylab("Frequency") + 
    ylim(c(0, 1)) +
    theme(plot.title = element_text(size = 14),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(breaks = c("Yes", "No"))
  ggsave("survey_analysis/results/pre-experiment/btk26.svg", plot = btk26plot, device = "svg", width = 6, height = 5)
}

plot_rfk <- function(data) {
  rfk1 <- table(data$RFK.1)
  rfk1_rel <- rfk1 / length(data$RFK.1)
  rfk1_rel <- as.data.frame(rfk1_rel)
  rfk1_rel$Var1 <- factor(rfk1_rel$Var1, levels=c("Very Low", "Low", "Somewhat low",
                                                  "Neither low nor high", "Somewhat high",
                                                  "High", "Very high"))
  rfk1_rel[6,] <- list("High", 0.)
  rfk1_rel[7,] <- list("Very high", 0)
  
  rfk1plot <- ggplot(data = rfk1_rel, aes(x = Var1, y = Freq, fill = Var1)) + 
    geom_bar(stat = "identity", width = 0.6) +
    coord_flip() +
    scale_x_discrete(limits=rev) +
    labs(title = "Level of knowledge of organising a machine repair facility") +
    xlab("Answer") + 
    ylab("Frequency") + 
    ylim(c(0, 1)) +
    theme(plot.title = element_text(size = 14),
          axis.text.y = element_text(size = 12),
          axis.text.x = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.position = "none")
  ggsave("survey_analysis/results/pre-experiment/rfk1.svg", plot = rfk1plot, device = "svg", width = 7.5, height = 5)
  
  long_rfk <- long_preq(data, "machine")
  rfk_26 <- table(long_rfk$question, long_rfk$RFK)
  rfk_26 <- as.data.frame(rfk_26)
  
  rfk_26$rel.freq <- rfk_26$Freq / aggregate(Freq ~ Var1, FUN = sum, data = rfk_26)$Freq
  
  rfk26plot <- ggplot(data = rfk_26, aes(x = Var1, y = rel.freq, fill = Var2)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.6) +
    coord_flip() +
    scale_x_discrete(limits=rev) +
    labs(title = "Pre-experiment domain knowledge: machinery repair",
         fill = "Answer") +
    xlab("Question") + 
    ylab("Frequency") + 
    ylim(c(0, 1)) +
    theme(plot.title = element_text(size = 14),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16)) +
    scale_fill_discrete(breaks = c("Yes", "No"))
  ggsave("survey_analysis/results/pre-experiment/rfk26.svg", plot = rfk26plot, device = "svg", width = 6, height = 5)
}

plot_btk(all_data)
plot_rfk(all_data)
