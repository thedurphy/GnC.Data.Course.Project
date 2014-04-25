Method to making run_analysis.R     <a name = "top"></a>
===============================

### Table of Contents

1. [First Draft](#firstdraft)
 - [Importing the Data](#importing)
 - [Arranging the Datasets into one](#arranging)
 - [Creating a separate tidy dataset that shows the means of all the variables sorted by subjects and their respective activity](#tidydata)

2. [Explanation of the oneSet and tidyData data-sets and their Variables](#explanation)
    - [The main variables of the Data Sets](#variables)
    - [The Data Sets](#datasets)
3. [The Scripts](#scripts)
    - [run_analysis.R](#ra1)
    - [run_analysis2.R](#ra2)
 

### *Couple of notes before starting*

### There are 2 scripts I uploaded
1.  **run_analysis.R** is a function and will automatically write the tidy dataset as 'tidyData.txt' in your working directory
2.  **run_analysis2.R** is a function and will prompt you to choose the name of the tidy dataset and the location you would like to save it


### The following packages will be automatically installed by either script
* data.table
* car
* reshape2


# First Draft <a name = "firstdraft"></a>
[back up top](#top)

> Before writing the script, I performed the following codes manually to create the desired data frames.  By doing it manually and step-by-step, I was able to experiment and find the most efficient way.


## Importing the Data <a name = "importing"></a>
[back up top](#top)
### Imported the subject list from both the *train* and *test* directories into separate variables
1. `> trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactor = F)`
2. `> testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactor = F)`
3. `> names(testSubject) <- "Subject"`
4. `> names(trainSubject) <- "Subject"`

### Imported the y files from *train* and *test* directories into separate variables and labeled them using the *recode()* function from the **car** package
1. `> ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)`
2. `> ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)`
3. `> ytrain <- recode(ytrain$V1, "'1' = 'Walking';`
`										'2' = 'Walking Upstairs';`
`										'3' = 'Walking Downstairs';`
										`'4' = 'Sitting';`
										`'5' = 'Standing';`
										`'6' = 'Laying'")`
4. `> ytest <- recode(ytest$V1, "'1' = 'Walking';`
										`'2' = 'Walking Upstairs';`
										`'3' = 'Walking Downstairs';`
										`'4' = 'Sitting';`
										`'5' = 'Standing';`
										`'6' = 'Laying'")`
5. `> ytrain <- data.frame(ytrain)`
6. `> ytest <- data.frame(ytest)`
7. `> names(ytrain) <- "Activity"`  *(renamed the column)*
8. `> names(ytest) <- "Activity"`    *(renamed the column)*

### Imported the features text and with *grep()* found exactly which variable indices were needed in the tidy data (mean, standard deviation)
1. `> features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)`
2. `> variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),`
							`grep("std()", features$V2, value = F, fixed = T)))`
3. `> featurenames <- features[variables,]$V2`    *(this created a vector of the names of the variables needed; used later)*


###  Imported the X *train* and *test* datasets using the previously created _variables_ vector to subset the specific columns the labeled the columns
1. `> xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]`
2. `> xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]`
3. `> names(xtrain) <- featurenames`
4. `> names(xtest) <- featurenames`

## Arranging the datasets into one <a name = "arranging"></a>
[back up top](#top)

### Combined all the *train* sets; combined all the *test* sets   *(by column)*
1. `> trainSet <- data.frame(trainSubject, ytrain, xtrain)`
2. `> testSet <- data.frame(testSubject, ytest, xtest)`

### Combined the remaining sets into one, by row
1. `> oneSet <- rbind(trainSet, testSet)`
2. `> oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]`   *(the recode() turns the Activity column into factors, this returns it to characters)*

#### Now I will rename the columns of **oneSet** so it looks a little tidier.  
3. `> oSnames <- names(oneSet)`
4. `> oSnames <- gsub("[.]", "", oSnames)`                *(removed the periods)*
5. `> names(oneSet) <- oSnames`                   *(oSnames is a vector of the column names in the final data sets)*

## Creating a separate tidy dataset that shows the means of all the variables sorted by subjects and their respective activity <a name = "tidydata"></a>
[back up top](#top)

1. `> molten = melt(oneSet, id = c("Subject", "Activity"))`   *(this collapses the data set into a long skinny dataset based on "subjects" and "activity")*
2. `> names(molten) <- c("Subject", "Activity", "Variable", "Value")`  *(made easily recognizable column names)*
3. `> tidyData = dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)`     *(made DF of the variable-means based on Subject and Activity)*
### If the columns are not in the same order as *oneSet*, try this.
4. `> tidyData <- tidyData[c(OSnames)]`     *(here is where you use the variable **oSnames** to reorder the columns to the original)*

# Explanation of the *oneSet* and *tidyData* data-sets and their Variables <a name = "explanation"></a>
[back up top](#top)

## The main variables of the Data Sets <a name = "variables"></a>
[back up top](#top)
 
They are the following...

 - Subject

   *which # out of 30 individuals*
 

 - Activity

  *the specific activity the individual is doing*

 

 - tBodyAcc-XYZ
 - tGravityAcc-XYZ
 - tBodyAccJerk-XYZ
 - tBodyGyro-XYZ
 - tBodyGyroJerk-XYZ
 - tBodyAccMag
 - tGravityAccMag
 - tBodyAccJerkMag
 - tBodyGyroMag
 - tBodyGyroJerkMag
 - fBodyAcc-XYZ
 - fBodyAccJerk-XYZ
 - fBodyGyro-XYZ
 - fBodyAccMag
 - fBodyAccJerkMag
 - fBodyGyroMag
 - fBodyGyroJerkMag

#### A couple of things to note
1.  the 'XYZ' denotes the 3 dimensions of data being recorded so they will have their own columns
2.  For expediency, the data sets will only include the *mean* and the *standard deviation* columns from the primary raw data which were 
denoted by *mean()* and *std()*
3. For example: the first column of the data-sets were *originally* **tBodyAcc-mean()-X**
4. For tidiness, it has been converted into **tBodyAccmeanY**

#### Let's move left to right on the variables to define what they mean.
##### **Examples:**  *these are some example variables from the datasets*
1. tBodyAccmeanY
2. fBodyBodyGyroJerkMagstd
3. tGravityAccmeanX

 

 - the first letter (t or f) denotes '(t)time domain signal' or whether
   '(f)Fast Fourier  Transform (FFT)' was applied to it
 - the results within the '(t) time domain signals' were then separated
   into 'Body' and 'Gravity' measurements as you can see in Examples 1 &
   2
 - the 3rd part of the variable denotes which piece of equiptment from
   the cellphone was used for recording the data: Acc = Accelerometer;
   Gyro = Gyroscope
 - the variables with 'Jerk' denotes a values derived from body linear
   acceleration and angular velocity over time
 - the next part shows whether the value is the 'Mean' or the 'Standard
   Deviation'; mean, std, respectively
 - if the variable has an X, Y, or Z, it denotes the dimensional
   component being measured

## The Data Sets <a name = "datasets"></a>
[back up top](#top)

..There are 2 data sets the script will out put into the Global Environment to work with: **oneSet** and **tidyData** (tidyData will be opened to View)

**oneSet** will have 10299 observations (rows) of the 66 variables that result by only taking the *mean* and the *standard deviation* from the primary raw data
...each *Subject* will have multiple observations per *Activity*

**tidyData** is the average of every variable sorted by the *Subject* and the *Activity* they are performing.
...since there are 6 activities and 30 subjects the final dimensions will be (6*30) 180 rows and (2+66) 68 columns  *(2 being the Subject and Activity columns)*

###**The Original CodeBook** that gives a detailed explanation of the variables is can be found [here](../blob/master/CodeBook.md)

# The scripts  <a name = "scripts"></a>
[back up top](#top)

## run_analysis.R <a name = "ra1"></a>
`source("https://raw.githubusercontent.com/thedurphy/GnC.Data.Course.Project/master/run_analysis.R")`
`run_analysis()`

`run_analysis <- function(){`

    `require(data.table)`

	`require(reshape2)`

	`require(car)`

 `trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt",` `stringsAsFactor = F)`

 `testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt",` `stringsAsFactor = F)`

 `names(testSubject) <- "Subject"`

 `names(trainSubject) <- "Subject"`

 `ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)`

 `ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)`

 `ytrain <- recode(ytrain$V1, "'1' = 'Walking';`

    									`'2' = 'Walking Upstairs';`

										`'3' = 'Walking Downstairs';`

										`'4' = 'Sitting';`

										`'5' = 'Standing';`

										`'6' = 'Laying'")`

 `ytest <- recode(ytest$V1, "'1' = 'Walking';`

    									`'2' = 'Walking Upstairs';`

										`'3' = 'Walking Downstairs';`

										`'4' = 'Sitting';`

										`'5' = 'Standing';`

										`'6' = 'Laying'")`

 `ytrain <- data.frame(ytrain)`

 `ytest <- data.frame(ytest)`

 `names(ytrain) <- "Activity"`

 `names(ytest) <- "Activity"`

 `features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)`

 `variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),`

                    `grep("std()", features$V2, value = F, fixed = T)))`

 `featurenames <- features[variables,]$V2`

 `xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]`

 `xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]`

 `names(xtrain) <- featurenames`

 `names(xtest) <- featurenames`

 `trainSet <- data.frame(trainSubject, ytrain, xtrain)`

 `testSet <- data.frame(testSubject, ytest, xtest)`

 `oneSet <<- rbind(trainSet, testSet)`

 `oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]`

 `oSnames <- names(oneSet)`

 `oSnames <- gsub("[.]", "", oSnames)`

 `names(oneSet) <- oSnames`

 `molten = melt(oneSet, id = c("Subject", "Activity"))`

 `names(molten) <- c("Subject", "Activity", "Variable", "Value")`

 `tidyData <<- dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)`

 `View(tidyData)`

 `write.table(tidyData, file = "tidyData.txt")`

 `}`

## run_analysis2.R <a name = "ra2"></a>
[back up top](#top)

`source("https://raw.githubusercontent.com/thedurphy/GnC.Data.Course.Project/master/run_analysis2.r")`
`run_analysis2()`

`run_analysis2 <- function(){`

    `require(data.table)`

	`require(reshape2)`

	`require(car)`

 `trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt",` `stringsAsFactor = F)`

 `testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt",` `stringsAsFactor = F)`

 `names(testSubject) <- "Subject"`

 `names(trainSubject) <- "Subject"`

 `ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)`

 `ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)`

 `ytrain <- recode(ytrain$V1, "'1' = 'Walking';`

    									`'2' = 'Walking Upstairs';`

										`'3' = 'Walking Downstairs';`

										`'4' = 'Sitting';`

										`'5' = 'Standing';`

										`'6' = 'Laying'")`

 `ytest <- recode(ytest$V1, "'1' = 'Walking';`

    									`'2' = 'Walking Upstairs';`

										`'3' = 'Walking Downstairs';`

										`'4' = 'Sitting';`

										`'5' = 'Standing';`

										`'6' = 'Laying'")`

 `ytrain <- data.frame(ytrain)`

 `ytest <- data.frame(ytest)`

 `names(ytrain) <- "Activity"`

 `names(ytest) <- "Activity"`

 `features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)`

 `variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),`

                    `grep("std()", features$V2, value = F, fixed = T)))`

 `featurenames <- features[variables,]$V2`

 `xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]`

 `xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]`

 `names(xtrain) <- featurenames`

 `names(xtest) <- featurenames`

 `trainSet <- data.frame(trainSubject, ytrain, xtrain)`

 `testSet <- data.frame(testSubject, ytest, xtest)`

 `oneSet <<- rbind(trainSet, testSet)`

 `oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]`

 `oSnames <- names(oneSet)`

 `oSnames <- gsub("[.]", "", oSnames)`

 `names(oneSet) <- oSnames`

 `molten = melt(oneSet, id = c("Subject", "Activity"))`

 `names(molten) <- c("Subject", "Activity", "Variable", "Value")`

 `tidyData <<- dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)`

 `View(tidyData)`

 `write.table(tidyData, file = file.choose(new = T))`

 `}`
 