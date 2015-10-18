# -*- coding: utf-8 -*-
"""
Created on Tue Oct 13 22:43:29 2015

@author: sajal
"""

num_topics=1

from nltk.tokenize import RegexpTokenizer
from stop_words import get_stop_words
from nltk.stem.porter import PorterStemmer
from gensim import corpora, models
import gensim,os,operator
from nltk.corpus import stopwords


import MySQLdb
import time


def extract_tf_df (index) :
    extract_tf_df.counter+=1
    print "counter :",extract_tf_df.counter
    global list_keys,corpus,dictionary
    try :
        print index
        key=list_keys[index]
        try :
            value=dictionary[key]
            tf_value=0
            df_value=0
            for items in corpus :
                for tuples in items :
                    if tuples[0]==value:
                        tf_value=tf_value+tuples[1]
                        df_value=df_value+1
                    
            time.sleep(0.1)
            if tf_value>10 :
                return str(key)+"+,+"+str(tf_value)+"+,+"+str(df_value)
            return
        except Exception,e :
            print "Error ",str(key)," -> ",str(e)
    except Exception,e :
            print "Error ",str(e)

extract_tf_df.counter=0
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
#    update_sql="UPDATE Corpus_English SET Stemmed_Article=\""+ str(stemmed_big_tokens)[1:-1]+"\" where Article=\""+i+"\""
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
    return stemmed_big_tokens
#    return update_sql

db = MySQLdb.connect(host="localhost", user='root', db="Disease_names",use_unicode=True, passwd='sajal',charset='utf8' )
cursor = db.cursor()

#sql="SELECT distinct Article FROM `Corpus_English` where Stemmed_Article=\"\""
#sql="SELECT distinct Article FROM `Corpus_English`"
#doc_set=[]
#try :
#    cursor.execute(sql)
#    results = cursor.fetchall()
#    for rows in results :
#        doc_set=doc_set+[rows[0]]
#except Exception,e :
#        print "Not sql :",str(e)
#  
#print "sql done"      
#tokenizer = RegexpTokenizer(r'\w+')
#
## create English stop words list
#en_stop = get_stop_words('en')
#stop = stopwords.words('english')
#en_stop=en_stop+stop
## Create p_stemmer of class PorterStemmer
#p_stemmer = PorterStemmer()
#    
## create sample documents
##doc_a = "Brocolli is good to eat. My brother likes to eat good brocolli, but not my mother."
##doc_b = "My mother spends a lot of time driving my brother around to baseball practice."
##doc_c = "Some health experts suggest that driving may cause increased tension and blood pressure."
##doc_d = "I often feel pressure to perform well at school, but my mother never seems to drive my brother to do better."
##doc_e = "Health professionals say that brocolli is good for your health." 
#
## compile sample documents into a list
##doc_set = [doc_a, doc_b, doc_c, doc_d, doc_e]
#
## list for tokenized documents in loop
#texts = []
#sqls=[]
import multiprocessing as mp
pool = mp.Pool(processes=8)
#
## loop through document list
#texts = pool.map(stem_stop_token, range(len(doc_set)))
##sqls = pool.map(stem_stop_token, range(len(doc_set)))
#
#print "all done"
##for index_update_sql in range(len(sqls)) :
##    print index_update_sql
##    update_sql=sqls[index_update_sql]
##    try :
##           cursor.execute(update_sql)
##           db.commit()
##    except Exception, e: 
##           print  "\nERROR\n" + str(e)
##           print update_sql
##           db.rollback()
##
##db.close()
#
## turn our tokenized documents into a id <-> term dictionary
#dictionary = corpora.Dictionary(texts)
#print "dictionary made"
#
## convert tokenized documents into a document-term matrix
#corpus = [dictionary.doc2bow(text) for text in texts]
#print "corpus created"
#
#f=open("corpus.py","w")
#f.write("[\n")
#for values in corpus :
#    f.write(str(values)+",\n")
#f.write("]")
#f.close()

#f=open("dictionary.py","w")
#f.write(str(dictionary.token2id))
#f.close()
#dictionary=""
#with open("dictionary.py") as infile:
#    for line in infile:
#        dictionary=dictionary+line
#dictionary=eval(dictionary)

list_keys=dictionary.keys()

#import ast
#corpus=[]
#with open("corpus.py") as newfile:
#    for line in newfile:
#        if (line!="]" and line !="[\n") and line[0]=="[":
#            corpus=corpus+[ast.literal_eval(line[:-2])]



tf_df_values=[]
time.sleep(10)

tf_df_values = pool.map(extract_tf_df, range(len(list_keys)))

#values_tf={}
#values_df={}
#for indice in range(len(tf_df_values)):
#    print indice
#    tf_df_value=tf_df_values[indice]
#    split_tf_df_values=tf_df_values.split("+,+")
#    key=split_tf_df_values[0]
#    values_tf[key]=split_tf_df_values[1]
#    values_df[key]=split_tf_df_values[2]
#
#sorted_values = sorted(values_tf.items(), key=operator.itemgetter(1),reverse=True)
#for indices in range(len(sorted_values)):
#    value_tf=sorted_values[indices]
#    key=value_tf[0]
#    tf=value_tf[1]
#    df=values_df[key]
#    insert_query="INSERT INTO  `Disease_names`.`Topics_TF_DF` (`Word`,`TF`,`DF`)VALUES (\""+str(key)+"\","+str(tf)+","+str(df)+");"
#    try :
#       cursor.execute(insert_query)
#       db.commit()
#    except Exception, e: 
#       print  "\nERROR\n" + str(e)
#       print insert_query
#       db.rollback()

db.close()

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
