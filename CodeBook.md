# Syracuse Crime Analysis: Code Book

**Overview:** The following describes the units, variable definitions, variable transformations, and any additional information beyond the data cleaning, analysis, and visualization processes outlined in the `README.md`.

## Data Sources

### Syracuse Post Standard Crime Database

The source of the raw crime data is the Syracuse Post Standard's [Crime Database](https://www.syracuse.com/crime/index.ssf/page/police_reports.html), which is pre-processed upstream by reporting police agencies, notably for block-level anaonymization. According to the Standard, "reported crimes are updated weekly and are the most recent reported by the police departments". It is noted that there may be some delay in the reporting of crimes "considered particularly sensitive in nature", e.g. murder, robbery, and aggravated assault. Reported crimes include all those classified as "Part I" under the federal [Uniform Crime Reporting Program](http://media.syracuse.com/news/other/part_I_crimes.pdf), with the exception of forcible rape, as crimes of sexual violence are not reported per Syracuse Police Department policy.

Crimes within the retrieved data are classified as `Aggravated assault`, `Arson`, `Burglary`, `Larceny`, `Murder`, `Robbery`, and `Vehicle theft`. Only crimes reported by the Syracuse Police department were ingested for this analysis. 

### US Census Geocoder

The source of the FIPS GEOIDs linked to each reported address were collected through the [US Census Geocoder](https://geocoding.geo.census.gov/geocoder/), on which more may be read [here](https://www.census.gov/geo/maps-data/data/geocoder.html). The geocoder provides FIPS codes for `state`, `county`, `tract`, and `block` geographies in batches of up to 10,000. Crime data in the `crime` data frame were manipulated to make the geocoding process more amenable, including circumventing anonymization of reported crimes to the block level. Text manipulation included:

1. Removal of "block" and resulting white space from variable `address`;
2. Detection of all `address` values containing "Destiny", in reference to Destiny USA, and replacement with "2158 Park Street", a nearby parking lot within the same census tract;
3. Substitution of all `address` values with house number "0" with house number "100";
4. Removal of 2 crimes reported on interstate highways "I-690" and "I-81"

## Package Dependencies

The following R packages were used in the data collection, cleaning, analysis, and visualization process:

1. `sf`
2. `tmap`
3. `dplyr`
4. `purrr`
5. `readr`
6. `broom`
7. `tidyr`
8. `tigris`
9. `ggplot2`
10. `stringr`
11. `lubridate`

In addition, base R functions and RStudio package dependencies were employed for versions 3.4.3 and 1.1.414, respectively.

