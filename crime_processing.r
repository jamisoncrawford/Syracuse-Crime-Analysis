
#--------------------------------------------------------------#
# CRIME DATA CLEANING, VISUALIZATION, & ANALYSIS

### 2018-06-10
### R v. 3.4.3
### RStudio v. 1.1.414

# DESCRIPTION: Cleans raw data data from Syracuse Post Standard Crime Database;
#              Prepares data for manual batch geocoding by US Census;
#              Visualizes each of Syracuse's 55 census tracts;
#              Performs regression analysis on improving or worsening tracts.

#--------------------------------------------------------------#
# CLEAR LIBRARY; INSTALL & LOAD REQUIRED PACKAGES

rm(list=ls())
if(!require(pacman)){install.packages("pacman")}; library(pacman)
packages <- c("sf", "tmap", "dplyr", "purrr", "readr", "broom", "tidyr", 
              "tigris", "stringr", "ggplot2", "lubridate")
p_load(packages, character.only = TRUE); rm(packages)       

#--------------------------------------------------------------#
# READ IN DATA & FORMAT

url <- "https://raw.githubusercontent.com/jamisoncrawford/Syracuse-Crime-Analysis/master/Data/spd_crimes_since_2016.csv"
cols <- c("crime", "address", "city", "agency", "date", "time")
types <- c("cccccc")

crime <- read_csv(file = url, 
                  col_names = cols,         # Rename columns: Object "cols"
                  trim_ws = TRUE, 
                  skip = 1, 
                  col_types = types) %>%    # Coerce classes: "types"
    select(-agency, -time)                  # Remove "agency" and "time" columns

rm(url, cols, types)                        # Remove obsolete objects

#--------------------------------------------------------------#
# REMOVE "BLOCK", DELETE WHITESPACE, REFORMAT ADDRESSES; FORMAT DATES

crime$address <- crime$address %>% 
    str_replace_all(pattern = "block " , 
                    replacement = "") %>%       # Remove "block" from "address"
    str_replace_all(pattern = " +" , 
                    replacement = " ") %>%      # Correct 2+ spaces
    str_replace_all(pattern = ".*Destiny.*",       # Replace with nearby address
                    replacement = "2158 Park St") %>%
    str_replace_all(pattern = "^0 ",
                    replacement = "100 ")       # Replace "0" in "address"

crime <- crime[!grepl(x = crime$address, 
                      pattern = "690|0 81"), ]  # Remove highway crimes

crime$date <- mdy(crime$date)                   # Coerce to class "POSIXlt"

crime <- crime %>% 
    mutate(month = floor_date(x = date, 
                              unit = "month"),  # Create variable "month"
            id = seq_along(crime)) %>%          # Create unique ID: "id"
    mutate(state = "NY") %>%                    # Create variable "state"
    select(-date) %>%                           # Remove variable "date"
    select(id, month, crime:state)              # Reorder variables

#--------------------------------------------------------------#
# PREPARE CENSUS GEOCODER TABLE

## Geocoder: https://geocoding.geo.census.gov/geocoder/geographies/addressbatch?form
## More Info: https://www.census.gov/geo/maps-data/data/geocoder.html 

geocode <- crime %>%                      # Initialize object "to_geocode"
    mutate(zip = "") %>%                  # Create empty column "zip"
    select(id, address:zip)               # Rearrange to be geocoder-friendly

n <- as.integer(nrow(geocode) / 2)

geo_1 <- geocode[1:n, ]                   # Assign to two equal data frames
geo_2 <- geocode[(n+1):(n*2), ]

rm(n)                                     # Remove placeholder: "n"

if(!file.exists("./crime_data")){ 
    dir.create("./crime_data")}           # Create "crime_data" directory

map2(.x = list(x = geo_1,
               x = geo_2),
     .y = list(file = "./crime_data/geo_1.csv", 
               file = "./crime_data/geo_2.csv"), 
     .f = write_csv,
     col_names = FALSE)                  # Write to "crime_data" directory

getwd()                                   # Get directory location: "crime_data"

## Note: Follow the `README.md`` instructions to geocode datasets in "crime_data"
## https://github.com/jamisoncrawford/Syracuse-Crime-Analysis/blob/master/README.md 

#--------------------------------------------------------------#
# READ IN GEOCODED DATA; MERGE RESULTS & CRIME DATA FRAMES

url_1 <- "https://raw.githubusercontent.com/jamisoncrawford/Syracuse-Crime-Analysis/master/Data/GeocodeResults.csv"
url_2 <- "https://raw.githubusercontent.com/jamisoncrawford/Syracuse-Crime-Analysis/master/Data/GeocodeResults2.csv"
cols <- c("id", "address", "match", "type", "output", "lat_long", "tiger_id", "side", "state", "county", "tract", "block")
types <- "iccccccccccc"

geo_1 <- read_csv(file = url_1, col_names = cols, col_types = types, trim_ws = TRUE) # Read in first results

geo_2 <- read_csv(file = url_2, col_names = cols, col_types = types, trim_ws = TRUE) # Read in second results

crime <- bind_rows(geo_1, geo_2) %>%        # Merge results
    arrange(id) %>%                         # Arrange by variable: "id"
    bind_cols(crime, geocode) %>%           # Merge tables "crime", "geocode"
    select(id, month, crime, state:tract)   # Reduce columns

rm(geo_1, geo_2, geocode, cols, 
   types, url_1, url_2)                     # Remove obsolete variables

sum(complete.cases(crime)) / nrow(crime)    # 94.49% geocoding accuracy

#--------------------------------------------------------------#
# REMOVE INCOMPLETE CASES; CREATE GEOID FROM FIPS CODES

crime <- crime[complete.cases(crime), ]                       # Remove incomplete cases

crime$county <- str_pad(crime$county, 
                        width = 3, 
                        pad = "0", 
                        side = "left")                        # Pad "county" FIPS code with "0"
crime$tract <- str_pad(crime$tract, 
                       width = 6, 
                       pad = "0", 
                       side = "left")                         # Pad "tract" FIPS code with "0"
crime$geoid <- paste0(crime$state, crime$county, crime$tract) # Paste padded FIPS codes: "geoid"

crime <- crime %>% mutate(tract = str_sub(string = tract, start = 3, end = 6),
                          tract = str_replace_all(string = tract, 
                                                  pattern = "00$", 
                                                  replacement = "")) # Remove trailing "00"

crime$tract <- gsub(x = crime$tract, pattern = "^(.{2})(.{2})$", replacement = "\\1\\.\\2" ) # Insert "." in "tract"
crime <- crime %>% select(month, geoid, tract, crime)                                        # Rearrange columns

#--------------------------------------------------------------#
# FILTER FOR GEOIDS OUTSIDE 55 CENSUS TRACTS

url <- "https://raw.githubusercontent.com/jamisoncrawford/Syracuse-Crime-Analysis/master/Data/fips_geoid.csv"

fips <- read_csv(url, col_types = "c")  # Read in FIPS GEOID values

crime <- crime %>%
  filter(geoid %in% fips$geoid)         # Filtered 113 non-matching tracts

rm(url, fips)                           # Remove obsolete variables

#--------------------------------------------------------------#
# REFORMAT CRIME DATA FRAME

crime <- crime %>%
    filter(month < date("2018-06-01")) %>%   # Remove incomplete data
    rename(type = crime)                     # Rename "crime" variable: "type"

cols <- c("geoid", "tract", "type")

crime[cols] <- lapply( crime[cols], factor) # Coerce all but "date" to "factor"

rm(cols)

#--------------------------------------------------------------#
# SEPARATE LARCENY & PART I CRIMES; REATE TABLES: CRIME, LARCENY, OTHER

larceny <- crime %>%
    filter(type == "Larceny")                # Preserve "Larceny" only

other <- crime %>%
    filter(type != "Larceny")                # Preserve all crime but "Larceny"

crime_table <- count(larceny, 
                     month,
                     geoid,
                     tract ) %>%             # Table by "month", "geoid", "type"
    rename(count = n)

larceny_table <- count(larceny, 
                       month,
                       geoid,
                       tract ) %>%           # Table by "month", "geoid", "type"
    rename(count = n)

other_table <- count(other,
                     month,
                     geoid,
                     tract ) %>%             # Table by "month", "geoid", "type"
    rename(count = n)

write_csv(crime_table, "crm_all_table.csv")
write_csv(larceny_table, "crm_larceny_table.csv")
write_csv(other_table, "crm_other_table.csv")
