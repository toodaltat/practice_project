################################################################################
# Loading neccasary scripts
################################################################################

source("00_libraries.R")

################################################################################
# Setting up dataframe
################################################################################

# input: resume_df

# intent: dropping unwanted columns.

# output: resume_df

resume_df <- resume_df %>% select(-address, -passing_years, -educational_results,
                                  -result_types, -company_urls, -start_dates, -end_dates,
                                  -locations, -extra_curricular_activity_types, -extra_curricular_organization_names,
                                  -extra_curricular_organization_links, -role_positions, -certification_providers, -certification_skills,
                                  -online_links, -issue_dates, -expiry_dates, -age_requirement)


################################################################################
# Setting up tools
################################################################################

# Preprocess Text function
stopwords_english <- stopwords("en")

preprocess_text <- function(text) {
  # Check if text is NA or empty
  if (is.na(text) | text == "") return("")
  
  # Convert to lowercase
  clean_text <- tolower(text)
  
  # Replace punctuation with spaces using gsub (including other punctuation marks)
  clean_text <- gsub("[[:punct:]]+", " ", clean_text)
  
  # Replace single hyphens with spaces
  clean_text <- gsub("\\s-\\s", " ", clean_text)
  
  # Split by whitespace (including commas) and remove stopwords
  tokens <- unlist(strsplit(clean_text, "\\s+"))
  
  # Remove stopwords
  processed_tokens <- tokens[!(tokens %in% stopwords_english)]
  
  # Return a cleaned string, joined by spaces
  cleaned_text <- paste(processed_tokens, collapse = " ")
  
  return(cleaned_text)
}



################################################################################
