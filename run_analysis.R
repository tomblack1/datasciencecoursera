####run_analysis.R

################
##  General Comment:
##	Is this the most efficient way to do this? No, does it work, Yes.
##	Hopefully as I get more experience with this tool I will 
##	become more efficient, but for now this will have to do.
################

##pull all column names, we will want to use these for naming columns when importing the "data" files
features<-read.table("./UCI HAR Dataset/features.txt",sep=" ",col.names=c("ColId","featureName"))

##use grepl to limit columns with names like "mean" or "std" and not "meanFreq", this is the best way i could think to do this
lessfeatures<-features[(grepl("mean",features$featureName)|grepl("std",features$featureName))&!grepl("meanFreq",features$featureName),]

####BEGIN GET IMPORT DATA FROM TRAIN AND TEST AND MERGE INTO ONE DATASET
#############TEST SET
testdata<-read.table("./UCI HAR Dataset/test/X_test.txt")

##give column names based on the features pulled in above
colnames(testdata)=features$featureName

##Cull down and only keep necessary columns, filter based on the same criteria as lessfeatures above (probably a better way, but this works)
testdata<-testdata[,(grepl("mean",colnames(testdata))|grepl("std",colnames(testdata)))&!grepl("meanFreq",colnames(testdata))]

##Add Id field to allow linking of the Subject and Activity data that come next
testdata<-cbind(Id=seq(from=1, to=nrow(testdata), by=1),testdata)

##SubjectID values are pulled in and given a sequence to allow for linking to data and activity records
testsubjects<-read.table("./UCI HAR Dataset/test/subject_test.txt",sep=" ",col.names=c("SubjectID"))
testsubjects<-cbind(Id=seq(from=1, to=nrow(testsubjects), by=1),testsubjects)

##ActivityID values are pulled in and given a sequence to allow for linking to data and subject records
testactivity<-read.table("./UCI HAR Dataset/test/y_test.txt",sep=" ",col.names=c("ActivityID"))
testactivity<-cbind(Id=seq(from=1, to=nrow(testactivity), by=1),testactivity)

##Fully merge all TEST data into one set so that Activity, Subject and Data (post culling) are on one record
alltest<-merge(testsubjects,testdata,by="Id")
alltest<-merge(testactivity,alltest,by="Id")

####There may be a more efficient way to do this also, but again it works so it stays
#############TRAINING SET
traindata<-read.table("./UCI HAR Dataset/train/X_train.txt")
colnames(traindata)=features$featureName
##only keep necessary columns
traindata<-traindata[,(grepl("mean",colnames(traindata))|grepl("std",colnames(traindata)))&!grepl("meanFreq",colnames(traindata))]
##Add Id field to allow linking
traindata<-cbind(Id=seq(from=1, to=nrow(traindata), by=1),traindata)

##Subject values are pulled in and given a sequence to allow for linking to data and activity records
trainsubjects<-read.table("./UCI HAR Dataset/train/subject_train.txt",sep=" ",col.names=c("SubjectID"))
trainsubjects<-cbind(Id=seq(from=1, to=nrow(trainsubjects), by=1),trainsubjects)

##Activity values are pulled in and given a sequence to allow for linking to data and subject records
trainactivity<-read.table("./UCI HAR Dataset/train/y_train.txt",sep=" ",col.names=c("ActivityID"))
trainactivity<-cbind(Id=seq(from=1, to=nrow(trainactivity), by=1),trainactivity)

##Fully merge all TRAIN data into one set so that Activity, Subject and Data are on one record
alltrain<-merge(trainsubjects,traindata,by="Id")
alltrain<-merge(trainactivity,alltrain,by="Id")

#####  MAKE ONE DATASET TO RULE THEM ALL
##use row binding to paste the 2 sets together
alldata<-rbind(alltest,alltrain)

####END GET IMPORT DATA FROM TRAIN AND TEST AND MERGE INTO ONE DATASET

###Melt the data down based on the ActivityID and SubjectID while making all the lessfeatures measurements
##(this takes things from horizontal to vertical)
meltedtest<-melt(alldata,id=c("ActivityID","SubjectID"),measure.vars=lessfeatures$featureName)

####I hate to say again, but probably not the best way to do it, but I understand this so there it is.
##Use dcast to esentially do a group by on the Activity, Subject and variable, while taking a mean of the value
##(this takes things from vertical to horizontal again)
tstData<-dcast(meltedtest,ActivityID+SubjectID~variable,mean)
##melt again so that it is back into a narrow and tall table, i think this is tiddier
mlt2<-melt(tstData,id=c("ActivityID","SubjectID"),measure.vars=lessfeatures$featureName)


###Pull in all activity names
activity<-read.table("./UCI HAR Dataset/activity_labels.txt",sep=" ",col.names=c("ActivityID","ActivityName"))

##Pull ActivityName into mlt2 data frame
finaldata<-merge(activity,mlt2,by="ActivityID")

finaldata<-finaldata[,c("ActivityName","SubjectID","variable","value")]

##write the tidy set out to the working directory
write.table(finaldata, file="tidyData.txt",row.name=FALSE)