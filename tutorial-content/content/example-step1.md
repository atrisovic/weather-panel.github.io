# Hands-On Exercise, Step 1: Preparing the Weather Data

## Downloading the data 

In our example, we will use Berkeley Earth (BEST) data. BEST data is
available as national timeseries (area-weighted, so not usually useful
even for studying national-level data) and as a 1-degree grid.

1. Go to the BEST archive, http://berkeleyearth.org/archive/data/
2. Scroll down to the Gridded Data (ignore the Time Series Data which
   is listed first).
3. Under Gridded Data, find "Daily Land (Experimental; 1880 –
   Recent)".
4. Download the Average Temperature (TAVG) data in 1-degree gridded
   form for 1980 - 1989.
5. Place this file (`Complete_TAVG_Daily_LatLong1_1980.nc`) in the
   `data/climate_data` folder.

As a first pre-processing step, we will clip this file to the United
States.

## Loading the data

First, let's load all of the data into memory. This code assumes that
it (the code) is stored in a file (call it `preprocess_best.m` or
`preprocess_best.py`) in a directory `code/`, a sister to the `data/`
directory.

````{tabbed} Python
```{code-block} python
import numpy as np
import xarray as xr
import datetime as dt

ds = xr.open_dataset('../data/climate_data/Complete_TAVG_Daily_LatLong1_1980.nc')

# Create time variable, which wasn't auto-generated from the netcdf due to BEST's ambiguous timing
ds['time'] = (('time'),dt.datetime(1980,1,1)+np.arange(0,ds.dims['time'])*dt.timedelta(days=1))
```
````

````{tabbed} Matlab
```{code-block} matlab
data_dir = '../data/climate_data/';
filename = 'Complete_TAVG_Daily_LatLong1_1980.nc';
	   
clim_tmp = ncread([data_dir,filename],'climatology');
anom_tmp = ncread([data_dir,filename],'temperature');
doy_tmp = ncread([data_dir,filename],'day_of_year');

% Also loading the "months" variable - most datasets don't have it, but
% it will make more sophisticated projecting methods easier. This is
% particularly useful because of the gregorian calendar (which includes
% leap days, and therefore would otherwise add an extra step to
% determining which month each datastep is)
months = ncread([data_dir,filename],'month');
```
````

## Constructing temperature levels

The variable `temperature` in BEST is actually the temperature
_anomaly_; the actual temperature is formed by adding it to the
`climatology` variable. Unfortunately, the `climatology` variable only
accounts for days 1:365 of the year, and ignores leap days (which the
`temperature` variable does not). This section doubles the climatology
for Feb 28th to also work on Feb 29th, and creates a `tas` variable
that's the `climatology` + `temperature`.

````{tabbed} Python
```{code-block} python
import calendar

# Expand climatology to span all days
clim_tmp = xr.DataArray(dims=('time','latitude','longitude'),
                        coords={'time':ds.time,'latitude':ds.latitude,'longitude':ds.longitude},
                        data=np.zeros((ds.dims['time'],ds.dims['latitude'],ds.dims['longitude']))*np.nan)

# Sub in variables one year at a time
for yr in np.unique(ds.time.dt.year):
    if calendar.isleap(yr):
        clim_tmp.loc[{'time':(clim_tmp.time.dt.year==yr)&(clim_tmp.time.dt.dayofyear<=59)}] = ds.climatology.values[0:59]
        clim_tmp.loc[{'time':(clim_tmp.time.dt.year==yr)&(clim_tmp.time.dt.dayofyear==60)}] = ds.climatology.values[59]
        clim_tmp.loc[{'time':(clim_tmp.time.dt.year==yr)&(clim_tmp.time.dt.dayofyear>60)}] = ds.climatology.values[59:365]
    else:
        clim_tmp.loc[{'time':(clim_tmp.time.dt.year==yr)}] = ds.climatology.values

ds['climatology'] = clim_tmp

ds['tas'] = ds['temperature'] + ds['climatology']
ds = ds.drop(['temperature','climatology'])
```
````

````{tabbed} Matlab
```{code-block} matlab
% BEST data is given in terms of anomalies from the underlying
% climatology. So, the climatology has to be loaded first.
tas = anom_tmp + clim_tmp(:,:,doy_tmp); 

clear clim_tmp, anom_tmp, doy_tmp
```
````

## Subset it geographically

We can drop a lot of the global data. This can also happen earlier in
the process.

Using the extreme points of the continental United States (see e.g. [here](https://en.wikipedia.org/wiki/List_of_extreme_points_of_the_United_States)) + 1 degree of wiggle room.

````{tabbed} Python
```{code-block} python
geo_lims = {'lat':[23,51],'lon':[-126,-65]}

ds = ds.sel(latitude=slice(*geo_lims['lat']),longitude=slice(*geo_lims['lon'])).load()
```
````

````{tabbed} Matlab
```{code-block} matlab
lat = ncread([data_dir,filename],'latitude');
lon = ncread([data_dir,filename],'longitude');

%% Subset to continental United States
lon_idxs = ((lon>=geo_lims(1)) & (lon<=geo_lims(2)));
lat_idxs = ((lat>=geo_lims(3)) & (lat<=geo_lims(4)));

tas = tas(lon_idxs,lat_idxs,:);
lon = lon(lon_idxs);
lat = lat(lat_idxs);
```
````

## Save the result

We will write out the clipped, concatenated data to a single file for
future processing. We make some changes in the process to conform to
the standards used in CMIP5 datasets.

````{tabbed} Python
```{code-block} python
output_fn = '../data/climate_data/tas_day_BEST_historical_station_19800101-19891231.nc'

ds.attrs['origin_script']='preprocess_best.py'

# Rename to lat/lon to fit CMIP5 defaults
ds = ds.rename({'latitude':'lat','longitude':'lon'})

ds.to_netcdf(output_fn)
```
````

````{tabbed} Matlab
```{code-block} matlab
% Set output filename
fn_out = '../data/climate_data/tas_day_BEST_historical_station_19800101-19891231.nc';

% Write temperature data to netcdf 
nccreate(fn_out,'tas','Dimensions',{'lon',size(tas,1),'lat',size(tas,2),'time',size(tas,3)})
ncwrite(fn_out,'tas',tas);
% These attributes aren't strictly necessary, but very helpful to have in
% the file
ncwriteatt(fn_out,'tas','long_name','near-surface air temperature');
ncwriteatt(fn_out,'tas','units','C');

% Write lat/lon data to netcdf file
nccreate(fn_out,'lat','Dimensions',{'lat',size(tas,2)})
nccreate(fn_out,'lon','Dimensions',{'lon',size(tas,1)})
ncwrite(fn_out,'lat',lat);
ncwrite(fn_out,'lon',lon);
ncwriteatt(fn_out,'lat','long_name','latitude')
ncwriteatt(fn_out,'lon','long_name','longitude')
ncwriteatt(fn_out,'lat','units','degrees')
ncwriteatt(fn_out,'lon','units','degrees')

% Write time dimension to netcdf file
time_idxs = 0:(size(tas,3)-1);

nccreate(fn_out,'time','Dimensions',{'time',size(tas,3)})
ncwrite(fn_out,'time',time_idxs)
ncwriteatt(fn_out,'time','units','days since 1980-01-01')

nccreate(fn_out,'month','Dimensions',{'time',size(tas,3)})
ncwrite(fn_out,'month',months)
ncwriteatt(fn_out,'month','units','month number')

% Write global attributes (again, not strictly necessary, but very useful);
% using the '/' name for global
ncwriteatt(fn_out,'/','variable','tas')
ncwriteatt(fn_out,'/','variable_long','near-surface air temperature')
ncwriteatt(fn_out,'/','source','Berkeley Earth Surface Temperature Project')
ncwriteatt(fn_out,'/','origin_script','preprocess_best.m')
ncwriteatt(fn_out,'/','calendar','gregorian')
```
````
