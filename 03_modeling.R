################################################################################
source("02_cleaning.R")
################################################################################
# LDA modeling // N-grams
################################################################################

#lda_responsibilites <-perform_lda(resume_df, "responsibilities")

#lda_skills <- perform_lda(resume_df, "skills", num_topic = 3, num_words = 10)

#lda_field_studied <- perform_lda(resume_df, "major_field_of_studies", num_topics = 2, num_words = 10)

#lda_career <- perform_lda(resume_df, "career_objective")

#lda_skills_required <- perform_lda(resume_df, "skills_required", num_topics = 2, num_words = 10)

################################################################################
# Producing TF-IDF tables.
################################################################################

tfidf_skills <- compute_tfidf(resume_df, "id", "skills")
tfidf_skills

#tfidf_major_field <- compute_tfidf(resume_df, "id", "major_field_of_studies")
#tfidf_major_field

#tfidf_related_skills <- compute_tfidf(resume_df, "id", "related_skils_in_job")

#tfidf_edu_institution <- compute_tfidf(resume_df, "id", "educational_institution_name")


