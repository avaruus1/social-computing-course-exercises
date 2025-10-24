import sqlite3
import traceback
import nltk

from nltk.sentiment.vader import SentimentIntensityAnalyzer
import pandas as pd
from gensim.corpora import Dictionary
from gensim.models.ldamodel import LdaModel
from gensim.models.coherencemodel import CoherenceModel
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer
import nltk

DATABASE = '../database.sqlite'
g = {}

def get_db():
    """
    Connect to the application's configured database. The connection
    is unique for each request and will be reused if this is called
    again.
    """
    if 'db' not in g:
        g["db"] = sqlite3.connect(
            DATABASE,
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g["db"].row_factory = sqlite3.Row

    return g["db"]


def query_db(query, args=(), one=False, commit=False):
    """
    Queries the database and returns a list of dictionaries, a single
    dictionary, or None. Also handles write operations.
    """
    db = get_db()

    # Using 'with' on a connection object implicitly handles transactions.
    # The 'with' statement will automatically commit if successful,
    # or rollback if an exception occurs. This is safer.
    try:
        with db:
            cur = db.execute(query, args)

        # For SELECT statements, fetch the results after the transaction block
        if not commit:
            rv = cur.fetchall()
            return (rv[0] if rv else None) if one else rv

        # For write operations, we might want the cursor to get info like lastrowid
        return cur

    except sqlite3.Error as e:
        print(f"Database error: {e}")
        traceback.print_stack()

        return None

def main(data):
    # Download necessary NLTK data, without these the below functions wouldn't work
    nltk.download('punkt')
    nltk.download('punkt_tab')
    nltk.download('stopwords')
    nltk.download('wordnet')

    # Load data
    # data = pd.read_csv("posts.csv")

    # Get a basic stopword list
    stop_words = stopwords.words('english')

    # Add extra words to make our analysis even better
    stop_words.extend(
        ['would', 'best', 'always', 'amazing', 'bought', 'quick' 'people', 'new', 'fun', 'think', 'know', 'believe',
         'many', 'thing', 'need', 'small', 'even', 'make', 'love', 'mean', 'fact', 'question', 'time', 'reason', 'also',
         'could', 'true', 'well', 'life', 'said', 'year', 'going', 'good', 'really', 'much', 'want', 'back', 'look',
         'article', 'host', 'university', 'reply', 'thanks', 'mail', 'post', 'please',
         'keep', 'get', 'totally', 'sometimes', 'see', 'maybe', 'sure', 'let', 'haha', 'way', 'like', # This row and others following it are stopwords added by me
         'hiy', 'last', 'seriously', 'bit', 'tied', 'ended', 'might', 'consider', 'everyone', 'important',
         'remember', 'change', 'everything', 'actually', 'great', 'real', 'got', 'got', 'wow', 'next', 'damn',
         'right', 'hit', 'every', 'right', 'agree', 'tried', 'issue', 'difference', 'huh', 'try',
         'first', 'another', 'point', 'worth', 'take', 'made', 'little', 'one', 'day', 'lol', 'changed',
         'feel', 'local', 'crucial', 'sound', 'expected', 'deeper', 'whole', 'wait', 'something', 'step', 'hey', 'taking',
         'nice', 'trying', 'key', 'without', 'perfect', 'spreading', 'lot', 'enough', 'hard', 'considered', 'bigger'
         ])

    # this object will help us lemmatise words (i.e. get the word stem)
    lemmatizer = WordNetLemmatizer()

    # after the below for loop, we will transform each post into "bags of words" where each BOW is a set of words from one post
    bow_list = []
    data_trimmed = data.copy()
    for idx, row in data_trimmed.iterrows():
        text = row["content"]
        tokens = word_tokenize(text.lower())  # tokenise (i.e. get the words from the post)
        tokens = [lemmatizer.lemmatize(t) for t in tokens]  # lemmatise
        tokens = [t for t in tokens if len(t) > 2]  # filter out words with less than 3 letter s
        tokens = [t for t in tokens if t.isalpha() and t not in stop_words]  # filter out stopwords
        # if there's at least 1 word left for this post, append to list
        if len(tokens) > 0:
            bow_list.append(tokens)
        else:
            data_trimmed = data_trimmed.drop(idx)

    # Create dictionary and corpus
    dictionary = Dictionary(bow_list)
    # Filter words that appear less than 2 times or in more than 30% of posts
    dictionary.filter_extremes(no_below=2, no_above=0.3)
    corpus = [dictionary.doc2bow(tokens) for tokens in bow_list]

    # Train LDA model. We want to determine how we can best split the data into 4 topics
    lda = LdaModel(corpus, num_topics=10, id2word=dictionary, passes=10, random_state=2)

    # Now that the LDA model is done, let's see how good it is by computing its 'coherence score'
    coherence_model = CoherenceModel(model=lda, texts=bow_list, dictionary=dictionary, coherence='c_v')
    coherence_score = coherence_model.get_coherence()

    print(f"Coherence Score: {coherence_score}")

    # First, to see the topics, print top 5 most representative words per topic
    print(f'These are the words most representative of each of the 10 topics:')
    for i, topic in lda.print_topics(num_words=5):
        print(f"Topic {i}: {topic}")

    topic_counts = [0] * 10
    posts_by_topic = {}
    for i, bow in enumerate(corpus):
        topic_dist = lda.get_document_topics(bow)  # list of (topic_id, probability)
        dominant_topic = max(topic_dist, key=lambda x: x[1])[0]  # find the top probability
        topic_counts[dominant_topic] += 1  # add 1 to the most probable topic's counter
        posts_by_topic[dominant_topic] = posts_by_topic.get(dominant_topic, []) + [data_trimmed.iloc[i]]

    # Display the topic counts
    for i, count in enumerate(topic_counts):
        print(f"Topic {i}: {count} posts")

    # Exercise 2
    analyzer = SentimentIntensityAnalyzer()
    score_avg = {"neg": 0, "neu": 0, "pos": 0, "compound": 0}
    for idx, row in data.iterrows():
        text = row["content"]
        compute_and_add(analyzer, score_avg, text)

    do_divide(score_avg, data)

    print(f"Average sentiment for all posts & comments: {score_avg}")

    for idx in range(10):
        topic_posts = posts_by_topic[idx]
        score_avg = {"neg": 0, "neu": 0, "pos": 0, "compound": 0}
        for post in topic_posts:
            text = post["content"]
            compute_and_add(analyzer, score_avg, text)
        do_divide(score_avg, topic_posts)
        print(f"Average sentiment for topic {idx} posts: {score_avg}")


def compute_and_add(analyzer, score_avg, text):
    scores = analyzer.polarity_scores(text)
    score_avg["compound"] += scores["compound"]
    score_avg["neu"] += scores["neu"]
    score_avg["pos"] += scores["pos"]
    score_avg["neg"] += scores["neg"]

def do_divide(score_avg, data_trimmed):
    score_avg["compound"] /= len(data_trimmed)
    score_avg["neu"] /= len(data_trimmed)
    score_avg["pos"] /= len(data_trimmed)
    score_avg["neg"] /= len(data_trimmed)


if __name__ == '__main__':
    posts = [r[0] for r in query_db("SELECT content FROM posts")]
    comments = [r[0] for r in query_db("SELECT content FROM comments")]

    main(pd.DataFrame(posts + comments, columns=["content"]))
