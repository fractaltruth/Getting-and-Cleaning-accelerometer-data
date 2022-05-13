# Using 'reshape2' library to makes it easy to transform data 
# between wide and long formats
library('reshape2')
library('data.table')

# Downloading and unzipping the downloaded zipped file
data_url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
file_on_pc <- 'accelerometer_data'

if (!exists('accelerometer_data')) {
        download.file(data_url, file_on_pc)
}


accelerator_data <- unzip(file_on_pc)

# Load various activities performed by people, which is labelled as 'activity labels'
activity_labels <- read.table('UCI HAR Dataset/activity_labels.txt')[, 2]

# Load the various columns in the data set, which is here denoted as 'features'
features <- read.table('UCI HAR Dataset/features.txt')[, 2]

# As we are interested in the mean and standard deviation of each measurement,
# we will extract those data
needed_features <- grepl('mean|std', features)

# Now we need to load and process the X and Y test data
X_test <- read.table('UCI HAR Dataset/test/X_test.txt')
y_test <- read.table('UCI HAR Dataset/test/y_test.txt')
sub_test <- read.table('UCI HAR Dataset/test/subject_test.txt')

names(X_test) = features

# We will extract only those measurements related to mean and standard deviation
X_test = X_test[, needed_features]

# Now we need to load and process the X and Y train data
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

sub_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# We will extract only those measurements related to mean and standard deviation
X_train = X_train[, needed_features]

# Load activity labels for both test and train data
y_test[, 2] = activity_labels[y_test[, 1]]
y_train[, 2] = activity_labels[y_train[,1]]

names(y_test) = c("Activity_ID", "Activity_Label")
names(y_train) = c("Activity_ID", "Activity_Label")

names(sub_test) = "subject"
names(sub_train) = "subject"

# Bind both test and train data
acc_test_data <- cbind(as.data.table(sub_test), y_test, X_test)
acc_train_data <- cbind(as.data.table(sub_train), y_train, X_train)

# Now we will merge both the test and train data
acc_data = rbind(acc_test_data, acc_train_data)

id_labels  = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data = melt(acc_data, id = id_labels, measure.vars = data_labels)

# Apply mean function to the data using dcast function
acc_tidy_data = dcast(melt_data, row.name = FALSE, subject + Activity_Label ~ variable, mean)
