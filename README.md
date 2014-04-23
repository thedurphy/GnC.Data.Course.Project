Method to making run_analysis.R
===============================
### *Couple of notes before starting*

### There are 2 scripts I uploaded
1.  **run_analysis.R** is a function and will automatically write the tidy dataset as *tidyData.txt* in your working directory.  *tidyData.txt* is also included in this repo. 
2.  **run_analysis2.r** is a function and will prompt you to choose the name of the tidy dataset and the location you would like to save it.
3.  An easy way to run the scripts is by setting your working directory to the directory that includes the Raw Data Folded.  Then copy paste into R teh following....

##### For run_analysis.R
source("https://raw.githubusercontent.com/thedurphy/GnC.Data.Course.Project/master/run_analysis.R")

##### For run_analysis2.R
source("https://raw.githubusercontent.com/thedurphy/GnC.Data.Course.Project/master/run_analysis2.r")

###### Both will produce *oneSet* and *tidyData* data sets, the requested large dataset and tidy-average dataset, to the global environment for easy experimentation

### The following packages will be automatically installed by either script
* data.table
* car
* reshape2


# First Draft
####  I performed the following steps manually to create the requested datasets.  Hopefully it will shed some insight on my thought process

## Importing the Data
### 1.  Imported the subject list from both the *train* and *test* directories into separate variables
1. > trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactor = F)
2. > testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactor = F)
3. > names(testSubject) <- "Subject"
4. > names(trainSubject) <- "Subject"

### 2.  Imported the y files from *train* and *test* directories into separate variables and labeled them using the *recode()* function from the **car** package
1. > ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)
2. > ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)
3. > ytrain <- recode(ytrain$V1, "'1' = 'Walking';
										'2' = 'Walking Upstairs';
										'3' = 'Walking Downstairs';
										'4' = 'Sitting';
										'5' = 'Standing';
										'6' = 'Laying'")
4. > ytest <- recode(ytest$V1, "'1' = 'Walking';
										'2' = 'Walking Upstairs';
										'3' = 'Walking Downstairs';
										'4' = 'Sitting';
										'5' = 'Standing';
										'6' = 'Laying'")
5. > ytrain <- data.frame(ytrain)
6. > ytest <- data.frame(ytest)
7. > names(ytrain) <- "Activity"  *(renamed the column)*
8. > names(ytest) <- "Activity"    *(renamed the column)*

### 3.  Imported the features text and with *grep()* found exactly which variable indices were needed in the tidy data (mean, standard deviation).  

######I chose the names that matched *mean()* and *std()*.  This resulted in 66 results.  There were features that included the word *mean* but I chose not to include them because there were implicitly placed in a separate category from the *features_info.txt* file included.  Also, for every *mean()*, there is a corresponding *std()* column.  Since the requested data asked for mean *and* standard deviation, it seemed logical to limit the data set to results that corresponded to each other in order to preserve information integrity.
1. > features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)
2. > variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),
							grep("std()", features$V2, value = F, fixed = T)))
3. > featurenames <- features[variables,]$V2    *(this created a vector of the names of the variables needed; used later)*


###  4.  Imported the X *train* and *test* datasets using the previously created _variables_ vector to subset the specific columns the labeled the columns
1. > xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]
2. > xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]
3. > names(xtrain) <- featurenames
4. > names(xtest) <- featurenames

## Arranging the datasets into 1

### 1.  Combined all the *train* sets; combined all the *test* sets   *(by column)*
1. > trainSet <- data.frame(trainSubject, ytrain, xtrain)
2. > testSet <- data.frame(testSubject, ytest, xtest)

### 2.  Combined the remaining sets into one, by row
1. > oneSet <- rbind(trainSet, testSet)
2. > oneSet$Activity <- as.character(oneSet$Activity)   (*the recode()* turns the Activity column into factors, this returns it to characters)

### 3.  Now I will rename the columns of **oneSet** so it looks a little tidier.  
3. > oSnames <- names(oneSet)
4. > oSnames <- gsub("[.]", "", oSnames)                *(removed the periods)*
5. > names(oneSet) <- oSnames                   *(oSnames is a vector of the column names in the final data sets)*

## Creating a seperate tidy dataset that shows the means of all the variables sorted by subjects and their respective activity
1. > molten = melt(oneSet, id = c("Subject", "Activity"))   *(this collapses the data set into a long skinny dataset based on "subjects" and "activity")*
2. > names(molten) <- c("Subject", "Activity", "Variable", "Value")  *(made easily recognizable column names)*
3. > tidyData = dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)     *(made DF of the variable-means based on Subject and Activity)*
### If the columns are not in the same order as *oneSet*, try this.
4. > tidyData <- tidyData[c(OSnames)]     *(here is where you use the variable *oSnames* to reorder the columns to the original)*

# Explanation of the *oneSet* and *tidyData* data-sets and their Variables

## The main variables of the Data Sets are the following.
1. Subject   *(which # out of 30 individuals)*
2. Activity  *(the specific activity the individual is doing)*

3. tBodyAcc-XYZ
4. tGravityAcc-XYZ
5. tBodyAccJerk-XYZ
6. tBodyGyro-XYZ
7. tBodyGyroJerk-XYZ
8. tBodyAccMag
9. tGravityAccMag
10. tBodyAccJerkMag
11. tBodyGyroMag
12. tBodyGyroJerkMag
13. fBodyAcc-XYZ
14. fBodyAccJerk-XYZ
15. fBodyGyro-XYZ
16. fBodyAccMag
17. fBodyAccJerkMag
18. fBodyGyroMag
19. fBodyGyroJerkMag

#### A couple of things to note
1.  the 'XYZ' denotes the 3 dimensions of data being recorded so they will have their own columns
2.  For expediency, the data sets will only include the *mean* and the *standard deviation* columns from the primary raw data which were 
denoted by *mean()* and *std()*
3. For example: the first column of the data-sets were *originally* **tBodyAcc-mean()-X**
4. For tidiness, it has been converted into **tBodyAccmeanY**

#### Let's move left to right on the variables to define what they mean.
##### Examples:
1. tBodyAccmeanY
2. fBodyBodyGyroJerkMagstd
3. tGravityAccmeanX

###### the first letter (t or f) denotes '(t)time domain signal' or whether '(f)Fast Fourier  Transform (FFT)' was applied to it
###### the results within the '(t) time domain signals' were then separated into 'Body' and 'Gravity' measurements as you can see in Examples 1 & 2
###### the 3rd part of the variable denotes which piece of equiptment from the cellphone was used for recording the data:
###### Acc = Accelerometer; Gyro = Gyroscope
###### the variables with 'Jerk' denotes a values derived from body linear acceleration and angular velocity over time
###### the next part shows whether the value is the 'Mean' or the 'Standard Deviation'; mean, std, respectively
###### if the variable has an X, Y, or Z, it denotes the dimensional component being measured

#### The Data Sets

..There are 2 data sets the script will out put into the Global Environment to work with: **oneSet** and **tidyData** (tidyData will be opened to View)

**oneSet** will have 10299 observations (rows) of the 66 variables that result by only taking the *mean* and the *standard deviation* from the primary raw data
...each *Subject* will have multiple observations per *Activity*

**tidyData** is the average of every variable sorted by the *Subject* and the *Activity* they are performing.
...since there are 6 activities and 30 subjects the final dimensions will be (6*30) 180 rows and (2+66) 68 columns  *(2 being the Subject and Activity columns)*

# The scripts

## run_analysis.R
###### run_analysis <- function(){
######    require(data.table)
######	require(reshape2)
######	require(car)
###### trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactor = F)
###### testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactor = F)
###### names(testSubject) <- "Subject"
###### names(trainSubject) <- "Subject"
###### ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)
###### ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)
###### ytrain <- recode(ytrain$V1, "'1' = 'Walking';
######    									'2' = 'Walking Upstairs';
######										'3' = 'Walking Downstairs';
######										'4' = 'Sitting';
######										'5' = 'Standing';
######										'6' = 'Laying'")
###### ytest <- recode(ytest$V1, "'1' = 'Walking';
######    									'2' = 'Walking Upstairs';
######										'3' = 'Walking Downstairs';
######										'4' = 'Sitting';
######										'5' = 'Standing';
######										'6' = 'Laying'")
###### ytrain <- data.frame(ytrain)
###### ytest <- data.frame(ytest)
###### names(ytrain) <- "Activity"
###### names(ytest) <- "Activity"
###### features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)
###### variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),
######                    grep("std()", features$V2, value = F, fixed = T)))
###### featurenames <- features[variables,]$V2
###### xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]
###### xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]
###### names(xtrain) <- featurenames
###### names(xtest) <- featurenames
###### trainSet <- data.frame(trainSubject, ytrain, xtrain)
###### testSet <- data.frame(testSubject, ytest, xtest)
###### oneSet <<- rbind(trainSet, testSet)
###### oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]
###### oSnames <- names(oneSet)
###### oSnames <- gsub("[.]", "", oSnames)
###### names(oneSet) <- oSnames
###### molten = melt(oneSet, id = c("Subject", "Activity"))
###### names(molten) <- c("Subject", "Activity", "Variable", "Value")
###### tidyData <<- dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)
###### write.table(tidyData, file = "tidyData.txt")
###### View(tidyData)
###### }

## run_analysis2.R
###### run_analysis <- function(){
######    require(data.table)
######	require(reshape2)
######	require(car)
###### trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactor = F)
###### testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactor = F)
###### names(testSubject) <- "Subject"
###### names(trainSubject) <- "Subject"
###### ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)
###### ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)
###### ytrain <- recode(ytrain$V1, "'1' = 'Walking';
######    									'2' = 'Walking Upstairs';
######										'3' = 'Walking Downstairs';
######										'4' = 'Sitting';
######										'5' = 'Standing';
######										'6' = 'Laying'")
###### ytest <- recode(ytest$V1, "'1' = 'Walking';
######    									'2' = 'Walking Upstairs';
######										'3' = 'Walking Downstairs';
######										'4' = 'Sitting';
######										'5' = 'Standing';
######										'6' = 'Laying'")
###### ytrain <- data.frame(ytrain)
###### ytest <- data.frame(ytest)
###### names(ytrain) <- "Activity"
###### names(ytest) <- "Activity"
###### features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)
###### variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),
######                    grep("std()", features$V2, value = F, fixed = T)))
###### featurenames <- features[variables,]$V2
###### xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]
###### xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]
###### names(xtrain) <- featurenames
###### names(xtest) <- featurenames
###### trainSet <- data.frame(trainSubject, ytrain, xtrain)
###### testSet <- data.frame(testSubject, ytest, xtest)
###### oneSet <<- rbind(trainSet, testSet)
###### oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]
###### oSnames <- names(oneSet)
###### oSnames <- gsub("[.]", "", oSnames)
###### names(oneSet) <- oSnames
###### molten = melt(oneSet, id = c("Subject", "Activity"))
###### names(molten) <- c("Subject", "Activity", "Variable", "Value")
###### tidyData <<- dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)
###### write.table(tidyData, file = file.choose(new = T))
###### View(tidyData)
###### }