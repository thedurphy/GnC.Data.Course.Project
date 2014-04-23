Method to making run_analysis.R
===============================
# First Draft (before writing the script, do every step yourself)

### **You will need to install and load the following packages
* data.table
* car
* plyr
* reshape2


## Importing the Data
1. Imported the subject list from both the *train* and *test* directories into separate variables
### > trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactor = F)
### > testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactor = F)
### > names(testSubject) <- "Subject"
### > names(trainSubject) <- "Subject"

2. Imported the y files from *train* and *test* directories into separate variables and labeled them using the recode() function from the **car** package
### > ytrain <- read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactor = F)
### > ytest <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactor = F)
### > ytrain <- recode(ytrain$V1, "'1' = 'Walking';
										'2' = 'Walking Upstairs';
										'3' = 'Walking Downstairs';
										'4' = 'Sitting';
										'5' = 'Standing';
										'6' = 'Laying'")
### > ytest <- recode(ytest$V1, "'1' = 'Walking';
										'2' = 'Walking Upstairs';
										'3' = 'Walking Downstairs';
										'4' = 'Sitting';
										'5' = 'Standing';
										'6' = 'Laying'")
### > ytrain <- data.frame(ytrain)
### > ytest <- data.frame(ytest)
### > names(ytrain) <- "Activity"  *(renamed the column)*
### > names(ytest) <- "Activity"    *(renamed the column)*

3. Imported the features text and with grep() found exactly which variable indices were needed in the tidy data (mean, standard deviation)
### > features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactor = F)
### > variables <- sort(c(grep("mean()", features$V2, value = F, fixed = T),
							grep("std()", features$V2, value = F, fixed = T)))
### > featurenames <- features[variables,]$V2    *(this created a vector of the names of the variables needed; used later)*


4.  Imported the X *train* and *test* datasets using the previously created _variables_ vector to subset the specific columns the labeled the columns
..1. > xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")[variables]
..2. > xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[variables]
..3. > names(xtrain) <- featurenames
..4. > names(xtest) <- featurenames

## Arranging the datasets into 1

1. Combined all the *train* sets; combined all the *test* sets   (by column)
..1. > trainSet <- data.frame(trainSubject, ytrain, xtrain)
..2. > testSet <- data.frame(testSubject, ytest, xtest)

2. Combined the remaining sets into one, by row
..1. > oneSet <- rbind(trainSet, testSet)
..2. > oneSet$Activity <- levels(oneSet$Activity)[oneSet$Activity]   (the recode() turns the Activity column into factors, this returns it to characters)
### Now I will rename the columns of **oneSet** so it looks a little tidier.  
..3. > oSnames <- names(oneSet)
..4. > oSnames <- gsub("[.]", "", oSnames)                *(removed the periods)*
..5. > names(oneSet) <- oSnames                   *(oSnames is a vector of the column names in the final data sets)*

## Creating a seperate tidy dataset that shows the means of all the variables sorted by subjects and their respective activity
..1. > molten = melt(oneSet, id = c("Subject", "Activity"))   *(this collapses the data set into a long skinny dataset based on "subjects" and "activity")*
..2. > names(molten) <- c("Subject", "Activity", "Variable", "Value")  (made easily recognizable column names)
..3. > tidyData = dcast(molten, formula = Subject + Activity ~ Variable, value.var = "Value", mean)     *(made DF of the variable-means based on Subject and Activity)*
### If the columns are not in the same order as *oneSet*, try this.
..4. > tidyData <- tidyData[c(OSnames)]     *(here is where you use the variable *oSnames* to reorder the columns to the original)*

# Explanation of the **oneSet** and **tidyData** data-sets and their Variables

1. The main variables of the Data Sets are the following.
2. Subject   *which # out of 30 individuals*
3. Activity  *the specific activity the individual is doing*

4. tBodyAcc-XYZ
5. tGravityAcc-XYZ
6. tBodyAccJerk-XYZ
7. tBodyGyro-XYZ
8. tBodyGyroJerk-XYZ
9. tBodyAccMag
10. tGravityAccMag
11. tBodyAccJerkMag
12. tBodyGyroMag
13. tBodyGyroJerkMag
14. fBodyAcc-XYZ
15. fBodyAccJerk-XYZ
16. fBodyGyro-XYZ
17. fBodyAccMag
18. fBodyAccJerkMag
19. fBodyGyroMag
20. fBodyGyroJerkMag

* A couple of things to note
..1.  the 'XYZ' denotes the 3 dimensions of data being recorded so they will have their own columns
..2.  For expediency, the data sets will only include the *mean* and the *standard deviation* columns from the primary raw data which were 
denoted by *mean()* and *std()*
..3. For example: the first column of the data-sets were *originally* **tBodyAcc-mean()-X**
..4. For tidiness, it has been converted into **tBodyAccmeanY**

*Let's move left to right on the variables to define what they mean.
Examples:
1. tBodyAccmeanY
2. fBodyBodyGyroJerkMagstd
3. tGravityAccmeanX

..* the first letter (t or f) denotes '(t)time domain signal' or whether '(f)Fast Fourier  Transform (FFT)' was applied to it
..* the results within the '(t) time domain signals' were then separated into 'Body' and 'Gravity' measurements as you can see in Examples 1 & 2
..* the 3rd part of the variable denotes which piece of equiptment from the cellphone was used for recording the data:
.....*Acc = Accelerometer; Gyro = Gyroscope
..* the variables with 'Jerk' denotes a values derived from body linear acceleration and angular velocity over time
..* the next part shows whether the value is the 'Mean' or the 'Standard Deviation'; mean, std, respectively
..* if the variable has an X, Y, or Z, it denotes the dimensional component being measured

* The Data Sets

..There are 2 data sets the script will out put into the Global Environment to work with: **oneSet** and **tidyData** (tidyData will be opened to View)

**oneSet** will have 10299 observations (rows) of the 66 variables that result by only taking the *mean* and the *standard deviation* from the primary raw data
...each *Subject* will have multiple observations per *Activity*

**tidyData** is the average of every variable sorted by the *Subject* and the *Activity* they are performing.
...since there are 6 activities and 30 subjects the final dimensions will be (6*30) 180 rows and (2+66) 68 columns  *(2 being the Subject and Activity columns)*

# The script

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

