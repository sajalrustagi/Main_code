library(RMySQL)
library(tm)
library(SnowballC)   

mydb = dbConnect(MySQL(), user='root', password='sajal', dbname='Disease_names', host='localhost', passwd='sajal')
rs = dbSendQuery(mydb,'set character set "utf8"')

new__non_rs = dbSendQuery(mydb, "SELECT distinct Article FROM `Articles_English_language_Non_corpus`")
non_corpus_stemmed_articles = fetch(new__non_rs, n=-1)
len_non_corpus_stemmed_articles<-length(non_corpus_stemmed_articles$Article)

docs <- Corpus(VectorSource(non_corpus_stemmed_articles$Article))
docs <- tm_map(docs, removePunctuation)
for(j in seq(docs))   
{   
  docs[[j]] <- gsub("/", " ", docs[[j]])   
  docs[[j]] <- gsub("@", " ", docs[[j]])   
  docs[[j]] <- gsub("\\|", " ", docs[[j]])   
}   
docs <- tm_map(docs, tolower)   
docs <- tm_map(docs, removeWords, stopwords("english"))
docs <- tm_map(docs, stemDocument)
docs <- tm_map(docs, stripWhitespace)   
docs <- tm_map(docs, PlainTextDocument)  

#save(docs,"")

# dtm <- DocumentTermMatrix(docs)   
# dtms <- removeSparseTerms(dtm, 0.98)
# freq <- colSums(as.matrix(dtms))   
# ord <- order(freq)   
# m<-tail(freq[ord],100)[1]+1   
