# Using Weather and Climate Data

```{admonition} Key objectives and decision points
:class: note
Objectives:

- Understand how to work with data in the NetCDF format in your preferred language.
- Understand the differences between reanalysis and interpolated data products.
- Learn how to find information evaluating these data products for the variables and regions that are relevant for your work.
- Learn how to identify major uncertainties inherent to different types of weather data products.

Decision points:

 - How to choose climate or weather data to use in your research project?
```

This section will introduce you to the right questions to ask when deciding on climate or weather data to use in your research. It will cover how to deal with a commonly used weather and climate data format in multiple languages, understanding the differences between gridded weather data products, finding evaluations of weather data products, examples on how to do download several different weather data products, and a few warnings on common biases in weather data, especially precipitation. 

When using weather data as independent variables in an economic model, or climate data to project your research results into the future, please keep in mind that:

- There is no universally *right* or *correct* weather or climate data product.
- Every weather or climate data product has its use cases, limitations, uncertainties, and quirks.

## The NetCDF Data Format

We start off this section with a guide to the [NetCDF](https://climatedataguide.ucar.edu/climate-data-tools-and-analysis/NetCDF-overview) format, a common data format used for weather and climate data. Most weather and climate datasets will be published primarily or additionally in the NetCDF format. It's efficient, self-describing, and supported by any major programming language, though you’ll have to pre-process data into another format (.csv, etc.) before you can use it in STATA. If you get familiar with the commands to read the header and access data in the language you’re most comfortable with, you will be able to work with most existing climate or weather datasets.

### Your code environment

Through this section, we introduce relevant commands whenever possible for the following languages and packages:

````{tabbed} Python (xarray)

[`xarray`](http://xarray.pydata.org/en/stable/) (recommended) is a package for working with N-dimensional data that natively supports NetCDF files.

For any Python (xarray) code chunks, it's assumed that the `xarray` package is loaded as `xr`: 

```{code-block} python
import xarray as xr
```
````

````{tabbed} Matlab
MATLAB has native support for working with N-dimensional data.
````

````{tabbed} R
Support through the [ncdf4](https://cran.r-project.org/web/packages/ncdf4/index.html) package.

For any R code chunks, it's assumed the `ncdf4` package is loaded with: 

```{code-block} R 
library(ncdf4)
```
````

````{tabbed} Python (NetCDF4)
Support through the [netCDF4](https://unidata.github.io/netcdf4-python/netCDF4/index.html) module.

For any Python (NetCDF4) code chunks, it's assumed that the `NetCDF4` package is loaded as `nc`:

```{code-block} python
import netCDF4 as nc
```
````

````{tabbed} nco
[nco](http://nco.sourceforge.net) ("NetCDF operators") - it is a series of command-line tools to check the contents of a file, collate different NetCDF files, and extract individual variables without having to go through a full language. Here are a few important commands: 

- `ncview` (to display spatial data), 
- `ncks` ("nc kitchen sink" - to split or concatenate files command line), and 
- `ncdump` (to print contents of the file).
````


```{tip}
If you know several of the languages referred to in this tutorial and just want our opinion on which one to use, we suggest:
- Python (`xarray`): if you want tools specifically designed for modern uses of weather/climate data that do much of the annoying background work (dealing with different file structures, variable names, date formats, etc.) for you, at the expense of less flexibility for uncommon needs
- MATLAB: if you like a simple, bare-bones treatment of data where you are in explicit control of everything that happens, at the expense of having to be more careful with pre-processing and backend management.
```

### NetCDF Contents

The core function of NetCDF files is to store arrays. These arrays may have one dimension (e.g., time), two dimensions (e.g., latitude and longitude), three dimensions (e.g., latitude, longitude, and time), or more. The other contents of the file help you to interpret these arrays.

NetCDF files have three kinds of information:

- *Attribute*: Documentation information, associated with either individual variables or the file as a whole ("global attributes"). Each attribute has a name (e.g., `version`) and text content (e.g., "Someone to Lean On").
- *Variables*: The arrays themselves, containing the data you want. Each array has an order of dimensions. For a two-dimensional array, the first dimension corresponds to the rows and the second dimension to the columns.
- *Dimensions*: The dimensions information in a NetCDF shows how many elements are spanned by each dimension. For example, a file containing a 1-degree grid over the world may have a `lon` dimension of length 360 and a `lat` dimension with length 180.
  
Typically, dimensions will have their own variables (generally with the same name). These variables give you the value of each index in the dimension. For example, if there is a `lon` dimension with length 360, there will usually be a `lon` variable, which is a 1-dimensional array. Its contents would look something like `[-179.5, -178.5, -177.5, ..., 179.5]`.

### NetCDF File Organization

The NetCDF file structure is self-describing, meaning all the information you need to understand the data is contained within the file as well (in theory). *However*, the format doesn’t *require* any specific information to be included apart from variables and dimensions. The names of attributes, which attributes are included, etc., may vary between files.

````{note}
There are unfortunately few general filesystem standards used when publishing historical weather data. Climate model ouptut, on the other hand, will generally be standardized to the format used by CMIP (the "Coupled Model Intercomparison Project," a [‘model intercomparison project’](https://www.wcrp-climate.org/wgcm-cmip) in which different modeling groups agree to run their climate models on identical climate ‘experiments’ and publish their data in a uniform format; CMIP6 is the latest generation of the largest 'MIP', analysis of which makes up a substantial portion of IPCC reports).

For example, depending on its age, climate data you will encounter will generally follow a CMIP6 filename format, of the form:

`[variable shorthand]_[frequency]_[model name]_[experiment]_[run]_[grid label]_[timeframe].nc`

or a CMIP5 filename format, of the form:

`[variable shorthand]_[frequency]_[model name]_[experiment]_[run]_[timeframe].nc`

(This terminology will also be useful to recognize even when filenames are not of this format, as is likely for weather data products.)

- some commonly encountered **variable shorthands:**
    - `tas` = temperature; “[air] temperature at surface,” which is different from “surface temperature” (the temperature of the ground) or temperature at other heights. Sometimes also listed as `t2m` for 2m air temperature or `TREFHT` for reference height temperature. (Always assumed to be taken a few feet off the ground to avoid confusing air temperature with the surface radiating temperature)
    - `pr` = precipitation rate
- **frequency**: e.g. *day* for daily
- **experiment**: some descriptor of the forcing (e.g., profile of greenhouse gases), e.g., *rcp85* for the RCP8.5 scenario frequently used in projections.
- **run**: if the same model was run multiple times with the same forcing, but different physics or initial conditions, it will be noted here (e.g. *r1i1p1*). Don’t worry about this.
- **grid label**: whether data was regridded from the model's native grid
- **timeframe**: frequently in `yyyymmdd-yyyymmdd` format.

```{seealso}
For more information on "CMIP5" and "CMIP6" terminology, see: [CMIP6 Guidance for Data Users](https://pcmdi.llnl.gov/CMIP6/Guide/dataUsers.html) or the [CMIP5 Standard Output](https://pcmdi.llnl.gov/mips/cmip5/requirements.html).
```
````

Weather and climate variables in NetCDF files may be organized in a few different ways:

- one variables per file: each file contains a single variable over the whole (or some large subset) of the time domain
- one timestep per file: each file contains a single timestep with a suite of variables
- combination: file contains many variables over a large time domain (rare due to size constraints)

To figure out which file saving convention your NetCDF file uses, and what is contained, check the header of the file:

### The NetCDF Header

NetCDF files are self-describing, meaning that the file itself contains descriptive information about the data contained within. Every NetCDF file has a header that describes these contents. This will often be the first aspect of the file you look at, to verify the file has the variables you need, in what order the dimensions of the variables are stored, what the variables are named, etc. Here are the commands to print the header for NetCDF filename `fn`: 

````{tabbed} Python (xarray)
```{code-block} python
ds = xr.open_dataset(fn)
ds
```
````

````{tabbed} Matlab
```{code-block} matlab
ncdisp(fn)
```
````

````{tabbed} R
```{code-block} R
ncfile <- nc_open(fn)
ncfile
```
````

````{tabbed} Python (NetCDF4)
```{code-block} python
ds = nc.Dataset(fn)
ds
```
````

````{tabbed} nco
```{code-block} 
# 
ncdump -h fn
```
````

The header will contain ‘global attributes,’ which are just text fields containing housekeeping information (information specifying the institution that created the file, copyright information, etc.). Then, for each variable contained within the file, the header specifies the names and sizes of their dimensions, plus any variable-specific attributes, like units.

Use the header to check what your desired variable is called, and what dimensions it has. The header can also be used to verify the order of dimensions that a variable is saved in - for a 3-dimensional variable, `lon,lat,time` is common, but some files will have the `time` variable first. 

### Attributes

Here are some important common “attributes” of NetCDF files or variables:

- **Units** - generally attached to the variable in question. Common variable units:
    - *Temperature* - almost always in Kelvin
    - *Precipitation* - often in *kg/m^2s*, which is the SI unit for precipitation rate (volume per time). Multiply by 3600 to get mm/hour, or 141.7323 to get in/hour (the density of water is 1000 kg/m^3, multiplying by the density calculates the rate in m/s, or depth/time - the rest is just accounting to your desired units of depth and time).
- **Missing / Fill Value** - if there are some absurdly high or low values in your data, you may want to check if those just represent the missing / fill value, a common sub-attribute of variables. Data may also be stored in ["masked arrays"](https://currents.soest.hawaii.edu/ocn_data_analysis/_static/masked_arrays.html).
- **Calendar** - probably the most important and inconsistent attribute for climate data (for historical ‘weather’ data products, one would hope it just follows the Gregorian calendar). Either global, or attached to the “record-keeping dimension” (`time` ). Common formats include
    - *365_day* / *noleap* / *365day* / *no_sleap* / etc. - the years are magically shortened so they all have 365 days (most common for climate data)
    - *gregorian* / *proleptic_gregorian* - modern calendar with leap years
    - *360_day* - rare calendar in which the year has 360 days (so all months have equal lengths). To my knowledge, the Hadley Model is the only major recent model to use this, but be aware of its existence.


### Reading NetCDF data

NetCDF files can be easily imported as numeric data in any language. Here are some common ways, for the variable `var`:

````{tabbed} Python (xarray)
```{code-block} python
ds = xr.open_dataset(fn)
ds.var
```

`xr.open_dataset(fn)` prepares to load all variables contained in `fn` into a [Dataset](http://xarray.pydata.org/en/stable/data-structures.html#dataset), which allows you to conduct operations across all variables in the file. `ds.var` extracts the variable named `'var'` specifically, into a [DataArray](http://xarray.pydata.org/en/stable/data-structures.html#dataarray). Data is loaded 'lazily,' meaning only variable information (not content) is loaded until calculations are done on them. To force loading, run `ds.load()`.
````

````{tabbed} Matlab
```{code-block} matlab
var = ncread(fn,'var');
```
````

````{tabbed} R
```{code-block} R
ncfile <- nc_open(fn)
var <- ncvar_get(ncfile,'var')
```
````

````{tabbed} Python (NetCDF4)
```{code-block} python
ncf = nc.Dataset(fn)
var = ncf.variables['var'][:]
```

`ncf.variables[var]` returns a `float` object that keeps the attributes from the NetCDF file
````
(content:loading-netcdf)=
#### Loading a subset of a NetCDF file
NetCDF files can be partially loaded, which is particularly useful if you only need a geographic or temporal subset of a variable. Unless you are using `xarray` (which allows you to refer to dimensions by name), make sure you confirm the order of dimensions first by reading the NetCDF header, to avoid subsetting the wrong dimension. 

The following example assumes `fn` is a file containing a 3-dimensional (`lon,lat,time`) variable called "`'var'`", and extracts a 5 x 5 pixel time series for 365 time steps:

````{tabbed} Python (xarray)
Data is loaded lazily and only fully loaded when calculations are done, so you can slice (subset) data without loading it into memory. Slicing can be done by time, variable, etc.

```{code-block} python
ds = xr.open_dataset(fn))
ds = ds.loc[0:5,0:5,0:365]

# or, if you know the dimension variables (e.g. lat, lon, time):
ds = ds.isel(lat=slice(0,5),lon=slice(0,5),time=slice(0,5))

# or, if you know the values of the dimensions you want - this command
# would roughly subset your dataset to the continental United States
# and the years 1979 to 2010.
# (note the use of "sel" vs. "isel" above)
ds = ds.sel(lat=slice(22,53),lon=slice(-125,-65),time=slice('1979-01-01','2010-12-31'))
```
````

````{tabbed} Matlab
```{code-block} matlab
% in the format ncread(filename,variable name,start idx,count)
var = ncread(fn,'var',[1 1 1],[5 5 365]);
```
````

````{tabbed} R
```{code-block} R
ncfile <- nc_open(fn)
vardata <- ncvar_get(ncfile, var, start=c(1,1,1), count=c(5,5,365))
```
````

These files also include variables that give values for indices along each dimension (`lon, lat` / `location` and `time`), which can be extracted like any other variable using the functions listed above. In some cases, these may be listed as `lat`, `latitude`, `Latitude`, `Lat`, `latitude_1`, `nav_lat`, and any number of other names. Therefore, make sure to first double-check the name of those dimensions in the NetCDF header. 

```{note}
Longitude can be either of the form `-180:180` or `0:360`. In the latter form, `359` is 1$^\circ$W and so forth. 
```

The `time` variable can also be listed in a few different formats. An integer representation of “days since [some date, often 1850-01-01]” is common, as is an integer representation of the form [YYYYMMDD], among others. The key is to always check the description of the variable in the header, and adjust your methods accordingly until it’s in a format you want it in. If you're using python, the `xarray` package has the ability to interpret some of these time representations for you and translates them into the `datetime64` class, which makes some kinds of manipulation, like [averaging over months](http://xarray.pydata.org/en/stable/time-series.html), easier.

Now that you have loaded your weather and climate data, good practice is to double-check that it downloaded and processed correctly. Common red flags include suspiciously many `NA` / `NaN` values, suspiciously high or low values, or variables that unexpectedly don't line up with geographic features. Plotting your data can be a good first order check: 

### Basic Visualization of Climate and Weather Data

To diagnose your data or to illustrate the weather and climate data used in your model, you will likely want to create plots and maps. The following is a very high-level overview; more detailed guides include:

📚 ["Earth and Environmental Science with python" guide](https://earth-env-data-science.github.io/intro.html)
: A great guide to working with `xarray` in general, but also to plotting geographic data with `xarray` and `cartopy`, especially the section on ["Making Maps with Cartopy"](https://earth-env-data-science.github.io/lectures/mapping_cartopy.html])

📚 ["Visualizing and Processing Climate Data Within MATLAB"](https://climate.copernicus.eu/visualising-and-processing-climate-data-within-matlab)
: A guide to plotting climate data using MATLAB, created by the institute that publishes [ERA5](content:working-with-era5)


#### 2-Dimensional Plotting

Assuming that your data is loaded and named as it is in the [section above](content:loading-netcdf), the following example shows how to plot the time series of a single pixel of your variable "`var`", or an average across all pixels.  

````{tabbed} Python (xarray)

```{code-block} python
# This will plot a time series of the first lat/lon pixel
ds.var.isel(lon=0,lat=0).plot()

# This will plot a time series of the pixel at 23N, 125W
ds.var.sel(lon=-125,lon=23).plot()

# This will plot the average time series over all lat/lon points
ds.var.mean(('lat','lon')).plot()
```
````

````{tabbed} Matlab
As before, we're assuming the variable `var` is in the form `lon,lat,time`.
```{code-block} matlab
% This will plot a time series of the first lat/lon pixel
plot(squeeze(var(1,1,:)))

% This will plot the average time series over all lat/lon points
plot(squeeze(mean(mean(var,1),2)))
```
````

#### Maps 

Weather and climate data is generally geographic in nature; you're therefore likely to want or need to create maps of your variables. Maps can also offer an easy first-order check to see if your data subset correctly. Assuming that yoour data is loaded and named as it is in the [SECTION ABOVE XXXX], the following example shows how to plot a map of a single timestep of your variable "`var`" or an average across all timesteps.

````{tabbed} Python (xarray)

```{code-block} python
## Example without geographic information: 
# To plot a heatmap of your 3-dimensional variable 
# at the first timestep of the data
ds.var.isel(time=0).plot()
# To plot a heatmap of your variable, averaged across
# all timesteps
ds.var.mean('time').plot()


## Example with geographic information:
import cartopy.crs as ccrs
from matplotlib import pyplot as plt    
ax = plt.axes(projection=ccrs.EckertIV()
ds.var.isel(time=0).plot(transform=ccrs.PlateCarree()
ax.coastlines()
# (to plot the time mean, use 
# ds.var.mean('time').plot(transform=ccrs.PlateCarree())
```
````

````{tabbed} Matlab
As before, we're assuming the variable `var` is in the form `lon,lat,time`.
```{code-block} matlab
% To plot a heatmap of your 3-dimensional variable 
% at the first timestep of the data
pcolor(squeeze(var(:,:,1)).'); shading flat
%  To plot a heatmap of your variable, averaged across
% all timesteps
pcolor(squeeze(mean(var,3)).'); shading flat

% Alternatively, with geographic information:
axesm('eckert4') % Set desired projection in the function call; i.e. 'eckert4'
pcolorm(lat,lon,squeeze(tas(:,:,1)).'); shading flat 
% coast.mat is included with Matlab installations; this will add coastlines. 
coasts=matfile('coast.mat')
geoshow(coasts.lat,coasts.long)
```
````


## Gridded Data

Weather data is traditionally collected at weather stations. Weather stations are imperfect, unevenly distributed point sources of data whose raw output may not be suitable for economic and policy applications. Weather readings may be biased - for example, rain gauges tend to [underestimate](https://journals.ametsoc.org/view/journals/apme/58/10/jamc-d-19-0049.1.xml) peak rainfall, and air temperature sensors often become [more inaccurate](https://journals.ametsoc.org/view/journals/atot/21/7/1520-0426_2004_021_1025_saeeia_2_0_co_2.xml) at extreme temperatures.

Weather stations are more likely to be located in wealthier and more populated areas, which makes them less useful for work in developing countries or for non-human variables such as agriculture. Their number and coverage constantly changes, making it difficult to compare across regions or time ranges. Despite being the most accurate tool for measuring the current weather at their location, they may hide microclimates nearby.

Thankfully, a large suite of data products have been developed to mitigate these issues. These generally consist of combining or ‘assimilating’ many data sources and analysis method into a ‘gridded dataset’ - the earth is divided into a latitude x longitude (x height) grid, and one value for a variable (temperature, precipitation, etc.) is provided at each gridpoint and timestep. These data products generally cover either the whole globe (or all global land), or are specialized to a certain region, and provide consistent coverage at each grid point location. 

```{note}
Some variables, especially relating to hydrology, may be better suited to station data, by providing single values for large regions such as river basins
```

However, since the world is not made up of grids (i.e. the world is not broken up into 50 x 50 km chunks, within which all weather conditions are identical), some processing has to be done even for historical “weather” data, and other limitations arise. For historical data, this processing is one of the sources of differences between data products, and for climate data, the simulation of sub-grid processes is the greatest source of uncertainty between models.

```{note}
Keep in mind that just because a dataset exists at a certain resolution, does not mean it is accurate at that resolution! 
```

The next section will briefly introduce how these products are generated, how to choose between them, and best practices for using “historical” data.

## Gridded Weather Data Products

**The Interpolation - Reanalysis Spectrum:**
Historical data products differ by how they ["assimilate"](https://climatedataguide.ucar.edu/climate-data/atmospheric-reanalysis-overview-comparison-tables) (join observational with model data) or combine data, and how much “additional” information is added beyond (pre-processed) station data. They can be thought of as a rough spectrum ranging from ‘observational’ data products that merely statistically interpolate data into a grid to ‘reanalysis’ products that feed data products into a sort of climate model to produce a more complete set of variables. Some datasets are observational but include topographic and other physical information in their statistical methods, while some reanalysis datasets use pure model output for only some variables.

Both ends of their spectrum have tradeoffs, and generalizable statements about these tradeoffs are hard to make because of differences in methodologies. The following are a few simplified rules of thumb:

### “Observational” / Interpolated Datasets
Examples: GISTEMP, GHCN, Wilmot and Matsuura (aka “UDel”), Berkeley Earth (aka “BEST”), HadCrut4, PRISM, CHIRPS, etc.

- Observations are statistically interpolated into a grid with little or no physical information added (though topography and - less commonly - wind speed are occasionally included)
- Products generally differ by which stations or other data sources are included and excluded

```{panels}
Strengths
^^^
- Simple, biases well-understood
- High correlation with source station data in areas with strong station coverage
---
Weaknesses
^^^
- Less realistic outside areas with strong station coverage
- Statistical interpolation means data not bound by physicality
- Often only available at lower temporal resolution (e.g. monthly)
```

```{seealso}
See also UCAR's Model Data Guide [summary](https://climatedataguide.ucar.edu/climate-data/global-temperature-data-sets-overview-comparison-table) on temperature datasets.
```

### Reanalysis Datasets

Examples: ERA-INTERIM, ERA5, JRA-55, MERRA-2, NCEP2 (outdated), etc.

- Observational data are combined with climate models to produce a full set of atmospheric variables
- Products differ by what data is included (as with interpolated datasets), but now also differ by which underlying models are used

```{panels}
Strengths
^^^
- Large extant literature on most major reanalysis products; limitations are generally well-understood (though not always well-estimated; and biases are often tested against interpolated datasets)
- Coverage in areas with low station coverage (generally poorer or less populated areas) is more physically reasonable
- Covers a large number of variables (though uncertainties differ between them)
---
Weaknesses
^^^
- Limited by often significant biases in underlying models that may or may not be well understood
- Accuracy in areas of high station density may be lower than in interpolated products
- Not fully physical either - laws of conservation e.g. are often relaxed
```

```{seealso}
See also UCAR's Model Data Guide [summary](https://climatedataguide.ucar.edu/climate-data/atmospheric-reanalysis-overview-comparison-tables) on reanalyses.
```

### Regional Datasets
Observational datasets exist with both global coverage (e.g. GISTEMP, HadCRUT, etc.) or regional coverage (e.g. PRISM in North America, TRMM in the tropics, etc.). Global datasets attempt to build a self-consistent database spanning the whole globe, and are therefore more likely to have sparser data coverage in specific regions - both as a logistical limitation, but also to ensure data pre-processing is as standardized as possible. Regional datasets may provide higher-resolution coverage and more specialized methodologies by incorporating local climatological knowledge or data sources that are not publicly available or parsable by global datasets (see e.g. the discussion in [Dinku et al. 2019](http://www.sciencedirect.com/science/article/pii/B9780128159989000075)). 

### Using Gridded Weather Data
On the [next page](content:working-with-data), we will get into how to choose and work with weather data products - but before that, we'd like to leave you with two warnings on using [hydrological variables](content:warning-on-hydrological) and using [station data](content:station-data).


(content:warning-on-hydrological)=
## A Warning on Hydrological Variables (Precipitation, Humidity, etc.)
![Hi, I'm your new meteorologist and a former software developer. Hey, when we say 12pm, does that mean the hour from 12pm to 1pm, or the hour centered on 12pm? Or is it a snapshot at 12:00 exactly? Because our 24-hour forecast has midnight at both ends, and I'm worried we have an off-by-one error.](https://imgs.xkcd.com/comics/meteorologist.png)

*[XKCD](https://imgs.xkcd.com/comics/meteorologist.png) describing several common dilemmas when using rain data*

Precipitation is a special beast. It is spatiotemporally highly heterogeneous (it can rain a lot in one place, and not rain at all on the other side of the hill, or an hour or a minute later) and difficult to measure accurately. Unfortunately, since rain (or lack thereof) can have tremendous impacts on humans, we often have to find ways to work with rain observations.

![Data from [Bosliovich et al. (2015)](https://gmao.gsfc.nasa.gov/pubs/docs/Bosilovich785.pdf); gridded data products disagree on average global monthly precipitation by up to 40%, and aren't always consistent!](images/global_monthly.png)
*Data from [Bosilovich et al. (2015)](https://gmao.gsfc.nasa.gov/pubs/docs/Bosilovich785.pdf); gridded data products disagree on average global monthly precipitation by up to 40%, and aren't always consistent!*

Unlike temperature, which is relatively uniform spatiotemporally and can be interpolated with a relatively high degree of confidence, precipitation data is very difficult to interpolate and requires a more sophisticated understanding of regional precipitation patterns to assimilate into gridded products. Consequently, gridded precipitation data should be used with ["extreme caution"](https://climatedataguide.ucar.edu/climate-data/atmospheric-reanalysis-overview-comparison-tables), and its uncertainties should not be underestimated. 

Even 'raw' precipitation data from weather stations and rain gauges are problematic. Developing a reliable, easily scaled rain gauge network is a difficult task. For example, a common type of rain gauge, the 'tipping bucket', only records rain in discrete intervals (when the bucket fills and subsequently 'tips'), and therefore could record a rainstorm if a drizzle tips an already-full bucket. In rare cases, tipping buckets stationed in remote areas may be stuck in the "tipped" position for some time before anyone notices or can repair them.

In general, rain gauges of most types are biased low. In strong wind conditions, many drops may not enter the rain catch in a gauge due to turbulence; in strong storms, point estimates may miss areas of greatest intensity. Rain data averaged over areas with complex terrain is biased because of the vertical profile of precipitation (stations are generally in valleys). Kenji Matsuura (of the UDel dataset fame) in his [expert guidance](https://climatedataguide.ucar.edu/climate-data/global-land-precipitation-and-temperature-willmott-matsuura-university-delaware) on his dataset explains: “Under-catch bias can be nontrivial and very difficult to estimate adequately, especially over extensive areas...”

Bias-correcting is integrated into weather data products, often involving assimilation of multiple data sources (satellites, radar, etc.) but significant biases remain (see above Figure).

Precipitation is often recommended as a control in economic models, but its unique character makes it difficult to work with. Beyond the strong uncertainty in precipitation data, precipitation is highly non-gaussian and its correlation with temperature is time- and space- dependent. When using precipitation in your model, be aware of its limitations, check robustness against multiple data products, or on geographic subsets that have better station coverage and potentially less biased data. Make sure to read studies evaluating your chosen data product - for example [Dinku et al. 2018](https://rmets.onlinelibrary.wiley.com/doi/abs/10.1002/qj.3244) for CHIRPS in Eastern Africa (a useful Google Scholar search for any product could be "[data product name] validation OR evaluation OR bias OR uncertainty"). Finally, make sure you think about what role precipitation plays in your model - see [choosing weather variables](content:choosing-weather-variables)!

(content:station-data)=
## Station Data

Station data (e.g. [Global Historical Climatology Network (GHCN)](https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/global-historical-climatology-network-ghcn) and the Global Summary of the Day) *can* be useful in policy and economic applications, and has been frequently used by especially older studies in the field. It provides a high degree of accuracy in areas of high station density, which generally corresponds to areas with a higher population density and a higher income level. Especially if you are working with urban areas, station data will likely capture the urban heat island effect more accurately than any gridded product. 

However, station data can’t be seen as the ‘true’ weather either; assumptions and calibration methodologies affect data here as well (see e.g. [Parker 2015](https://journals.ametsoc.org/doi/full/10.1175/BAMS-D-14-00226.1)), some variables remain rather uncertain, and the influence of microclimates even in close proximity to stations shouldn’t be underestimated (think for example the Greater Los Angeles region, where temperature can vary up to 35 F between the inland valleys and the coast).

```{admonition} Do not interpolate data yourself
:class: warning
Under normal circumstances, do not try to interpolate data yourself. Interpolated and reanalysis data products covered above were specifically designed for this purpose and have vetted methodologies and publicly available citable diagnostics and uncertainties.
```
