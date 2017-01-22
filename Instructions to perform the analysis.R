### STEP 0. Get the data

# 1. Set a working directory
# 2. Download the data from:
# 3. https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 4. Unzip downloaded data and copy the folder "UCI HAR Dataset" into your working directory

### STEP 1. Feature and Activity Tables

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",
                              col.names = c("ActivityNumber","ActivityName"))
str(activity_labels)
# 'data.frame':	6 obs. of  2 variables:
activity_labels

features <- read.table("./UCI HAR Dataset/features.txt")
str(features)
#'data.frame':	561 obs. of  2 variables:
head(features)

# Extracting feature names, so I can assign them as column names in X_test and X_train files
feature_names <- features$V2

### STEP 2. READ IN TEST FOLDER

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",
                           col.names = "TestVolunteerNumber")

str(subject_test)
# 'data.frame':	2947 obs. of  1 variable:
head(subject_test)

table(subject_test$TestVolunteerNumber)
#   2   4   9  10  12  13  18  20  24 
# 302 317 288 294 320 327 364 354 381 

# reading in test data with feature names as column names
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt",
                     col.names = feature_names)

head(X_test)
str(X_test)
# 'data.frame':	2947 obs. of  561 variables:

Y_test <- read.table("./UCI HAR Dataset/test/y_test.txt",
                     col.names = "ActivityNumber")
head(Y_test)
str(Y_test)
# 'data.frame':	2947 obs. of  1 variable:

table(Y_test$ActivityNumber)
#   1   2   3   4   5   6 
# 496 471 420 491 532 537 

### STEP 3. READ IN TRAIN FOLDER

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",
                            col.names = "TrainVolunteerNumber")
str(subject_train)
# 'data.frame':	7352 obs. of  1 variable:

table(subject_train$TrainVolunteerNumber)
# 1   3   5   6   7   8  11  14  15  16  17  19  21  22  23  25  26  27  28 
# 347 341 302 325 308 281 316 323 328 366 368 360 408 321 372 409 392 376 382 
# 29  30 
# 344 383 

# reading in train data with feature names as column names
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt",
                      col.names = feature_names)

head(X_train)
str(X_train)
# 'data.frame':	7352 obs. of  561 variables:

Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt",
                      col.names = "ActivityNumber")
head(Y_train)
str(Y_train)
# 'data.frame':	7352 obs. of  1 variable:

table(Y_train$ActivityNumber)
#   1    2    3    4    5    6 
# 1226 1073  986 1286 1374 1407 


### STEP 4. Adding descriptive information to TEST dataset

# Adding Activity name by activity number
Y_test_named <- merge(Y_test,activity_labels,by="ActivityNumber",all=TRUE)
head(Y_test_named)

# Checking if labels were correctly assigned
table(Y_test_named$ActivityNumber,Y_test_named$ActivityName) 
# LAYING SITTING STANDING WALKING WALKING_DOWNSTAIRS WALKING_UPSTAIRS
# 1      0       0        0     496                  0                0
# 2      0       0        0       0                  0              471
# 3      0       0        0       0                420                0
# 4      0     491        0       0                  0                0
# 5      0       0      532       0                  0                0
# 6    537       0        0       0                  0                0

# creating one test dataset with volunteer number, activity name and all the measurements
final_test <- cbind(VolunteerNumber=subject_test$TestVolunteerNumber,
                    ActivityName=Y_test_named$ActivityName,
                    X_test)
head(final_test,n=1)
str(final_test)

# check frequency of Volunteer number against Subject_test table
table(final_test$VolunteerNumber)
#   2   4   9  10  12  13  18  20  24 
# 302 317 288 294 320 327 364 354 381 

# check frequency of Activity against activity_lable table
table(final_test$ActivityName)
# LAYING            SITTING           STANDING            WALKING 
# 537                491                532                496 
# WALKING_DOWNSTAIRS   WALKING_UPSTAIRS 
# 420                471 

### STEP 5. Adding descriptive information to TRAIN dataset

# Adding Activity name by activity number
Y_train_named <- merge(Y_train,activity_labels,by="ActivityNumber",all=TRUE)
head(Y_train_named)

# Checking if labels were correctly assigned
table(Y_train_named$ActivityNumber,Y_train_named$ActivityName) 
#   LAYING SITTING STANDING WALKING WALKING_DOWNSTAIRS WALKING_UPSTAIRS
# 1      0       0        0    1226                  0                0
# 2      0       0        0       0                  0             1073
# 3      0       0        0       0                986                0
# 4      0    1286        0       0                  0                0
# 5      0       0     1374       0                  0                0
# 6   1407       0        0       0                  0                0

# creating one train dataset with volunteer number, activity name and all the measurements
final_train <- cbind(VolunteerNumber=subject_train$TrainVolunteerNumber,
                    ActivityName=Y_train_named$ActivityName,
                    X_train)

head(final_train,n=1)
str(final_train)

# check frequency of Volunteer number against Subject_train table
table(final_train$VolunteerNumber)
# 1   3   5   6   7   8  11  14  15  16  17  19  21  22  23  25  26  27  28 
# 347 341 302 325 308 281 316 323 328 366 368 360 408 321 372 409 392 376 382 
# 29  30 
# 344 383 

# check frequency of Activity against activity_lable table
table(final_train$ActivityName)
# LAYING            SITTING           STANDING            WALKING 
# 1407               1286               1374               1226 
# WALKING_DOWNSTAIRS   WALKING_UPSTAIRS 
# 986               1073 

### STEP 6. MERGING TRAIN and TEST data

final_full <- rbind(final_test,final_train)
dim(final_full)
#[1] 10299   563 
# orginal 561 variables + Volunteer Number + Activity Name

### STEP 7. Extracting mean and std for each measurement

# extracting column names with "mean"
final_full_mean <- final_full[,
                             grepl("mean",colnames(final_full))]

# dropping all column variables with "meanFreq"
final_full_mean <- final_full_mean[,
                                 !grepl("Freq",colnames(final_full_mean))]

# extracting column names with "std"
final_full_std <- final_full[,
                              grepl("std",colnames(final_full))]

# merging data with "means" and "stds" columns
final_full_sel <- cbind(VolunteerNumber=final_full$VolunteerNumber,
                        ActivityName=final_full$ActivityName,
                        final_full_mean,
                        final_full_std)
str(final_full_sel)
# 'data.frame':	10299 obs. of  68 variables

# check that there are 30 volumnteers in the final dataset
table(final_full_sel$VolunteerNumber)
# 1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19 
# 347 302 341 317 302 325 308 281 288 294 316 320 327 323 328 366 368 364 360 
# 20  21  22  23  24  25  26  27  28  29  30 
# 354 408 321 372 381 409 392 376 382 344 383 

# check that there are 6 activities in the final dataset
table(final_full_sel$ActivityName)
# LAYING            SITTING           STANDING            WALKING 
# 1944               1777               1906               1722 
# WALKING_DOWNSTAIRS   WALKING_UPSTAIRS 
# 1406               1544 

# check activities per volunteer number
table(final_full_sel$VolunteerNumber, final_full_sel$ActivityName)

### STEP 8. Creating new dataset with the average for each variable and each subject

# requires dplyr package
install.packages("dplyr")
library(dplyr)

final_full_sel_aggr <- 
  final_full_sel %>% 
  group_by(VolunteerNumber,ActivityName) %>% 
  summarise_all(mean)

str(final_full_sel_aggr)

# check number activities per volunteer
table(final_full_sel_aggr$VolunteerNumber)
# 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 
# 1  1  1  2  1  2  1  1  1  2  1  2  1  2  1  1  2  2  1  2  1  2  1  1  1  1 
# 27 28 29 30 
# 2  1  1  1 

# check number volunteers per activity
table(final_full_sel_aggr$ActivityName)
# LAYING            SITTING           STANDING            WALKING 
# 6                  7                  7                  6 
# WALKING_DOWNSTAIRS   WALKING_UPSTAIRS 
# 6                  8 

# writing the final dataset into .csv
write.csv(final_full_sel_aggr,
          file="SamsungGalaxySIITest-Average-measurements-for-30-volunteers.csv",
          row.names = FALSE)

# find final dataset in your working directory
