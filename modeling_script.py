# Importing libraries
import os
import re
import numpy as np
import pandas as pd
from collections import Counter

import nltk
####

# Setting up nltk with English stopwords.
nltk.download("stopwords", quiet=True)
from nltk.corpus import stopwords
stopwords_english = stopwords.words("english")
####

# reading in CSV
current_dir = os.getcwd()
data_path = os.path.join(current_dir, "data", "resume_data.csv")

df = pd.read_csv(data_path)
####

# Checking null values in dataframe.
# print(df.isnull().sum())
####

# Define preprocess_text function


def preprocess_text(text):
    """
    This function preprocess raw samples of text:
    - Converts to lowercase
    - Splits text on commas

    :param text: "raw" text (string)
    :return: processed_sample_tokens: list of tokens (list of strings)
    """

    # Converting to lowercase
    text = str(text)
    clean_text = text.lower()

    # Replace common punctuation marks with whitespace.
    pattern = r'[.;:\|\%\[\]\(\)\r\n\*]+'
    clean_text = re.sub(pattern, " ", clean_text)

    # Replace single hyphens with whitespace
    clean_text = re.sub(r"\s-\s", " ", clean_text)

    # Remove stopwords and split commas
    processed_sample_tokens = [tok for tok in clean_text.split(',') if tok not in stopwords_english]

    return processed_sample_tokens


# Applying function on skills column
df['clean_skills'] = df['skills'].apply(lambda x: preprocess_text(x))

# # Show a sample
# print(df.sample())

# Getting extraction from skills column
df['clean_skills'].apply(lambda x: len(str(x).split(','))).sort_values(ascending=False)

top = Counter([item for sublist in df['clean_skills'] for item in sublist])
temp = pd.DataFrame(top.most_common(10))

temp.columns = ['Common_words','count']
temp.style.background_gradient(cmap='Purples')

print(temp)