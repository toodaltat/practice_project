import os
import pandas as pd

import nltk
####

#### Setting up nltk with English stopwords.
nltk.download("stopwords", quiet=True)
from nltk.corpus import stopwords
stopwords_english = stopwords.words("english")
####

#### reading in CSV
current_dir = os.getcwd()
data_path = os.path.join(current_dir, "data", "resume_data.csv")

df = pd.read_csv(data_path)
####

print(df.isnull().sum())




