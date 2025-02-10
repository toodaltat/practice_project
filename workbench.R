################################################################################
# Loading libraries
################################################################################

library(tidyverse)
library(dplyr)
library(knitr)
library(kableExtra)
library(topicmodels)
library(tm)

current_dir <- getwd()

################################################################################
# Loading dataset
################################################################################

resume_file <- file.path(current_dir, 'data/resume_data.csv')

resume_df <- read_csv(resume_file)

################################################################################
# Cleaning
################################################################################

# input: resume_df

# intent: dropping unwanted columns, removing out of place characters.

# output: resume_df

resume_df <- resume_df %>% select(-address, -passing_years, -educational_results,
                                  -result_types, -company_urls, -start_dates, -end_dates,
                                  -locations, -extra_curricular_activity_types, -extra_curricular_organization_names,
                                  -extra_curricular_organization_links, -role_positions, -certification_providers, -certification_skills,
                                  -online_links, -issue_dates, -expiry_dates, -age_requirement)

resume_df[] <- lapply(resume_df, function(x) {
  x <- gsub("\\[\\]", "", x)
  x <- gsub("^\\[|\\]$", "", x)
  x <- gsub("'", "", x)
  return(x)
})


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

# Preprocess Text function
preprocess_text <- function(text) {
  # Convert to lowercase
  clean_text <- tolower(text)
  
  # Replace punctuation with spaces
  clean_text <- gsub("[.;:|\\%\\[\\]()\\r\\n\\*]+", " ", clean_text)
  
  # Replace single hyphens with spaces
  clean_text <- gsub("\\s-\\s", " ", clean_text)
  
  # Split by commas and remove stopwords
  tokens <- unlist(strsplit(clean_text, ","))
  processed_tokens <- tokens[!(tokens %in% stopwords_english)]
  
  return(processed_tokens)
}

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

################################################################################
