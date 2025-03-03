################################################################################

source("02_cleaning.R")

################################################################################
# LDA modeling // N-grams
################################################################################

lda_responsibilites <-perform_lda(resume_df, "responsibilities")

lda_skills <- perform_lda(resume_df, "skills", num_topic = 3, num_words = 10)

lda_field_studied <- perform_lda(resume_df, "major_field_of_studies", num_topics = 2, num_words = 10)

lda_career <- perform_lda(resume_df, "career_objective")

lda_skills_required <- perform_lda(resume_df, "skills_required", num_topics = 2, num_words = 10)


################################################################################

generate_bigrams(resume_df, "educational_institution_name")

################################################################################

sentiment_responsibilites <- perform_sentiment_analysis(resume_df, responsibilities)

################################################################################
# Counts items and produces table
################################################################################


language_counts <- resume_df %>%
  count(languages, name = "Count") %>%
  arrange(desc(Count))
table_language_counts <- kable(language_counts, caption = "Occurrence count of each unique language")


edu_count <- resume_df %>%
  count(educational_institution_name, name = "Count") %>%
  arrange(desc(Count))
table_edu_count <- kable(edu_count, caption = "Occurrence count of each unique educational institution name")


pro_comp_names <- resume_df %>%
  count(professional_company_names, name = "Count") %>%
  arrange(desc(Count))
table_pro_comp_names <- kable(pro_comp_names, caption = "Occurrence count of each unique professional company names")


