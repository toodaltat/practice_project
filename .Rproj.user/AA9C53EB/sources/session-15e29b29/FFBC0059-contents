################################################################################
# Loading libraries
################################################################################

library(tidyverse)
library(dplyr)

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

# output: ....

# Building dataframe holding persons language abilities.
spoken_lng_df <- resume_df %>% select(languages, proficiency_levels)

clean_spoken_lng_df <- na.omit(spoken_lng_df)

################################################################################
# Occurrence check
################################################################################

# Create a table of position counts
count_table <- data.frame(Unique_Entry = names(table(resume_df$positions)),
                          Count = as.integer(table(resume_df$positions)))

count_table <- count_table[order(-count_table$Count), ]

View(count_table)


