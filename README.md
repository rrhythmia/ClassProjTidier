# README.md
# how the script in run_analysis.R works

The script "run_analysis.R" creates a tidy dataset from the "activity tracker" dataset files in:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
( Original source: 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  )

The tidying creates a single data file whose first two columns are "subject" and "activity".  Further columns are the mean values for the aggregate tracker measurements from the "raw" dataset("aggregate tracker measurements" as in, the columns that were means, and standard deviations).
See the "readme.txt" in the unzipped dataset for information on its measurements.

To run the script:

1. Unzip the zipfile.  
It should create a "UCI HAR Dataset" directory, containing:
Four files:
  activity_labels.txt  
  features_info.txt	
  features.txt  
  README.txt  
Two directories:
  test	(contains subject_test.txt  X_test.txt  y_test.txt)
  train (contains subject_train.txt  X_train.txt  y_train.txt)
  (These directories also contain "Inertial Signals", which are not used.)

2. source("run_analysis.R")

3. Navigate to the "UCI HAR Dataset" directory, or otherwise set your working directory to be that directory  -  e.g. setwd("UCI HAR Dataset")

4. runActivityTrackerDatasetTidier(fnameTidy="tidyDS.txt",writeCodebook=FALSE)

(Warning: The script performs a multitude of dimension-related error checks, and will stop, with an inelegant error message, if any of them fail.)

What the script does: it
* merges the "test" and "train" datasets
* prepends the "subject" and "activity" columns to the measurements columns
* converts the numeric values for "activity" to descriptive ones
* strips out "activity=LAYING" data to protect subject privacy
* winnows down the tracker measurements (columns) to just the "means and standard deviations" ones, as specified in class assignment instructions
* aggregates these measurements by activity&subject, by calculating column means for each activity&subject pairing.
* (And if writeCodebook is set to TRUE, it also generates the codebook.)

 
