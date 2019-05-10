# for svm models
library(e1071)
# For random forest models
library(randomForest)
# for extreme gradient boosting
library(xgboost)
# for xgboost plotting
library(Ckmeans.1d.dp)
library(DiagrammeR)

## 75% of the sample size
smp_size <- floor(0.75 * nrow(poems))

train_ind <- nrow(poems) %>% seq_len() %>% sample(size = smp_size)

train <- poems[train_ind, ]
test <- poems[-train_ind, ]

# SVM
svmfit <- svm(Author ~ sentiment + LineWords, 
              data = train, 
              kernel = "linear",
              cost = 10,
              scale = FALSE
)


# evaluate error rate
cm <- table(predict(svmfit, test), test$Author)
svmfit.accuracy = (sum(diag(cm)))/sum(cm)
svmfit.accuracy

#Random Forests


forest.model <- randomForest(Author ~ sentiment + topic1 + topic2 + topic3 + topic4 + topic5 + topic6 + LineWords + PoemLines,
                             data = train, 
                             ntree=100 )
forest.pred <- predict(forest.model, newData=test)

# evaluate error rate
cm2 <- table(predict(forest.model, test), test$Author)
forest.accuracy = (sum(diag(cm2)))/sum(cm2)
forest.accuracy

xg.train.data <- as.matrix(train[c("sentiment", "LineWords", "PoemLines", "topic1", "topic2", "topic3", "topic4", "topic5", "topic6", "topic7")])
xg.train.label <- as.numeric(train$Author) - 1
xg.test.data <- as.matrix(test[c("sentiment", "LineWords", "PoemLines", "topic1", "topic2", "topic3", "topic4", "topic5", "topic6", "topic7")])
xg.test.label <- as.numeric(test$Author) - 1
xg.test.matrix <- xgb.DMatrix(data = xg.test.data, label = xg.test.label)

boost.model <- xgboost(
  data=xg.train.data,
  label=xg.train.label,
  nrounds = 100,
  objective = "multi:softmax",
  num_class = 7,
  eval_metric = "mlogloss"
)

cm3 <- table(predict(boost.model, xg.test.matrix) + 1, as.numeric(test$Author))
boost.accuracy = (sum(diag(cm3)))/sum(cm3)
boost.accuracy
