# Set working directory and clear environment
rm(list = ls())
setwd("C:/Users/joze_/OneDrive - Stockholm University (1)/Skrivbordet/forecasting_projects-main/API_Database_Visualize_pipeline")

# Load required packages
library(DBI)

# Establish the connection (using 'con' as a more conventional name)
con <- dbConnect(RPostgres::Postgres(),
                 dbname   = "Macro_DATABASE",
                 host     = "localhost",
                 port     = 5432,
                 user     = "postgres",
                 password = "mdsa45")

# Optional: List existing tables to verify connection
print(dbListTables(con))

# Read CSV files into R
merged_data   <- read.csv("Data/merged.csv")
quarterly_data <- read.csv("Data/quarterly.csv")
baro_data     <- read.csv("Data/baro.csv")

# Write the data frames to PostgreSQL tables.
# 'overwrite = TRUE' will drop any existing table with the same name.
# Alternatively, use 'append = TRUE' if you wish to add to an existing table.
dbWriteTable(con, "merged_table", merged_data, row.names = FALSE, overwrite = TRUE)
dbWriteTable(con, "quarterly_table", quarterly_data, row.names = FALSE, overwrite = TRUE)
dbWriteTable(con, "baro_table", baro_data, row.names = FALSE, overwrite = TRUE)

# Verify that new tables are created
print(dbListTables(con))

# [1] "baro_table"      "merged_table"    "quarterly_table" Perfect




# Disconnect when done
dbDisconnect(con)
