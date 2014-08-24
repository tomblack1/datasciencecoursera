README.md

################
##  General Comment:
##	Is this the most efficient way to do this? No, does it work, Yes.
##	Hopefully as I get more experience with R I will 
##	become more efficient, but for now this will have to do.
################

Pseudocode/code walkthrough

Pull all column names from features.txt; we will want to use these for naming columns when importing the 2 "data" files
Used grepl statements to limit columns with names like "mean" or "std" and not "meanFreq" ***this is the best way i could think to do this

GET IMPORT DATA FROM TRAIN AND TEST AND MERGE INTO ONE DATASET
TEST SET 1st
Handle test folder
  Read in the test "data" from X_test.txt
  Update column names for test "data" based on the features pulled in above
  Cull down and only keep necessary columns, filter based on the same criteria as lessfeatures above ***probably a better way, but this works
  Add "Id" field to allow linking of the Subject and Activity data that come next

  Subject values are pulled in from subject_test.txt and given a sequence to allow for linking to "data" and activity records
  Activity values are pulled in from Y_test.txt and given a sequence to allow for linking to data and subject records

  Fully merge all TEST data into one set so that Activity, Subject and "Data" (post culling) are on one record

***There may be a more efficient way to do this also, but again it works so it stays
TRAIN SET 2nd
Handle train folder
  Read in the train "data" from X_train.txt
  Update column names for train "data" based on the features pulled in above
  Cull down and only keep necessary columns, filter based on the same criteria as lessfeatures above ***probably a better way, but this works
  Add "Id" field to allow linking of the Subject and Activity data that come next

  Subject values are pulled in from subject_train.txt and given a sequence to allow for linking to "data" and activity records
  Activity values are pulled in from Y_train.txt and given a sequence to allow for linking to data and subject records

  Fully merge all TRAIN data into one set so that Activity, Subject and "Data" (post culling) are on one record

MAKE ONE DATASET TO RULE THEM ALL
  Use row binding to paste the 2 sets together (test + train)


  Melt the data down based on the ActivityID and SubjectID while making all the other fields measurements (this takes things from horizontal to vertical)


***I hate to say again, but probably not the best way to do it, but I understand this so there it is.
Use dcast to esentially do a group by on the Activity, Subject and variable, while taking a mean of the value (this takes things from vertical to horizontal again)
  
Melt again so that it is back into a narrow and tall table (this takes things from horizontal to vertical again), I find think this narrow format to be tidier

Pull in all activity names from activity_labels.txt

Pull ActivityName field into mlt2 data frame

Limit the fields within final data frame to include ActivityName, SubjectID, variable, and value

Write the tidy set out to the working directory as a standard txt file (tidyData.txt), quotes for text identifiers and a space for field separation.
