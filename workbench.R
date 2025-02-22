################################################################################
# Crafting appropriate dataframes
################################################################################

# input: resume_df

# output: language_table






# Building dataframe holding persons language abilities.
spoken_lng_df <- resume_df %>% select(languages, proficiency_levels)

# Assuming that people who didn't mention spoken language are mono lingual english speakers. 
spoken_lng_df$languages[is.na(spoken_lng_df$languages)] <- "English"
spoken_lng_df$proficiency_levels[is.na(spoken_lng_df$proficiency_levels)] <- "Native"

# Create a table of language counts
language_table <- spoken_lng_df %>%
  count(languages) %>%
  arrange(desc(n))

# Display the table
kable(language_table, col.names = c("Language", "Count"))


################################################################################
# Occurrence check
################################################################################

# Create a table of position counts
count_table <- data.frame(
  Unique_Entry = names(table(resume_df$positions)),
  Count = as.integer(table(resume_df$positions))
)

# Order by the count
count_table <- count_table[order(-count_table$Count), ]

# Use knitr and kableExtra to create a better formatted table
count_table %>%
  kable("html", caption = "Positions and Their Counts", col.names = c("Position", "Count")) %>%
  kable_styling("striped", full_width = FALSE) %>%
  column_spec(1, width = "20em") %>%
  column_spec(2, width = "5em") %>%
  scroll_box(width = "100%", height = "300px")


################################################################################
# Topic analysis
################################################################################

# Convert text to a Document-Term Matrix (DTM)
docs <- Corpus(VectorSource(resume_df$responsibilities))
dtm <- DocumentTermMatrix(docs)

# Apply LDA with 3 topics
lda_model <- LDA(dtm, k = 5, control = list(seed = 1234))

# View topics
job_responsibilties <- terms(lda_model, 5)  # Get top 5 words for each topic
print(job_responsibilties)



# Convert text to a Document-Term Matrix (DTM)
skill_docs <- Corpus(VectorSource(resume_df$skills))
skill_dtm <- DocumentTermMatrix(docs)

# Apply LDA with 3 topics
skill_lda_model <- LDA(skill_dtm, k = 3, control = list(seed = 1234))

# View topics
skill_overview <- terms(skill_lda_model, 5)  # Get top 5 words for each topic
print(skill_overview)


################################################################################
# Inspection
################################################################################

# Load necessary libraries
df <- resume_df

# Sample stopwords list (you can expand this list or use a package)
stopwords_english <- c("a", "about", "above", "after", "again", "against", "all", "am", "an", "and", "any", "are", "aren't", "as", "at", "be", "because", "been", "before", "being", "below", "between", "both", "but", "by", "can't", "cannot", "could", "couldn't", "did", "didn't", "does", "doesn't", "don't", "during", "each", "few", "for", "from", "further", "had", "hadn't", "has", "hasn't", "haven't", "having", "he", "he's", "her", "here", "here's", "hers", "herself", "him", "himself", "his", "how", "how's", "howsoever", "i", "i'm", "i've", "i'd", "i'll", "i'm", "i'mn't", "if", "if's", "in", "insofar", "into", "is", "isn't", "it", "it's", "it'll", "it'snt", "itself", "just", "more", "moreover", "no", "nor", "not", "of", "of's", "off", "on", "on's", "once", "only", "or", "other", "others", "ought", "our", "ours", "ourselves", "out", "outside", "over", "own", "same", "than", "that", "that'll", "that's", "that'sn't", "thatsoever", "the", "the's", "themselves", "them", "themself", "there", "there's", "thereafter", "therefore", "where", "where's", "who", "who's", "whose", "why", "why's", "whysoever", "with", "within", "without")

----

# Apply the preprocess_text function
df$clean_skills <- sapply(df$skills, preprocess_text)

# Show the processed sample
print(df)

# Get the length of tokens in clean_skills
df$skill_count <- sapply(df$clean_skills, function(x) length(strsplit(x, ",")[[1]]))

# Sort skill counts (descending)
df_sorted <- df[order(-df$skill_count), ]
print(df_sorted)

# Get top 10 most common words
all_words <- unlist(df$clean_skills)
word_table <- table(all_words)
top_words <- sort(word_table, decreasing = TRUE)[1:10]
top_words_df <- data.frame(Common_words = names(top_words), count = as.integer(top_words))

# Print the top words table
print(top_words_df)



################################################################################
library(tm)
library(topicmodels)
library(knitr)
library(future)
library(future.apply)

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
  }) %...>% value()
  
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

# Example usage
perform_lda(resume_df, "responsibilities")

################################################################################

# Define words you want to filter by
#keywords <- c("data", "analysis")

# Filter rows where 'responsibilities' contains any of the keywords
#filtered_df <- resume_df %>%
#  filter(str_detect(responsibilities, str_c(keywords, collapse = "|")))

# View the result

#summary(filtered_df)



generate_bigrams <- function(data, column, score_column, score_threshold = 80, max_n = 5) {
  
  # Compute average word count per row
  avg_word_count <- data %>%
    mutate(word_count = str_count(.data[[column]], "\\S+")) %>%
    summarise(avg_words = mean(word_count, na.rm = TRUE)) %>%
    pull(avg_words)
  
  # Cap n at max_n (default = 5)
  n_value <- min(round(avg_word_count), max_n)
  
  print(paste("Using n =", n_value))
  
  # Generate n-grams
  bigrams <- data %>%
    select(all_of(column), all_of(score_column)) %>%
    drop_na(all_of(column), all_of(score_column)) %>%
    filter(.data[[score_column]] > score_threshold) %>%
    unnest_tokens(bigram, all_of(column), token = "ngrams", n = n_value) %>%
    count(bigram, sort = TRUE)
  
  # Return formatted table
  return(kable(bigrams, caption = paste("Most Common", n_value, "-grams in", column)))
}

average_word_count <- resume_df %>%
  mutate(word_count = str_count(educational_institution_name, "\\S+") + 0) %>% # Count words in each row
  summarise(avg_word_count = mean(word_count, na.rm = TRUE)) # Compute average word count


# Example Usage:
generate_bigrams(resume_df, "educational_institution_name", score_threshold = 0.8, n = 5)


bigrams <- resume_df %>% 
  select(educational_institution_name) %>%
  drop_na(educational_institution_name) %>%
  filter(resume_df$matched_score > 0.800) %>%
  unnest_tokens(bigram, educational_institution_name, token = "ngrams", n = 5) %>%
  count(bigram, sort = TRUE) # count word occurances and take average for ngram

kable(bigrams, caption = "Most Common N-grams in Educational Institutions")






### TESTING CODE ###
if (!exists("resume_df") || !is.data.frame(resume_df)) {
  stop("resume_df is not defined or is not a dataframe.")
}

################################################################################



resume_df$professional_company_names <- gsub("\\bcompany name\\b", "", resume_df$professional_company_names, ignore.case = TRUE)

unique(resume_df$professional_company_names)

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
  
  beta <- broom::tidy(lda_model, matrix = "beta") 
  
  
  # Extract top words per topic
  #topic_terms <- terms(lda_model, num_words)
  
  # Convert matrix output to a data frame
  #topic_df <- as.data.frame(topic_terms)
  
  # Rename columns for clarity
  #colnames(topic_df) <- paste("Topic", 1:num_topics)
  
  # Create a dynamic caption using the column name
  #caption_text <- paste("Top Words per Topic (LDA Model) for", column_name)
  
  # Reset future plan back to sequential (prevents issues with nested parallelism)
  plan(sequential)
  
  return(lda_model)
}



library(textdata)

sentiments <- df %>%
  unnest_tokens(word, text) %>%
  inner_join(get_sentiments("bing")) %>%
  count(sentiment, sort = TRUE)

ggplot(sentiments, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_col() +
  theme_minimal()

####

word_counts <- df %>%
  unnest_tokens(word, text) %>%
  count(word, sort = TRUE)

ggplot(word_counts %>% head(20), aes(x = reorder(word, n), y = n)) +
  geom_col(fill = "darkred") +
  coord_flip() +
  labs(title = "Most Frequent Words", x = "Word", y = "Count")


######

library(igraph)
library(ggraph)

bigram_graph <- ngrams %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(n > 5) %>%
  graph_from_data_frame()

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), repel = TRUE) +
  theme_void()

###

library(tidytext)
library(dplyr)
library(ggplot2)

# Assuming df contains a column "text"
ngrams <- df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE)

ggplot(ngrams %>% head(20), aes(x = reorder(bigram, n), y = n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Most Frequent Bigrams", x = "Bigram", y = "Count")


beta %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ggplot(aes(x = reorder(term, beta), y = beta, fill = as.factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()



