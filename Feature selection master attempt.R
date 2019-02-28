# install.packages("randomForest")
library('randomForest')

Rsquared<-function(y, f){
  return (1 - sum((f - y)^2) / sum((y - mean(y))^2))}

combined<-function(filea,fileb,x){
  cbind(filea,fileb[1:(nrow(fileb)-(x-1)),2])}

lag<-function(file,x){
  cbind(file[x:nrow(file),2],file[1:(nrow(file)-(x-1)),-2])}

bubblesort <- function(x, y)
{
  n <- length(x) # better insert this line inside the sorting function
  for (k in n:2) # every iteration of the outer loop bubbles the maximum element 
    # of the array to the end
  {
    i <- 1       
    while (i < k)        # i is the index for nested loop, no need to do i < n
      # because passing j iterations of the for loop already 
      # places j maximum elements to the last j positions
    {
      # print(i)
      if (x[i] < x[i+1]) # if the element is greater than the next one we change them
      {
        temp <- x[i+1]
        x[i+1] <- x[i]
        x[i] <- temp
        
        temp <- y[i+1]
        y[i+1] <- y[i]
        y[i] <- temp
      }
      i <- i+1           # moving to the next element
    }
  }
  return (list(x, y))              # returning sorted x (the last evaluated value inside the body
  # of the function is returned), we can also write return(x)
}

file1<-read.csv('master file_2011.csv',stringsAsFactors = FALSE)
sum(is.na(file1))

daysLagged <- 6
#lagging the data and creating a Forward MOAS column (Y)
lagged_data<-lag(file1,daysLagged)
colnames(lagged_data)[1]<-"Forward_Spreads"
#laggedData<-cbind(file1[6:nrow(file1), 2],file1[1:(nrow(file1)-5), -2])


#adding original credit spreads to the data

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
# for (val in seq_len(length(trainingData)-2))
Rsquareds <- vector()
dependents <- vector(mode = 'character')
for (val in 4)
{
  # print(val)
  dependentCombinations <- c(combn(names(trainingData)[!names(trainingData) %in% c("DATE", "Forward_Spreads")], val,
                                   simplify = FALSE))
  index = 1
  for (combination in dependentCombinations)
  {
    print(index)
    index = index + 1
    form <- reformulate(termlabels = combination, response = "Forward_Spreads")
    if (val < 3) mtr = 1
    else mtr = as.integer(floor(val/3))
    thisModel <- randomForest(form, data=trainingData, subset = train_sampler, importance=TRUE, ntree=500,
                              na.action = na.exclude, mtry = mtr)
    rfPredictedValues <- predict(thisModel, testingData[, -1])
    
    Rsquareds <- append(Rsquareds, Rsquared(testingData[, 1], rfPredictedValues))
    dependents <- append(dependents, list(combination))
    # print(dependents)
    
    if (length(Rsquareds)>1){
      tempVar <- bubblesort(Rsquareds, dependents)
      # print(tempVar)
      Rsquareds <- tempVar[[1]]
      dependents <- vector(mode = 'character')
      dependents <- tempVar[[2]]
    }
    
    if (length(Rsquareds) == 11) {
      Rsquareds <- Rsquareds[1:10]
      dependents <- dependents[1:10]
    }
    
    # if (index ==2)
    #   stop()
  }
  
  write.csv(cbind(Rsquareds, dependents), file = paste("Best OOS results ", val, ".csv"), row.names = FALSE)
}

