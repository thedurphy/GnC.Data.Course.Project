run_analysis <- function(){
    require(data.table)
	require(reshape2)
	require(car)
trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactor = F)
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactor = F)
names(testSubject) <- "Subject"
names(trainSubject) <- "Subject"
ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)
ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)
ytrain <- recode(ytrain$V1, "'1' = 'Walking';
    									'2' = 'Walking Upstairs';
										'3' = 'Walking Downstairs';
										'4' = 'Sitting';
										'5' = 'Standing';
										'6' = 'Laying'")
ytest <- recode(ytest$V1, "'1' = 'Walking';
    									'2' = 'Walking Upstairs';
										'3' = 'Walking Downstairs';
										'4' = 'Sitting';
										'5' = 'Standing';
										'6' = 'Laying'")
ytrain <- data.frame(ytrain)
ytest <- data.frame(ytest)
names(ytrain) <- "Activity"
names(ytest) <- "Activity"
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)
variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),
                    grep("std()", features$V2, value = F, fixed = T)))
featurenames <- features[variables,]$V2
xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]
xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]
names(xtrain) <- featurenames
names(xtest) <- featurenames
trainSet <- data.frame(trainSubject, ytrain, xtrain)
testSet <- data.frame(testSubject, ytest, xtest)
oneSet <<- rbind(trainSet, testSet)
oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]
oSnames <- names(oneSet)
oSnames <- gsub("[.]", "", oSnames)
names(oneSet) <- oSnames
molten = melt(oneSet, id = c("Subject", "Activity"))
names(molten) <- c("Subject", "Activity", "Variable", "Value")
tidyData <<- dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)
View(tidyData)
}
