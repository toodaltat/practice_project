################################################################################
# Loading neccasary scripts
################################################################################

source("00_libraries.R")

################################################################################
# Setting up dataframe
################################################################################

# input: resume_df

# intent: dropping unwanted columns

# output: resume_df


resume_df <- resume_df %>% select(-address, -passing_years, -educational_results,
                                  -result_types, -company_urls, -start_dates, -end_dates,
                                  -locations, -extra_curricular_activity_types, -extra_curricular_organization_names,
                                  -extra_curricular_organization_links, -role_positions, -certification_providers, -certification_skills,
                                  -online_links, -issue_dates, -expiry_dates, -age_requirement)


################################################################################
# Gather occurrences
################################################################################

# input: resume_df

# intent: Add occurrence of selected columns 

# output: resume_df with occurrence column added

occurrences_counter <- function(data, column_name, output_name) {
  data %>%
    mutate(cleaned_name = tolower(.data[[column_name]])) %>%
    group_by(cleaned_name) %>%
    mutate(!!output_name := n()) %>%
    ungroup() %>%
    arrange(desc(.data[[output_name]])) %>%
    select(-cleaned_name)
}


################################################################################
# Cleans a selected list of words from a column
################################################################################

# input:

# intent:

# output:

clean_column <- function(data, column_name, word_removal) {
  
  # Construct regex pattern for removal and apply pattern using gsub
  pattern <- paste0("\\b(", paste(word_removal, collapse = "|"), ")\\b")
  data[[column_name]] <- gsub(pattern, "", data[[column_name]], ignore.case = TRUE)
  
  # Remove extra spaces
  data[[column_name]] <- trimws(gsub("\\s+", " ", data[[column_name]]))
  
  return(data)
}


################################################################################
# Setting up NLP tools
################################################################################

# input: void

# intent: build functions for cleaning

# output: preprocess_text()


# Preprocess Text function
stopwords_english <- stopwords("en")

preprocess_text <- function(text) {
  # Check if text is NA or empty
  if (is.na(text) | text == "") return("")
  
  # Convert to lowercase
  clean_text <- tolower(text)
  
  # Replace punctuation with spaces using gsub (including other punctuation marks)
  clean_text <- gsub("[[:punct:]]+", " ", clean_text)
  
  # Replace single hyphens with spaces
  clean_text <- gsub("\\s-\\s", " ", clean_text)
  
  # Split by whitespace (including commas) and remove stopwords
  tokens <- unlist(strsplit(clean_text, "\\s+"))
  
  # Remove stopwords
  processed_tokens <- tokens[!(tokens %in% stopwords_english)]
  
  # Return a cleaned string, joined by spaces
  cleaned_text <- paste(processed_tokens, collapse = " ")
  
  return(cleaned_text)
}


################################################################################

# input: void

# intent: N-grams function

# output: generate_bigrams() which produces a kable table


generate_bigrams <- function(data_frame, column_name, score_threshold = 0.8, max_n = 5) {
  
  # Compute average word count per row
  avg_word_count <- data_frame %>%
    mutate(word_count = str_count(data_frame[[column_name]], "\\S+")) %>%
    summarise(avg_words = mean(word_count, na.rm = TRUE)) %>%
    pull(avg_words)
  
  # Cap n at max_n
  n_value <- min(round(avg_word_count), max_n)
  
  print(paste("Using n =", n_value))
  
  # Generate n-grams
  bigrams <- data_frame %>%
    select(all_of(column_name), matched_score) %>% 
    drop_na(all_of(column_name), matched_score) %>%  # Ensure no missing values
    filter(matched_score > score_threshold) %>% 
    unnest_tokens(bigram, all_of(column_name), token = "ngrams", n = n_value) %>%
    count(bigram, sort = TRUE)
  
  # Return formatted table
  return(kable(bigrams, caption = paste("Most Common", n_value, "-grams in", column_name)))
}


################################################################################

# input: void

# intent: LDA model function which returns topic word probability

# output: perform_lda(), beta:

perform_lda <- function(data, column_name, num_topics = 3, num_words = 5, seed = 1234, workers = availableCores() - 1) {
  
  # Set up parallel processing
  plan(multisession, workers = workers)
  
  # Converts Rows into "documents", Columns into "terms" and Values become word frequencies
  docs <- Corpus(VectorSource(data[[column_name]]))
  dtm <- DocumentTermMatrix(docs)
  
  # Remove empty rows
  row_sums <- rowSums(as.matrix(dtm))
  dtm <- dtm[row_sums > 0, ]
  
  # Fit LDA model in parallel
  lda_model <- future({
    topicmodels::LDA(dtm, k = num_topics, control = list(seed = seed))
  })
  lda_model <- value(lda_model)

  # Extract beta matrix
  beta <- broom::tidy(lda_model, matrix = "beta")
  
  # Reset future plan back to sequential
  plan(sequential)
  
  return(beta)
}


################################################################################

# input:

# intent:

# output:


# Define function for sentiment analysis
perform_sentiment_analysis <- function(data, text_column) {
  text_column <- ensym(text_column)
  
  sentiments <- data %>%
    unnest_tokens(word, !!text_column) %>%
    inner_join(get_sentiments("bing")) %>%
    count(sentiment, sort = TRUE)
  
  # Plot sentiment distribution
  ggplot(sentiments, aes(x = sentiment, y = n, fill = sentiment)) +
    geom_col() +
    theme_minimal()
}

################################################################################
