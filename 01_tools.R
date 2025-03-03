################################################################################
source("00_libraries.R")
################################################################################
# Gather occurrences
################################################################################

#' @param data A data frame containing the column to analyze.
#' @param column_name The name of the column for which occurrences should be counted.
#' @param output_name The name of the new column that will store the occurrence count.
#' @return The original data frame with an additional column containing the count of occurrences per unique value in `column_name`.
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

#' @param data A data frame containing the column to be cleaned.
#' @param column_name The name of the column to process.
#' @param word_removal A vector of words to remove from the specified column.
#' @return The modified data frame with specified words removed from `column_name`, and extra spaces trimmed.

clean_column <- function(data, column_name, word_removal) {
  data[[column_name]] <- str_remove_all(data[[column_name]], regex(paste(word_removal, collapse = "|"), ignore_case = TRUE))
  
  # Remove extra spaces
  data[[column_name]] <- trimws(gsub("\\s+", " ", data[[column_name]]))
  
  return(data)
}


################################################################################
# Setting up NLP tools
################################################################################

# Setting stopwords to English lexicon.
stopwords_english <- stopwords("en")


#' @param text A character string containing text to preprocess.
#' @return A cleaned character string with punctuation removed, stopwords filtered out, and normalized whitespace.

preprocess_text <- function(text) {
  if (is.na(text) | text == "") return("")
  
  # Convert to lowercase and replace punctuation with spaces
  clean_text <- tolower(text)
  clean_text <- gsub("[[:punct:]]+", " ", clean_text)
  clean_text <- gsub("\\s-\\s", " ", clean_text)
  
  # Split by whitespace and remove stopwords
  tokens <- unlist(strsplit(clean_text, "\\s+"))
  processed_tokens <- tokens[!(tokens %in% stopwords_english)]
  
  # Return a cleaned string joined by spaces
  cleaned_text <- paste(processed_tokens, collapse = " ")
  
  return(cleaned_text)
}


################################################################################

#' @param data A data frame containing the text column to analyze.
#' @param column_name The name of the text column from which bigrams will be generated.
#' @param score_threshold The minimum score a row must have to be included in bigram extraction.
#' @param max_n The maximum number of words to consider per n-gram.
#' @return A kable-formatted table displaying the most common bigrams.

generate_bigrams <- function(data, column_name, score_threshold = 0.8, max_n = 5) {
  
  # Compute average word count per row
  avg_word_count <- data %>%
    mutate(word_count = str_count(data[[column_name]], "\\S+")) %>%
    summarise(avg_words = mean(word_count, na.rm = TRUE)) %>%
    pull(avg_words)

  n_value <- min(round(avg_word_count), max_n)
  
  print(paste("Using n =", n_value))
  
  # Generate n-grams
  bigrams <- data %>%
    select(all_of(column_name), matched_score) %>% 
    drop_na(all_of(column_name), matched_score) %>%  # Ensure no missing values
    filter(matched_score > score_threshold) %>% 
    unnest_tokens(bigram, all_of(column_name), token = "ngrams", n = n_value) %>%
    count(bigram, sort = TRUE)
  
  # Return formatted table
  return(kable(bigrams, caption = paste("Most Common", n_value, "-grams in", column_name)))
}


################################################################################

#' @param data A data frame containing the text column to be analyzed.
#' @param column_name The name of the column containing text data.
#' @param num_topics The number of topics to extract from the text.
#' @param num_words The number of top words to display per topic.
#' @param seed A random seed for reproducibility.
#' @param workers The number of CPU cores to use for parallel processing.
#' @return A tibble containing topic-word probabilities from the LDA model.

perform_lda <- function(data, column_name, num_topics = 3, num_words = 5, seed = 1234, workers = availableCores() - 1) {
  plan(multisession, workers = workers)
  
  # Convert text column into a corpus and then into a document-term matrix,
  # where rows represent documents, columns represent terms, and values are term frequencies.
  docs <- Corpus(VectorSource(data[[column_name]]))
  dtm <- DocumentTermMatrix(docs)
  
  # Remove empty rows
  row_sums <- rowSums(as.matrix(dtm))
  dtm <- dtm[row_sums > 0, ]
  
  # Fit the LDA model asynchronously using the future package
  lda_model <- future({
    topicmodels::LDA(dtm, k = num_topics, control = list(seed = seed))
  })
  lda_model <- value(lda_model)

  # Extract term-topic probabilities "beta matrix"
  beta <- broom::tidy(lda_model, matrix = "beta")
  
  # Reset future plan back to sequential
  plan(sequential)
  
  return(beta)
}


################################################################################

#' @param data A data frame containing the text column to be analyzed.
#' @param text_column The name of the column containing text data.
#' @return A ggplot object visualizing the distribution of positive and negative sentiment based on the "bing" lexicon.

perform_sentiment_analysis <- function(data, text_column) {
  text_column <- ensym(text_column)
  
  sentiments <- data %>%
    unnest_tokens(word, !!text_column) %>%
    inner_join(get_sentiments("bing")) %>%
    count(sentiment, sort = TRUE)
  
  # Create a bar chart visualizing the distribution of positive and negative sentiment
  ggplot(sentiments, aes(x = sentiment, y = n, fill = sentiment)) +
    geom_col() +
    theme_minimal()
}

################################################################################
