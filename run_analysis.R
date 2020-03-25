# FileName: run_analysis.R
# Author: Daniel Fynes-Clinton
# Date: 2020-03-24
# Description: This file extracts data from the 'Human Activity Recognition Using Smartphones Data Set' and performs the following additional functions:
#   1.Merges the training and the test sets to create one data set.
#   2.Extracts only the measurements on the mean and standard deviation for each measurement.
#   3.Uses descriptive activity names to name the activities in the data set
#   4.Appropriately labels the data set with descriptive variable names.
#   5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Step 1: Merges the training and the test sets to create one data set

#Working directory will need to be set accordingly (uncomment to use, otherwise assumes Samsung data is already in working directory)
#  setwd("C:\\Users\\RYZEN\\Documents\\R\\Cleaning Data Project\\UCI HAR Dataset")

#Extract activities and features
  activities <- read.table('.\\activity_labels.txt',col.names = c('ActivityIndex','Activity'))
  features <- read.table('.\\features.txt',col.names = c('FeatureIndex','Feature'))

#Extract Train Data
  subjectTrain <- read.table('.\\train\\subject_train.txt',col.names = 'SubjectNumber')
  xTrain <- read.table('.\\train\\X_train.txt',col.names = features$Feature,check.names = FALSE)
  yTrain <- read.table('.\\train\\y_train.txt',col.names = 'ActivityIndex')

#Bind Train Columns
  trainData<-cbind(subjectTrain,yTrain,xTrain)

#Extract Test Dataset
  subjectTest <- read.table('.\\test\\subject_test.txt',col.names = 'SubjectNumber')
  xTest <- read.table('.\\test\\X_test.txt',col.names = features$Feature,check.names = FALSE)
  yTest <- read.table('.\\test\\y_test.txt',col.names = 'ActivityIndex')

#Bind Columns
  testData<-cbind(subjectTest,yTest,xTest)

#Combine test and train data
  testData$Source<-rep("test",nrow(testData))
  trainData$Source<-rep("train",nrow(trainData))
  mergedData<-rbind(testData,trainData)
  
  
  #Step 2: Extracts only the measurements on the mean and standard deviation for each measurement  
  
#Extract Measurement Data Column Indices
  colMeanStd  <- grep('mean\\(\\)|std\\(\\)',colnames(mergedData))
  
#Extract Non-Measurement Data Column Indices
  colNonMeasure  <- grep('SubjectNumber|ActivityIndex|Source',colnames(mergedData))

#Extract Subset using Column Indices  
  mergedMeanStd <- mergedData[,c(colNonMeasure,col_mean_std)]
  
  #Step 3:  Uses descriptive activity names to name the activities in the data set

#Use Merge to get Activity Names 
  mergedMeanStd <- merge(activities,mergedMeanStd)
  
#Optionally remove ActivityIndex Column
  mergedMeanStd <-mergedMeanStd[,-1]
  
  #Step 4:  Appropriately labels the data set with descriptive variable names
  
#Extract column names
  colNames <- colnames(mergedMeanStd)
  
#Subsitute column names with more descriptive names 
  colNames <- sub(x = colNames,pattern = '^t',replacement = 'Time domain signal: ')
  colNames <- sub(x = colNames,pattern = '^f',replacement = 'Frequency domain signal: ')
  colNames <- sub(x = colNames,pattern = 'std\\(\\)',replacement = ' Standard Deviation')
  colNames <- sub(x = colNames,pattern = 'mean\\(\\)',replacement = ' Mean value')
  colNames <- sub(x = colNames,pattern = 'BodyAcc',replacement = 'Body Acceleration ')
  colNames <- sub(x = colNames,pattern = 'GravityAcc',replacement = 'Gravity Acceleration ')
  colNames <- sub(x = colNames,pattern = 'BodyGyro',replacement = 'Body Angular Velocity ')
  colNames <- sub(x = colNames,pattern = '-X',replacement = ' in X Direction')
  colNames <- sub(x = colNames,pattern = '-Y',replacement = ' in Y Direction')
  colNames <- sub(x = colNames,pattern = '-Z',replacement = ' in Z Direction')
  colNames <- sub(x = colNames,pattern = 'Mag',replacement = ' Magnitude')

#Make changes to column names
  colnames(mergedMeanStd) <- colNames
  
  #Step 5:  From the data set in step 4, creates a second, independent tidy data set with the average of each variable 
  #         for each activity and each subject.
  
#Remove source column because it is not needed in final data set
  mergedMeanStd <-mergedMeanStd[,-3]
  
#Load dplyr package to be able to use group by and summarize functions
  library(dplyr)
  tidyData <- mergedMeanStd %>%
    group_by(Activity,SubjectNumber) %>%
    summarize_all(mean)
  
#Write data to a text file
  write.table(tidyData,file = 'tidyData.txt',row.names = F)
  