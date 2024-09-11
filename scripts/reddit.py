import praw
import pandas as pd
import time


# Detalles de la aplicación en Reddit
client_id = "DX3G_cp3oFZz2dnMv9Fm2Q"
client_secret = "Ixr5PuZxvRxWc8tp1xbijolQBwYeOg"
username = "klaus_lehmann"
password = "klehmann89"
user_agent = "facso"
auth_url = "https://www.reddit.com/api/v1/access_token"



# Autenticación con PRAW
reddit = praw.Reddit(
    client_id=client_id,
    client_secret=client_secret,
    username=username,
    password=password,
    user_agent=user_agent
)

print(reddit.read_only)


for submission in reddit.subreddit("bikepacking").new(limit = 2):
    print(submission.selftext, submission.title)


posts = []
for submission in reddit.subreddit("Rlanguage").hot(limit = None):
    data =  [submission.id, submission.title, submission.selftext, submission.score ]
    posts.append(data)


df_r = pd.DataFrame(posts, columns=['id', 'title', 'selfttext', "score"])
df_r.to_parquet("data/r_submissions.parquet")


# Descargar cosas de python
posts = []
for submission in reddit.subreddit("Python").hot(limit = None):
    data =  [submission.id, submission.title, submission.selftext, submission.score ]
    posts.append(data)



len(posts)






import requests
import json

def get_pushshift_data(query, after, before, subreddit):
    url = f"https://api.pushshift.io/reddit/search/submission/?q={query}&after={after}&before={before}&subreddit={subreddit}&size=1000"
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}

    response = requests.get(url, headers=headers)
    data = json.loads(response.text)
    return data['data']

after = "1609459200"  # Timestamp for 2021-01-01
before = "1640995200"  # Timestamp for 2022-01-01
query = ""  # Empty query to get all posts
subreddit = "Python"

posts = get_pushshift_data(query, after, before, subreddit)
for post in posts:
    print(post['title'])





import praw
from datetime import datetime


subreddit = reddit.subreddit('Python')

# Definir filtros de tiempo
time_filters = ['day', 'week', 'month', 'year', 'all']

# Obtener posts utilizando diferentes filtros de tiempo
posts = []
for time_filter in time_filters:
    submissions = subreddit.top(time_filter=time_filter, limit=1000)
    for submission in submissions:
        posts.append(submission.title)



import praw
import pandas as pd
from dotenv import load_dotenv
import os
load_dotenv()

client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')
username = os.getenv('USERNAME')
password = os.getenv('PASSWORD')
user_agent = os.getenv('USER_AGENT')
auth_url = "https://www.reddit.com/api/v1/access_token"

client_secret



total_downloaded = 0
objetive = 1500
params = {'after': None}
data = []
while total_downloaded < objetive: 
  
  for submission in reddit.subreddit("Python").new(limit = 500, params = params):
    data.append([submission.fullname, submission.title])
    
  params = {'after': submission.fullname }  
  total_downloaded = len(data)
  print("descargado hasta el momento: ", total_downloaded) 
  print("durmiendo...") 
  time.sleep(2)

len(data)
data

data = []
for submission in reddit.subreddit("Rlanguage").new(limit = 10):
    data.append([submission.fullname, submission.title])

data