(content:hands-on3)=
# Hands-on exercise, step 3: aggregating the data

## Aggregating the weather data

There exist tools in R and Python which aggregate gridded data
according to a shapefile. In particular, `xagg` in Python and `stagg`
in R handle partial grid-cell overlapping and arbitrary weighting
grid, and we recommend that it be used irrespective of the language
being used elsewhere. 

## Setting up the environment

`````{tab-set}
````{tab-item} Python
The approach uses `xarray` for gridded data, `geopandas` to work with shapefiles, and `xagg` to aggregate gridded data onto shapefiles. 

Install `xagg` according to [the instructions from
GitHub](https://github.com/ks905383/xagg).

You will need to download a shapefile for the US counties. We use one
from the ESRI community website:
<https://community.esri.com/ccqpr47374/attachments/ccqpr47374/enterprise-portal/4124/1/UScounties.zip>

Save its contents to a folder `geo_data` in the `data` directory. The
following code should be run from the `data` directory.

Begin your code as follows:
```python
import xarray as xr
import geopandas as gpd
import xagg as xa
import numpy as np
```
````

````{tab-item} R
The approach uses `raster` to work with gridded data, `tigris` to work
with shapefiles, and `stagg` to aggregate gridded data onto shapefiles.

Install `stagg` according to [the instructions from
GitHub](https://github.com/tcarleton/stagg).

Begin your code as follows:
```{code-block} R
library(stagg)
library(raster)
library(tigris)
library(dplyr)
```
````
`````

Now, load the data from the previous steps and the county shapefile:

`````{tab-set}
````{tab-item} Python
```python
# Load temperature data using xarray
ds_tas = xr.open_dataset(
    '../data/climate_data/tas_day_BEST_historical_station_19800101-19891231.nc')

# Load population data using xarray 
ds_pop = xr.open_dataset('../data/pcount/usap90ag.nc')

# Load county shapefiles using geopandas
gdf_counties = gpd.read_file('../data/geo_data/UScounties.shp')
```
````

````{tab-item} R
```{code-block} R
## Load data and expand to global grid
global.extent <- extent(-180, 180, -90, 90)

rr.tas <- stack("../data/climate_data/tas_day_BEST_historical_station_19800101-19891231.nc")
rr.tas.padded <- extend(rr.tas, global.extent)
rr.pop <- raster("../data/pcount/usap90ag.nc")
rr.pop.padded <- extend(rr.pop, global.extent)
rr.pop.padded[is.na(rr.pop.padded)] = 0

## Load counties
counties <- tigris::counties()
counties$FIPS <- paste0(counties$STATEFP, counties$COUNTYFP)
```
````
`````

## Transforming the data

Next, we need to construct any nonlinear transformations of the data.

For our econometric model, we want temperature in both linear and quadratic form, centered around $20^\circ$ C: $T-20^\circ C$ and $T^2 - (20^\circ C)^2$.

`````{tab-set}
````{tab-item} Python
```python
ds_tas['tas_adj'] = ds_tas.tas-20
ds_tas['tas_sq'] = ds_tas.tas**2 - 20**2

# xagg aggregates every gridded variable in ds_tas - however, we don't need
# every variable currently in tas. Let'ss drop "tas" (the un-adjusted temperature)
# and "land_mask" which is included, but not necessary for our further analysis.
ds_tas = ds_tas.drop_vars('tas')
ds_tas = ds_tas.drop_vars('land_mask')
```
````

````{tab-item} R
With `stagg`, we will let the library handle this with the
`staggregate_polynomial` function (below).
````
`````

## Create map of pixels onto polygons

We need to create a weight map of pixels to polygons. For each
polygon, we need to know which pixels overlap it and by how much.

`xagg` and `stagg` do this by creating polygons for each pixel in the
gridded dataset, taking the intersect between each county polygon and
all pixel polygons, and calculating the average area of overlap
between the pixels that touch the polygon and the polygon.

`````{tab-set}
````{tab-item} Python
```python
weightmap = xa.pixel_overlaps(ds_tas, gdf_counties, weights=ds_pop.Population, subset_bbox=False)
```
````

````{tab-item} R
```R
grid.weights <- secondary_weights(secondary_raster=rr.pop.padded, grid=rr.tas.padded)
county.weights <- overlay_weights(polygons=counties, polygon_id_col="FIPS", grid=rr.tas.padded, secondary_weights=grid.weights)
```
````
`````


## Aggregate values onto polygons

For each county, we want to calculate the weighted average of the temperatures of the pixels that cover the county. Since we included population as a desired weight above, the weight for each pixel is a combination of how much of the pixel overlaps with the county and its population density. In other words, a pixel that covers more of a county and has a higher population density will be weighted more in that county's temperature average than a pixel that covers less of a county and is more sparsely populated. 

The output of this step now gives, for each county, a 10-year time series of linear and quadratic temperature, properly area- and population-weighted.  

`````{tab-set}
````{tab-item} Python

Using the weight map calculated above, `xagg` now aggregates all the
gridded variables in `ds_tas` (the `tas_adj` and `tas_sq` we
calculated above) onto the county polygons. 

`aggregated` is an object specific to the `xagg` package. We need to
modify it to be usable, for example using `aggregated.to_dataset()` or
`aggregated.to_csv()`. See the `xagg` docs for more info. Here we use
`aggregated.to_dataset()` which produces an `xarray` dataset, which
will be convenient for providing a standardized output.

```python
aggregated = xa.aggregate(ds_tas, weightmap)

## Aggregate the result to the annual level
ds = aggregated.to_dataset()
ds2 = ds.groupby(ds.time.dt.year).sum()
```
````

````{tab-item} R
```R
## Shift axis of climate data to conform to stagg expectations
rr.tas.padded2 <- shift(rr.tas.padded, dx = 360)

## Calculate aggregation
county.tas <- staggregate_polynomial(data=rr.tas.padded2, daily_agg="none", time_agg='year', overlay_weights=county.weights, degree=2)
```
````
`````


## Export this as a `.csv` file to be used elsewhere

Finally, we need to export this data to be used elsewhere. For this tutorial, we want to allow a variety of tools, so we'll
export the aggregated data into a `.csv` (comma-separated value) file,
which can easily be read by R, STATA, and most other programming
tools. 

The result from `xagg` will be reshaped 'wide' - so every row is a
county, and every column is a timestep of the variables. `stagg` on
the other hand aggregates the results to the annual level and provides
each county-year as a row. We also want to output this data in a
standard form, so that the next step does not depend on the language
and library used for this step.

`````{tab-set}
````{tab-item} Python

Use `aggregated.to_dataset()` or `aggregated.to_dataframe()`,
depending on whether you'd like to continue using it in `xarray` or
`pandas`. The code below provides a standard format for the next step.

```python
ds2['STATE_FIPS'] = ds2.STATE_FIPS.astype(str)
ds2['CNTY_FIPS'] = ds2.CNTY_FIPS.astype(str)

ds2['FIPS'] = xr.apply_ufunc(np.char.add, ds2.STATE_FIPS, ds2.CNTY_FIPS)
ds2['FIPS'] = ds2.FIPS.isel(year=0).drop('year')

ds2.swap_dims({'poly_idx': 'FIPS'}).drop('poly_idx')
ds2.to_dataframe().to_csv("../data/climate_data/agg_vars.csv")
```
````

````{tab-item} R
The polynomial calculation used by `stagg` assumes a baseline
temperature of 0 C. We will now adjust this to a baseline of 20 C.

```R
## Only write out valid entries
county.tas.valid <- subset(county.tas, !is.na(order_1))

## Remove 20 deg per day
daysperyear <- table(substring(names(rr.tas), 2, 5))
county.tas.base <- data.frame(year=as.numeric(names(daysperyear)), order_1=20*as.numeric(daysperyear), order_2=(20^2)*as.numeric(daysperyear))

county.tas.final <- county.tas.valid %>% left_join(county.tas.base, by='year', suffix=c('', '.base'))

county.tas.final$tas_adj <- county.tas.final$order_1 - county.tas.final$order_1.base
county.tas.final$tas_sq <- county.tas.final$order_2 - county.tas.final$order_2.base
names(county.tas.final)[2] <- 'FIPS'

write.csv(county.tas.final, '../data/climate_data/agg_vars.csv', row.names=F)
```
````
`````
