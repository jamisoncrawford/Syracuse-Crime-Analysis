# Syracuse Crime Analysis

**Overview:** This analysis explains the programmatic and manual steps taken to retrieve Syracuse crime data from the [Syracuse Post Standard Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html), from 2016 to present (2018-06-11), as well as manual batch geocoding via the [US Census Geocoder](https://geocoding.geo.census.gov/geocoder/). The repository contains the Crime Database raw data, raw data output from the Census Geocoder, an R script, `crime.script.r`, containing cleaning and analysis for 55 Syracuse census tracts, the present `README.md` containing a step-by-step guide to the data collection, analysis, and visualization process, and a a `CodeBook.md` containing units, variable definitions, variable transformations, and notable limitations of the analysis. 

## Data Collection, Analysis, & Visualization Script

The R script, `crime.script.r` has several package dependencies, all of which are automatically installed if undetected. Though the steps to retrieve the raw data are outlined herein, the script itself pulls duplicate data from the `Data` folder in this repository. 
