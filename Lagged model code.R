lag<-function(file,x){
  cbind(file[x:nrow(file),2],file[1:(nrow(file)-(x-1)),-2])}

combined<-function(filea,fileb,x){
  cbind(filea,fileb[1:(nrow(fileb)-(x-1)),2])}

#Calculating R2
Rsquared<-function(y, f){
  1 - sum((f - y)^2) / sum((y - mean(y))^2)}

file1<-read.csv('master file_2011.csv',stringsAsFactors = FALSE)
sum(is.na(file1))

daysLagged <- 1:10

Rsquareds <- vector()
varExplained <- vector()
for (x in daysLagged)
{
  lagged_data<-lag(file1,x)
  # View(lagged_data)
  colnames(lagged_data)[1]<-"Forward_Spreads"
  laggedData.credSpread<-combined(lagged_data,file1,x)
  colnames(laggedData.credSpread)[21]<-"original_spreads"

  dataf<-laggedData.credSpread
  set.seed(102)

  trainingData<-dataf[1:floor(nrow(dataf)*.7),]
  testingData<-dataf[(floor(nrow(dataf)*.7)+1):nrow(dataf),]
  train_sampler=sample(seq_len(nrow(trainingData)),size=floor(.7*nrow(trainingData)))
  set.seed(100)
  rmForestModel5<-randomForest(Forward_Spreads~ CDX.IG_5Y+HYOAS_Spreads+Ind_Production
                             +Price_ratio+original_spreads,data=trainingData,subset = train_sampler,
                             importance=TRUE, ntree=500, mtry=3,
                             na.action = na.exclude)
  # rmForestModel5
  rfPredictedValues <- predict(rmForestModel5, testingData[, -1])
  Rsquareds <- append(Rsquareds, Rsquared(testingData[, 1], rfPredictedValues))
  varExplained <- append(varExplained, rmForestModel5$rsq[length(rmForestModel5$rsq)]*100)
}

Variation_explained<-sapply(varExplained,function(x){x/100})
as.data.frame(Variation_explained)
df1<-cbind(Rsquareds,Variation_explained)
View(df1)
write.csv(df1,'plot.csv')


