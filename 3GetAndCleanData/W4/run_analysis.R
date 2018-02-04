# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(data.table)

#collect & unzip dataset  
download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ", destfile = "./dataset.zip")
unzip("./dataset.zip")

#get labels & features 
zipdir<-"UCI HAR Dataset"

dt_activity_label <- data.table::fread(paste(zipdir, "/activity_labels.txt", sep =""), col.names = c("class", "activity"))
dt_feature <- data.table::fread(paste(zipdir, "/features.txt", sep =""), col.names = c("id", "feature"))

#select mean & std columns
index_meanstd <- grep("(mean|std)\\(\\)", dt_feature[, feature])
feature_meanstd <- gsub('[()-]', '', dt_feature[index_meanstd, feature])

## (2). Extracts only the measurements on the mean and standard deviation for each measurement.
## (5). Appropriately labels the data set with descriptive variable names. 
#get train data 
type <- "train"
dt_train_set <- data.table::fread(paste(zipdir, "/", type,"/X_", type, ".txt", sep =""), select = index_meanstd, col.names = feature_meanstd)
dt_train_activity <- data.table::fread(paste(zipdir, "/", type,"/y_", type, ".txt", sep =""), col.names = c("class"))
dt_train_subject <- data.table::fread(paste(zipdir, "/", type,"/subject_", type, ".txt", sep =""), col.names = c("subject"))

dt_train_set <- cbind(dt_train_subject, dt_train_activity, dt_train_set)

#get test data 
type <- "test"
dt_test_set <- data.table::fread(paste(zipdir, "/", type,"/X_", type, ".txt", sep =""), select = index_meanstd, col.names = feature_meanstd)
dt_test_activity <- data.table::fread(paste(zipdir, "/", type,"/y_", type, ".txt", sep =""), col.names = c("class"))
dt_test_subject <- data.table::fread(paste(zipdir, "/", type,"/subject_", type, ".txt", sep =""), col.names = c("subject"))

dt_test_set <- cbind(dt_test_subject, dt_test_activity, dt_test_set)

## (1). Merges the training and the test sets to create one data set.
dt_set    <- rbind(dt_train_set, dt_test_set)

## (3). Uses descriptive activity names to name the activities in the data set
dt_set <- merge(x = dt_set, y = dt_activity_label, by = "class", all.x = TRUE)

## (5). From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# library(reshape2)
library(dplyr)
dt_set_mean <- dt_set %>% group_by(class, subject, activity) %>% summarise_all(funs(mean))

# write the tidy dataset 
data.table::fwrite(x = dt_set_mean, file = "tidydata.txt", quote = FALSE, sep = ",", row.names = FALSE)
