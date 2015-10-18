# install.packages("caret")
# install.packages("RMySQL")
# install.packages("e1071")

library(e1071)
library(RMySQL)
library(caret) 
library("reshape2")
library("ggplot2")

install.packages(doParallel)
library(doParallel)
cl <- makeCluster(detectCores()) 
registerDoParallel(cl)

accuracy_size=10
accuracy_diff=10

mydb = dbConnect(MySQL(), user='root', password='sajal', dbname='Disease_names', host='localhost', passwd='sajal')
rs = dbSendQuery(mydb,'set character set "utf8"')

new_rs = dbSendQuery(mydb, "SELECT distinct Stemmed_Article FROM `Corpus_English`  where Stemmed_Article !=\"\"")
stemmed_articles = fetch(new_rs, n=-1)
len_stemmed_article<-length(stemmed_articles$Stemmed_Article)

overall_accuracy<-double(accuracy_size)
# for (iterate_time in 1:accuracy_size) 
# {
iterate_time=10
# word_count=iterate_time*10
word_count=iterate_time*accuracy_diff

# data(iris)
# df <- iris
# 
# df <- subset(df ,  Species=='setosa')  #choose only one of the classes
query=paste("SELECT * FROM `Topics_LDA_1_temp_1000` ORDER BY  `Topics_LDA_1_temp_1000`.`Probability` DESC LIMIT 0 ,",toString(word_count))
rs = dbSendQuery(mydb, query)
words = fetch(rs, n=-1)
words <- subset(words, select = -Topic_Num)
nodata <- as.data.frame(setNames(replicate(word_count,logical(len_stemmed_article), simplify = F), seq(1:word_count)))
colnames(nodata)<-words$Word
for(i in 1:word_count) 
{
  for (j in 1:len_stemmed_article)
  {
   article= stemmed_articles$Stemmed_Article[j]
   word=words$Word[i]
   nodata[[word]][j]<-grepl(word,article)
  }
}
# x <- subset(df, select = -Species) #make x variables
# y <- df$Species #make y variable(dependent)
x<-nodata
y<-as.data.frame(rep(c(T),each=len_stemmed_article))
colnames(y)<-"y"
# obj <- tune(svm, x, y, ranges = list(gamma = 2^(-1), cost = 2^(2)),type="one-classification",tunecontrol = tune.control(performances=T))

# obj <- tune(svm, x, y, ranges = list(gamma = 2^(-1:1), cost = 2^(2:4)),type="one-classification",tunecontrol = tune.control(performances=T))
obj <- tune(svm, x, y, ranges = list(gamma = 2^(-1:1), cost = 2^(2:4)),type="one-classification",tunecontrol = tune.control(sampling = "cross",cross = 10, nrepeat = 3))
summ<-summary(obj)
# model <- svm(x, y,gamma=summ$best.parameters$gamma,cost=summ$best.parameters$cost,type='one-classification') #train an one-classification model 
model <- svm(x, y,type='one-classification') #train an one-classification model 


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
# confusionMatrix(tab,as.factor(TRUE))
accuracy<-(tab[2][1] /(tab[1][1]+tab[2][1]))*100
accuracy
overall_accuracy[iterate_time]<-accuracy
# }
x_input<-seq(1:accuracy_size)*accuracy_diff

main_frame<-as.data.frame(cbind(overall_accuracy,x_input))

test_data_long <- melt(main_frame, id="x_input")  # convert to long format

ggplot(data=main_frame,
       aes(x=x_input, y=overall_accuracy, colour="red")) +
  geom_line()


# dev.new(width=5, height=5)
# plot(fit, iris.part[, c(1,2)])
# 
# # Tabulate actual labels vs. fitted labels
# pred = predict(fit, iris.part)
# table(Actual=iris.part$Species, Fitted=pred)
# 
# # Obtain feature weights
# w = t(fit$coefs) %*% fit$SV
# svm_model <- tune(svm(training,y=NULL, type='one-classification', nu=0.01, gamma=0.002, scale=TRUE, kernel="radial", tunecontrol = tune.control(nrepeat = 3))
# tune.svm(x = training,y=rep(TRUE,length(training[,1])), tunecontrol = tune.control(nrepeat = 3),scale=TRUE,kernel="radial",type="one-classification",nu=0.01)
