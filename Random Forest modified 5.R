# install.packages("randomForest")
library('randomForest')

Rsquared<-function(y, f){
  return (1 - sum((f - y)^2) / sum((y - mean(y))^2))}

randomForestRunner<-function(form, d, sub, imp = TRUE, ntr = 500, naAction = na.exclude,
                             keepInbag = TRUE, repl = TRUE)
{
  # print(form)
  return (randomForest(formula = form, data = d, subset = sub, importance = imp, ntree = ntr, na.action = na.exclude,
                      keep.inbag = keepInbag, replace = repl))
}

file1<-read.csv('master file_2011.csv',stringsAsFactors = FALSE)
sum(is.na(file1))

daysLagged <- 6
#lagging the data and creating a Forward MOAS column (Y)
lag<-function(file,x){cbind(file[x:nrow(file),2],file[1:(nrow(file)-(x-1)),-2])}
lagged_data<-lag(file1,daysLagged)
colnames(lagged_data)[1]<-"Forward_Spreads"
#laggedData<-cbind(file1[6:nrow(file1), 2],file1[1:(nrow(file1)-5), -2])


#adding original credit spreads to the data
combined<-function(filea,fileb,x){cbind(filea,fileb[1:(nrow(fileb)-(x-1)),2])}
laggedData.credSpread<-combined(lagged_data,file1,daysLagged)
colnames(laggedData.credSpread)[21]<-"original_spreads"
#cbind(lagged_data, file1[1:(nrow(file1)-5),2])

dataf<-laggedData.credSpread

set.seed(102)
trainingData<-dataf[1:floor(nrow(dataf)*.7),]
testingData<-dataf[(floor(nrow(dataf)*.7)+1):nrow(dataf),]

#sampler variable created from trainingData
train_sampler=sample(seq_len(nrow(trainingData)),size=floor(.7*nrow(trainingData)))

#Full Random Forest


set.seed(100)
rmForestModel<-randomForestRunner(Forward_Spreads~.-DATE, trainingData, train_sampler)
rmForestModel
#Prediction on testing data
rfPredictedValues<-predict(rmForestModel, testingData[,-1])

#Calculating R2
Rsquared<-function(y, f)
{1 - sum((f - y)^2) / sum((y - mean(y))^2)}

#df<-cbind(trainingData[,1], rfPredictedValues)
Rsq = Rsquared(testingData[,1], rfPredictedValues)
#value is 14.34%

#View(rmForestModel$importance)
#varImp(rmForestModel)        # caret package
#varImpPlot(rmForestModel)    # RF forest Package
importance(rmForestModel)    # same as above

# Q.1 difference between importance(model) and varImp(model) and model$importance?



# Low values of importance for ETF's volchange, thus removing them.
set.seed(100)
rmForestModel1<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch,
                            data=trainingData,subset = train_sampler,
                            importance=TRUE, ntree=500,
                            na.action = na.exclude)
rmForestModel1
#Prediction on testing data
rfPredictedValues1<-predict(rmForestModel1, testingData[,-1])

#df<-cbind(trainingData[,1], rfPredictedValues)
Rsq1 = Rsquared(testingData[,1], rfPredictedValues1)
#value is 14.95%

#varImp(rmForestModel1)        # caret package
#varImpPlot(rmForestModel1)    # RF forest Package
importance(rmForestModel1)


# Low values of importance for SP500Vol_ch
set.seed(100)
rmForestModel2<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch
                             -SP500Vol_Ch,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500,
                             na.action = na.exclude)
rmForestModel2
#Prediction on testing data
rfPredictedValues2<-predict(rmForestModel2, testingData[,-1])
Rsq2 = Rsquared(testingData[,1], rfPredictedValues2)
#value is 23.95%
importance(rmForestModel2)


# 4th model removing SP500Ch.
set.seed(100)
rmForestModel3<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch
                             -SP500Vol_Ch-SP500Ch,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500,
                             na.action = na.exclude)
rmForestModel3
#Prediction on testing data
rfPredictedValues3<-predict(rmForestModel3, testingData[,-1])
Rsq3 = Rsquared(testingData[,1], rfPredictedValues3)
#value is 9.05%
importance(rmForestModel3)


# 5th model removing all INCnode purity<0 variables and adding SP500Ch back
set.seed(100)
rmForestModel4<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch
                             -SP500Vol_Ch-GDP_ch-CPI-Fedfund_rate,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500,
                             na.action = na.exclude)
rmForestModel4
#Prediction on testing data
rfPredictedValues4<-predict(rmForestModel4, testingData[,-1])
Rsq4 = Rsquared(testingData[,1], rfPredictedValues4)
#value is 21.21%
#shows that SP500Ch is an important variable
importance(rmForestModel4)

# 6th model taking only those for which both importance are>10%
set.seed(100)
rmForestModel5<-randomForest(Forward_Spreads~ CDX.IG_5Y+HYOAS_Spreads+Ind_Production
                             +Price_ratio,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500, mtry=1,
                             na.action = na.exclude)
rmForestModel5
#Prediction on testing data
rfPredictedValues5<-predict(rmForestModel5, testingData[,-1])
Rsq5 = Rsquared(testingData[,1], rfPredictedValues5)
#value is 77.52% and 82.79 if mtry=3 instead of 4.
#these are 4 important variables.
importance(rmForestModel5)


#tree5<-getTree(rmForestModel5,k=1, labelVar = FALSE)
