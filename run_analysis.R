# run_analysis.R 
#
# For class project,in class.coursera.org/getdata-033
# Also see:
#  README.md (explains how the script works, and where the data came from)
#  CodeBook.md (describes the variables, the data, and any transformations or work performed to clean up the data)
#  The tidied data set


# Clear
rm(list=ls())
cat("\014")

runActivityTrackerDatasetTidier <- function(
  fnameTidy="tidyDS.txt", 
  writeCodebook=FALSE,
  maxrows =-1  # for testing.  A positive # will read in only that many rows.
  ) {
   # maxrows = -1 will read em all in
  
  require("dplyr")
  require("tidyr")

  print("This script may take 20 seconds or more to run.")
  stopifnot(file.exists("train") & file.exists("test"))
  
  # -------------------------------------------
  # Read in dataset files

  # maxrows = 30   # -1 will read em all in
  
  # Read in all the Train files
  list.files("train")
  trSubj <- read.table("train/subject_train.txt",nrows=maxrows)
  trX <- read.table("train/X_train.txt",nrows=maxrows)
  trActiv <- read.table("train/y_train.txt", nrows=maxrows)
  
  stopifnot(nrow(trSubj)==nrow(trX) & nrow(trSubj)==nrow(trActiv))
  stopifnot(ncol(trSubj)==1 & ncol(trActiv)==1)
  
  # Read in all the Test files
  list.files("test")
  teSubj <- read.table("test/subject_test.txt",nrows=maxrows)
  teX <- read.table("test/X_test.txt",nrows=maxrows)
  teActiv <- read.table("test/y_test.txt",nrows=maxrows)
  
  stopifnot(nrow(teSubj)==nrow(teX) & nrow(teSubj)==nrow(teActiv))
  stopifnot(ncol(teSubj)==1 & ncol(teActiv)==1)
  
  # Rbind the respective data
  
  # (first, consistency check)
  stopifnot(ncol(teSubj)==ncol(trSubj))
  stopifnot(ncol(teX)==ncol(trX))
  stopifnot(ncol(teActiv)==ncol(trActiv))
  
  #   1. Merge each training and test set to create one data set (each)
  dSubj <- rbind(teSubj,trSubj)
  dX <- rbind(teX,trX)
  dActiv <- rbind(teActiv,trActiv)
  
  #   2. Extract only the measurements of the mean and standard deviation, from X files
  vnames <- read.table("features.txt",stringsAsFactors = FALSE)  # read the variable names
  
  nvars <- nrow(vnames)
  stopifnot(vnames[nvars,1]==nvars)   # ensure the indexes are not askew
  
  ivmeans <- grep("-mean", vnames[,2]) # (just get colindexes, so dont use value=TRUE)
  ivdevs <- grep("-std", vnames[,2])   # (just get colindexes, so dont use value=TRUE)
  icols <- sort(unlist(c(ivmeans,ivdevs)))  # indices of the columns we want to keep
  dXmd <- dX[,icols]
  xmdColnames <- vnames[,2][icols]
  
  #   3. Use descriptive activity names to name the activities in the data set
  #  (convert "activity" into a Factor)
  tdActTypes <- read.table("activity_labels.txt",stringsAsFactors = FALSE)
  dActivAsDesc <- factor(dActiv[,1], levels=tdActTypes[,1], labels=tdActTypes[,2])
  activityStrs <- tdActTypes[,2]
  
  # Glue columns together - Subject, Activity, VarsToUse
  df0 <- as.data.frame(cbind(dSubj,dActivAsDesc,dXmd))
  
  #   4. Appropriately label the data set with descriptive variable names. 
  colnsTmp <- c("subject","activity", unlist(xmdColnames))
  stopifnot(length(colnsTmp)==ncol(df))
  colnames(df0) <- colnsTmp

  # Privacy
  dfp <- filter(df0, activity!="LAYING")
  
  #   5. From the data set in step 4, create a second, independent tidy data set with the average of each variable 
  #        for each activity and each subject.
#  bySubjAct <- group_by(df,subject, activity)
#  nc <- ncol(df)
  dfm <- group_by(dfp, subject,activity) %>% summarise_each(funs(mean))
  colnames(dfm) <- c("subject","activity", unlist(sapply(xmdColnames,function(x){paste("MEAN",x,sep="-")})))
  
  # write dataset
  ret<-write.table(dfm,fnameTidy,row.names=FALSE)
  print(paste("Write of dataset",fnameTidy))

  if (writeCodebook) {
    print("Preparing to write codebook")
    # --------------------------------------------
    # write codebook
    
    vdescs <- sapply(xmdColnames, function(cname){paste("Mean of the",cname,
        "measures for this subject and activity")})
    
    cdescs <- c("Person wearing tracker", "Activity", unlist(vdescs))
    numFields <- length(colnames(dfm))
    stopifnot(numFields== length(cdescs))
    
    indexs <- seq_along(colnames(dfm))
    extras <- rep("",numFields)
    extras[2] <- paste("\n\t", 
                       paste(activityStrs, sep="",collapse="\n\t"),
                   "\n\t(Note: for privacy, measurements from reclining subjects (activity='LAYING') were removed.)",
                   sep="",
                   collapse="\n"
                   )
    # cblines0 <- data.frame()
    cblines0 <- as.data.frame(cbind(indexs,rep(". ",numFields), colnames(dfm), rep(":\t",numFields), cdescs, extras))
    cblines1 <- tidyr::unite(cblines0,glom,unlist(1:ncol(cblines0)),
                             sep="",remove=TRUE)
    cblines <- cblines1$glom
     
    starline <- paste(rep("*",50),collapse="")
    
    hlines <- c(
      starline,
      paste("Codebook for Activity tracker dataset '", fnameTidy, "'", sep="", collapse=""),
      starline,
      "Describing the variables, the data, and any transformations or ",
      "work performed to clean up the tidied data set",
      "(Also see README.md)",
      "(And see orig. dataset's 'readme.txt' for Units and other information)",
      "",
      "*** end of information on using Codebook  ***",
      starline,
       paste("\n",numFields," Columns of data:\n")
      )
    
      fnameCB <- paste("Codebook",fnameTidy,sep="")
      
      writeLines(con=fnameCB,text=unlist(c(hlines,cblines)))
      print(paste("Write of codebook",fnameCB))
      # --------------------------------------------------
   }  
}

