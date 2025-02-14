# Master Script
cat("Starting API Data Collection...\n")
source("C:/Users/joze_/OneDrive - Stockholm University (1)/Skrivbordet/forecasting_projects-main/API_Database_Visualize_pipeline/script/Api data edited.R")
cat("Finished API Data Collection.\n")

cat("Starting Data Cleaning...\n")
source("C:/Users/joze_/OneDrive - Stockholm University (1)/Skrivbordet/forecasting_projects-main/API_Database_Visualize_pipeline/script/clean the data edited.R")
cat("Finished Data Cleaning.\n")

cat("Starting Database Upload...\n")
source("C:/Users/joze_/OneDrive - Stockholm University (1)/Skrivbordet/forecasting_projects-main/API_Database_Visualize_pipeline/script/DBI.R")
cat("Finished Database Upload.\n")

rm(list = ls())


