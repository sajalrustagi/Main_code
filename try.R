require(e1071)

# Subset the iris dataset to only 2 labels and 2 features
iris.part = subset(iris, Species != 'setosa')
iris.part$Species = factor(iris.part$Species)
iris.part = iris.part[, c(1,2,5)]

# Fit svm model
fit = svm(Species ~ ., data=iris.part, type='C-classification', kernel='linear')

# Make a plot of the model
dev.new(width=5, height=5)
plot(fit, iris.part[, c(1,2)])

# Tabulate actual labels vs. fitted labels
pred = predict(fit, iris.part)
table(Actual=iris.part$Species, Fitted=pred)

# Obtain feature weights
w = t(fit$coefs) %*% fit$SV

# # Calculate decision values manually
# iris.scaled = scale(iris.part[,-3], fit$x.scale[[1]], fit$x.scale[[2]]) 
# t(w %*% t(as.matrix(iris.scaled))) - fit$rho
# 
# # Should equal...
# fit$decision.values