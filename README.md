# Syracuse Crime Analysis

**GitHub Page:** You can visit the GitHub page for the analysis [here](https://jamisoncrawford.github.io/Syracuse-Crime-Analysis/).

**Overview:** This analysis explains the programmatic and manual steps taken to retrieve Syracuse crime data from the [Syracuse Post Standard Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html), from 2016 to present (2018-06-11), as well as manual batch geocoding via the [US Census Geocoder](https://geocoding.geo.census.gov/geocoder/). The repository contains the Crime Database raw data, raw data output from the Census Geocoder, an R script, `crime.script.r`, containing cleaning and analysis for 55 Syracuse census tracts, the present `README.md` containing a step-by-step guide to the data collection, analysis, and visualization process, and a a `CodeBook.md` containing units, variable definitions, variable transformations, and notable limitations of the analysis. 

## Data Collection, Analysis, & Visualization Process

The R script, `crime.script.r` has several package dependencies, all of which are automatically installed if undetected. Though the steps to retrieve the raw data are outlined herein, the script itself pulls duplicate data from the `Data` folder in this repository. 

### Manual Retrieval: Crime Database

Data were pulled directly from the [Syracuse Post Standard Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html) and reside in the `Data` folder: `spd_crimes_since_2016.csv`. Filters applied to search the database included "Department" set to "Syracuse Police", "Crime" to "All reported crimes", and "Date Range" from "01/01/2016" to "06/10/2016", as seen [here](https://i.imgur.com/dskkpXt.png), resulting in 12,775 observations. To retrieve and unzip these data, users must select the "Download Data" icon in the upper-right of the results field, as seen [here](https://i.imgur.com/ufJDscv.png).

`processing_script_1.1.r` has been modified to pull data ranging between 2018-06-01 and 2018-11-30.

### Cleaning Process

Once the data is retrieved, the `crime.script.r` then performs the following functions:

1. Package dependencies are detected and, if not present, are automatically installed and loaded;
2. Data are read in and formatted, select variables are kept and renamed;
3. Variable `address` text is manipulated heavily, including removal of obfuscating words (e.g. "block") and manual reassignment of addresses to nearby locations within the same census tract (e.g. "Destinyt Usa Dr" to "2158 Park St"); 
4. Variable `date` is coerced to `POSIXlt` class and converted to the first day of the month for all instances;
5. Variables `id`, `state`, and `zip` are created to accomodate the Census Geocoder;
6. The data frame, `crime`, is separated into two data frames of equal size (n = 6,386);
7. Directory `crime_data` is automatically created in users' working directories and the two data frames, `geo_1.csv` and `geo_2.csv` are stored locally for batch geocoding. They are written as text files with column headers removed to be Geocoder-friendly.

### Manual Geocoding Process

The [US Census Geocoder](https://geocoding.geo.census.gov/geocoder/) allows users to geocode geographies in batches of up to 10,000 addresses. More information can be read [here](https://www.census.gov/geo/maps-data/data/geocoder.html). To geocode each file, `geo_1.csv` and `geo_2.csv`, users must select "Address Batch" under "FIND GEOGRAPHIES USING", and upload each file separately with the default values, viz. "Benchmark" set to "Public_AR_Current" and "Vintage" set to "Current_Current", as seen [here](https://i.imgur.com/8tL2BBJ.png). Select "Get Results" and your browser will indicate, in the bottom left, that it is "Waiting for geocoding.geo.census.gov...", as seen [here](https://i.imgur.com/zyKWcff.png). This process may take up to 15 minutes. Once both files have been uploaded and geocoded, your browser will indicate that they've downloaded, and you may retrieve them from your download folder, as seen [here](https://i.imgur.com/WNdImNH.png) and [here](https://i.imgur.com/PwKCRbk.png), respectively. The data collection and cleaning process may continue in `crime.script.r`. Notably, the geocoding process in these data is able to geocode input addresses with 94.49% accuracy.

`processing_script_1.1.r` has been modified to pull data ranging between 2018-06-01 and 2018-11-30. Due to fewer crimes geocoded in the 5-month window, v. 1.1 now reflects a single .csv  file for Census geocoding.

### Cleaning & Analysis, Continued

The R script, `crime.script.r`, may now perform the following:

1. Read in, format, select and rename variables of interest, and merge the `geo_1`, `geo_2`, and `crime` data frames;
2. Paste variables `state`, `county`, and `tract` to create `geoid`, a FIPS code recognized by US Census;
3. Reformat variable `tract` to 2- and 4-digit, human-readable values;
4. Filter incomplete (non-geocoded) instances and 113 instances outside of Syracuse's 55 census tracts using FIPS GEOID values, located in the `Data` folder of this repository as `fips_geoid.csv`;
5. Aggregate reported crimes to create contingency tables `type_table` and `tract_table`, grouping crimes by `month`, `tract`, and `type`, and `month` and `tract`, respectively;
6. Plot exploratory time series visualizations on crime over time by `type` and faceted by `tract`, including linear and loess lines;
7. Apply linear regressions recursively to various permutations of `crime` as a function of `month` and `type`;
8. Apply multiple hypothesis correction and supply adjusted `p.value`, with slope coefficient `estimate` arranged in descending order;
9. Filter `p.value` for several hundred individual linear regression coefficients at 0.05 and 0.1 levels of significance;
10. Draw static and interactive choropleth maps of cumulative table `total_crime` with variable `crime` mapped to saturation
11. Automatically save choropleth maps and times series visualizations to the users' working directories

## Notable Findings

Few regression models proved significant until controlling for variable `type`, specifically `Larceny` in a number of tracts. Census Tract 1, due to the disproportionate concentration of `Larceny` reported at Destiny USA (the major mall in Syracuse), may require suppression or penalization to gain further insight, and materially obfuscates any discernible patterns in the choropleth maps. 

Work is set to continue on these analyses.

## Updates

2018-06-10: Initialized repository and performed data collection, analyses, and markdown documentation.
2018-12-04: `processing_script_1.1.r` and related tables have been modified to pull data ranging between 2018-06-01 and 2018-11-30.

## Contributors

The following individuals have contributed significantly to this work:

1. William Wagner-Flynn; Data Analyst, Syracuse City School District
2. Frank Ridzi, PhD; Vice President of Community Investment, Central New York Community Foundation
3. Jamison Crawford; Principal Analyst, Data Analysis & Visualization Consultant
