################################################################################
# Loading libraries
################################################################################

library(broom)
library(tidyverse)
library(tidytext)
library(dplyr)
library(re)
library(knitr)
library(kableExtra)
library(RColorBrewer)
library(topicmodels)
library(tm)
library(stopwords)
library(future)
library(future.apply)
library(Hmisc)
library(stringr)
library(rlang)
library(textdata)
library(wordcloud)
library(ggplot2)

current_dir <- getwd()
plan(multicore, workers = availableCores() - 1)

################################################################################
# Loading data set
################################################################################

resume_file <- file.path(current_dir, 'data/resume_data.csv')

resume_df <- read_csv(resume_file)

################################################################################
