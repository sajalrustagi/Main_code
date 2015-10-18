# -*- coding: utf-8 -*-
"""
Created on Sun Oct 11 16:08:41 2015

@author: sajal
"""
num_topics=1

from nltk.tokenize import RegexpTokenizer
from stop_words import get_stop_words
from nltk.stem.porter import PorterStemmer
from gensim import corpora, models
import gensim,os
from nltk.corpus import stopwords


import MySQLdb
import time

def stem_stop_token(index):
    global doc_set
    i=doc_set[index]
    # clean and tokenize document string
    raw = i.lower()
    tokens = tokenizer.tokenize(raw)
    #print "tokenized ",index
    # remove stop words from tokens
    stopped_tokens = [a for a in tokens if not a in en_stop]
    #print "stop_word removed ",index
    # stem tokens
    stemmed_tokens = [p_stemmer.stem(a) for a in stopped_tokens ]
    stemmed_big_tokens = [a for a in stemmed_tokens if len(a)>1]
    update_sql="UPDATE Corpus_English SET Stemmed_Article=\""+ str(stemmed_big_tokens)[1:-1]+"\" where Article=\""+i+"\""
    #print update_sql
#    try :
#           cursor.execute(update_sql)
#           db.commit()
#    except Exception, e: 
#           print  "\nERROR\n" + str(e)
#           print update_sql
#           db.rollback()
          
    #print "stemmed ",index
    # add tokens to list
    print index
    time.sleep(0.1)
#    return stemmed_big_tokens
    return update_sql

db = MySQLdb.connect(host="localhost", user='root', db="Disease_names",use_unicode=True, passwd='sajal',charset='utf8' )
cursor = db.cursor()

#sql="SELECT distinct Article FROM `Corpus_English` where Stemmed_Article=\"\""
sql="SELECT distinct Article FROM `Corpus_English` where Stemmed_Article=\"\""
doc_set=[]
try :
    cursor.execute(sql)
    results = cursor.fetchall()
    for rows in results :
        doc_set=doc_set+[rows[0]]
except Exception,e :
        print "Not sql :",str(e)
  
print "sql done"      
tokenizer = RegexpTokenizer(r'\w+')

# create English stop words list
en_stop = get_stop_words('en')
stop = stopwords.words('english')
en_stop=en_stop+stop
# Create p_stemmer of class PorterStemmer
p_stemmer = PorterStemmer()
    
# create sample documents
#doc_a = "Brocolli is good to eat. My brother likes to eat good brocolli, but not my mother."
#doc_b = "My mother spends a lot of time driving my brother around to baseball practice."
#doc_c = "Some health experts suggest that driving may cause increased tension and blood pressure."
#doc_d = "I often feel pressure to perform well at school, but my mother never seems to drive my brother to do better."
#doc_e = "Health professionals say that brocolli is good for your health." 

# compile sample documents into a list
#doc_set = [doc_a, doc_b, doc_c, doc_d, doc_e]

# list for tokenized documents in loop
texts = []
sqls=[]
import multiprocessing as mp
pool = mp.Pool(processes=32)

# loop through document list
#texts = pool.map(stem_stop_token, range(len(doc_set)))
sqls = pool.map(stem_stop_token, range(len(doc_set)))

print "all done"
for index_update_sql in range(len(sqls)) :
    print index_update_sql
    update_sql=sqls[index_update_sql]
    try :
           cursor.execute(update_sql)
           db.commit()
    except Exception, e: 
           print  "\nERROR\n" + str(e)
           print update_sql
           db.rollback()

db.close()

# turn our tokenized documents into a id <-> term dictionary
#dictionary = corpora.Dictionary(texts)
#print "dictionary made"
#
## convert tokenized documents into a document-term matrix
#corpus = [dictionary.doc2bow(text) for text in texts]
#print "corpus created"


## generate LDA model
##range_list=range(5)
##range_list.reverse()
##for num_topics in range_list :
##    num_topics+=1
#print "start topic extraction -",num_topics
#ldamodel = gensim.models.LdaMulticore(corpus, num_topics=num_topics, id2word = dictionary, iterations=20)
#topics=ldamodel.print_topics(num_topics=num_topics, num_words=1000)
#print "topics extracted -",num_topics
#for index in range(len(topics)) :
#    topic=topics[index]
#    x=topic.split(" + ")
#    for items in x :
#        items=items.split("*")
#        insert_query="INSERT INTO  `Disease_names`.`Topics_LDA_"+str(num_topics)+"_temp_1000` (`Probability` ,`Word` ,`Topic_Num`)VALUES ("+str(items[0])+",\""+str(items[1])+"\","+str(index+1)+");"
#        try :
#           cursor.execute(insert_query)
#           db.commit()
#        except Exception, e: 
#           print  "\nERROR\n" + str(e)
#           print insert_query
#           db.rollback()
#print "topics inserted database -",num_topics
#db.close()