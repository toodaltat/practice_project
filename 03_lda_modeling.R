################################################################################

source("02_cleaning.R")

################################################################################
# LDA modeling // N-grams
################################################################################

#perform_lda(resume_df, "responsibilities")

#perform_lda(resume_df, "skills")

#perform_lda(resume_df, "educational_institution_name", num_topics = 2, num_words = 15) 

#perform_lda(resume_df, "major_field_of_studies")

#perform_lda(resume_df, "career_objective")

#generate_bigrams(resume_df, "educational_institution_name")

################################################################################
################################################################################

resume_df <- resume_df %>%
  # filter(matched_score > 0.80)
  mutate(cleaned_name = tolower(educational_institution_name)) %>%
  group_by(cleaned_name) %>%
  mutate(occurrence_count = n()) %>%
  ungroup() %>%
  arrange(desc(occurrence_count)) %>%
  select(-cleaned_name)

View(resume_df)
