################################################################################
source("01_tools.R")
################################################################################
# Setting up dataframe
################################################################################

# input: resume_df

# intent: dropping unwanted columns

# output: resume_df


resume_df <- resume_df %>% select(-address, -passing_years, -educational_results,
                                  -result_types, -company_urls, -start_dates, -end_dates,
                                  -locations, -extra_curricular_activity_types, -extra_curricular_organization_names,
                                  -extra_curricular_organization_links, -role_positions, -certification_providers, -certification_skills,
                                  -online_links, -issue_dates, -expiry_dates, -age_requirement)



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

# Removes selected words from the column "skills_required"
word_removal <- c("skills", "skill")
resume_df <- clean_column(resume_df, "skills_required", word_removal)

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
