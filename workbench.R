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
docs <- Corpus(VectorSource(resume_df$responsibilities.1))
dtm <- DocumentTermMatrix(docs)

# Apply LDA with 3 topics
lda_model <- LDA(dtm, k = 3, control = list(seed = 1234))

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

View(resume_df)


################################################################################

################################################################################
