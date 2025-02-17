################################################################################
# Loading necessary scripts
################################################################################

source("01_setup.R")

################################################################################
# Cleaning
################################################################################

# Assuming that people who didn't mention spoken language are mono lingual English speakers. 
resume_df$languages[is.na(resume_df$languages)] <- "english"
resume_df$proficiency_levels[is.na(resume_df$proficiency_levels)] <- "native"

# Specify the columns you want to apply the function to
columns_to_process <- setdiff(names(resume_df), "matched_score")

# Apply preprocess_text only to the specified columns using future_lapply for multi core processing.
resume_df[columns_to_process] <- future_lapply(resume_df[columns_to_process], function(col) {
  if (is.character(col)) {
    return(sapply(col, preprocess_text))
  } else {
    return(col)
  }
})


################################################################################