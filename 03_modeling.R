################################################################################

source("02_cleaning.R")

################################################################################
# LDA modeling // N-grams
################################################################################

lda_responsibilites <-perform_lda(resume_df, "responsibilities")

lda_skills <- perform_lda(resume_df, "skills", num_topic = 3, num_words = 10)

lda_field_studied <- perform_lda(resume_df, "major_field_of_studies", num_topics = 2, num_words = 10)

lda_career <- perform_lda(resume_df, "career_objective")


################################################################################

generate_bigrams(resume_df, "educational_institution_name")

################################################################################

perform_sentiment_analysis(resume_df, responsibilities)

################################################################################


