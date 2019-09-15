
library(data.table)
library(reshape2)

# Load activity labels and features

activitylabels <- fread("activity_labels.txt", col.names = c("classlabels", "activityname"))
features <- fread("features.txt", col.names = c("index", "featurenames"))
featureswanted <- grep("(mean|std)\\(\\)", features[, featurenames])
measurements <- features[featureswanted, featurenames]
measurements <- gsub('[()]', '', measurements)

# Load train 

train <- fread("train/X_train.txt")[, featureswanted, with = FALSE]

setnames(train, colnames(train), measurements)

trainactivities <- fread("train/Y_train.txt", col.names = c("activity"))

trainsubjects <- fread("train/subject_train.txt", col.names = c("subjectnum"))

train <- cbind(trainsubjects, trainactivities, train)

# Load test 

test <- fread("test/X_test.txt")[, featureswanted, with = FALSE]

setnames(test, colnames(test), measurements)

testactivities <- fread("test/Y_test.txt", col.names = c("activity"))

testsubjects <- fread("test/subject_test.txt", col.names = c("subjectnum"))

test <- cbind(testsubjects, testactivities, test)

# merge

merged <- rbind(train, test)

# step 5

merged[["activity"]] <- factor(merged[, activity]
                                 , levels = activitylabels[["classlabels"]]
                                 , labels = activitylabels[["activityname"]])

merged[["subjectnum"]] <- as.factor(merged[, subjectnum])

merged <- melt(data = merged, id = c("subjectnum", "activity"))

merged <- dcast(data = merged, subjectnum + activity ~ variable, fun.aggregate = mean)

fwrite(x = merged, file = "tidy.txt", quote = FALSE)
