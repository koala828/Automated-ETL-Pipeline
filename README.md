# ETL Data Pipeline for API Data Collection and Analysis

## Overview
This project implements an end-to-end ETL (Extract, Transform, Load) pipeline that automates the collection of data from external APIs, cleans and transforms the raw data, and loads it into a PostgreSQL database for easy to access data that can later on be used for analysis. The pipeline is built in R and is designed for automated execution via Windows Task Scheduler.

## Features
- **Automated Data Collection:** Retrieves data from various APIs.
- **Data Cleaning & Transformation:** Processes and cleans raw data to ensure quality and consistency.
- **Database Integration:** Utilize PostgreSQL to store cleaned data using R.
- **Modular & Maintainable:** Separated scripts for data collection, cleaning, and storage facilitate easy updates and debugging.
- **Scheduled Automation:** Configured to run automatically at set intervals using Windows Task Scheduler.


## Prerequisites
- **R** (v4.3.3 or later recommended)
- **RStudio** (optional, for development)
- **PostgreSQL** (for database storage)
- Windows (for scheduling via Task Scheduler)

