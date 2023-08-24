import xarray as xr
import geopandas as gpd
import xagg as xa
import numpy as np

ds_tas = xr.open_dataset(
    'climate_data/tas_day_BEST_historical_station_19800101-19891231.nc')

# Load population data using xarray 
ds_pop = xr.open_dataset('pcount/usap90ag.nc')

# Load county shapefiles using geopandas
gdf_counties = gpd.read_file('geo_data/UScounties.shp')


ds_tas['tas_adj'] = ds_tas.tas-20
ds_tas['tas_sq'] = ds_tas.tas**2 - 20**2

# xagg aggregates every gridded variable in ds_tas - however, we don't need
# every variable currently in tas. Let'ss drop "tas" (the un-adjusted temperature)
# and "land_mask" which is included, but not necessary for our further analysis.
ds_tas = ds_tas.drop('tas')
ds_tas = ds_tas.drop('land_mask')

weightmap = xa.pixel_overlaps(ds_tas,gdf_counties,weights=ds_pop.Population,subset_bbox=False)

aggregated = xa.aggregate(ds_tas, weightmap)

## aggregated.to_csv('climate_data/agg_vars.csv')
ds = aggregated.to_dataset()
ds2 = ds.groupby(ds.time.dt.year).sum()

ds2['STATE_FIPS'] = ds2.STATE_FIPS.astype(str)
ds2['CNTY_FIPS'] = ds2.CNTY_FIPS.astype(str)

ds2['FIPS'] = xr.apply_ufunc(np.char.add, ds2.STATE_FIPS, ds2.CNTY_FIPS)
ds2['FIPS'] = ds2.FIPS.isel(year=0).drop('year')

ds2.swap_dims({'poly_idx': 'FIPS'}).drop('poly_idx')
ds2.to_dataframe().to_csv("climate_data/agg_vars.csv")
