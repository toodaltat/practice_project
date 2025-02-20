################################################################################

source("02_cleaning.R")

################################################################################
# LDA modeling // N-grams
################################################################################

perform_lda(resume_df, "responsibilities")

perform_lda(resume_df, "skills")

perform_lda(resume_df, "educational_institution_name", num_topics = 2, num_words = 15) 

perform_lda(resume_df, "major_field_of_studies", num_topics = 2, num_words = 10)

perform_lda(resume_df, "career_objective")


################################################################################

generate_bigrams(resume_df, "educational_institution_name")


################################################################################

resume_df$professional_company_names <- gsub("\\bcompany name\\b", "", resume_df$professional_company_names, ignore.case = TRUE)

unique(resume_df$professional_company_names)

View(resume_df)
