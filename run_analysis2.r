run_analysis2 <- function(){
    require(data.table)  ## These following lines will load required packages
	require(reshape2)
	require(car)
	
## The following lines involved loading the data and organizing the individual sets
trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactor = F)	## Subjects from the 'train'
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactor = F)		## Subjects from 'test'
names(testSubject) <- "Subject"		## Renames column to "Subject"
names(trainSubject) <- "Subject"	## Renames column to "Subject"
ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)	## Activity values from 'train'
ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)		## Activity values from 'test'


##  The following lines use recode() from the 'car' package to rename the numeric activity values to their corresponding Activity
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

										
## The following lines turn the activity vectors to a data-frame
ytrain <- data.frame(ytrain)
ytest <- data.frame(ytest)

## Renames the column to "Activity"
names(ytrain) <- "Activity"		
names(ytest) <- "Activity"


##  The following imports the 'features' or the variable names of the cell phone data
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)
##  Creates an increasing numeric vector of variables the show the mean and standard deviation; anything with mean() or std()
variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),  
                    grep("std()", features$V2, value = F, fixed = T)))
featurenames <- features[variables,]$V2  	##  Creates a list from the 'features' matching the indices from 'variables'
											##  To be later used to name the final datasets
											
##  The following imports the specific variables according to the indices created by the 'variables' vector
xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]
xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]
## 	Names the columns of the raw data using the list created in 'featurenames'
names(xtrain) <- featurenames
names(xtest) <- featurenames

##  The following combines the train-sets and the test-sets separately; then together creating one large set : oneSet
trainSet <- data.frame(trainSubject, ytrain, xtrain)
testSet <- data.frame(testSubject, ytest, xtest)
oneSet <<- rbind(trainSet, testSet)
oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]		##  recode() makes the Activity column factors; this returns it to characters

##  The following makes the column names of oneSet more tidy
oSnames <- names(oneSet)				## Creates a vector of the names of the column
oSnames <- gsub("[.]", "", oSnames)		## Takes all the periods out of the vector
names(oneSet) <- oSnames				## Renames 'oneSet's columns from the tidy name vector (oSnames)

##  This part creates a new data set that shows the average(mean) of every variable grouped by 'Subjects' and their corresponding 'Activity'
molten = melt(oneSet, id = c("Subject", "Activity"))  ##  Collapses 'oneSet' to a long, simplified data set sorted by 'Subject' & 'Activity'
names(molten) <- c("Subject", "Activity", "Variable", "Value")  ## This step is necessary but I just renamed the collapsed dataset columns
##  The final part reforms the data row-wise by 'Subject' and 'Activity' then column-wise by the 'Variables', then takes the mean according to ##  the group
tidyData <<- dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)
write.table(tidyData, file = file.choose(new = T))
View(tidyData)  ##  This brings up the 'tidyData' in the preview window
} 
