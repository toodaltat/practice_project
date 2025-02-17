################################################################################

source("02_cleaning.R")

################################################################################
# LDA modeling
################################################################################

# Convert text to a Document-Term Matrix (DTM)
docs <- Corpus(VectorSource(resume_df$responsibilities))

dtm <- DocumentTermMatrix(docs)

row_sums <- rowSums(as.matrix(dtm))
sum(row_sums == 0)  # Count empty documents
dtm <- dtm[row_sums > 0, ]

# Apply LDA with 3 topics
lda_model <- LDA(dtm, k = 3, control = list(seed = 1234))

# View topics
job_responsibilties <- terms(lda_model, 5)  # Get top 5 words for each topic
print(job_responsibilties)

# Responsibilities
# Topic 1 - lead engineer     Topic 2 - manager Topic 3 - techniqual support           
#[1,] "design"        "management"    "support"        
#[2,] "collaboration" "development"   "data"           
#[3,] "analysis"      "policy"        "maintenance"    
#[4,] "data"          "communication" "troubleshooting"
#[5,] "verification"  "task"          "management"


################################################################################

# Convert text to a Document-Term Matrix (DTM)
dergree_docs <- Corpus(VectorSource(resume_df$major_field_of_studies))

dergree_dtm <- DocumentTermMatrix(dergree_docs)

row_sums <- rowSums(as.matrix(dergree_dtm))
sum(row_sums == 0)  # Count empty documents
dergree_dtm <- dergree_dtm[row_sums > 0, ]

# Apply LDA with 3 topics
dergree_lda_model <- LDA(dergree_dtm, k = 3, control = list(seed = 78765))

# View topics
dergree_batch <- terms(dergree_lda_model, 5)  # Get top 5 words for each topic
print(dergree_batch)

#Topic 1 -business  Topic 2 - comp/network  Topic 3 - COSC     
#[1,] "accounting"     "none"              "engineering"
#[2,] "management"     "electrical"        "computer"   
#[3,] "business"       "computers"         "science"    
#[4,] "finance"        "data"              "technology" 
#[5,] "administration" "telecommunication" "electronics"

################################################################################

View(resume_df$responsibilities)

# Define words you want to filter by
keywords <- c("data", "analysis")

# Filter rows where 'responsibilities' contains any of the keywords
filtered_df <- resume_df %>%
  filter(str_detect(responsibilities, str_c(keywords, collapse = "|")))

# View the result

summary(filtered_df)
View(filtered_df)

summary(resume_df)
