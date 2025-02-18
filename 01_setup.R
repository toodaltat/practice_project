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
# Setting up tools
################################################################################

# input: void

# intent: build functions for cleaning

# output: "preprocess_text" function


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

# intent: LDA model function

# output: perform_lda


# Function to perform LDA using parallel processing
perform_lda <- function(data, column_name, num_topics = 3, num_words = 5, seed = 1234, workers = availableCores() - 1) {
  
  # Set up parallel processing
  plan(multisession, workers = workers)
  
  # Convert text to a Document-Term Matrix (DTM)
  docs <- Corpus(VectorSource(data[[column_name]]))
  dtm <- DocumentTermMatrix(docs)
  
  # Remove empty rows
  row_sums <- rowSums(as.matrix(dtm))
  dtm <- dtm[row_sums > 0, ]
  
  # Fit LDA model in parallel
  lda_model <- future({
    LDA(dtm, k = num_topics, control = list(seed = seed))
  })
  lda_model <- value(lda_model)
  
  # Extract top words per topic
  topic_terms <- terms(lda_model, num_words)
  
  # Convert matrix output to a data frame
  topic_df <- as.data.frame(topic_terms)
  
  # Rename columns for clarity
  colnames(topic_df) <- paste("Topic", 1:num_topics)
  
  # Create a dynamic caption using the column name
  caption_text <- paste("Top Words per Topic (LDA Model) for", column_name)
  
  # Reset future plan back to sequential (prevents issues with nested parallelism)
  plan(sequential)
  
  # Return a formatted table using knitr::kable()
  return(kable(topic_df, caption = caption_text))
}

################################################################################

