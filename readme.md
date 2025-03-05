# Resume Data Processing and NLP Analysis

## Overview

This project focuses on processing and analyzing resume data using NLP.
The analysis includes data cleaning, text preprocessing, topic modeling,
sentiment analysis and n-gram extraction.

## Features

-   **Data Cleaning**: Removes unnecessary words, fills missing values,
    and processes text columns.
-   **Text Preprocessing**: Converts text to lowercase, removes
    punctuation, and filters stopwords.
-   **Bigram Extraction**: Identifies frequently occurring word pairs in
    resume descriptions.
-   **Topic Modeling (LDA)**: Extracts key topics from resume text data.
-   **Sentiment Analysis**: Analyzes sentiment polarity using the Bing
    lexicon.

## Installation

### Dependencies

R version 4.4.0 (2024-04-24 ucrt) – “Puppy Cup”

Ensure you have the following R packages installed:

    install.packages(c("broom", "tidyverse", "tidytext", "dplyr", "re", "knitr",
                       "kableExtra", "RColorBrewer", "topicmodels", "tm", "stopwords",
                       "future", "future.apply", "Hmisc", "stringr", "rlang", "textdata",
                       "wordcloud", "ggplot2", "patchwork"))

## Setup

1.  Pull the data set from Kaggle:
    <https://www.kaggle.com/datasets/saugataroyarghya/resume-dataset>

2.  Clone the repository and set your working directory:

        current_dir <- getwd()

3.  Load the dataset:

        resume_file <- file.path(current_dir, 'data/resume_data.csv')
        resume_df <- read_csv(resume_file)

4.  Load necessary scripts:

        source("00_libraries.R")
        source("01_tools.R")

## Functions

### 1. `occurrences_counter()`

Counts occurrences of unique values in a specified column.

    data %>% occurrences_counter("column_name", "output_name")

### 2. `clean_column()`

Removes specific words from a text column.

    data %>% clean_column("column_name", c("word1", "word2"))

### 3. `preprocess_text()`

Processes text by removing punctuation, converting to lowercase, and
filtering stopwords.

    preprocess_text("sample text here")

### 4. `generate_bigrams()`

Extracts common n-grams from a text column.

    data %>% generate_bigrams("column_name", score_threshold = 0.8, max_n = 5)

### 5. `perform_lda()`

Performs topic modeling using LDA.

    data %>% perform_lda("column_name", num_topics = 3, num_words = 5)

### 6. `perform_sentiment_analysis()`

Analyzes sentiment distribution using the Bing lexicon.

    data %>% perform_sentiment_analysis("column_name")

## Data Processing

### Cleaning

-   Fills missing language fields with “English”.
-   Removes unwanted words from specific text columns.

### Preprocessing

-   Applies `preprocess_text()` to clean text columns.
-   Uses `future_lapply()` for efficient parallel processing.

## Output

-   Cleaned resume dataset.
-   Visualizations for sentiment analysis and topic modeling.

## Future Enhancements

-   Have a clear goal of "who" I am doing an analysis for. This will aid in
    directing me in what comparisons ill be looking for. == What part of the community
    is the dataset pulled from, who would be interested in it. Narrow down the scope.

-   Improve item recognition to classify skills, job titles and degree
    names. == Either look for a pattern or load a dictionary to work against.
    
-   Research and then implement more robust text classification models.
    == Identify what makes a text classification model robust.
    
-   Have a better grip on cleaning text methods. == Take snippets of text and test processes on them to find          faults.

-   Don't just 'git add .' as it makes my 'git commit -m "****"' less clear.

### For this project

-   Language department, look to see if people that aren't monolingual have higher
    'match score'. Is there a common theme with jobs that non-monolingual go for.
    
-   Education department, check for what majors look for what companies to set up a
    bridging program. Skills required to enter job market, this web page goes through
    a sound step by step process; https://www.kaggle.com/code/sonawanelalitsunil/skills-required-to-get-job-in-market

-   Run a TF-IDF on rows to look for unique words.