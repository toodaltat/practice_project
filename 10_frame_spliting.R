################################################################################
# Loading necessary scripts
################################################################################

source("02_cleaning.R")

################################################################################
# Crafting appropriate dataframes
################################################################################

# input: resume_df

# output: language_table

# Building dataframe holding persons language abilities.
spoken_lng_df <- resume_df %>% select(languages, proficiency_levels)

