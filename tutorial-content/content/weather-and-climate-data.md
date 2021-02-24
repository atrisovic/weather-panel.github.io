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

The [NetCDF](https://climatedataguide.ucar.edu/climate-data-tools-and-analysis/NetCDF-overview) format is a common data format used for weather and climate data. Most weather and climate datasets will be published primarily or additionally in the NetCDF format. It's efficient, self-describing, and supported by any major programming language, though you’ll have to pre-process data into another format (.csv, etc.) before you can use it in STATA. If you get familiar with the commands to read the header and access data in the language you’re most comfortable with, you will be able to work with most climate or weather datasets published in the world.

### Supported Languages

Throughout this section, we introduce relevant commands whenever
possible for the following languages and packages (click on the tab
names for details):

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

The core function of NetCDF files is to store arrays. These arrays may have one dimension (e.g., a vector of years), two dimensions (e.g., elevation across space), three dimensions (e.g., weather varying across space and time), or more. The other contents of the file help you to interpret these arrays.

NetCDF files have three kinds of information:

- *Attribute*: Documentation information, associated to either individual variables or the file as a whole. Each attribute has a name (e.g., `version`) and text content (e.g., "Someone to Lean On").
- *Variables*: The arrays themselves, containing the data you want. Each array has an order of dimensions. For a two-dimensional array, the first dimension corresponds to the rows and the second dimension to the columns.
- *Dimensions*: The dimensions information in a NetCDF says how many entries are in each dimension. For example, a file containing a 1-degree grid over the world would typically lave a `lon` dimension of length 360 and a `lat` dimension with length 180.
  
Typically, there will be variables that correspond to each of the dimensions, and sometimes these will have the same name as the dimension objects. These variables give you the value of each index in the dimension. For example, if there is a `lon` dimension with length 360, there will usually be a `lon` or `longitude` variable, which is an array with the single `lon` dimension, and its contents would look something like `[-179.5, -178.5, -177.5, ..., 179.5]`.

### NetCDF File Organization

The NetCDF file structure is self-describing, meaning all the information you need to understand what data are within are contained within the file as well (in theory). *However*, the format doesn’t require any information be put there, so names of attributes, which attributes are included, etc., may vary between files, especially if they’re ‘unofficial’ files not created by a major modeling group as part of a larger project.

````{note}
Some data you will be facing has standardized to something akin to the format used by CMIP output (a ‘model intercomparison project’ in which different modeling groups agreed to run their models on identical climate ‘experiments’ and publish their data in a uniform format; CMIP6 is the latest generation of the largest 'MIP', analysis of which makes up a substantial portion of IPCC reports).

For example, climate data you will encounter will generally follow a CMIP5 filename format, of the form:

`[variable shorthand]_[frequency]_[model name]_[experiment]_[run]_[timeframe].nc`

or a CMIP6 filename format, of the form:

`[variable shorthand]_[frequency]_[model name]_[experiment]_[run]_[grid label]_[timeframe].nc`

(This terminology will also be useful to recognize even when filenames are not of this format, as is likely for weather data products.)

- most commonly encountered **variable shorthands:**
    - `tas` = temperature; “[air] temperature at surface,” which is different from “surface temperature” (the temperature of the ground) or temperature at other heights. Sometimes also listed as `t2m` for 2m air temperature or `TREFHT` for reference height temperature. (Always assumed to be taken a few feet off the ground to avoid confusing air temperature with excess heat released by the ground)
    - `pr` = precipitation rate
- **frequency**: e.g. *day* for daily
- **experiment**: some descriptor of the forcing (e.g., profile of greenhouse gases) uses, e.g., *rcp85* for the RCP8.5 scenario frequently used in projections.
- **run**: if the same model was run multiple times with the same forcing, but different physics or initial conditions, it will be noted here (e.g. *r1i1p1*). Don’t worry about this.
- **grid label**: whether data was regridded from the model's native grid
- **timeframe**: frequently in `yyyymmdd-yyyymmdd` format.

```{seealso}
For more information on "CMIP5" and "CMIP6" terminology, see: [CMIP6 Guidance for Data Users](https://pcmdi.llnl.gov/CMIP6/Guide/dataUsers.html) or the [CMIP5 Standard Output](https://pcmdi.llnl.gov/mips/cmip5/requirements.html).
```
````

There are two common ways in which data is stored in NetCDF files:

- variables: each file contains a single variable over the whole (or a large chunk) of the time domain
- time slices: each file contains a single timestep with a suite of variables
- combination: file contains many variables over a large time domain (rare due to size constraints)

To figure out which file saving convention your NetCDF file uses, and what is contained, you can check the header of the file:

### The NetCDF Header

NetCDF files are self-describing, meaning that they contain information about the data contained within. Every NetCDF file has a header that describes these contents. This will often be the first aspect of the file you look at, to verify the file has the variables you need, in what order the dimensions of the variables are stored, etc. Here are the commands to print the header for NetCDF filename `fn`, for each mentioned tool above:

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

The header will open with ‘global attributes,’ which are just text fields that primarily tell you housekeeping information (modeling groups, copyright information, etc.). Then, for each variable contained within the file, the header will tell you what dimensions they contain and their respective sizes, plus variable-specific attributes, like units.

Use the header to check what your desired variable is called, and what dimensions it has. For a variable-focused NetCDF file (see above), the dimensions will likely be `lon,lat,time` (though always verify - some will save their data with the `time` variable first and non-gridded data may be saved as `location,time`). The file will also contain populated variables for each of these dimensions, giving the values of `lon,lat,time`  at each point (be aware - for non-rectangular grids, the *variables* `lon` and `lat` may each be 2-D arrays as well). If you are using `xarray` in python, `xr.open_dataset()` will usually be able to tell which dimensions are time, lon, lat for plotting purposes without any additional specification. 

### Attributes

Here are some important common “attributes” of NetCDF files or variables:

- **Calendar** - probably the most important and inconsistent attribute for climate data (for historical ‘weather’ data products, one would hope it just follows the Gregorian calendar). Either global, or attached to the “record-keeping dimension” (`time` ). Common formats include
    - *365_day* / *noleap* / *365day* / *no_leap* / etc. - the years are magically shortened so they all have 365 days (most common for climate data)
    - *gregorian* / *proleptic_gregorian* - modern calendar with leap years
    - *360_day* - rare calendar in which the year has 360 days (so all months have equal lengths). To my knowledge, the Hadley Model is the only major recent model to use this, but be aware of its existence.
- **Units** - generally attached to the variable in question. Common variable units:
    - *Temperature* - almost always in Kelvin
    - *Precipitation* - often in *kg/m^2s*, which is the SI unit for precipitation rate (volume per time). Multiply by 3600 to get mm/hour, or 141.7323 to get in/hour (the density of water is 1000 kg/m^3, multiplying by the density calculates the rate in m/s, or depth/time - the rest is just accounting to your desired units of depth and time).
- **Missing / Fill Value** - if there are some absurdly high or low values in your data, you may want to check if those just represent the missing / fill value, a common sub-attribute of variables. Data may also be stored in ["masked arrays"](https://currents.soest.hawaii.edu/ocn_data_analysis/_static/masked_arrays.html).

### Reading NetCDF data

NetCDF files can be easily imported as numeric data in any language. Here are some common ways, for the variable `var`:

````{tabbed} Python (xarray)
```{code-block} python
ds = xr.open_dataset(fn)
ds.var
```

Data is loaded slowly and only fully loaded when calculations are done - to force loading, run `ds.load()`
````

````{tabbed} Matlab
```{code-block} matlab
ncread(fn,var);
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
ncf.variables['var'][:]
```

`ncf.variables[var]` will return a `float` object that keeps the attributes from the NetCDF file
````


You’ll often only want or need a subset of a variable. In this case, make sure you know in what order the dimensions of the variable are saved at (see above; unless you are working with `xarray`, which handles this for you. Check the docs.). Say, if you want only a 5 x 5 x 365 subset of the data, you’d use:

````{tabbed} Python (xarray)
Data is loaded slowly and only fully loaded when calculations are done, so you can slice data without loading it into memory. Slicing can be done by time, variable, etc.

```{code-block} python
ds = xr.open_dataset(fn))
ds.loc[0:5,0:5,0:365]

# or, if you know the dimension variables (e.g. lat, lon, time):
ds.isel(lat=slice(0,5),lon=slice(0,5),time=slice(0,5))

# or, if you know the values of the dimensions you want (note "sel" vs. "isel")
ds.sel(lat=slice(22,53),lon=slice(-125,-65),time=slice('1979-01-01','2010-12-31'))
```
````

````{tabbed} Matlab
```{code-block} matlab
% in the format ncread(filename,variable name,start idx,count)
ncread(fn,var,[1 1 1],[5 5 365]);
```
````

````{tabbed} R
```{code-block} R
ncfile <- nc_open(fn)
vardata <- ncvar_get(ncfile, var, start=c(1,1,1), count=c(5,5,365))
```
````

As mentioned above, these files also include populated variables that give values for indices along each dimension (`lon, lat` / `location` and `time`), which can be extracted like any other variable using the functions listed above. In some cases, these may be listed as `lat`, `latitude`, `Latitude`, `Lat`, `latitude_1`, `nav_lat`, and any number of other names. Therefore, make sure to first double-check the name of those dimensions in the NetCDF header. As mentioned, `xarray` has built-in methods for identifying the file's dimensions, regardless of order, for plotting purposes.  

The `time` variable can also be listed in a few different formats. An integer representation of “days since [some date, often 1850-01-01]” is common, as is an integer representation of the form [YYYYMMDD], among others. The key is to always check the description of the variable in the header, and adjust your methods accordingly until it’s in a format you want it in. If you're using python, the `xarray` package has the ability to interpret some of these time representations for you and translates them into the `datetime64` class, which makes some kinds of manipulation, like averaging over months, easier.

### Diagnostic Maps of Climate Data

You may want to visualize your weather or climate data, either for internal diagnostics or for production figures showing your data. It's generally good practice to double-check that your data downloaded and processed correctly, by making sure there aren't suspiciously many NAs/NaNs, that the lat/lon grid matches up with where the data should go (first-order check: does your temperature/precipitation field trace out major land/ocean boundaries, etc.), and that the data is consistent. Here are easy ways to plot the first timestep of a gridded dataset: 

````{tabbed} Python (xarray)

```{code-block} python
# Assuming your variable is a 3-D (lat,lon,time, in any order) 
# variable called "tas", in a dataset loaded using 
# ds = xr.open_dataset() as above. This will get you a 
# "QuadMesh" image - just a heatmap of your data:
ds.tas.isel(time=1).plot()
# (for the time mean, you can use ds.tas.mean(time).plot() 
# similarly)
    
## Example with geographic information:
import cartopy.crs as ccrs    
# (see resources below on why transforms/projections 
# need to be explicitly noted)
ax = plt.axes(projection=ccrs.EckertIV()
ds.tas.isel(time=1).plot(transform=ccrs.PlateCarree()
ax.coastlines()
```

```{seealso}
For more information on plotting geographic data with `xarray` and `cartopy`, we highly recommend the ["Earth and Environmental Science" with python guide](https://earth-env-data-science.github.io/intro.html), especially the section on ["Making Maps with Cartopy"](https://earth-env-data-science.github.io/lectures/mapping_cartopy.html])
```
````

````{tabbed} Matlab

```{code-block} matlab
% Assuming your dataset is called "tas" (lon,lat,time)
% This will just plot a heatmap of your data:
pcolor(squeeze(tas(:,:,1)).'); shading flat

% Alternatively, with geographic information:
axesm('eckert4') % Set desired projection in the function call; i.e. 'eckert4'
pcolorm(lat,lon,squeeze(tas(:,:,1)).'); shading flat 
% coast.mat is included with Matlab installations; this will add coastlines. 
coasts=matfile('coast.mat')
geoshow(coasts.lat,coasts.long)
```
````


## Gridded Data

Weather data is traditionally collected at weather stations. Weather stations are imperfect, unevenly distributed point sources of data whose raw output may not be suitable for economic and policy applications. Weather stations are more likely to be located in wealthier and more populated areas, which makes them less useful for work in developing countries or for non-human variables such as agriculture. Their number and coverage constantly changes, making it difficult to weigh or to compare across regions. Despite being the most accurate tool for measuring the current weather at their location, they may hide microclimates nearby.

Thankfully, a large suite of data products have been developed to mitigate these issues. These generally consist of combining or ‘assimilating’ many data sources and analysis method into a ‘gridded dataset’ - the earth is divided into a latitude x longitude (x height) grid, and one value for a variable (temperature, precipitation, etc.) is provided at each gridpoint and timestep. These data products generally cover either the whole globe (or all global land), or are specialized to a certain region, and provide consistent coverage at each grid point location. 

```{note}
Some variables, especially relating to hydrology, may be better suited to station data, by providing single values for large regions such as river basins
```

However, since the world is not made up of grids (i.e. the world is not broken up into 50 x 50 km chunks, within which all weather conditions are identical), some processing has to be done even for historical “weather” data, and other limitations arise. For historical data, this processing is one of the sources of differences between data products, and for climate data, the simulation of sub-grid processes is the greatest source of uncertainty between models.

```{tip}
Keep in mind that just because a dataset exists at a certain resolution, does not mean it is accurate at that resolution! 
```

The next section will briefly introduce how these products are generated, how to choose between them, and best practices for using “historical” data.

## Weather Data Products

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
