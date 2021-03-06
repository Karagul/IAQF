# install.packages("randomForest")
library('randomForest')

Rsquared<-function(y, f){
  return (1 - sum((f - y)^2) / sum((y - mean(y))^2))}

lag<-function(file,x){
  cbind(file[x:nrow(file),2],file[1:(nrow(file)-(x-1)),-2])}

combined<-function(filea,fileb,x){
  cbind(filea,fileb[1:(nrow(fileb)-(x-1)),2])}

file1<-read.csv('master file_2011.csv',stringsAsFactors = FALSE)

daysLagged <- 6
#lagging the data and creating a Forward MOAS column (Y)
lagged_data<-lag(file1,daysLagged)
colnames(lagged_data)[1]<-"Forward_Spreads"

#adding original credit spreads to the data\
laggedData.credSpread<-combined(lagged_data,file1,daysLagged)
colnames(laggedData.credSpread)[21]<-"original_spreads"
dataf<-laggedData.credSpread

set.seed(102)
trainingData<-dataf[1:floor(nrow(dataf)*.7),]
testingData<-dataf[(floor(nrow(dataf)*.7)+1):nrow(dataf),]

#sampler variable created from trainingData
train_sampler=sample(seq_len(nrow(trainingData)),size=floor(.7*nrow(trainingData)))

#Full Random Forest
set.seed(100)
rmForestModel<-randomForest(Forward_Spreads~.-DATE, data=trainingData,subset = train_sampler,
                            importance=TRUE, ntree=500, na.action = na.exclude)
rmForestModel
#Prediction on testing data
rfPredictedValues<-predict(rmForestModel, testingData[,-1])
Rsq = Rsquared(testingData[,1], rfPredictedValues)
varImpPlot(rmForestModel)    
importance(rmForestModel)

# Model 1
# Low values of importance for ETF's volchange, thus removing them.
set.seed(100)
rmForestModel1<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch,
                            data=trainingData,subset = train_sampler,
                            importance=TRUE, ntree=500, na.action = na.exclude)
rmForestModel1
#Prediction on testing data
rfPredictedValues1<-predict(rmForestModel1, testingData[,-1])
Rsq1 = Rsquared(testingData[,1], rfPredictedValues1)

#varImp(rmForestModel1)        # caret package
#varImpPlot(rmForestModel1)    # RF forest Package
importance(rmForestModel1)


# Model 2
set.seed(100)
rmForestModel2<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch
                             -SP500Vol_Ch,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500, na.action = na.exclude)
rmForestModel2
rfPredictedValues2<-predict(rmForestModel2, testingData[,-1])
Rsq2 = Rsquared(testingData[,1], rfPredictedValues2)
importance(rmForestModel2)


# Model 3
set.seed(100)
rmForestModel3<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch
                             -SP500Vol_Ch-SP500Ch,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500, na.action = na.exclude)
rmForestModel3
#Prediction on testing data
rfPredictedValues3<-predict(rmForestModel3, testingData[,-1])
Rsq3 = Rsquared(testingData[,1], rfPredictedValues3)
importance(rmForestModel3)


# Model 4
set.seed(100)
rmForestModel4<-randomForest(Forward_Spreads~.-DATE-LQD_volch-HYG_volch-JNK_volch
                             -SP500Vol_Ch-GDP_ch-CPI-Fedfund_rate,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500, na.action = na.exclude)
rmForestModel4
#Prediction on testing data
rfPredictedValues4<-predict(rmForestModel4, testingData[,-1])
Rsq4 = Rsquared(testingData[,1], rfPredictedValues4)
importance(rmForestModel4)


# Model 5
set.seed(100)
rmForestModel5<-randomForest(Forward_Spreads~ CDX.IG_5Y+HYOAS_Spreads+Ind_Production
                             +Price_ratio,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500, mtry=1,
                             na.action = na.exclude)
rmForestModel5
#Prediction on testing data
rfPredictedValues5<-predict(rmForestModel5, testingData[,-1])
Rsq5 = Rsquared(testingData[,1], rfPredictedValues5)
importance(rmForestModel5)



