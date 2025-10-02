source("gme.R")
library(xlsx)

dta <- read.xlsx2("../../data/smoking.xls", 
                  sheetIndex = 1,
                  colClasses = rep("numeric", 10))
Y <- dta[,1]
X <- as.matrix(dta[,-1])
X <- cbind(1,X)
colnames(X)[[1]] <- "constant"
kappa(X)

model <- GMELogit$new()
model$fit(X, Y)
model$summary()
