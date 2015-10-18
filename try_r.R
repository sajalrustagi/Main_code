# set.seed(21)
# values <- sample(letters, 1e4, TRUE)
# vector <- character(0)
# # slow
# system.time( for (i in 1:length(values)) vector[i] <- values[i] )
# #   user  system elapsed 
# #  0.340   0.000   0.343 
# vector <- character(length(values))
# # fast(er)
# system.time( for (i in 1:length(values)) vector[i] <- values[i] )
# #   user  system elapsed 
# #  0.024   0.000   0.023 

library(e1071)
data(iris)
df <- iris

df <- subset(df ,  Species=='setosa')  #choose only one of the classes

x <- subset(df, select = -Species) #make x variables
y <- df$Species #make y variable(dependent)
model <- svm(x, y,type='one-classification') #train an one-classification model 


print(model)
summary(model) #print summary

# test on the whole set
pred <- predict(model, subset(iris, select=-Species)) #create predictions
y<-c(rep(c(T),each=length(pred)))
tab<-table(pred,y)
