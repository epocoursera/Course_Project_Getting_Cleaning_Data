# Set working directory
setwd("/Users/epocoursera/Bitbucket/Data Science/03_Getting_and_Cleaning_Data/project")

# Load data.table library to 
library("data.table")

# Load reshape2 library to
library("reshape2")

# Create "data" folder if it does not exist
if (!file.exists("data")) {dir.create("data")}

# Download Data Set
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="uci.zip",method="curl")
unzip("uci.zip", files = NULL, list = FALSE, overwrite = TRUE,
      junkpaths = FALSE, exdir = ".", unzip = "internal",
      setTimes = FALSE)

# Create "data" folder if it does not exist
if (!file.exists("data")) {dir.create("data")}

# Rename the folder "UCI HAR Dataset" into a folder named "data" by using 'file.rename' which also works on directories. 
file.rename("UCI HAR Dataset", "data")

# Read activity_labels.txt and features.txt
activity_labels <- read.table("./data/activity_labels.txt")[,2]
features <- read.table("./data/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
mean_features <- grepl("mean|std", features)

# Load and process X_test & y_test data.
X_test <- read.table("./data/test/X_test.txt")
y_test <- read.table("./data/test/y_test.txt")
subject_test <- read.table("./data/test/subject_test.txt")
names(X_test) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,mean_features]

# Load activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data via cbind function
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./data/train/X_train.txt")
y_train <- read.table("./data/train/y_train.txt")

# Load subject train
subject_train <- read.table("./data/train/subject_train.txt")

names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,mean_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind data via cbind function
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merging test and train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)

# Melt data (from reshape2 library) : takes wide-format data and melts it into long-format data.
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Create a tidy_data.txt file including results using row.name = FALSE 
write.table(tidy_data, file = "./tidy_data.txt", row.name=FALSE)