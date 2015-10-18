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

new__non_rs = dbSendQuery(mydb, "SELECT distinct Stemmed_Article FROM `Articles_English_language_Non_corpus`  where Stemmed_Article !=\"\"")
non_corpus_stemmed_articles = fetch(new__non_rs, n=-1)
len_non_corpus_stemmed_articles<-length(non_corpus_stemmed_articles$Stemmed_Article)

new__non_rs_II = dbSendQuery(mydb, "SELECT distinct Stemmed_Article FROM `Articles_English_language_Non_corpus_II`    where Stemmed_Article !=\"\"")
non_corpus_stemmed_articles_II = fetch(new__non_rs_II, n=-1)
len_non_corpus_stemmed_articles_II<-length(non_corpus_stemmed_articles_II$Stemmed_Article)

new_rs = dbSendQuery(mydb, "SELECT distinct Stemmed_Article FROM `Corpus_English`  where Stemmed_Article !=\"\"" )
stemmed_articles = fetch(new_rs, n=-1)
len_stemmed_article<-length(stemmed_articles$Stemmed_Article)

# train_data_corpus=stemmed_articles[c(1:len_non_corpus_stemmed_articles),]
# test_data_corpus=stemmed_articles[c(len_non_corpus_stemmed_articles+1:len_stemmed_article),]

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

###################################################
# word_count<-100
# 
# query=paste("SELECT * FROM `Topics_LDA_1_temp_1000` ORDER BY  `Topics_LDA_1_temp_1000`.`Probability` DESC LIMIT 0 ,",toString(word_count))
# rs = dbSendQuery(mydb, query)
# words = fetch(rs, n=-1)
# words <- subset(words, select = -Topic_Num)
# 
# nondata_II <- as.data.frame(setNames(replicate(word_count+1,logical(len_non_corpus_stemmed_articles_II), simplify = F), seq(1:(word_count+1))))
# colnames(nondata_II)<-c(words$Word,"result")
# for(i in 1:word_count) 
# {
#   for (j in 1:len_non_corpus_stemmed_articles_II)
#   {
#     article= non_corpus_stemmed_articles_II$Stemmed_Article[j]
#     word=words$Word[i]
#     nondata_II[[word]][j]<-grepl(word,article)
#   }
# }
# nondata_II$result<-rep(c(F),each=len_non_corpus_stemmed_articles_II)
# save(nondata_II, file="nondata_II_also.saved")
# load(nondata_II.saved)
##########################################################

word_count<-100
query=paste("SELECT * FROM `Topics_LDA_1_temp_1000` ORDER BY  `Topics_LDA_1_temp_1000`.`Probability` DESC LIMIT 0 ,",toString(word_count))
rs = dbSendQuery(mydb, query)
words = fetch(rs, n=-1)
words <- subset(words, select = -Topic_Num)

load("nodata.saved")
sampling_I<-sample(nrow(nodata),max_to_take)
test_x_corpus<-nodata[sampling_I,]
total<-c(1:len_stemmed_article)



load("nondata.saved")
load("nondata_II_also.saved")
nondata<-subset(nondata, select = c(words$Word,"result"))
nondata<-rbind(nondata,nondata_II)
len_non_corpus<-len_non_corpus_stemmed_articles+len_non_corpus_stemmed_articles_II
total_II<-c(1:len_non_corpus)
sampling_II<-sample(nrow(nondata),max_to_take)
test_x_non_corpus<-nondata[sampling_II,]



list_iterate_time=c(1:9,seq(10,90,10),seq(100,900,100),seq(1000,9000,1000),seq(10000,100000,10000))
count=0
for (iterate_time in list_iterate_time) 
{
  count=count+1
  size_training_set<-(iterate_time/2)
  
  for (inside_iterate_time in 1:5)
  {
  train_x_corpus<-nodata[sample(total[!total %in% sampling_I],size_training_set),]
  train_x_non_corpus<-nondata[sample(total_II[!total_II %in% sampling_II],size_training_set),]
  
  #iterate_time=100
  # word_count=iterate_time*10

  
  # nodata <- as.data.frame(setNames(replicate(word_count+1,logical(len_stemmed_article), simplify = F), seq(1:(word_count+1))))
  # colnames(nodata)<-c(words$Word,"result")
  # for(i in 1:word_count) 
  # {
  #   for (j in 1:len_stemmed_article)
  #   {
  #     article= stemmed_articles$Stemmed_Article[j]
  #     word=words$Word[i]
  #     nodata[[word]][j]<-grepl(word,article)
  #   }
  # }
  # nodata$result<-rep(c(T),each=len_stemmed_article)
  
  # save(nodata, file="nodata.saved")
  
  
  #   nondata <- as.data.frame(setNames(replicate(word_count+1,logical(len_non_corpus_stemmed_articles), simplify = F), seq(1:(word_count+1))))
  #   colnames(nondata)<-c(words$Word,"result")
  #   for(i in 1:word_count) 
  #   {
  #     for (j in 1:len_non_corpus_stemmed_articles)
  #     {
  #       article= non_corpus_stemmed_articles$Stemmed_Article[j]
  #       word=words$Word[i]
  #       nondata[[word]][j]<-grepl(word,article)
  #     }
  #   }
  #   nondata$result<-rep(c(F),each=len_non_corpus_stemmed_articles)
  # save(nondata, file="nondata.saved")
  # train_x_non_corpus<-nondata
  
  
  # if (file.exists("nondata_II.saved")){
  
  # }else{
  
  # }

  train_x_corpus<-subset(train_x_corpus, select = c(words$Word,"result"))
  test_x_corpus<-subset(test_x_corpus, select = c(words$Word,"result"))
  train_x_non_corpus<-subset(train_x_non_corpus, select = c(words$Word,"result"))
  test_x_non_corpus<-subset(test_x_non_corpus, select = c(words$Word,"result"))
  # x <- subset(df, select = -Species) #make x variables
  # y <- df$Species #make y variable(dependent)
  x<-subset(rbind(train_x_corpus,train_x_non_corpus), select = -result)
  y<-subset(rbind(train_x_corpus,train_x_non_corpus), select = result)
  colnames(y)<-"y"
  # obj <- tune(svm, x, y, ranges = list(gamma = 2^(-1), cost = 2^(2)),type="one-classification",tunecontrol = tune.control(performances=T))
  
  # obj <- tune(svm, x, y, ranges = list(gamma = 2^(-1:1), cost = 2^(2:4)),type="one-classification",tunecontrol = tune.control(performances=T))
  # obj <- tune(svm, x, y, ranges = list(gamma = 2^(-1:1), cost = 2^(2:4)),type="one-classification",tunecontrol = tune.control(sampling = "cross",cross = 10, nrepeat = 3))
  # summ<-summary(obj)
  # model <- svm(x, y,gamma=summ$best.parameters$gamma,cost=summ$best.parameters$cost,type='one-classification') #train an one-classification model 
  
  #   obj <- tune(svm, x, y, ranges = list(gamma = 2^(-3:3), cost = 2^(-2:3)),type='C-classification',tunecontrol = tune.control(sampling = "cross",cross = 10))
  #   summ<-summary(obj)
  # model <- svm(x, y,gamma=summ$best.parameters$gamma,cost=summ$best.parameters$cost,type='C-classification') #train an one-classification model
  start.time <- Sys.time()
  
  model <- svm(x, y,type='C-classification')
  
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  time_train[iterate_time]<-time.taken
  # print(model)
  # summary(model) #print summary
  
  # test on the whole set
  pred <- predict(model, x) #create predictions
  pred<-as.data.frame(pred)
  tab<-table(pred$pred,y$y)
  # new_tab<-tab
  # colnames(new_tab)<-"FALSE"
  # new_tab[1]<-0
  # new_tab[2]<-0
  # tab<-apply(cbind(tab,new_tab), 2, rev)
  conf<-confusionMatrix(tab)
  accuracy_I<-conf$overall[1]
  # accuracy<-(tab[1][1]+tab[2][2] /(tab[1][1]+tab[1]tab[2][1]))*100
  
  
  test_x<-subset(rbind(test_x_corpus,test_x_non_corpus),select=-result)
  test_y<-subset(rbind(test_x_corpus,test_x_non_corpus),select=result)
  # test on the whole set
  start.time <- Sys.time()
  pred <- predict(model, test_x) #create predictions
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  time_test[iterate_time]<-time.taken
  
  pred<-as.data.frame(pred)
  tab<-table(pred$pred,test_y$result)
  # new_tab<-tab
  # colnames(new_tab)<-"FALSE"
  # new_tab[1]<-0
  # new_tab[2]<-0
  # tab<-apply(cbind(tab,new_tab), 2, rev)
  conf<-confusionMatrix(tab)
  accuracy<-conf$overall[1]
  # accuracy<-(tab[2][1] /(tab[1][1]+tab[2][1]))*100
  accuracy
  }
  overall_accuracy_train_total_I[count]<-accuracy_I
  overall_accuracy_train_total_I[count]<-accuracy_II
  seq_value<-iterate_time
  
  
}

# x_input<-seq(1:accuracy_size)*accuracy_diff
# 
# main_frame<-as.data.frame(cbind(overall_accuracy,x_input))
# 
# test_data_long <- melt(main_frame, id="x_input")  # convert to long format
# 
# ggplot(data=main_frame,
#        aes(x=x_input, y=overall_accuracy, colour="red")) +
#   geom_line()

# svm_model <- tune(svm(training,y=NULL, type='one-classification', nu=0.01, gamma=0.002, scale=TRUE, kernel="radial", tunecontrol = tune.control(nrepeat = 3))
# tune.svm(x = training,y=rep(TRUE,length(training[,1])), tunecontrol = tune.control(nrepeat = 3),scale=TRUE,kernel="radial",type="one-classification",nu=0.01)
