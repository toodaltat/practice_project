################################################################################
# Loading libraries
################################################################################

library(tidyverse)

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

# intent: dropping unwanted columns

# output: resume_df

resume_df <- resume_df %>% select(-address, -passing_years, -educational_results,
                                  -result_types, -company_urls, -start_dates, -end_dates,
                                  -locations, -extra_curricular_activity_types, -extra_curricular_organization_names,
                                  -extra_curricular_organization_links, -role_positions, -certification_providers, -certification_skills,
                                  -online_links, -issue_dates, -expiry_dates, -age_requirement)
View(resume_df)
################################################################################
# Crafting approipate dataframes
################################################################################

# input: resume_df

# output: ....
colnames(resume_df)


spoken_lng_df <- resume_df %>% select(languages, proficiency_levels)

clean_spoken_lng_df <- na.omit(spoken_lng_df)

View(clean_spoken_lng_df)


#Exit note: Go through and tidy the "string" values in dataframe and find the common job_position_name value.
