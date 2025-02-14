# ===== Step 1: Get all data ====================
rm(list = ls())

# Set working directory - ensure the path is correct and use forward slashes.
setwd("C:/Users/joze_/OneDrive - Stockholm University (1)/Skrivbordet/forecasting_projects-main/API_Database_Visualize_pipeline")

# Load required libraries
library(pxweb, quietly = TRUE)
library(httr)
library(jsonlite)
library(dplyr)
library(pxR)
library(tidyr)

# Ensure the "Raw" and "Data" folders exist
if(!dir.exists("Raw")) dir.create("Raw")
if(!dir.exists("Data")) dir.create("Data")

# ==================================================
# Monetary Policy - KPIF Data (Last update: 2023-12-14)
# ==================================================
api_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/START/PR/PR0101/PR0101G/KPIF"
json_query <- '{
  "query": [
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": ["PR0101F1"]
      }
    },
    {
      "code": "Tid",
      "selection": {
        "filter": "all",
        "values": ["*"]
      }
    }
  ],
  "response": {
    "format": "json"
  }
}'

response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  data_text <- content(response, "text", encoding = "UTF-8")
  parsed_data <- fromJSON(data_text)
} else {
  stop("Error in KPIF API request")
}

# Extract keys and values
keys <- sapply(parsed_data$data, function(x) x$key)
values <- sapply(parsed_data$data, function(x) as.numeric(x$values))

# Create time series data frame and write to CSV
df <- data.frame(Date = keys, values = values, stringsAsFactors = FALSE)
kpif <- na.exclude(df)
infl <- ts(kpif$values, start = c(1988, 1), frequency = 12)
ts_data <- data.frame(Time = time(infl), Value = as.numeric(infl))
write.csv(ts_data, file = "Raw/kpif.csv", row.names = FALSE)

# ==================================================
# GDP Data from PXWEB (Last update: 2023-11-29)
# ==================================================
api_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/START/NR/NR0103/NR0103A/NR0103ENS2010T01Kv"
json_query <- '{
  "query": [
    {
      "code": "Anvandningstyp",
      "selection": {
        "filter": "item",
        "values": ["BNPM"]
      }
    },
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": ["NR0103BW"]
      }
    }
  ],
  "response": {
    "format": "px"
  }
}'
response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  binary_data <- content(response, "raw")
  # Decode and print for debugging (if needed)
  decoded_data <- rawToChar(binary_data)
  decoded_data_windows <- iconv(decoded_data, from = "Windows-1252", to = "UTF-8")
  message(decoded_data_windows)
  
  writeBin(binary_data, "data.px")
  px_data <- read.px("data.px")
  gdp_df <- as.data.frame(px_data)
  gdp_df <- na.exclude(gdp_df)
  head(gdp_df)
  write.csv(gdp_df, file = "Raw/realgdp.csv", row.names = FALSE)
} else {
  stop("Error in GDP API request")
}

# ==================================================
# Key Figures from PXWEB (Last update: 2024-01-30)
# ==================================================
api_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/START/FM/FM5001/FM5001X/NTFM5001"
json_query <- '{
  "query": [
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": ["000000UW"]
      }
    }
  ],
  "response": {
    "format": "px"
  }
}'
response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  binary_data <- content(response, "raw")
  decoded_data <- rawToChar(binary_data)
  decoded_data_windows <- iconv(decoded_data, from = "Windows-1252", to = "UTF-8")
  message(decoded_data_windows)
  
  writeBin(binary_data, "data.px")
  px_data <- read.px("data.px")
  keyfig_df <- as.data.frame(px_data)
  write.csv(keyfig_df, file = "Raw/keyfigures.csv", row.names = FALSE)
} else {
  stop("Error in Key Figures API request")
}

# ==================================================
# Riksbanken Data (Last update: 2023-12-29)
# ==================================================
api_url <- "https://api.riksbank.se/swea/v1/ObservationAggregates/SECBREPOEFF/M/1994-06-01"
response <- GET(api_url)
if (status_code(response) == 200) {
  data_text <- content(response, "text", encoding = "UTF-8")
  parsed_data <- fromJSON(data_text)
} else {
  stop("Error in Riksbanken API request")
}
repo_rate_df <- bind_rows(parsed_data)
write.csv(repo_rate_df, file = "Raw/reporate.csv", row.names = FALSE)

# ==================================================
# Housing Market Analysis
# ==================================================
# Real estate price index (1981=100) by quarter (Last update: 2024-01-23)
api_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/BO/BO0501/BO0501A/FastpiFritidshusKv"
json_query <- '{
  "query": [],
  "response": {
    "format": "px"
  }
}'
response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  binary_data <- content(response, "raw")
  writeBin(binary_data, "data.px")
  px_data <- read.px("data.px")
  real_estate_df <- as.data.frame(px_data)
  real_estate_df <- na.exclude(real_estate_df)
  head(real_estate_df)
  write.csv(real_estate_df, file = "Raw/Real estate price index.csv", row.names = FALSE)
} else {
  stop("Error in Real Estate API request")
}

# ==================================================
# Building Permits Data (Last update: 2024-01-23)
# ==================================================
json_query <- '{
  "query": [
    {
      "code": "Region",
      "selection": {
        "filter": "vs:RegionRiket99",
        "values": ["00"]
      }
    },
    {
      "code": "Hustyp",
      "selection": {
        "filter": "item",
        "values": ["1113", "21", "2224", "19"]
      }
    }
  ],
  "response": {
    "format": "px"
  }
}'
api_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/START/BO/BO0101/BO0101G/LghHustypKv"
response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  binary_data <- content(response, "raw")
  writeBin(binary_data, "building_data.px")
  px_data <- read.px("building_data.px")
  building_data <- as.data.frame(px_data)
  print(head(building_data))
  write.csv(building_data, file = "Raw/permits.csv", row.names = FALSE)
} else {
  stop("Error in Building Permits API request")
}

# ==================================================
# Barometer Data (Last update: 2024-01-30, data for Jan 2024)
# ==================================================
json_query <- '{
  "query": [],
  "response": {
    "format": "px"
  }
}'
api_url <- "https://statistik.konj.se:443/PxWeb/api/v1/sv/KonjBar/indikatorer/Indikatorm.px"
response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  binary_data <- content(response, "raw")
  writeBin(binary_data, "Indikatorm.px")
  px_data <- read.px("Indikatorm.px")
  Indikatorm <- as.data.frame(px_data)
  print(head(Indikatorm))
  write.csv(Indikatorm, file = "Raw/barometer.csv", row.names = FALSE)
} else {
  stop("Error in Barometer API request")
}

# ==================================================
# Purchasing Power Analysis (Last update: 2024-02-02)
# ==================================================
json_query <- '{
  "query": [
    {
      "code": "Region",
      "selection": {
        "filter": "vs:RegionRiket99",
        "values": ["00"]
      }
    },
    {
      "code": "Kon",
      "selection": {
        "filter": "item",
        "values": ["1+2"]
      }
    },
    {
      "code": "Alder",
      "selection": {
        "filter": "item",
        "values": ["16-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85+"]
      }
    },
    {
      "code": "Inkomstklass",
      "selection": {
        "filter": "item",
        "values": ["TOT"]
      }
    },
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": ["HE0110J7", "HE0110J8"]
      }
    }
  ],
  "response": {
    "format": "px"
  }
}'
api_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/START/HE/HE0110/HE0110A/SamForvInk1"
response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  binary_data <- content(response, "raw")
  writeBin(binary_data, "Indikatorm.px")
  px_data <- read.px("Indikatorm.px")
  inc <- as.data.frame(px_data)
  print(head(inc))
  write.csv(inc, file = "Raw/inc.csv", row.names = FALSE)
} else {
  stop("Error in Purchasing Power API request")
}

# ==================================================
# Consumer Price Index (CPI) by Product Group and Month
# ==================================================
json_query <- '{
  "query": [
    {
      "code": "VaruTjanstegrupp",
      "selection": {
        "filter": "vs:VaruTjänstegrCoicopA",
        "values": ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
      }
    },
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": ["000003TJ"]
      }
    }
  ],
  "response": {
    "format": "px"
  }
}'
api_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/START/PR/PR0101/PR0101A/KPICOI80MN"
response <- POST(api_url, body = json_query, encode = "json")
if (status_code(response) == 200) {
  data_text <- content(response, "text", encoding = "UTF-8")
} else {
  stop("Error in CPI API request")
}
binary_data <- content(response, "raw")
decoded_data <- rawToChar(binary_data)
decoded_data_windows <- iconv(decoded_data, from = "Windows-1252", to = "UTF-8")
message(decoded_data_windows)
writeBin(binary_data, "data.px")
px_data <- read.px("data.px")
data_frame <- as.data.frame(px_data)
wide_data_frame <- data_frame %>% 
  pivot_wider(names_from = Product.group, values_from = value)
print(wide_data_frame)
write.csv(wide_data_frame, file = "Raw/KPIproductgroups.csv", row.names = FALSE)


