my_data <- read.csv(url("http://datafestuoft2018.blob.core.windows.net/data/raw-data-datafest2018.csv"))
attach(my_data)

dataset_ca <- subset(my_data,country == "CA" & stateProvince != "UNKNOWN" & normTitleCategory != "NA" & estimatedSalary != 0)
dataset_ca$stateProvince <- factor(dataset_ca$stateProvince)

dataset_QC <- subset(dataset_ca, dataset_ca$stateProvince == "QC")
dataset_ON <- subset(dataset_ca, dataset_ca$stateProvince == "ON")
dataset_BC <- subset(dataset_ca, dataset_ca$stateProvince == "BC")
dataset_MB <- subset(dataset_ca, dataset_ca$stateProvince == "MB")
dataset_AB <- subset(dataset_ca, dataset_ca$stateProvince == "AB")
dataset_SK <- subset(dataset_ca, dataset_ca$stateProvince == "SK")
dataset_NS <- subset(dataset_ca, dataset_ca$stateProvince == "NS")
dataset_NL <- subset(dataset_ca, dataset_ca$stateProvince == "NL")
dataset_NT <- subset(dataset_ca, dataset_ca$stateProvince == "NT")
dataset_PE <- subset(dataset_ca, dataset_ca$stateProvince == "PE")
dataset_NU <- subset(dataset_ca, dataset_ca$stateProvince == "NU")
dataset_NB <- subset(dataset_ca, dataset_ca$stateProvince == "NB")
dataset_YT <- subset(dataset_ca, dataset_ca$stateProvince == "YT")

install.packages("ggplot2")
library("ggplot2")
ggplot(dataset_ca, aes(dataset_ca$stateProvince, estimatedSalary), color = dataset_ca$stateProvince) + geom_boxplot()

summary(aov(lm(estimatedSalary~normTitleCategory, data = dataset_ca)))

#TukeyHSD(result_1, normTitleCategory)

#qplot(reorder(normTitleCategory,estimatedSalary,median), y=estimatedSalary,data=dataset_ca,geom="boxplot",theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)))

ggplot(dataset_ca, aes(x = reorder(normTitleCategory, estimatedSalary,median), y = estimatedSalary)) + 
  geom_boxplot() + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))


n1 <- length(dataset_QC$normTitle)
n2 <- length(dataset_ON$normTitle)
n3 <- length(dataset_BC$normTitle)
n4 <- length(dataset_MB$normTitle)
n5 <- length(dataset_AB$normTitle)
n6 <- length(dataset_SK$normTitle)
n7 <- length(dataset_NS$normTitle)
n8 <- length(dataset_NL$normTitle)
n9 <- length(dataset_NT$normTitle)
n10 <- length(dataset_PE$normTitle)
n11 <- length(dataset_NU$normTitle)
n12 <- length(dataset_NB$normTitle)
n13 <- length(dataset_YT$normTitle)

chance_p <- matrix(c(n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13), nrow = 1, ncol = 13)
colnames(chance_p) <- c("QC","ON","BC","MB","AB","SK","NS","NL","NT","PE","NU","NB","YT")
rownames(chance_p) <- c("opportunity")

top_province <- subset(dataset_ca, stateProvince == "ON" | stateProvince == "QC" | stateProvince == "BC" | stateProvince == "AB" )
top_province$stateProvince <- factor(top_province$stateProvince)
career_dist <- table(top_province$normTitleCategory, top_province$stateProvince)

ind <- rowSums(career_dist == 0) != ncol(career_dist)
career_dist[ind, ]

desired <- c("project", "engcivil", "techsoftware", "meddr", "finance", "techinfo", "engelectric", "math", "engid", "socialscience", "engmech", "science", "management", "therapy", "mednurse", "engchem", "hr", "arts", "techhelp", "arch", "tech", "medtech", "accounting")

career_requirement <- dataset_ca[,c("jobLanguage","licenseRequiredJob", "educationRequirement")]


tblice <- xtabs( ~ top_province$stateProvince + top_province$licenseRequiredJob, data = top_province)

tblang <- xtabs( ~ top_province$stateProvince + top_province$jobLanguage, data = top_province)



top_career <- top_province[top_province$normTitleCategory %in% desired, ]
top_career$stateProvince <- factor(top_career$stateProvince)
top_career$normTitleCategory <- factor(top_career$normTitleCategory)

tblice_top <- xtabs( ~ top_career$stateProvince + top_career$licenseRequiredJob + top_career$normTitleCategory, data = top_career)
tblice_top_2 <- xtabs( ~ top_career$stateProvince + top_career$normTitleCategory + top_career$licenseRequiredJob , data = top_career)

m1 <- ftable(tblice_top_2)
library(gridExtra)
pdf("data_output.pdf", height=11, width=8.5)
grid.table(m1)
dev.off()


prop.table(tblice_top, c(3,1))

prop_AB <- c(0.8585,0.7281,0.8206,0.1753,0.9878,0.3413,0.6701,0.6038,0.8971,0.6500,0.6925,0.9449,0.3188,0.1158,0.3825,0.7314,0.5939,0.7838,0,0.7190,0.8859,0.9450,0.2541)
sort_top_career <- sort(desired)
rank_data_AB <- as.data.frame(matrix(c(prop_AB), nrow = 1))
colnames(rank_data_AB) <- sort_top_career
rownames(rank_data_AB) <- "value"

prop_BC <- c(0.8751,0.9579,0.9399,0.7500,0.5947,0.6187,0.8398,0.7835,0.7666,0.9041,0.7193,0.9835,0.2024,0.1838,0.4432,0.7549,0.9250,0.5324,1,0.8502,0.8932,0.9426,0.3864)
rank_data_BC <- matrix(c(prop_BC), nrow = 1)
colnames(rank_data_BC) <- sort_top_career
rownames(rank_data_BC) <- "value"

prop_ON <- c(0.8695,0.6921,0.9125,0.8735,0.6165,0.7152,0.7850,0.7297,0.8893,0.8100,0.7569,0.9464,0.6683,0.0823,0.5473,0.7297,0.8780,0.6250,0.6400,0.7919,0.8885,0.9459,0.5085)
rank_data_ON <- matrix(c(prop_ON), nrow = 1)
colnames(rank_data_ON) <- sort_top_career
rownames(rank_data_ON) <- "value"

prop_QC <- c(0.8792,1,0.9974,0,0.3784,0.5224,0.8209,0.5917,0.9359,0.9821,0.9092,0.9441,0,0.2803,0.4975,0.8685,0.9879,1,0.7700,0.9668,0.9752,1)
rank_data_QC <- matrix(c(prop_QC), nrow = 1)
colnames(rank_data_QC) <- sort(c("project", "engcivil", "techsoftware", "meddr", "finance", "techinfo", "engelectric", "math", "engid", "socialscience", "engmech", "science", "management", "therapy", "mednurse", "engchem", "hr", "arts", "techhelp", "arch", "medtech", "accounting"))
rownames(rank_data_QC) <- "value"

par(mfrow = c(2,2))
plot(sort(prop_AB), main = "AB")
plot(sort(prop_BC), main = "BC")
plot(sort(prop_ON), main = "ON")
plot(sort(prop_QC), main = "QC")

rank_data_AB[value]


career_rank_AB <- c("engcivil", "techsoftware", "math", "finance", "techinfo", "accounting", "arts")  #descending order by value
top_career_final_AB <- subset(top_career, top_career$normTitleCategory %in% career_rank_AB & top_career$educationRequirement != "NA")
top_career_final_AB$normTitleCategory <- factor(top_career_final_AB$normTitleCategory)
tbedu_AB <- xtabs( ~ top_career_final_AB$normTitleCategory + top_career_final_AB$educationRequirement)

career_rank_BC <- c("tech", "math", "arch", "techsoftware", "arts", "science", "hr", "techinfo")  #descending order by value
top_career_final_BC <- subset(top_career, top_career$normTitleCategory %in% career_rank_BC & top_career$educationRequirement != "NA")
top_career_final_BC$normTitleCategory <- factor(top_career_final_BC$normTitleCategory)
tbedu_BC <- xtabs( ~ top_career_final_BC$normTitleCategory + top_career_final_BC$educationRequirement)

career_rank_ON <- c("math", "techsoftware", "arts", "finance", "techinfo", "science", "engchem")  #descending order by value
top_career_final_ON <- subset(top_career, top_career$normTitleCategory %in% career_rank_ON & top_career$educationRequirement != "NA")
top_career_final_ON$normTitleCategory <- factor(top_career_final_ON$normTitleCategory)
tbedu_ON <- xtabs( ~ top_career_final_ON$normTitleCategory + top_career_final_ON$educationRequirement)

career_rank_QC <- c("therapy", "socialscience", "arch", "arts", "science", "hr", "techsoftware")  #descending order by value
top_career_final_QC <- subset(top_career, top_career$normTitleCategory %in% career_rank_QC & top_career$educationRequirement != "NA")
top_career_final_QC$normTitleCategory <- factor(top_career_final_QC$normTitleCategory)
tbedu_QC <- xtabs( ~ top_career_final_QC$normTitleCategory + top_career_final_QC$educationRequirement)


top_career_final_AB_ <- subset(top_career_final_AB, top_career_final_AB$experienceRequired != "NA")
tbexp_AB <- xtabs( ~ top_career_final_AB$normTitleCategory + top_career_final_AB$experienceRequired)

top_career_final_BC_ <- subset(top_career_final_BC, top_career_final_BC$experienceRequired != "NA")
tbexp_BC <- xtabs( ~ top_career_final_BC$normTitleCategory + top_career_final_BC$experienceRequired)

top_career_final_ON_ <- subset(top_career_final_ON, top_career_final_ON$experienceRequired != "NA")
tbexp_ON <- xtabs( ~ top_career_final_ON$normTitleCategory + top_career_final_ON$experienceRequired)

top_career_final_QC_ <- subset(top_career_final_QC, top_career_final_QC$experienceRequired != "NA")
tbexp_QC <- xtabs( ~ top_career_final_QC$normTitleCategory + top_career_final_QC$experienceRequired)





#=================================================================US=====================================================================

dataset_us <- subset(my_data,my_data$country == "US" & stateProvince != "UNKNOWN" & normTitleCategory != "NA" & estimatedSalary != 0 & normTitleCategory != "")
dataset_us$stateProvince <- factor(dataset_us$stateProvince)

aov(lm(estimatedSalary~normTitleCategory, data = dataset_us))

ggplot(dataset_us, aes(x = reorder(normTitleCategory, estimatedSalary, median), y = estimatedSalary)) + 
  geom_boxplot() + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

desired_us <- c("meddr","techsoftware","engid","engmech","engelectric","project","engcivil","techinfo","engchem","math","legal","techhelp", "finance", "therapy", "arch", "socialscience", 'mednurse', "management", "hr", "science", "accounting", "marketing", "sales")

#job_opportunity <- xtabs( ~ dataset_us$stateProvince + dataset_us$normTitle, data = dataset_us)

province <- unique(dataset_us$stateProvince)
chance_p_us <- c()
for (i in 1:length(province)){
  chance_p_us[i] <- length(subset(dataset_us, dataset_us$stateProvince == province[i])$normTitle)
}

chance_p_us_m <- matrix(chance_p_us, nrow = 1, ncol = length(chance_p_us))
colnames(chance_p_us_m) <- province
rownames(chance_p_us_m) <- c("opportunity")

plot(sort(chance_p_us))

top_province_us <- c("CA", "TX", "FL", "NY", "PA", "IL", "OH") #descending order

top_province_us_data <- dataset_us[dataset_us$stateProvince %in% top_province_us, ]
top_province_us_data$stateProvince <- factor(top_province_us_data$stateProvince)
top_province_us_data$normTitleCategory <- factor(top_province_us_data$normTitleCategory)
career_dist_us <- xtabs( ~  top_province_us_data$stateProvince + top_province_us_data$normTitleCategory)

ind <- rowSums(career_dist == 0) != ncol(career_dist)
career_dist[ind, ]

#career_requirement_us <- dataset_us[,c("jobLanguage","licenseRequiredJob", "educationRequirement")]

tblice <- xtabs( ~ top_province_us_data$stateProvince + top_province_us_data$licenseRequiredJob, data = top_province_us_data)

tblang <- xtabs( ~ top_province_us_data$stateProvince + top_province_us_data$jobLanguage, data = top_province_us_data)

prop.test(tblice, correct = FALSE)
#prop.test(tblang, correct = FALSE)


top_career_us <- top_province_us_data[top_province_us_data$normTitleCategory %in% desired_us, ]
top_career_us$stateProvince <- factor(top_career_us$stateProvince)
top_career_us$normTitleCategory <- factor(top_career_us$normTitleCategory)

tblice_top_us <- xtabs( ~ top_career_us$stateProvince + top_career_us$licenseRequiredJob + top_career_us$normTitleCategory, data = top_career_us)
#tblang_top_2 <- xtabs( ~ top_career$stateProvince + top_career$normTitleCategory + top_career$licenseRequiredJob , data = top_career)

#ftable(tblang_top_2)

prop.table(tblice_top_us, c(3,1))

prop_CA <- c(0.85264732,0.85296622,0.91819853,0.533348468,0.84896030,0.88387332,0.88840298,0.82398014,0.79107497,0.77600841,0.76298435,0.91545738,0.81171746,0.30873345,0.08286845,0.75789262,0.72480757,0.77725486,0.50461538,0.80093452,0.89506073,0.94963694,0.15456883)
sort_top_career_us <- sort(desired_us)
rank_data_CA <- as.data.frame(matrix(c(prop_CA), nrow = 1))
colnames(rank_data_CA) <- sort_top_career
rownames(rank_data_CA) <- "value"

prop_FL <- c(0.84976571,0.92242934,0.37903226,0.56834532,0.64025357,0.81037796,0.69306931,0.83930994,0.78502541,0.64725962,0.69784521,0.88899032,0.70246831,0.36481561,0.07210264,0.67595023,0.69215209,0.58687759,0.52556237,0.74875015,0.83898980,0.90617919,0.16215269)
rank_data_FL <- matrix(c(prop_FL), nrow = 1)
colnames(rank_data_FL) <- sort_top_career_us
rownames(rank_data_FL) <- "value"

prop_IL <- c(0.90789143, 0.92194093, 1, 0.56712329, 0.788, 0.89675344, 0.91813380, 0.84818388, 0.82902799, 0.74384707, 0.76740092, 0.91725409, 0.86872002, 0.33933033,0.08152731,0.80266010,0.76287271,0.89339599,0.40425532,0.82308869,0.91801865,0.93769226,0.16198621)
rank_data_IL <- matrix(c(prop_IL), nrow = 1)
colnames(rank_data_IL) <- sort_top_career_us
rownames(rank_data_IL) <- "value"

prop_NY <- c(0.86843775,0.90805124,0.84792627,0.45302013,0.75399172, 0.88288515,0.81416550,0.93365308,0.87690276,0.81271815,0.78682535,0.94325966,0.91279286,0.32052714,0.10741923,0.79072356,0.78461605,0.83513703,0.70579495,0.78048780,0.91421047,0.94391400,0.12844957)
rank_data_NY <- matrix(c(prop_NY), nrow = 1)
colnames(rank_data_NY) <- sort_top_career_us
rownames(rank_data_NY) <- "value"

prop_OH <- c(0.85052594,0.83808524,0.65230769,0.58273381,0.69979578,0.81471902,0.92776999,0.83314586,0.75902335,0.58084359,0.72265967,0.90503731,0.85672515,0.35731351,0.11193388,0.77051229,0.74121744,0.82423469,0.64081633,0.70348837,0.87107298,0.92374647,0.14675615)
rank_data_OH <- matrix(c(prop_OH), nrow = 1)
colnames(rank_data_OH) <- sort_top_career_us
rownames(rank_data_OH) <- "value"

prop_PA <- c(0.86117861,0.93716720,0.69902813,0.60294118,0.84972889,0.84760321,0.90515127,0.82704536,0.79225542,0.76419214,0.74025132,0.90153015,0.84035169,0.31833061,0.08733354,0.68275352,0.73845953,0.76030646,0.20825147,0.80541745,0.92647470,0.94911270,0.16738290)
rank_data_PA <- matrix(c(prop_PA), nrow = 1)
colnames(rank_data_PA) <- sort_top_career_us
rownames(rank_data_PA) <- "value"

prop_TX <- c(0.83082114,0.78307393,0.75,0.50961128,0.74945692,0.83924217,0.65803615,0.85055762,0.81814908,0.62815830,0.72848044,0.87939854,0.85097375,0.30402037,0.078757640,0.73362550,0.71439128,0.75289944,0.55351906,0.76355881,0.86731196,0.93371049,0.17076121)
rank_data_TX <- matrix(c(prop_TX), nrow = 1)
colnames(rank_data_TX) <- sort_top_career_us
rownames(rank_data_TX) <- "value"

par(mfrow = c(2,2))
plot(sort(prop_CA), main = "CA")
plot(sort(prop_FL), main = "FL")
plot(sort(prop_IL), main = "IL")
plot(sort(prop_NY), main = "NY")
plot(sort(prop_OH), main = "OH")
plot(sort(prop_PA), main = "PA")
plot(sort(prop_TX), main = "TX")

career_rank_CA <- c("techsoftware", "arts","math","techinfo","engid","engelectric","arch")  #descending order by value
top_career_final_CA <- top_career_us[top_career_us$normTitleCategory %in% career_rank_CA & top_career_us$educationRequirement != "NA", ]
top_career_final_CA$normTitleCategory <- factor(top_career_final_CA$normTitleCategory)
tbedu_CA <- xtabs( ~ top_career_final_CA$normTitleCategory + top_career_final_CA$educationRequirement)

career_rank_FL <- c("arch","techsoftware","marketing","accounting","finance","techinfo","engid")  #descending order by value
top_career_final_FL <- top_career_us[top_career_us$normTitleCategory %in% career_rank_FL & top_career_us$educationRequirement != "NA", ]
top_career_final_FL$normTitleCategory <- factor(top_career_final_FL$normTitleCategory)
tbedu_FL <- xtabs( ~ top_career_final_FL$normTitleCategory + top_career_final_FL$educationRequirement)

career_rank_IL <- c("engchem","techsoftware","arch","engmech","techinfo","marketing","accounting")  #descending order by value
top_career_final_IL <- top_career_us[top_career_us$normTitleCategory %in% career_rank_IL & top_career_us$educationRequirement != "NA", ]
top_career_final_IL$normTitleCategory <- factor(top_career_final_IL$normTitleCategory)
tbedu_IL <- xtabs( ~ top_career_final_IL$normTitleCategory + top_career_final_IL$educationRequirement)

career_rank_NY <- c("techsoftware","marketing","finance","techinfo","math","arch","engid")  #descending order by value
top_career_final_NY <- top_career_us[top_career_us$normTitleCategory %in% career_rank_NY & top_career_us$educationRequirement != "NA", ]
top_career_final_NY$normTitleCategory <- factor(top_career_final_NY$normTitleCategory)
tbedu_NY <- xtabs( ~ top_career_final_NY$normTitleCategory + top_career_final_NY$educationRequirement)

career_rank_OH <- c("engmech","techsoftware","marketing","techinfo","math","accounting","arch")  #descending order by value
top_career_final_OH <- top_career_us[top_career_us$normTitleCategory %in% career_rank_OH & top_career_us$educationRequirement != "NA", ]
top_career_final_OH$normTitleCategory <- factor(top_career_final_OH$normTitleCategory)
tbedu_OH <- xtabs( ~ top_career_final_OH$normTitleCategory + top_career_final_OH$educationRequirement)

career_rank_PA <- c("techsoftware","arch","techinfo","engmech","marketing","accounting","engelectric")  #descending order by value
top_career_final_PA <- top_career_us[top_career_us$normTitleCategory %in% career_rank_PA & top_career_us$educationRequirement != "NA", ]
top_career_final_PA$normTitleCategory <- factor(top_career_final_PA$normTitleCategory)
tbedu_PA <- xtabs( ~ top_career_final_PA$normTitleCategory + top_career_final_PA$educationRequirement)

career_rank_TX <- c("techsoftware","marketing","techinfo", "techinfo", "math", "finance", "engid", "accounting")  #descending order by value
top_career_final_TX <- top_career_us[top_career_us$normTitleCategory %in% career_rank_TX & top_career_us$educationRequirement != "NA", ]
top_career_final_TX$normTitleCategory <- factor(top_career_final_TX$normTitleCategory)
tbedu_TX <- xtabs( ~ top_career_final_TX$normTitleCategory + top_career_final_TX$educationRequirement)

top_career_final_CA_ <- subset(top_career_final_CA, top_career_final_CA$experienceRequired != "NA")
tbexp_CA <- xtabs( ~ top_career_final_CA$normTitleCategory + top_career_final_CA$experienceRequired)

top_career_final_FL_ <- subset(top_career_final_FL, top_career_final_FL$experienceRequired != "NA")
tbexp_FL <- xtabs( ~ top_career_final_FL$normTitleCategory + top_career_final_FL$experienceRequired)

top_career_final_IL_ <- subset(top_career_final_IL, top_career_final_IL$experienceRequired != "NA")
tbexp_IL <- xtabs( ~ top_career_final_IL$normTitleCategory + top_career_final_IL$experienceRequired)

top_career_final_NY_ <- subset(top_career_final_NY, top_career_final_NY$experienceRequired != "NA")
tbexp_NY <- xtabs( ~ top_career_final_NY$normTitleCategory + top_career_final_NY$experienceRequired)

top_career_final_OH_ <- subset(top_career_final_OH, top_career_final_OH$experienceRequired != "NA")
tbexp_OH <- xtabs( ~ top_career_final_OH$normTitleCategory + top_career_final_OH$experienceRequired)

top_career_final_PA_ <- subset(top_career_final_PA, top_career_final_PA$experienceRequired != "NA")
tbexp_PA <- xtabs( ~ top_career_final_PA$normTitleCategory + top_career_final_PA$experienceRequired)

top_career_final_TX_ <- subset(top_career_final_TX, top_career_final_TX$experienceRequired != "NA")
tbexp_QC <- xtabs( ~ top_career_final_TX$normTitleCategory + top_career_final_TX$experienceRequired)


#========================================================================German============================================================
dataset_de <- subset(my_data,country == "DE" & stateProvince != "UNKNOWN" & normTitleCategory != "NA" & estimatedSalary != 0)
dataset_de$stateProvince <- factor(dataset_de$stateProvince)

aov(lm(estimatedSalary~normTitleCategory, data = dataset_de))

ggplot(dataset_de, aes(x = reorder(normTitleCategory, estimatedSalary, median), y = estimatedSalary)) + 
  geom_boxplot() + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

desired_de <- c("science", "techsoftware", "finance", "arch", "management", "marketing", "techinfo", "accounting")


province <- unique(dataset_de$stateProvince)
chance_p_de <- c()
for (i in 1:length(province)){
  chance_p_de[i] <- length(subset(dataset_de, dataset_de$stateProvince == province[i])$normTitle)
}

chance_p_de_m <- matrix(chance_p_de, nrow = 1, ncol = length(chance_p_de))
colnames(chance_p_de_m) <- province
rownames(chance_p_de_m) <- c("opportunity")

plot(sort(chance_p_de))

top_province_de <- c("NW", "BY", "BW", "BE", "NI", "HE") #descending order

top_province_de_d <- dataset_de[dataset_de$stateProvince %in% top_province_de, ]
top_province_de_data <- subset(top_province_de_d, top_province_de_d$licenseRequiredJob != "NA")
top_province_de_data$stateProvince <- factor(top_province_de_data$stateProvince)
top_province_de_data$normTitleCategory <- factor(top_province_de_data$normTitleCategory)
career_dist_de <- xtabs( ~  top_province_de_data$stateProvince + top_province_de_data$normTitleCategory)

ind <- rowSums(career_dist == 0) != ncol(career_dist)
career_dist[ind, ]

#career_requirement_us <- dataset_us[,c("jobLanguage","licenseRequiredJob", "educationRequirement")]

tblice_de <- xtabs( ~ top_province_de_data$stateProvince + top_province_de_data$licenseRequiredJob, data = top_province_de_data)

tblang_de <- xtabs( ~ top_province_de_data$stateProvince + top_province_de_data$jobLanguage, data = top_province_de_data)

#prop.test(tblice_de, correct = FALSE)



top_career_de <- top_province_de_data[top_province_de_data$normTitleCategory %in% desired_de, ]
top_career_de$stateProvince <- factor(top_career_de$stateProvince)
top_career_de$normTitleCategory <- factor(top_career_de$normTitleCategory)
tblice_top_de <- xtabs( ~ top_career_de$stateProvince + top_career_de$licenseRequiredJob + top_career_de$normTitleCategory, data = top_career_de)

tbsalary <- xtabs( ~ top_career_de$normTitleCategory + top_career_de$estimatedSalary, data = top_career_de)


