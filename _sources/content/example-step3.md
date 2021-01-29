# Hands-On Exercise, Step 3: Aggregating the data

## Aggregating the weather data

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

## Transforming the data

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

## Create map of pixels onto polygons

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

## Aggregate values onto polygons

Using the weight map calculated above, `xagg` now aggregates all the gridded variables in `ds_tas` (the `tas_adj` and `tas_sq` we calculated above) onto the county polygons. For each county, the weighted average of the temperatures of the pixels that cover the county is calculated. Since we included population as a desired weight above, the weight for each pixel is a combination of how much of the pixel overlaps with the county and its population density. In other words, a pixel that covers more of a county and has a higher population density will be weighted more in that county's temperature average than a pixel that covers less of a county and is more sparsely populated. 

The output of this function now gives, for each county, a 10-year time series of linear and quadratic temperature, properly area- and population-weighted.  

(`aggregated` is an object specific to the `xagg` package; we need to modify it to be usable, for example using `aggregated.to_dataset()` or `aggregated.to_csv` as we do below - see the `xagg` docs for more info). 

```python
aggregated = xa.aggregate(ds_tas, weightmap)
```

## Export this as a .csv file to be used elsewhere

Finally, we need to export this data to be used elsewhere. For further processing in `python`, use `aggregated.to_dataset()` or `aggregated.to_dataframe()`, depending on whether you'd like to continue using it in `xarray` or `pandas`. 

For this tutorial, we want to allow a variety of tools, so we'll
export the aggregated data into a .csv (comma-separated value) file,
which can easily be read by R, STATA, and most other programming
tools. The data will be reshaped 'wide' by `xagg` - so every row is a
county, and every column is a timestep of the variables. 

```python
aggregated.to_csv('climate_data/agg_vars.csv')
```
