library(tidyverse)
library(dplyr)
library(fastDummies)
library(car)


############## Loading Datasets#########
Hesi <- read.csv("Regions and Households.csv") %>%
  dummy_cols(select_columns = "Region")  
  
unemployment_rate <- read.csv("Unemployment.csv")
diabetes_obesity <- read.csv("Diabetes_Obesity.csv")
politics <- read.csv("CountyPolitics.csv")

## cleaning unemployment rate data
unemployment_rate <- unemployment_rate %>%
  filter(Attribute == "Unemployment_rate_2020") %>%
  rename(unemployment_rate = "Value") %>%
  select(FIPS, unemployment_rate)


## cleaning politics dataset, creating binary variables of party, renaming fips code

politics <- politics %>%
  group_by(county_fips) %>%
  slice_max(n = 1, candidatevotes) %>%
  dummy_cols(select_columns = "party") %>%
  select(county_fips, party_DEMOCRAT, party_REPUBLICAN) %>%
  rename(FIPS = "county_fips")

####### Merging datasets##########
df1 <- merge(Hesi, diabetes_obesity, by.x = "FIPS", by.y = "FIPS")
df2 <- merge(df1, unemployment_rate, by.x = "FIPS", by.y = "FIPS")
df3 <- merge(df2, politics, by.x = "FIPS", by.y = "FIPS")


colnames(df3)

############## Viewing the final dataset#############

df3
head(df3)
tail(df3)
str(df3)
summary(df3)
colnames(df3)

## missing values
sum(is.na(df3))
missing <- df3[rowSums(is.na(df3)) > 0, ]
missing
count(missing)
map_int(df3,~sum(is.na(.x)))
# the only variable with missing values is the percent of fully vaccinated people so removed that variable
# one county Rio Arriba did not have an SVI values, so exclueded it from the data.
# After dealing with  all missing values, we have a total of 3112 observations in our data set
# our primary data set is called df3

######### Running the methods###############
###### Correlation Analysis and sactter plots #######
typeof(df3$Estimated.hesitant)
typeof(df3$SVI)

cor(df3$Estimated.hesitant, df3$SVI)
scatterplot(Estimated.hesitant ~ SVI, data=df3)

cor(df3$Estimated.hesitant, df3$CVAC.level.of.concern.for.vaccination.rollout)
scatterplot(Estimated.hesitant ~ CVAC.level.of.concern.for.vaccination.rollout, data=df3)

cor(df3$Estimated.hesitant, df3$Diabetes_Percent)
scatterplot(Estimated.hesitant ~ Diabetes_Percent, data=df3)

cor(df3$Estimated.hesitant, df3$Obesity_Percent)
scatterplot(Estimated.hesitant ~ Obesity_Percent, data=df3)

cor(df3$Estimated.hesitant, df3$Percent.Hispanic)
scatterplot(Estimated.hesitant ~ Percent.Hispanic, data=df3)

cor(df3$Estimated.hesitant, df3$Percent.non.Hispanic.American.Indian.Alaska.Native)
scatterplot(Estimated.hesitant ~ Percent.non.Hispanic.American.Indian.Alaska.Native, data=df3)

cor(df3$Estimated.hesitant, df3$Percent.non.Hispanic.Asian)
scatterplot(Estimated.hesitant ~ Percent.non.Hispanic.Asian, data=df3)

cor(df3$Estimated.hesitant, df3$Percent.non.Hispanic.Black)
scatterplot(Estimated.hesitant ~ Percent.non.Hispanic.Black, data=df3)

cor(df3$Estimated.hesitant, df3$Percent.non.Hispanic.White)
scatterplot(Estimated.hesitant ~ Percent.non.Hispanic.White, data=df3)

cor(df3$Estimated.hesitant, df3$Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander)
scatterplot(Estimated.hesitant ~ Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander, data=df3)

cor(df3$Estimated.hesitant, df3$Median_Household_Income_2019)
scatterplot(Estimated.hesitant ~ Median_Household_Income_2019, data=df3)

cor(df3$Estimated.hesitant, df3$unemployment_rate)
scatterplot(Estimated.hesitant ~ unemployment_rate, data=df3)

cor(df3$Estimated.hesitant, df3$Region_Midwest)
scatterplot(Estimated.hesitant ~ SVI, data=df3)

cor(df3$Estimated.hesitant, df3$Region_Northeast)
scatterplot(Estimated.hesitant ~ Region_Northeast, data=df3)

cor(df3$Estimated.hesitant, df3$Region_South)
scatterplot(Estimated.hesitant ~ Region_South, data=df3)

cor(df3$Estimated.hesitant, df3$Region_West)
scatterplot(Estimated.hesitant ~ Region_West, data=df3)

cor(df3$Estimated.hesitant, df3$party_DEMOCRAT)
scatterplot(Estimated.hesitant ~ party_DEMOCRAT, data=df3)

cor(df3$Estimated.hesitant, df3$party_REPUBLICAN)
scatterplot(Estimated.hesitant ~ party_REPUBLICAN, data=df3)

##### cor for strongly hesitant ####
cor(df3$Estimated.strongly.hesitant, df3$SVI)
cor(df3$Estimated.strongly.hesitant, df3$CVAC.level.of.concern.for.vaccination.rollout)
cor(df3$Estimated.strongly.hesitant, df3$Diabetes_Percent)
cor(df3$Estimated.strongly.hesitant, df3$Obesity_Percent)
cor(df3$Estimated.strongly.hesitant, df3$Percent.Hispanic)
cor(df3$Estimated.strongly.hesitant, df3$Percent.non.Hispanic.American.Indian.Alaska.Native)
cor(df3$Estimated.strongly.hesitant, df3$Percent.non.Hispanic.Asian)
cor(df3$Estimated.strongly.hesitant, df3$Percent.non.Hispanic.Black)
cor(df3$Estimated.strongly.hesitant, df3$Percent.non.Hispanic.White)
cor(df3$Estimated.strongly.hesitant, df3$Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander)
cor(df3$Estimated.strongly.hesitant, df3$Median_Household_Income_2019)
cor(df3$Estimated.strongly.hesitant, df3$unemployment_rate)




#########################################################################################################
###### k-means clustering######
#### Creating Dataframes for all the numerical columns####

numeric_df <- select(
  df3,
  Estimated.hesitant,
  SVI,
  CVAC.level.of.concern.for.vaccination.rollout,
  Percent.non.Hispanic.American.Indian.Alaska.Native,
  Percent.non.Hispanic.Black,
  Percent.non.Hispanic.White,
  Diabetes_Percent,
  party_DEMOCRAT,
  Region_West,
  Median_Household_Income_2019)
glimpse(numeric_df)
km <- data.frame(numeric_df)
km.norm <- scale(km)
# #the following code takes time, so  dont need to run it everytime
library(cluster)
set.seed(12345)
gaps <- clusGap(km.norm,kmeans,10,d.power=2)
maxSE(gaps$Tab[,"gap"],gaps$Tab[,"SE.sim"],"Tibs2001SEmax")
plot(gaps$Tab[,"gap"])
# 
# # 6 clusters make sense looking at the clusgap plot
# 


# smaller cluster for ease of interpretation:
km.cluster <- kmeans(km.norm, 6, nstart = 25)
unscale(km.cluster$centers, km.norm)

#visualization of K means
library(ggpubr)
install.packages("ggplot2")
library(ggplot2)
install.packages("factoextra")
library("factoextra")
set.seed(12345)
km.cluster <- kmeans(km.norm, 5, nstart = 25)
fviz_cluster(km.cluster, data = km, 
             ellipse.type = "convex",
             palette = "jco",
             repel = TRUE,
             ggtheme = theme_minimal())

# Dimension reduction using PCA
res.pca <- prcomp(km.norm,  scale = TRUE)
# Coordinates of individuals
ind.coord <- as.data.frame(get_pca_ind(res.pca)$coord)
# Add clusters obtained using the K-means algorithm
ind.coord$cluster <- factor(km.cluster$cluster)
# # Add Species groups from the original data sett
# ind.coord$Species <- df$Species
# # Data inspection
head(ind.coord)
eigenvalue <- round(get_eigenvalue(res.pca), 1)
variance.percent <- eigenvalue$variance.percent
head(eigenvalue)

ggscatter(
  ind.coord, x = "Dim.1", y = "Dim.2", 
  color = "cluster", palette = "npg", ellipse = TRUE, ellipse.type = "convex",
  size = 1.5,  legend = "right", ggtheme = theme_bw(),
  xlab = paste0("Dim 1 (", variance.percent[1], "% )" ),
  ylab = paste0("Dim 2 (", variance.percent[2], "% )" )
) +
  stat_mean(aes(color = cluster), size = 0.5)


### partitioning data####
# to avoid overfitting
# to calculate RMSE which will help us compare our models.
df3 <- as.data.frame(df3)
set.seed(12345)
training <- sample(1:nrow(df3), 0.6 * nrow(df3))
ycol <- match("Estimated.hesitant", colnames(df3))
df3.training <- df3[training, -ycol]
df3.training.results <- df3[training, ycol]
df3.test <- df3[-training, -ycol]
df3.test.results <- df3[-training, ycol]

######### Multiple Regression#########
# MODEL A:
MLRmodel <- lm(Estimated.hesitant ~
SVI +
  CVAC.level.of.concern.for.vaccination.rollout +
  Percent.Hispanic +
  Percent.non.Hispanic.American.Indian.Alaska.Native +
  Percent.non.Hispanic.Asian +
  Percent.non.Hispanic.Black +
  Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
  Percent.non.Hispanic.White +
  Median_Household_Income_2019 +
  Region_Midwest +
  Region_Northeast +
  Region_South +
  Diabetes_Percent +
  Obesity_Percent +
  unemployment_rate +
  party_DEMOCRAT,
data = df3[training, ]
)


summary(MLRmodel)

## using this model we generate results for the test set and calculate RMSE:
MLRmodel.predictions <- predict(MLRmodel, df3[-training, ])
(mean((df3.test.results - MLRmodel.predictions)^2))^0.5
# our root mean squared error is 0.0344 which is veryy small. That's a good thing!'

### #MODEL B:regression w/out unemployment rate, income and race
MLRmodel2 <- lm(Estimated.hesitant ~
SVI +
  CVAC.level.of.concern.for.vaccination.rollout +
  Region_Midwest +
  Region_Northeast +
  Region_South +
  Diabetes_Percent +
  Obesity_Percent +
  party_DEMOCRAT,
data = df3[training, ]
)

summary(MLRmodel2) 
## using this model we generate results for the test set and calculate RMSE:
MLRmodel2.predictions <- predict(MLRmodel2, df3[-training, ])
(mean((df3.test.results - MLRmodel2.predictions)^2))^0.5
# RMSE is 0.0364 almost the same as Model A
#R squared is 0.3501

### #MODEL C:regression w/out SVI
MLRmodel3 <- lm(Estimated.hesitant ~
                 CVAC.level.of.concern.for.vaccination.rollout +
                 Percent.Hispanic +
                 Percent.non.Hispanic.American.Indian.Alaska.Native +
                 Percent.non.Hispanic.Asian +
                 Percent.non.Hispanic.Black +
                 Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
                 Percent.non.Hispanic.White +
                 Median_Household_Income_2019 +
                 Region_Midwest +
                 Region_Northeast +
                 Region_South +
                 Diabetes_Percent +
                 Obesity_Percent +
                 unemployment_rate +
                 party_DEMOCRAT,
               data = df3[training, ]
)

summary(MLRmodel3)
## using this model we generate results for the test set and calculate RMSE:
MLRmodel3.predictions <- predict(MLRmodel3, df3[-training, ])
(mean((df3.test.results - MLRmodel3.predictions)^2))^0.5
#rmse is [1] 0.03441295
#R square 0.4121

##Model D
MLRmodel4 <- lm(Estimated.hesitant ~
                  CVAC.level.of.concern.for.vaccination.rollout +
                  Percent.Hispanic +
                  Percent.non.Hispanic.American.Indian.Alaska.Native +
                  Percent.non.Hispanic.Black +
                  Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
                  Percent.non.Hispanic.White +
                  Region_Midwest +
                  Region_Northeast +
                  Region_South +
                  Obesity_Percent +
                  unemployment_rate +
                  party_DEMOCRAT,
                data = df3[training, ]
)
MLRmodel4
summary(MLRmodel4)


## using this model we generate results for the test set and calculate RMSE:
MLRmodel4.predictions <- predict(MLRmodel4, df3[-training, ])
(mean((df3.test.results - MLRmodel4.predictions)^2))^0.5

#R square is 0.412
#RMSE is 0.0344

MLRmodel6 <- df3[training,] %>% 
  group_by(party_DEMOCRAT) %>% 
  group_map(~broom::tidy(lm(Estimated.hesitant ~
                              CVAC.level.of.concern.for.vaccination.rollout +
                              Percent.Hispanic +
                              Percent.non.Hispanic.American.Indian.Alaska.Native +
                              Percent.non.Hispanic.Black +
                              Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
                              Percent.non.Hispanic.White +
                              Region_Midwest +
                              Region_Northeast +
                              Region_South +
                              Obesity_Percent,
                            data= .x)))

install.packages("huxtable")
library("huxtable")
install.packages("officer")
library("officer")
install.packages("flextable")
library("flextable")
export_summs(MLRmodel4, scale = TRUE, to.file = "docx", file.name = "test.docx")


library(devtools)
install_github("dgrtwo/broom")
library(broom)
tidy_lmfit <- tidy(MLRmodel4)
write.docx(tidy_lmfit, "tidy_lmfit.docx")
library(jtools)
summ(MLRmodel4, model.info = FALSE, digits = 4)
plot_coefs(MLRmodel,MLRmodel4, scale= T, 
                             coefs=c( "SVI"="SVI",
                               "CVAC"="CVAC.level.of.concern.for.vaccination.rollout",
                                     "Hispanic"="Percent.Hispanic", 
                                     "Native American"="Percent.non.Hispanic.American.Indian.Alaska.Native",
                                     "Native Islander"="Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander",
                                     "Black"="Percent.non.Hispanic.Black" ,
                                     "White"="Percent.non.Hispanic.White",  
                                     "Midwest"="Region_Midwest",  
                                     "Northeast"="Region_Northeast",  
                                     "South"="Region_South",   
                                     "West"="Region_West",  
                                     "Obesity"="Obesity_Percent",  
                                     "Unemployment Rate"= "unemployment_rate",  
                                     "Democrat"="party_DEMOCRAT",  
                                     "Republican"="party_REPUBLICAN"))

MLRmodel5 <- lm(Estimated.hesitant ~
                  SVI+
                  CVAC.level.of.concern.for.vaccination.rollout +
                  Percent.Hispanic +
                  Percent.non.Hispanic.American.Indian.Alaska.Native +
                  Percent.non.Hispanic.Black +
                  Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
                  Percent.non.Hispanic.White +
                  Region_Midwest +
                  Region_Northeast +
                  Region_South +
                  Obesity_Percent +
                  unemployment_rate +
                  party_DEMOCRAT,
                data = df3[training, ]
)

summary(MLRmodel5)
## using this model we generate results for the test set and calculate RMSE:
MLRmodel5.predictions <- predict(MLRmodel5, df3[-training, ])
(mean((df3.test.results - MLRmodel5.predictions)^2))^0.5
#### Regression Trees
library(tree)

df3.tree <- tree(Estimated.hesitant ~
SVI +
  CVAC.level.of.concern.for.vaccination.rollout +
  Percent.Hispanic +
  Percent.non.Hispanic.American.Indian.Alaska.Native +
  Percent.non.Hispanic.Asian +
  Percent.non.Hispanic.Black +
  Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
  Percent.non.Hispanic.White +
  Median_Household_Income_2019 +
  Region_Midwest +
  Region_West+
  Region_Northeast +
  Region_South +
  Diabetes_Percent +
  Obesity_Percent +
  unemployment_rate +
  party_DEMOCRAT+
  party_REPUBLICAN,
data = df3[training, ],
mindev = 0.005
)


plot(df3.tree)
text(df3.tree, cex = 0.6)
summary(df3.tree)
# residual mean deviance is 0.001099

# The following command generates predictions for the test set and calculates RMSE
df3.tree.predictions <- predict(df3.tree, df3[-training, ])
(mean((df3.test.results - df3.tree.predictions)^2))^0.5

# determining the best mindev by comparing many different tree to come up with a tree with lowest possible RMSE
best.mindev <- -1
RMSE <- -1
best.RMSE <- 99999999
for (i in seq(from = 0.0005, to = 0.05, by = 0.0005)) {
  df3.tree <- tree(Estimated.hesitant ~
                     SVI +
                     CVAC.level.of.concern.for.vaccination.rollout +
                     Percent.Hispanic +
                     Percent.non.Hispanic.American.Indian.Alaska.Native +
                     Percent.non.Hispanic.Asian +
                     Percent.non.Hispanic.Black +
                     Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
                     Percent.non.Hispanic.White +
                     Median_Household_Income_2019 +
                     Region_Midwest +
                     Region_West+
                     Region_Northeast +
                     Region_South +
                     Diabetes_Percent +
                     Obesity_Percent +
                     unemployment_rate +
                     party_DEMOCRAT+
                     party_REPUBLICAN,
                   data = df3[training, ], mindev = i)
  df3.tree.predictions <- predict(df3.tree, df3)[-training]
  RMSE <- (mean((df3.test.results - df3.tree.predictions)^2))^0.5
  if (RMSE < best.RMSE) {
    best.mindev <- i
    best.RMSE <- RMSE
  }
}
print(paste("The optimal value of mindev is", best.mindev, "with a RMSE of", best.RMSE))
#"The optimal value of mindev is 0.0045 with a RMSE of 0.0345403185339632"

df3.best.tree <- tree(Estimated.hesitant ~
                        SVI +
                        CVAC.level.of.concern.for.vaccination.rollout +
                        Percent.Hispanic +
                        Percent.non.Hispanic.American.Indian.Alaska.Native +
                        Percent.non.Hispanic.Asian +
                        Percent.non.Hispanic.Black +
                        Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander +
                        Percent.non.Hispanic.White +
                        Median_Household_Income_2019 +
                        Region_Midwest +
                        Region_Northeast +
                        Region_South +
                        Diabetes_Percent +
                        Obesity_Percent +
                        unemployment_rate +
                        party_DEMOCRAT,
                      data = df3[training, ],
                      mindev=best.mindev)
plot(df3.best.tree)
text(df3.best.tree, cex=0.5)


(mean((df3.test.results - df3.tree.predictions)^2))^0.5
#All three models have very similar rmse
library("dplyr")
df3 <- df3 %>% rename(CVAC="CVAC.level.of.concern.for.vaccination.rollout") %>% 
  rename(Hispanic="Percent.Hispanic") %>% 
  rename(Native.American="Percent.non.Hispanic.American.Indian.Alaska.Native") %>% 
  rename(Asian="Percent.non.Hispanic.Asian") %>% 
  rename(African.American="Percent.non.Hispanic.Black") %>% 
  rename(Native.Islander="Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander") %>%  
  rename(White="Percent.non.Hispanic.White") %>% 
  rename(Median_HH_Income="Median_Household_Income_2019") %>% 
  rename(Midwest="Region_Midwest") %>% 
  rename(Northeast="Region_Northeast") %>% 
  rename(South="Region_South") %>%  
  rename(West="Region_West") %>% 
  rename(Diabetes= "Diabetes_Percent") %>% 
  rename(Obesity="Obesity_Percent") %>% 
  rename(unemployment_rate= "unemployment_rate") %>% 
  rename(Democrat="party_DEMOCRAT") %>% 
  rename(Republican="party_REPUBLICAN")


########### REGRESSION MODEL BETTER VISUALIZATION ################################

install.packages("jtools")
library("jtools")
plot_coefs(MLRmodel4, scale = TRUE,
           coefs=c(
             "SVI"="SVI",
             "CVAC"="CVAC.level.of.concern.for.vaccination.rollout",
             "Hispanic"="Percent.Hispanic", 
             "Native American"="Percent.non.Hispanic.American.Indian.Alaska.Native",
             "Native Islander"="Percent.non.Hispanic.Native.Hawaiian.Pacific.Islander",
             "Asian"="Percent.non.Hispanic.Asian",  
             "African American"="Percent.non.Hispanic.Black",
             "White"="Percent.non.Hispanic.White",  
             "Median Income"="Median_Household_Income_2019",  
             "Midwest"="Region_Midwest",  
             "Northeast"="Region_Northeast",  
             "South"="Region_South",   
             "West"="Region_West",  
             "Diabetes"= "Diabetes_Percent",  
             "Obesity"="Obesity_Percent",  
             "Unemployment Rate"= "unemployment_rate",  
             "Democrat"="party_DEMOCRAT",  
             "Republican"="party_REPUBLICAN"))
summary(MLRmodel4)


########### REGRESSION TREE BETTER VISUALIZATION ################################
install.packages("rpart")
install.packages("rpart.plot")
library(rpart)       # performing regression trees
library(rpart.plot)
m1 <- rpart(
  formula = Estimated.hesitant ~
    SVI +
    CVAC +
    Hispanic +
    Native.American +
    Native.Islander +
    African.American +
    White +
   Midwest +
    West+
    unemployment_rate +
    Democrat,
  data = df3[training, ],
  method  = "anova")
rpart.plot(m1, cex=.5)
rpart.plot(m1, type =1, extra = 0,cex=0.6, branch.lty = 3, box.palette = "Auto")


######################################################################################
