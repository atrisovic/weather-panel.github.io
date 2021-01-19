## Weather Mortality in the United States, Step 2: Understanding the outcomes

### Thinking about the data-generating process

First, let us think about the process that relates mortality to
weather. Weather fluctations can have impacts on all scales, but
generally when we are thinking of heat waves killing people, it is
because of direct exposure. The main data-generating process is local.

It is also non-linear. Both cold and hot weather kills people,
relative to deaths at moderate (pleasant) temperatures. We can model
this with a quadratic relationship. We need to choose some baseline
temperature for comparison purposes. For our example, we will use 20
C. The dose-response function will describe excess mortality, relative
to a day with an average temperature of 20 C.

We also need to weight our pixel data. We want the dose-response
function to be representative of a random individual, not a random
region-year data point, so we will weight gridcells by population.

Finally, the mortality data we will use is annual, while the weather
data is daily. We still want to estimate a daily dose-response
function, so we will say that take sums over all days of both the
weather and outcome data. The sum over daily death data is annual
death data, which is what we have.

Then, we want to transform the weather data by creating two predictor
variables, for the linear and quadratic terms relative to 20 C.

$$X_{1, i, y} = \sum_{t \in \text{Year}(y)} \sum_{p \in \Theta(i)} \psi_{p} (T_{p i t} - 20)$$
$$X_{2, i, y} = \sum_{t \in \text{Year}(y)} \sum_{p \in \Theta(i)} \psi_{p} (T_{p i t}^2 - 20^2)$$

where $\psi_{p}$ is the population in gridcell $p$.

### Download the population data

https://sedac.ciesin.columbia.edu/data/set/gpw-v3-population-count

```R
library(raster)
rr <- raster("~/groups/weatherpanels/weather-panel.github.io/example/data/pcount/usap90ag.bil")

rr2 <- aggregate(rr, fact=24, fun=sum)
rr3 <- crop(rr2, extent(-126, -65, 23, 51))

writeRaster(rr3, "~/groups/weatherpanels/weather-panel.github.io/example/data/pcount/usap90ag.nc4",
 overwrite=TRUE, format="CDF", varname="Population", varunit="people",
 xname="lon", yname="lat")
```

### Aggregating the weather data

One of the tutorial authors has produced a new tool for aggregating
gridded data according to a shapefile: `xagg`. Since it handles
partial grid-cell overlapping and arbitrary weighting grid, we
recommend that it be used irrespective of the language being used
elsewhere. Install it according to the instructions here:
https://github.com/ks905383/xagg

You will need to download a shapefile for the US counties. We use one
from the ESRI community website:
https://community.esri.com/ccqpr47374/attachments/ccqpr47374/enterprise-portal/4124/1/UScounties.zip

Save its contents to a folder `geo_data` in the `data` directory. The
following code should be run from the `data` directory.

## Setting up the environment

The approach uses `xarray` for gridded data, `geopandas` to work with shapefiles, and `xagg` to aggregate gridded data onto shapefiles. 

```python
import xarray as xr
import geopandas as gpd
import xagg as xa
import numpy as np
```

First, load the data from the previous steps:

```python
# Load temperature data using xarray
ds_tas = xr.open_dataset('climate_data/tas_day_BEST_historical_station_19800101-19891231.nc')

# Load population data using xarray 
ds_pop = xr.open_dataset('pcount/usap90ag.nc')

# Load county shapefiles using geopandas
gdf_counties = gpd.read_file('geo_data/UScounties.shp')
```

### Traansforming the data

Next, we need to construct any nonlinear transformations of the data.

For our econometric model, we want temperature in both linear and quadratic form, centered around $20^\circ$ C: 

$T-20^\circ C$ and $T^2 - (20^\circ C)^2$.

```python
ds_tas['tas_adj'] = ds_tas.tas-20
ds_tas['tas_sq'] = ds_tas.tas**2 - 20**2

# xagg aggregates every gridded variable in ds_tas - however, we don't need
# every variable currently in tas. Let'ss drop "tas" (the un-adjusted temperature)
# and "land_mask" which is included, but not necessary for our further analysis.
ds_tas = ds_tas.drop('tas')
ds_tas = ds_tas.drop('land_mask')
```

### Create map of pixels onto polygons

We need to create a weight map of pixels to polygons. For each
polygon, we need to know which pixels overlap it and by how much.

`xagg` does this by creating polygons for each pixel in the gridded
dataset, taking the intersect between each county polygon and all
pixel polygons, and calculating the average area of overlap between
the pixels that touch the polygon and the polygon.

```python
weightmap =
xa.pixel_overlaps(ds_tas,gdf_counties,weights=ds_pop.Population,subset_bbox=False)
```

### Aggregate values onto polygons

Using the weight map calculated above, `xagg` now aggregates all the gridded variables in `ds_tas` (the `tas_adj` and `tas_sq` we calculated above) onto the county polygons. For each county, the weighted average of the temperatures of the pixels that cover the county is calculated. Since we included population as a desired weight above, the weight for each pixel is a combination of how much of the pixel overlaps with the county and its population density. In other words, a pixel that covers more of a county and has a higher population density will be weighted more in that county's temperature average than a pixel that covers less of a county and is more sparsely populated. 

The output of this function now gives, for each county, a 10-year time series of linear and quadratic temperature, properly area- and population-weighted.  

(`aggregated` is an object specific to the `xagg` package; we need to modify it to be useable, for example using `aggregated.to_dataset()` or `aggregated.to_csv` as we do below - see the `xagg` docs for more info). 

```python
aggregated = xa.aggregate(ds_tas,weightmap)
```

### Export this as a .csv file to be used elsewhere

Finally, we need to export this data to be used elsewhere. For further processing in `python`, use `aggregated.to_dataset()` or `aggregated.to_dataframe()`, depending on whether you'd like to continue using it in `xarray` or `pandas`. 

For this tutorial, we want to allow a variety of tools, so we'll
export the aggregated data into a .csv (comma-separated value) file,
which can easily be read by R, STATA, and most other programming
tools. The data will be reshaped 'wide' by `xagg` - so every row is a
county, and every column is a timestep of the variables. 

```python
aggregated.to_csv('agg_vars.csv')
```

### Downloading the mortality data

The Compressed Mortality File (CMF) provides comprehensive,
county-scale mortality data for the United States. The data through
1988 is publically available, so we will use this for our analysis.

1. Go to the CMF information page,
   https://www.cdc.gov/nchs/data_access/cmf.htm
2. Under "Data Availability", find the mortality and population files
   for 1979 - 1988, and download these.
3. Unzip these files, and place the resulting text files,
   `Mort7988.txt` and `Pop7988.txt` into the `data/cmf` folder.

These files report data as fixed-width ASCII text, meaning that spans
of characters on each line represent columns of the data.

In the mortality data file, `Mort7988.txt`, here are the elements of
interest: Characters 1 - 5 provide the FIPS code (FIPS is a 5 digit
code uniquely identifying each county in the US). Characters 6 - 9
report the year of death. The next few columns give the race, age, and
cause of death, but we will combine results across all of
these. Characters 20 - 23 report the number of deaths that correspond
to that county, year, race, age, and cause.

In the population data file, `Pop7988.txt`, the lines start with FIPS
codes and years, like the mortality data. But then the age groups are
all listed on the line: starting with character 19, the population in
each of 12 age groups is reported with 8 characters per age group
number (so, the first age group, 1 - 4 year-olds, is characters 19 -
26; then 5 - 9 year-olds is reported in characters 27 - 34; and so
on).


### Loading the data

Here we sum across all races and ages and merge the mortality and
population data.

```R
library(dplyr)

df.mort <- read.fwf("~/groups/weatherpanels/weather-panel.github.io/example/data/cmf/Mort7988.txt",
   c(5, 4, 10, 4), col.names=c('fips', 'year', 'ignore', 'deaths'))

df2.mort <- df.mort %>% group_by(fips, year) %>% summarize(deaths=sum(deaths))

df.pop <- read.fwf("~/groups/weatherpanels/weather-panel.github.io/example/data/cmf/Pop7988.txt",
   c(5, 4, 9, rep(8, 12), 25, 1), col.names=c('fips', 'year',
   'ignore', paste0('pop', 1:12), 'county', 'type'))

df2.pop <- df.pop %>% group_by(fips, year) %>% summarize(pop=sum(pop1 +
    pop2 + pop3 + pop4 + pop5 + pop6 + pop7 + pop8 + pop9 + pop10 +
    pop11 + pop12), type=type[1])

df3 <- df2.pop %>% left_join(df2.mort, by=c('fips', 'year'))
df3$deaths[is.na(df3$deaths)] <- 0

df4 <- subset(df3, type == 3)

write.csv(df4[, -which(names(df4) == 'type')], "~/groups/weatherpanels/weather-panel.github.io/example/data/cmf/merged.csv", row.names=F)
```

### Constructing annual polynomials summed over days



### Merging weather and outcome data

### Running the regression

