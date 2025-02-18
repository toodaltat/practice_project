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




