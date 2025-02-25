################################################################################
# Loading necessary scripts
################################################################################

source("01_setup.R")

################################################################################
# Cleaning
################################################################################

# input: resume_df

# intent: Fills in missing values and removes clutter from certain columns

# output: resume_df

# Assuming that people who didn't mention spoken language are mono lingual English speakers
resume_df$languages[is.na(resume_df$languages)] <- "english"
resume_df$proficiency_levels[is.na(resume_df$proficiency_levels)] <- "native"

# Removes selected words from the column "educational_institution_name"
word_removal <- c("none", "na", "NA", "hs", "iit", "isi", "k", "g", "r", "l", "p", "il", "ï", "kmpg", "n", "mras", "srmu", "m")
resume_df <- clean_column(resume_df, "educational_institution_name", word_removal)

# Removes selected words from the column "major_field_of_studies"
word_removal <- c("none")
resume_df <- clean_column(resume_df, "major_field_of_studies", word_removal)

# Removes selected words from the column "professional_company_names"
word_removal <- c("none", "company", "name", "n")
resume_df <- clean_column(resume_df, "professional_company_names", word_removal)

################################################################################
# Pre_processing
################################################################################

# input: resume_df

# intent: Strip text data of unnecessary words

# output: resume_df


# Apply preprocess_text only to the specified columns using future_lapply for multi core processing.
columns_to_process <- setdiff(names(resume_df), "matched_score")
resume_df[columns_to_process] <- future_lapply(resume_df[columns_to_process], function(col) {
  if (is.character(col)) {
    return(sapply(col, preprocess_text))
  } else {
    return(col)
  }
})

################################################################################
# Calling occurrences_counter
################################################################################

resume_df <- occurrences_counter(resume_df, "educational_institution_name", output_name = "edu_count")

resume_df <- occurrences_counter(resume_df, "professional_company_names", output_name = "company_count")

################################################################################
