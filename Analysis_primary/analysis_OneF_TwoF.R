# install.packages("caret")
# install.packages("RMySQL")
# install.packages("e1071")

library(e1071)
library(RMySQL)
library(caret) 
library("reshape2")
library("ggplot2")

# install.packages(doParallel)
library(doParallel)
cl <- makeCluster(detectCores()) 
registerDoParallel(cl)

size_training_set=30000
accuracy_size=10
accuracy_diff=100
max_to_take<-15000

mydb = dbConnect(MySQL(), user='root', password='sajal', dbname='Disease_names', host='localhost', passwd='sajal')
rs = dbSendQuery(mydb,'set character set "utf8"')

new__non_rs = dbSendQuery(mydb, "SELECT distinct Stemmed_Article FROM `Articles_English_language_Non_corpus`")
non_corpus_stemmed_articles = fetch(new__non_rs, n=-1)
len_non_corpus_stemmed_articles<-length(non_corpus_stemmed_articles$Stemmed_Article)

new__non_rs_II = dbSendQuery(mydb, "SELECT distinct Stemmed_Article FROM `Articles_English_language_Non_corpus_II`    where Stemmed_Article !=\"\"")
non_corpus_stemmed_articles_II = fetch(new__non_rs_II, n=-1)
len_non_corpus_stemmed_articles_II<-length(non_corpus_stemmed_articles_II$Stemmed_Article)

new_rs = dbSendQuery(mydb, "SELECT distinct Stemmed_Article FROM `Corpus_English`  where Stemmed_Article !=\"\"" )
stemmed_articles = fetch(new_rs, n=-1)
len_stemmed_article<-length(stemmed_articles$Stemmed_Article)


overall_accuracy_train_total_I<-list()
overall_accuracy_test_total_I<-list()
overall_accuracy_train_total_II<-list()
overall_accuracy_test_total_II<-list()
overall_time_train_total_I<-list()
overall_time_test_total_I<-list()
overall_time_train_total_II<-list()
overall_time_test_total_II<-list()
seq_value<-list()
# time_train<-double(accuracy_size)
# time_test<-double(accuracy_size)



word_count<-100
query=paste("SELECT * FROM `Topics_LDA_1_temp_1000` ORDER BY  `Topics_LDA_1_temp_1000`.`Probability` DESC LIMIT 0 ,",toString(word_count))
rs = dbSendQuery(mydb, query)
words = fetch(rs, n=-1)
words <- subset(words, select = -Topic_Num)

load("nodata.saved")
sampling_I<-sample(nrow(nodata),max_to_take)
test_x_corpus<-nodata[sampling_I,]
total<-c(1:len_stemmed_article)
test_x_corpus_sample<-sampling_I


load("nondata.saved")
load("nondata_II_also.saved")
nondata<-subset(nondata, select = c(words$Word,"result"))
nondata<-rbind(nondata,nondata_II)
len_non_corpus<-len_non_corpus_stemmed_articles+len_non_corpus_stemmed_articles_II
total_II<-c(1:len_non_corpus)
sampling_II<-sample(nrow(nondata),max_to_take)
test_x_non_corpus<-nondata[sampling_II,]
test_x_non_corpus_sample<-sampling_II



list_iterate_time=c(1:9,seq(10,90,10),seq(100,900,100),seq(1000,9000,1000),seq(10000,100000,10000))
count=0
for (iterate_time in list_iterate_time) 
{
  count=count+1
  size_training_set<-(iterate_time/2)
  
  for (inside_iterate_time in 1:5)
  {
    train_x_corpus_sample<-sample(total[!total %in% sampling_I],size_training_set)
    train_x_non_corpus_sample<-sample(total_II[!total_II %in% sampling_II],size_training_set)
    train_x_corpus<-nodata[x_corpus_sample,]
    train_x_non_corpus<-nondata[x_non_corpus_sample,]
    
    train_x_corpus_I<-subset(train_x_corpus, select = c(words$Word,"result"))
    test_x_corpus_I<-subset(test_x_corpus, select = c(words$Word,"result"))
    train_x_non_corpus_I<-subset(train_x_non_corpus, select = c(words$Word,"result"))
    test_x_non_corpus_I<-subset(test_x_non_corpus, select = c(words$Word,"result"))
    
    x<-subset(rbind(train_x_corpus_I,train_x_non_corpus_I), select = -result)
    y<-subset(rbind(train_x_corpus_I,train_x_non_corpus_I), select = result)
    colnames(y)<-"y"
    
    start.time <- Sys.time()

    model <- svm(x, y,type='C-classification')
    
    end.time <- Sys.time()
    time.taken <- end.time - start.time
    time_train[iterate_time]<-time.taken
    pred <- predict(model, x) 
    pred<-as.data.frame(pred)
    tab<-table(pred$pred,y$y)
    conf<-confusionMatrix(tab)
    accuracy_train_I<-conf$overall[1]
    
    
    test_x<-subset(rbind(test_x_corpus_I,test_x_non_corpus_I),select=-result)
    test_y<-subset(rbind(test_x_corpus_I,test_x_non_corpus_I),select=result)
    # test on the whole set
    start.time <- Sys.time()
    pred <- predict(model, test_x) 
    end.time <- Sys.time()
    time.taken <- end.time - start.time
    time_test[iterate_time]<-time.taken
    
    pred<-as.data.frame(pred)
    tab<-table(pred$pred,test_y$result)
    conf<-confusionMatrix(tab)
    accuracy_test_I<-conf$overall[1]
    
    load("data_I_non.saved")
    load("data_II_non.saved")
    load("data_corpus.saved")
    non_corpus<-rbind(data_I_non,data_II_non)
    test_x_non_corpus<-test_x_non_corpus_sample,
    
    
  }
  overall_accuracy_train_total_I[count]<-accuracy_train_I
  overall_accuracy_test_total_I[count]<-accuracy_test_I
  seq_value<-iterate_time
  
  
}