# Hands-on exercise, step 1: preparing the weather data

## Introduction

The Hands-On Exercise is a simple, real-life example of climate
econometrics. Our goal is to estimate a relationship between mortality
and temperature, building on all of the advice from this tutorial. In
the first three steps, we will prepare the combined weather and
mortality dataset, while thinking about the right structure for the
econometric model. The final step performs the regression and graphs
the result.

The potential for excess mortality driven by higher temperatures is
one of the most significant risks of climate change. When we use the
value of a stastical life (VSL) to monitize it, mortality can also be
one of the most economically costly channels of climate risk.

Several approaches are available to quantify this risk. Controlled
experiments can help us understand the response of people to heat, but
they lose the effect of real-life responses to heat (such as turning
on air-conditioning). Causes of death can be used to identify
heat-related impacts, but they may miss important indirect effects,
such as a heat weakening the immune system. We analyze reported "all
cause" mortality to get a full picture of the effects of temperature.

One consequence of this choice is that the effects of extreme cold
will also appear. In fact, in some areas, higher temperatures might
result in fewer deaths as winters become more mild. We will need to
estimate an econometric relationship that accounts for both of these
effects.

## Preparing to prepare the weather data

This section will walk you through downloading and pre-processing an example dataset, the BEST data we mentioned in the [previous section](content:best-and-chirps). "Pre-processing" data is the process through which data is standardized into a format that's easy to interpret and use in your analysis. It generally includes adapting the data into filesystem and file formats that work for your project requirements and code workflows, and, crucially, quality control and verification. 

We strongly recommend that you homogenize all your weather and climate data into the same filename and file structure system whenever possible. That way, any code you write will easily be generalizable to all the data you work with. Extra time spent pre-processing will therefore make your projects more robust and save you time later. In this section, we will save data in the CMIP format introduced in a [previous section](content:netcdf-org) on file organization (one file = one variable, coupled with a set of variable and filename conventions), which we believe works well for many common applications. 

## Filesystem organization
Please skim through the section on [code and data organization](content:code-organization) before beginning the hands-on exercise. 

For the rest of this section, we will assume you are working from a directory structure similar to what is introduced there. Specifically, we assume you will have created a folder called `../data/climate_data/`, relative to your working directory, in which to store raw climate data. 

## Downloading the data 

In our example, we will use Berkeley Earth (BEST) data. BEST data is
available as national timeseries (which weight all _geographic_ areas equally in a country, and may therefore not be useful for studying even national-level data that implicitly describes properties of populations or crops that are unequally distributed over the country) and as a 1-degree grid. Working with BEST data requires extra pre-processing steps, which will allow us to illustrate some basic data processing across a few languages. Many data products will require less pre-processing, some will require more.  

1. Go to the BEST archive, <http://berkeleyearth.org/archive/data/>
2. Scroll down to the Gridded Data (ignore the Time Series Data which
   is listed first).
3. Under Gridded Data, find "Daily Land (Experimental; 1880 –
   Recent)".
4. Download the Average Temperature (TAVG) data in 1-degree gridded
   form for 1980 - 1989.
5. Place this file (`Complete_TAVG_Daily_LatLong1_1980.nc`) in the
   `sources/climate_data` folder.

As a first pre-processing step, we will clip this file to the United
States.

## Loading the data

First, let's load all of the data into memory. This code assumes that
it (the code) is stored in a file (call it `preprocess_best.R`, `preprocess_best.m`, or
`preprocess_best.py`) in your `code/` directory, a sister to the `sources/`
directory.

`````{tab-set}
````{tab-item} R
```{code-block} R
library(ncdf4)

nc <- nc_open("../data/climate_data/Complete_TAVG_Daily_LatLong1_1980.nc")

# Display header
nc

time <- seq(as.Date("1980-01-01"), length.out=nc$dim$time$len, by="1 day")
```
````

````{tab-item} Python
```{code-block} python
import numpy as np
import xarray as xr
import datetime as dt

ds = xr.open_dataset('../data/climate_data/Complete_TAVG_Daily_LatLong1_1980.nc')

# Display header
ds

# Create time variable, which wasn't auto-generated from the netcdf 
# due to BEST's ambiguous timing
ds['time'] = (
    ('time'),dt.datetime(1980,1,1)+np.arange(0,ds.dims['time'])*dt.timedelta(days=1))
```
````

````{tab-item} Matlab
```{code-block} matlab
data_dir = '../data/climate_data/';
filename = 'Complete_TAVG_Daily_LatLong1_1980.nc';

% Display header
ncdisp([data_dir,filename])
	   
clim_tmp = ncread([data_dir,filename],'climatology');
anom_tmp = ncread([data_dir,filename],'temperature');
doy_tmp = ncread([data_dir,filename],'day_of_year');

% Also loading the "months" variable - most datasets won't have this, but
% it will make more sophisticated projecting methods easier. This is
% particularly useful because of the gregorian calendar (which includes
% leap days, and therefore would otherwise add an extra step to
% determining which month each datastep is)
months = ncread([data_dir,filename],'month');
```
````
`````
Note that we also printed the NetCDF file's [header](content:netcdf-header). This allows us to inspect the contents of the file and the variables. Note, for example, that the units of the variable `temperature` are $^\circ$C, not K as is often the case for weather data. 

## Constructing temperature levels

The variable `temperature` in BEST is actually the temperature
_anomaly_; the actual temperature is formed by adding it to the
`climatology` variable. Unfortunately, the `climatology` variable only
accounts for days 1:365 of the year, and ignores leap days (which the
`temperature` variable does not). This section doubles the climatology
for Feb 28th to also work on Feb 29th, and creates a `tas` variable
that's the `climatology` + `temperature`. (`tas` as a variable name 
refers to "near-Surface Air Temperature", or temperature at
some reference height, usually 2 meters above the surface.)

`````{tab-set}
````{tab-item} R
```{code-block} R
doy <- ncvar_get(nc, 'day_of_year')
tas.anom <- ncvar_get(nc, 'temperature')
tas.clim <- ncvar_get(nc, 'climatology')

tas.clim.all <- tas.clim[,, doy]
tas <- tas.anom + tas.clim.all
```
````

````{tab-item} Python
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

````{tab-item} Matlab
```{code-block} matlab
% BEST data is given in terms of anomalies from the underlying
% climatology. So, the climatology has to be loaded first.
tas = anom_tmp + clim_tmp(:,:,doy_tmp); 

clear clim_tmp, anom_tmp, doy_tmp
```
````
`````

## Subset it geographically

We can drop a lot of the global data. This can also happen earlier in
the process.

Using the extreme points of the continental United States (see e.g., [here](https://en.wikipedia.org/wiki/List_of_extreme_points_of_the_United_States)) + 1 degree of wiggle room.

`````{tab-set}
````{tab-item} R
```{code-block} R
lon <- ncvar_get(nc, 'longitude')
lat <- ncvar_get(nc, 'latitude')

latlims = c(23, 51)
lonlims <- c(-126,-65)

tas2 <- tas[lon >= lonlims[1] & lon <= lonlims[2], lat >= latlims[1] & lat <= latlims[2],]
```
````

````{tab-item} Python
```{code-block} python
geo_lims = {'latitude':slice(23,51),'longitude':slice(-126,-65)}

ds = ds.sel(**geo_lims).load()
```
````

````{tab-item} Matlab
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
`````

## Verify the data
This is a good moment to take a look at your data, to make sure it downloaded correctly and that your pre-processing code did what you expected it to. The simplest way to do so is to plot your data and inspect it visually. 

From the section on [Basic Visualization of Climate and Weather Data](content:basic-visualization):

`````{tab-set}
````{tab-item} python
Let's plot a time series of the closest grid cell to Los Angeles, CA:
```{code-block} python
ds.tas.sel(longitude=-118.2,latitude=34.1,method='nearest').plot()
```
Does the time series look reasonable (for example, do the temperatures match up with what you expect temperatures in LA to look like)? Are there any missing data? Is there a trend? 

Let's also look at the seasonal cycle of temperature as well: 
```{code-block} python
# Plot the day-of-year average
(ds.tas.sel(longitude=-118.2,latitude=34.1,method='nearest').
 groupby('time.dayofyear').mean()).plot()
```
What can you say about the seasonality of your data? 

Now, let's plot a map of the average summer temperature of our data: 
```{code-block} python
from cartopy import crs as ccrs
from matplotlib import pyplot as plt

# Create a geographic axis with the Albers Equal Area projection, a 
# commonly-used projection for continental USA maps
ax = plt.subplot(projection=ccrs.AlbersEqualArea(central_longitude=-96))

# Get average summer temperatures, by using boolean subsetting to 
# subset time to just the months June, July, and August, and then 
# taking the average over all JJAs 
ds_summer = ds.isel(time=(ds.time.dt.season=='JJA')).mean('time')

# Plot contour map of summer temperatures, making sure to set the 
# transform of the data itself (PlateCarree() tells the code to intepret
# x values as longitude, y values as latitude, so it can transform 
# the data to the AlbersEqualArea projection)
ds_summer.tas.plot.contourf(transform=ccrs.PlateCarree(),levels=21) 

# Add coastlines, for reference
ax.coastlines()
```
Does the map look reasonable to you? For example, do you see temperatures change abruptly at the coasts? Did you subset the data correctly? Why do you think there are a few 'missing' pixels in the northern USA (remember, this dataset is land-only)? 
````

````{tab-item} Matlab
Let's plot a time series of the closest grid cell to Los Angeles, CA:
```{code-block} matlab
% Find the closet lat / lon indices to LA
[~,lat_idx] = min(abs(lat-34.1))
[~,lon_idx] = min(abs(lon-(-118.2)))
% Plot a time series of that grid cell
plot(squeeze(tas(lon_idx,lat_idx,:)))
```
Does the time series look reasonable (for example, do the temperatures match up with what you expect temperatures in LA to look like)? Are there any missing data? Is there a trend? 

Let's also look at the seasonal cycle of temperature as well: 
```{code-block} matlab
# Plot the first year of data
plot(squeeze(tas(lon_idx,lat_idx,1:365)))
```
What can you say about the seasonality of your data? 

Now, let's plot a map of the average temperature of our data: 
```{code-block} matlab
% Set an equal-area projection
axesm('eckert4') 

% Plot time-mean data 
pcolorm(lat,lon,squeeze(mean(tas,3).'); shading flat 

% Add coastlines
coasts=matfile('coast.mat')
geoshow(coasts.lat,coasts.long)
```
Does the map look reasonable to you? For example, do you see temperatures change abruptly at the coasts? Did you subset the data correctly? 

````
`````

## Save the result

We will write out the clipped, concatenated data to a single file for
future processing. We make some changes in the process to conform to
the CMIP file system standards, for ease of future processing.

`````{tab-set}
````{tab-item} R
```{code-block} R
# Set output filename of your pre-processed file
output_fn <- "../data/climate_data/tas_day_BEST_historical_station_19800101-19891231.nc"

# Define dimensions
dimlon <- ncdim_def("lon", "degrees_east", lon[lon >= lonlims[1] & lon <= lonlims[2]], longname='longitude')
dimlat <- ncdim_def("lat", "degrees_north", lat[lat >= latlims[1] & lat <= latlims[2]], longname='latitude')
dimtime <- ncdim_def("time", "days since 1980-01-01 00:00:00", as.numeric(time - as.Date("1980-01-01")),
                     unlim=T, calendar="proleptic_gregorian")

# Define variable with the dimensions listed above
vartas <- ncvar_def("tas", "C", list(dimlon, dimlat, dimtime), NA, longname="temperature")

# Create netcdf vile
ncnew <- nc_create(output_fn, vartas)
# Add the variable data
ncvar_put(ncnew, vartas, tas2)

# Close file
nc_close(ncnew)
```
````

````{tab-item} Python
```{code-block} python
# Set output filename of your pre-processed file
output_fn = '../data/climate_data/tas_day_BEST_historical_station_19800101-19891231.nc'

# Add an attribute mentioning how this file was created
# This is good practice, especially for NetCDF files, 
# whose metadata can help you keep track of your workflow. 
ds.attrs['origin_script']='preprocess_best.py'

# Rename to lat/lon to fit CMIP defaults
ds = ds.rename({'latitude':'lat','longitude':'lon'})

ds.to_netcdf(output_fn)
```
````

````{tab-item} Matlab
```{code-block} matlab
% Set output filename of your pre-processed file
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
ncwriteatt(fn_out,'/','calendar','gregorian')

% Add an attribute mentioning how this file was created
% This is good practice, especially for NetCDF files, 
% whose metadata can help you keep track of your workflow. 
ncwriteatt(fn_out,'/','origin_script','preprocess_best.m')
```
````
`````
Now you can start working with the downloaded data! We'll come back to using this file in [Step 3](content:hands-on3) of the Hands-On Exercise. 
