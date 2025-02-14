
rm(list = ls())
setwd("C:/Users/joze_/OneDrive - Stockholm University (1)/Skrivbordet/forecasting_projects-main/API_Database_Visualize_pipeline")
library(dplyr)
library(tidyverse)
library(lubridate)

# Ensure the "Raw" and "Data" folders exist
if(!dir.exists("Raw")) dir.create("Raw")
if(!dir.exists("Data")) dir.create("Data")

# ===== Step 2: Import and Prepare Data ====================
kpif <- read.csv('Raw/kpif.csv')
keyfigures <- read.csv('Raw/keyfigures.csv')
realgdp <- read.csv('Raw/realgdp.csv')
reporate <- read.csv('Raw/reporate.csv')
real_estate <- read.csv('Raw/Real estate price index.csv')
permits <- read.csv('Raw/permits.csv')
baro <- read.csv('Raw/barometer.csv')

# ==================== Make all data similiar with month ====================

# ==================== KPIF ====================
kpif_ts <- ts(kpif[,2], start = c(1988, 1), frequency = 12)
monthly_dates <- seq(as.Date("1988-01-01"), by = "month", length.out = length(kpif_ts))
kpif$time <- monthly_dates
kpif <- kpif %>% dplyr::rename(kpif = Value)


# ==================== Keyfigures ====================
# where each unique value in the key.figure column is converted into a separate column

keyfigures <- keyfigures %>%
  mutate(time = ymd(paste0(substr(month, 1, 4), "-", substr(month, 6, 7), "-01")))

keyfigures <- keyfigures %>%
  pivot_wider(
    names_from = key.figure,
    values_from = value,
    names_prefix = "category_",
    id_cols = time)



# ==================== realgdp ====================
head(realgdp)
str(realgdp)

realgdp_ts <- ts(realgdp[,4], start = c(1993, 1), frequency = 4)
monthly_dates <- seq(as.Date("1993-01-01"), by = "quarter", length.out = length(realgdp_ts))
realgdp$time <- monthly_dates
realgdp$quarter <- quarter(realgdp$time)
realgdp <- realgdp %>% dplyr::rename(realgdp = value)
realgdp <- realgdp[,c(1,4,5)]
realgdp <- realgdp %>% mutate(prev_year_gdp = lag(realgdp, 4), percent_change = ((realgdp - prev_year_gdp) / prev_year_gdp))
# ==================== REPO ====================
repo_rate_ts <- ts(reporate[, 'ultimo'], start = c(1994, 6), frequency = 12)
monthly_dates_repo <- seq(as.Date("1994-06-01"), by = "month", length.out = length(repo_rate_ts))
reporate$time <- monthly_dates_repo
reporate <- reporate %>% select(year, time, ultimo)
reporate <- reporate %>% dplyr::rename(reporate = ultimo)


# ==================== real_estate ====================
head(real_estate)
str(real_estate)

real_estate_ts <- ts(real_estate[,3], start = c(1986, 1), frequency = 4)
monthly_dates <- seq(as.Date("1986-01-01"), by = "quarter", length.out = length(real_estate_ts))
real_estate$time <- monthly_dates
real_estate$quarter <- quarter(real_estate$time)
real_estate <- real_estate %>% dplyr::rename('Real estate price index' = value )

real_estate <- real_estate %>% # yearly change
  arrange(time) %>%
  mutate(
    last_year_index = lag(`Real estate price index`, 4),
    yearly_change = (`Real estate price index` - last_year_index) / last_year_index
  )

real_estate <- real_estate[,c(1,3:4,6)]

# ==================== permits ====================
head(permits)
str(permits)

# Reshape the data
permits <- permits %>%
  spread(key = type.of.building, value = value)

permits_ts <- ts(permits[,4], start = c(1996, 1), frequency = 4)
monthly_dates <- seq(as.Date("1996-01-01"), by = "quarter", length.out = length(permits_ts))
permits$time <- monthly_dates
permits$quarter <- quarter(permits$time)
permits <- permits[,c(1,4:8)]
permits$allpermits <- rowSums(permits[, 2:5], na.rm = TRUE)



# ==================== baro ====================
head(baro)
str(baro)
baro <- baro %>%
  spread(key = Indikator, value = value)


baro_ts <- ts(baro[, 4], start = c(1996, 1), frequency = 12)
monthly_dates_repo <- seq(as.Date("1996-01-01"), by = "month", length.out = length(baro_ts))
baro$time <- monthly_dates_repo
baro <- baro[, order(sapply(baro, function(x) sum(is.na(x))))]

# ==================== Save cleaned data ====================
# monthly data
merged <- merge(reporate, kpif, by = c("time"), all = TRUE)
merged <- merge(merged, keyfigures, by = c("time"), all = TRUE)

# Quarterly data
quarterly <- merge(realgdp, permits, by = c("time", "quarter"), all.x = TRUE, all.y = FALSE)
quarterly <- merge(quarterly, real_estate, by = c("time", "quarter"), all.x = TRUE, all.y = FALSE)

write.csv(merged,file = "Data/merged.csv", row.names = FALSE)
write.csv(quarterly,file = "Data/quarterly.csv", row.names = FALSE)
write.csv(baro,file = "Data/baro.csv", row.names = FALSE)










