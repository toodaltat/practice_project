################################################################################
# Loading libraries
################################################################################
packages <- c(
  "broom", "tidyverse", "tidytext", "dplyr", "re", "knitr", "kableExtra",
  "RColorBrewer", "topicmodels", "tm", "stopwords", "future", "future.apply",
  "Hmisc", "stringr", "rlang", "textdata", "wordcloud", "ggplot2", "patchwork"
)

lapply(packages, library, character.only = TRUE)

current_dir <- getwd()
plan(multicore, workers = availableCores() - 1)

################################################################################
# Loading data set and setting save location
################################################################################
plot_folder_path <- paste0(current_dir, "/data/images/")

resume_file <- file.path(current_dir, 'data/resume_data.csv')
resume_df <- read_csv(resume_file)

################################################################################
