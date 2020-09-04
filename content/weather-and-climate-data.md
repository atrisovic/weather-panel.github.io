# 1. Using Weather and Climate Data

When using weather data as independent variables in an economic model, or climate data to project your research results into the future, please note:

- There is no universally *right* or *correct* weather or climate data product
- Every weather or climate data product has its use cases, limitations, uncertainties, and quirks

This section will introduce you to the right questions to ask when deciding on climate or weather data to use in your research.

## 1.1 The NetCDF Data Format

Almost all climate and weather datasets are released in [netCDF](https://climatedataguide.ucar.edu/climate-data-tools-and-analysis/netcdf-overview) format. It's efficient, self-describing, and supported by any major programming language, though you’ll have to pre-process data into another format (.csv, etc.) before you can use it in STATA. If you get familiar with the commands to read the header and access data in the language you’re most comfortable with, you will be able to work with almost any climate or weather dataset published in the world.

### Supported Languages

Through this section, when possible relevant commands for working with netCDF files are listed for:

- Matlab (native support)
- python
    - [xarray](http://xarray.pydata.org/en/stable/) (recommended) - a package for dealing with N-dimensional data that natively supports netCDF files
    - [netCDF4-python](https://unidata.github.io/netcdf4-python/netCDF4/index.html) module
- R ([ncdf4](https://cran.r-project.org/web/packages/ncdf4/index.html) package)
- [nco](http://nco.sourceforge.net) (“netCDF operators”) - command line tools
    - documentation may look overwhelming, but at its core, it’s an easy way to check the contents of a file, collate different netCDF files, and extract individual variables without having to go through a full language.
    - important commands: `ncview` (to display spatial data), `ncks` (“nc kitchen sink” - to split or
      concatenate files command line), and `ncdump` (to print contents of the file)

For any R code chunks, it’s assumed the ncdf4 package is loaded (`library(ncdf4)`). For any python code chunks, it’s assumed that the xarray package is loaded as `xr` (`import xarray as xr`) or the netCDF4-python module is loaded as `nc` (`import netCDF4 as nc`).

NB: If you know several of the languages referred to in this tutorial and just want the author's opinion on which one to use, I would suggest:
- Matlab: if you like a simple, bare-bones treatment of data where you are in explicit control of everything that happens, at the expense of having to be more careful with the background / file processing work
- python + `xarray`: if you want tools specifically designed for modern uses of weather/climate data that do much of the annoying background work (dealing with different file structures, variable names, date formats, etc.) for you, at the expense of less flexbility for uncommon needs

### netCDF Contents

The core function of NetCDF files is to store matrices. These matrices may have one dimension (e.g., a vector of years), two dimensions (e.g., elevation across space), three dimensions (e.g., weather varying across space and time), or more. The other contents of the file help you to interpret these matrices.

NetCDF files have three kinds of information:

- *Attribute*: Documentation information, associated to either individual variables or the file as a whole. Each attribute has a name (e.g., `version`) and text content (e.g., "Someone to Lean On").
- *Variables*: The matrices themselves, containing the data you want.. Each matrix has an order of dimensions. For a two-dimensional matrix, the first dimension corresponds to the rows and the second dimension to the columns.
- *Dimensions*: The dimensions information in a NetCDF says how many entries are in each dimension. For example, a file containing a 1-degree grid over the world would typically lave a `lon` dimension of length 360 and a `lat` dimension with length 180.
  
Typically, there will be variables that correspond to each of the dimensions, and sometimes these will have the same name as the dimension objects. These variables give you the value of each index in the dimension. For example, if there is a `lon` dimension with length 360, there will usually be a `lon` or `longitude` variable, which is a matrix with the single `lon` dimension, and its contents would look something like `[-179.5, -178.5, -177.5, ..., 179.5]`.

### netCDF File Organization

The netCDF file structure is self-describing, meaning all the information you need to understand what data are within are contained within the file as well (in theory). *However*, the format doesn’t require any information be put there, so names of attributes, which attributes are included, etc., may vary between files, especially if they’re ‘unofficial’ files not created by a major modeling group as part of a larger project.

But fear not: thankfully, most data you will be facing has standardized to something akin to the format used by CMIP output (a ‘model intercomparison project’ in which different modeling groups agreed to run their models on identical climate ‘experiments’ and publish their data in a uniform format; CMIP6 is the latest generation of the largest 'MIP', analysis of which makes up a substantial portion of IPCC reports).

For example, climate data you will encounter will generally follow a CMIP5 filename format, of the form:

`[variable shorthand]_[frequency]_[model name]_[experiment]_[run]_[timeframe].nc`

or a CMIP6 filename format, of the form:

`[variable shorthand]_[frequency]_[model name]_[experiment]_[run]_[grid label]_[timeframe].nc`

(This terminology will also be useful to recognize even when filenames are not of this format, as is likely for weather data products.)

- most commonly encountered **variable shorthands:**
    - `tas` = temperature; “[air] temperature at surface,” which is different from “surface temperature” (the temperature of the ground) or temperature at other heights. Sometimes also listed as `t2m` for 2m air temperature or `TREFHT` for reference height temperature. (Always assumed to be taken a few feet off the ground to minimize confusing air temperature with excess heat released by the ground)
    - `pr` = precipitation rate
- **frequency**: *day* for daily, *ann* for annual. *mon* for monthly; is sometimes listed as *Amon* for atmospheric variables; feel free to ignore this distinction.
- **experiment**: some descriptor of the forcing used (forcing = profile of greenhouse gases), e.g. *rcp85* for the RCP8.5 scenario frequently used in projections.
- **run**: if the same model was run multiple times with the same forcing, but different physics or initial conditions, it will be noted here (e.g. *r1i1p1*). Don’t worry about this.
- **grid label**: whether data was regridded from the model's native grid
- **timeframe**: frequently in `yyyymmdd-yyyymmdd` format.

(For more information on "CMIP5" and "CMIP6" terminology, please see: [CMIP6 Guidance for Data Users](https://pcmdi.llnl.gov/CMIP6/Guide/dataUsers.html) or the [CMIP5 Standard Output](https://pcmdi.llnl.gov/mips/cmip5/requirements.html))

There are two common ways in which data is stored in netCDF files:

- variables: each file contains a single variable over the whole (or a large chunk) of the time domain
- time slices: each file contains a single timestep with a suite of variables
- combination: file contains many variables over a large time domain (rare due to size constraints)

To figure out which file saving convention your netCDF file uses, and what is contained, you can check the header of the file:

### The netCDF Header

netCDF files are self-describing, meaning that they contain information about the data contained within. Every netCDF file has a header that describes these contents. This will often be the first aspect of the file you look at, to verify the file has the variables you need, in what order the dimensions of the variables are stored, etc. Here are the commands to print the header for netCDF filename `fn`, for each mentioned tool above:

| nco            | Matlab       | R                                          | python (netCDF4)               | python (xarray)                     |
| -------------- | ------------ | ------------------------------------------ | ------------------------------ | ----------------------------------- |
| `ncdump -h fn` | `ncdisp(fn)` | `ncfile <- nc_open(fn)`<br>`ncfile` | `ds = nc.Dataset(fn))`<br>`ds` | `ds = xr.open_dataset(fn))`<br>`ds` |

The header will open with ‘global attributes,’ which are just text fields that primarily tell you housekeeping information (modeling groups, copyright information, etc.). Then, for each variable contained within the file, the header will tell you what dimensions they contain and their respective sizes, plus variable-specific attributes, like units.

Use the header to check what the variable you want is called, and what dimensions it has. For a variable-focused netCDF file (see above), the dimensions will likely be `lon,lat,time` (though always verify - some will save their data with the `time` variable first and non-gridded data may be saved as `location,time`). The file will also contain populated variables for each of these dimensions, giving the values of `lon,lat,time`  at each point (be aware - for non-rectangular grids, the *variables* `lon` and `lat` may each be 2-D arrays as well). If you are using `xarray` in python, `xr.open_dataset()` will usually be able to tell which dimensions are time, lon, lat without any additional specification. 

### Attributes

Here are some important common “attributes” of netCDF files or variables:

- **Calendar** - probably the most important and inconsistent attribute for climate data (for historical ‘weather’ data products, one would hope it just follows the Gregorian calendar). Either global, or attached to the “record-keeping dimension” (`time` ). Common formats include
    - *365_day* / *noleap* / *365day* / *no_leap* / etc. - the years are magically shortened so they all have 365 days (most common for climate data)
    - *gregorian* / *proleptic_gregorian* - modern calendar with leap years
    - *360_day* - rare calendar in which the year has 360 days (so all months have equal lengths). To my knowledge, the Hadley Model is the only major recent model to use this, but be aware of its existence.
- **Units** - generally attached to the variable in question. Common variable units:
    - *Temperature* - almost always in Kelvin
    - *Precipitation* - often in *kg/m^2s*, which is the SI unit for precipitation rate (volume per time). Multiply by 3600 to get mm/hour, or 141.7323 to get in/hour (the density of water is 1000 kg/m^3, multiplying by the density calculates the rate in m/s, or depth/time - the rest is just accounting to your desired units of depth and time).
- **Missing / Fill Value** - if there are some crazy high or low values in your data, you may want to check if those just represent the missing / fill value, a common sub-attribute of variables. Data may also be stored in ["masked arrays"](https://currents.soest.hawaii.edu/ocn_data_analysis/_static/masked_arrays.html).

### Reading netCDF data

netCDF files can be easily imported as numeric data in any language. Here are some common ways:

| Matlab            | R                                                         | python (netCDF4)                                                                                                                                           | python (xarray)                                                                                                                             |
| ----------------- | --------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `ncread(fn,var);` | `ncfile <- nc_open(fn)`<br>`var <- ncvar_get(ncfile,var)` | `ncf = nc.Dataset(fn)` <br>`ncf.variables[var][:]`<br>(`ncf.variables[var]` will return a `float` object that keeps the attributes from the netCDF file) | `ds = xr.open_dataset(fn))`<br>ds.var<br>(data is loaded lazily and only fully loaded when calculations are done - to force loading, run `ds.load()`) |

You’ll often only want or need a subset of a variable. In this case, make sure you know in what order the dimensions of the variable are saved at (see above; unless you are working with `xarray`, which handles this for you. Check the docs.). Say, if you want only a 5 x 5 x 365 subset of the data, you’d use:

| Matlab                                     | R                                                                                                           | python (xarray)                                                                                                                                                                                                                                        |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ncread(fn,var,`<br>`[1 1 1],[5 5 365]);` | `ncfile <- nc_open(fn)`<br>`vardata <- ncvar_get(ncfile,var,             start=c(1,1,1), count=c(5,5,365))` | `ds = xr.open_dataset(fn))`<br>`ds.loc[0:5,0:5,0:365]` <br>(data is loaded lazily and only fully loaded when calculations are done, so you can slice data without loading it into memory. Slicing can be done by time, variable, etc.; check the docs) |

As mentioned above, these files also include populated variables that give values for indices along each dimension (`lon, lat` / `location` and `time`), which can be extracted like any other variable using the functions listed above. Make sure to double-check the name of those dimensions in the netCDF header first (the author has seen grid variables listed for example as `lat`, `latitude`, `Latitude`, `Lat`, `latitude_1`, `nav_lat`, and any number of other names). As mentioned, `xarray` has built-in methods for identifying the dimensions in the file, regardless of order. 

The `time` variable can also be listed in a few different formats. An integer representation of “days since [some date, often 1850-01-01]” is common, as is an integer representation of the form [YYYYMMDD], among others. The key is to always check the description of the variable in the header, and adjust your methods accordingly until it’s in a format you want it in. If you're using python, the `xarray` package has the ability to interpret some of these time representations for you and translates them into the `datetime64` class, which makes some kinds of manipulation, like averaging over months, easier.

### Diagnostic Maps of Climate Data

You may want to visualize your weather or climate data, either for internal diagnostics or for production figures showing your data. It's generally good practice to double-check that your data downloaded and processed correctly, by making sure there aren't suspiciously many NAs/NaNs, that the lat/lon grid matches up with where the data should go (first-order check: does your temperature/precipitation field trace out major land/ocean boundaries, etc.), and that the data is consistent. Here are easy ways to plot the first timestep of a gridded dataset: 

#### Python (xarray)
```python
# Assuming your variable is a 3-D (lat,lon,time, in any order) 
# variable called "tas", in a dataset loaded using 
# ds = xr.open_dataset() as above. This will get you a 
# "QuadMesh" image - just a heatmap of your data:
ds.tas.isel(time=1).plot()
# (for the time mean, you can use ds.tas.mean(time).plot() 
# similarly)
    
# Example with gegographic information:
import cartopy.crs as ccrs # If plotting on a geographically correct map    
# (see resources below on why transforms/projections 
# need to be explicitly noted)
ax = plt.axes(projection=ccrs.EckertIV()
ds.tas.isel(time=1)
 .plot(transform=ccrs.PlateCarree()
ax.coastlines()
```
(For more information on plotting geographic data with xarray and cartopy, the author highly recommends the ["Earth and Environmental Science" with python guide](https://earth-env-data-science.github.io/intro.html), especially the section on ["Making Maps with Cartopy"](https://earth-env-data-science.github.io/lectures/mapping_cartopy.html]))

#### Matlab
```Matlab
% Assuming your dataset is called "tas" (lon,lat,time)
% This will just plot a heatmap of your data:
pcolor(squeeze(tas(:,:,1)).'); shading flat

% Alternatively, with geographic information:
axesm() % Set desired projection in the function call; i.e. 'eckert4'
pcolorm(lat,lon,squeeze(tas(:,:,1)).'); shading flat 
% coast.mat is included with Matlab installations; this will add 
% coastlines. 
coasts=matfile('coast.mat')
geoshow(coasts.lat,coasts.long)
```


## 1.2 Gridded Data

Weather data is traditionally collected at weather stations. Weather stations are imperfect, unevenly distributed point sources of data whose raw output may not be suitable for economic and policy applications. Weather stations are more likely to be located in wealthier and more populated areas, which makes them less useful for work in developing countries or for non-human variables such as agriculture. Their number and coverage constantly changes, making it difficult to weigh or to compare across regions. Despite being the most accurate tool for measuring the current weather at their location, they may hide microclimates nearby.

Thankfully, a large suite of data products have been developed to mitigate these issues. These generally consist of combining or ‘assimilating’ many data sources and analysis method into a ‘gridded dataset’ - the earth is divided into a latitude x longitude (x height) grid, and one value for a variable (temperature, precipitation, etc.) is provided at each gridpoint and timestep. These data products generally cover either the whole globe or all land areas, and provide consistent coverage at each grid point location. *(NB: Some variables, especially relating to hydrology, may be better suited to station data, by providing single values for large regions such as river basins)*.

However, since the world is not made up of grids (i.e. the world is not broken up into 50 x 50 km chunks, within which all weather conditions are identical), some processing has to be done even for historical “weather” data, and other limitations arise. For historical data, this processing is one of the sources of differences between data products, and for climate data, the simulation of sub-grid processes is the greatest source of uncertainty between models.

Keep in mind that just because a dataset exists at a certain resolution, does not mean it is accurate at that resolution! 

The next section will briefly introduce how these products are generated, how to choose between them, and best practices for using “historical” data.

## 1.3 Weather Data Products

**The Interpolation - Reanalysis Spectrum**
Historical data products differ by how they ["assimilate"](https://climatedataguide.ucar.edu/climate-data/atmospheric-reanalysis-overview-comparison-tables) (join observational with model data) or combine data, and how much “additional” information is added beyond (pre-processed) station data. They can be thought of as a rough spectrum ranging from ‘observational’ data products that merely statistically interpolate data into a grid to ‘reanalysis’ products that feed data products into a sort of climate model to produce a more complete set of variables. Some datasets are observational but include topographic and other physical information in their statistical methods, while some reanalysis datasets use pure model output for only some variables.

Both ends of their spectrum have tradeoffs, and generalizable statements about these tradeoffs are hard to make because of differences in methodologies. The following are a few simplified rules of thumb:

### “Observational” / Interpolated Datasets
Examples: GISTEMP, GHCN, Wilmot and Matsuura (aka “UDel”), Berkeley Earth (aka “BEST”), HadCrut4, PRISM, CHIRPS, etc.

- Observations are statistically interpolated into a grid with little or no physical information added (though topography and - less commonly - wind speed are occasionally included)
- Products generally differ by which stations or other data sources are included and excluded

*Strengths*:

- Simple, biases well-understood
- High correlation with source station data in areas with strong station coverage

*Weaknesses*:

- Less realistic outside areas with strong station coverage
- Statistical interpolation means data not bound by physicality
- Often only available at lower temporal resolution (e.g. monthly)

(see also UCAR's Model Data Guide [summary](https://climatedataguide.ucar.edu/climate-data/global-temperature-data-sets-overview-comparison-table) on temperature datasets)

### Reanalysis Datasets

Examples: ERA-INTERIM, ERA-5, JRA-55, MERRA-2, NCEP2 (outdated), etc.

- Observational data are combined with climate models to produce a full set of atmospheric variables
- Products differ by what data is included (as with interpolated
  datasets), but now also differ by which underlying models are used

*Strengths*:  

- Large extant literature on most major reanalysis products; limitations are generally well-understood (though not always well-estimated; and biases are often tested against interpolated datasets)
- Coverage in areas with low station coverage (generally poorer or less populated areas) is more physically reasonable
- Covers a large number of variables (though uncertainties differ between them)

*Weaknesses*:

- Not fully physical either - laws of conservation e.g. are often relaxed
- Limited by often significant biases in underlying models that may or may not be well understood
- Accuracy in areas of high station density may be lower than in interpolated products

(see also UCAR's Model Data Guide [summary](https://climatedataguide.ucar.edu/climate-data/atmospheric-reanalysis-overview-comparison-tables) on reanalyses)

### Regional Datasets
Observational datasets exist with both global coverage (e.g. GISTEMP, HadCRUT, etc.) or regional coverage (e.g. PRISM in North America, TRMM in the tropics, etc.). Global datasets attempt to build a self-consistent database spanning the whole globe, and are therefore more likely to have sparser data coverage in specific regions - both as a logistical limitation, but also to ensure data pre-proceessing is as standardized as possible. Regional datasets may provide higher-resolution coverage and more specialized methodologies by incorporating local climatological knowledge or data sources that are not publicly available or parsable by global datasets (see e.g. the discussion in [Dinku et al. 2019](http://www.sciencedirect.com/science/article/pii/B9780128159989000075)). 

## 1.4 Where to Even Begin - Resources and How to Start Working with a Data Product

Some incredibly useful resources to keep in mind while working with weather data are the following two sites:

- https://climatedataguide.ucar.edu - an encyclopedia for weather and climate data products with expert guidance on strengths and weaknesses for most commonly-used datasets
- https://reanalyses.org - a forum and wiki for makers and users of reanalyses with a focus on evaluating data products and comparing them with observational data
- https://www.esrl.noaa.gov/psd/data/writ/moncomp/datasets/ - a “who’s who” of historical weather products with basic facts about each

These resources will help you determine which data product is right for you (and better interpret results from existing studies - for example, NCEP2, which was commonly used in economics and policy studies, has known issues including larger biases in the Southern Hemisphere).

Additionally, think about if you want climatological ("what you expect") data, rather than weather ("what you get") data. Climatology is generally known with more precision and available at higher resolution, but will only represent average patterns (e.g., average temperature by month) rather than any particular year.

### Getting Started with a Data Product - Sample Process using BEST and CHIRPS
Say you're looking at agriculture in Ethiopia. You would like both temperature and precipitation data (see warning on hydrological variables below), and would like to use observational datasets. You consider BEST for temperature due to their daily output and CHIRPS, a hybrid station-satellite data product, for precipitation because you found literature specifically examining its biases in your region of interest. 

1. *Understand the Data Product* - you look up CHIRPS and UDel on the UCAR Climate Data Guide 
	1. CHIRPS is unfortunately not covered on the UCAR Climate Data Guide. _However_, you find several articles specifically validating it in Ethiopia (e.g. [Dinku et al. 2018](https://rmets.onlinelibrary.wiley.com/doi/full/10.1002/qj.3244) or [Gebrechorkos et al. 2018](https://eprints.soton.ac.uk/435188/)). You see that satellite data products are more biased South of the Rift Valley than North. You also see that CHIRPS tends to overestimate rainfall. You consider how these biases may affect your results. 
	2. BEST _is_ [covered](https://climatedataguide.ucar.edu/climate-data/global-surface-temperatures-best-berkeley-earth-surface-temperatures) on the Climate Data Guide. You see that it is able to provide high-resolution data because it includes more incomplete and partial station records than other global products. However, you also see that the data is highly smoothed, meaning that it will likely be more biased in areas with large heterogeneity in temperature - for example in the mountainous highlands of Ethiopia. You resolve to use different sources to check for robustness.  
2. *Prepare to Download the Data* - most weather products will require some bureaucracy to download data, and most have their own weird quirks about how they want data to be downloaded. CHIRPS and BEST do not require bureaucracy (creating accounts, signing data agreements, etc.), but CHIRPS will require some scripting to download. 
	1. CHIRPS: After some searching, you find that CHIRPS data is stored in a publicly accessible [directory](https://data.chc.ucsb.edu/products/CHIRPS-2.0/) (this is a simpler setup than most). You navigate to the `africa_daily/bils/` directory, and choose between 0.5 degree resolution and 2.5 degree resolution. However, you realize that you may have to write a shell script to download this data, to avoid clicking every file separately (using `ftplib` in python and similar packages is also an option).  
	2. BEST: you click on 'Get Data (external)' on the Climate Data Guide website, taking you to Berkley Earth's data overview page. You navigate down to the section on 'Gridded Data'. You'll have to click on every decade separately, but without further ado, clean NetCDF files are being downloaded to your machine. 
3. *Accessing the Data*
	1. CHIRPS: Unfortauntely, the data is not in `.nc` format, but in `bil` format. This is a raster data format - but thankfully, this is easy enough to deal with in the featured languages - for example, `xarray` has `xr.open_rasterio()`, MATLAB has `multibandread`, and `R` has the `raster` package. The author would suggest you resave the file as a NetCDF, for consistency and ease of access (using `xr.to_netcdf`, for example). 
	2. BEST: the filename, as is typical for observational datasets, is in tis own format - so you might want to rename them into CMIP format just for ease of reading. By reading the NetCDF header, you note that the grid variables are stored as `latitude` and `longitude` and the temperature as `temperature`, and you're set to go!

These datasets are stored in different geographical grids and will need to be regridded to a common grid, using tools like `xesmf` in python. See also Section 3 on weigthing schemes. 


### Getting Started with a Data Product - Sample Process Using ERA-5

Say you’re studying heat waves in the Sahel. Weather station data is low, so you need a gridded data product. You consider ERA5, the most advanced modern reanalysis data product as of 2019, recently released by the European Centre for Medium-Range Weather Forecasting (ECMWF, which incidentally also produces the world’s most respected hurricane forecast model).


1. *Understand the Data Product* - you look up ERA5 on the UCAR Climate Data Guide https://climatedataguide.ucar.edu/climate-data/era5-atmospheric-reanalysis;
    1. It tells you the product has a resolution of about 31 km horizontally (this is about as high as it gets in this generation of data products) and includes 137 pressure levels (this is the vertical resolution; you can safely ignore this if you just care about temperature by the surface). It also allows hourly data (this too is uncommon; most only provide daily, or maybe 3-hourly). However, observe caution here: just because the data is available at this resolution does not mean it is reliable at that resolution, and you will likely need to spend time aggregating the data across time to develop your final dataset.
    2. You see that it even gives you an estimate of the internal model uncertainty by rerunning the same analysis 10 times (10 “ensemble members”), though in “weaknesses” you note that the uncertainty may be underestimated.
    3. It extends back to 1979 for now (1979 is a common cutoff point due to the start of satellite observations in 1978).
    4. The summary describes it as an ‘extraordinary product’, so you feel good in your choice, especially since most of the weaknesses described (temperature in the tropopause, upper stratosphere global average temperature, etc.) don’t seem to affect your region or variables of interest (near-surface temperature).
2. *Prepare to Download the Data* - most weather products will require some bureaucracy to download data, and most have their own weird quirks about how they want data to be downloaded
    1. You click on ‘Get Data (external)’ in the Data Guide to find a [link](https://cds.climate.copernicus.eu/#!/search?text=ERA5&type=dataset) to the Copernicus climate data store. There, you realize that you’ll need to sign up for an account (modern data products from larger institutions such as the ECMWF will thankfully have an automated system for this; some smaller products may require you to wait until someone manually approves your account), which just asks you to sign a data use agreement (remember to correctly cite data sources!).
    2. The download page also gives you some documentation for the data product, including variable names - you see “2m air temperature” in Kelvin is the variable you need.
    3. You click on the data you want, which years you want it for, etc., and prepare to check out. Here, there are two options: GRIB, and NetCDF (experimental). You click NetCDF, because after this guide, you feel comfortable working with it (*NB: GRIB is another meteorological data format - it’s less common and less flexible than NetCDF, but slightly more efficient in storage. The author has yet to see it as the only option for a data product; NetCDF is still dominant. GRIB files can be converted easily to NetCDF files through [command-line tools](https://confluence.ecmwf.int/display/OIFS/How+to+convert+GRIB+to+netCDF) such as [cdo](https://code.zmaw.de/projects/cdo) *).
    4. You click download, and voila! (*NB: Many datasets, especially those from smaller institutions, will not give up their secrets so easily. Be prepared to have to deal with “wget” scripts, “jblob” scripts, writing ftp scripts, and so forth, with well-meaning but poorly-written accompanying documentation. In some of these cases, it might be fastest to call up your best climate researcher friend, who may be able to just copy their scripts to you*).
3. *Accessing the Data*
    1. However, you see an issue - your climate data is named some weird automatically generated filename. In this case, you may want to rename the file following the CMIP5 convention introduced above, or, if there are multiple files, write a script to do this for you (pro tip: the information in a netCDF header, which will tell you the timespan and variables of each file, is always extractable; using e.g. `ncinfo` in Matlab, or the object generated by `nc_open` in R. If you're using `xarray`, `xr.open_mfdataset()` will let you list multiple files, which it will sort correctly into one dataset automatically if all goes well.) (*NB: this is uncommon but not unheard of for weather products. Be prepared to deal with inconsistent and weird filenames)*
    2. Reading off the netCDF header (as detailed above) shows that your variable is named `t2m` (stored as a `longitude x latitude x time` grid), the grid variables are called `latitude`  and `longitude`, and the time variable is called `time`. Now you can access the data as detailed above!

### Thinking ahead to climate projections

Research linking social outcomes to weather variations often aim to project results into the future to estimate the impact of climate change on their variable of interest. We have chosen (at least for now) not to expand this guide to include information on climate projection because of its immense complexity. Oftentimes a more sophisticated understanding of how models work and their uncertainties is needed to avoid underestimating propagated uncertainties in your final estimates. As with weather data products (potentially even more so), there is no *right* or *correct* climate model, or group of models to use (see e.g. [Knutti 2010](https://link.springer.com/article/10.1007/s10584-010-9800-2) or [Collins 2017](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2017GL073370)). Emissions scenarios, the response of the models to emissions scenarios, intermodel variability, and *intra*-model variability all add to the uncertainty in your projection, and their relative strength may depend on the timescale and aims of your study. 

However, to get started in thinking about incorporating changes in climate into your analysis, the author also recommends:
- [Nissan et al. (2019)](https://onlinelibrary.wiley.com/doi/abs/10.1002/wcc.579): "On the use and misuse of climate change projections in international development"
- [Auffhammer et al. (2013)](https://academic.oup.com/reep/article-abstract/7/2/181/1522753): "Using Weather Data and Climate Model Output in Economic Analyses of Climate Change"

If you plan to project results into the future, you can start thinking about its logistics now. Climate data comes from imperfect models whose raw output generally has to be "bias-corrected" before being used in econometric or policy research contexts. Bias-correction involves using information from a weather dataset to inform the output of a climate model, either by applying model changes to the weather data (so-called "delta-method" projection) or by adjusting the model output by applying a historical difference between the model and weather data to the future model output. We won't go into details about these methods (like everything in this field, they have their strengths and weaknesses), but you should generally use data that has been bias-corrected to the same weather data set you are using to inform your econometric model. Oftentimes this bias-correction is still conducted by the econometric or policy-focused research group, but some pre-bias-corrected climate projections exist. For example, NASA's [(NEX-GDDP)](https://nex.nasa.gov/nex/projects/1356/) dataset is bias-corrected to the [Global Meteorological Forcing Dataset (GMFD) for Land Surface Modeling](http://hydrology.princeton.edu/data.pgf.php) historical dataset.

### A Quick Summarizing Note

This process may seem overwhelming, especially given the large variety of data products that exist, and the sometimes rather opaque processes for figuring out what works best.

The author’s personal suggestion is to start off with a regional observational dataset, if one exists for the region and variables you wish to examine, or else a well-understood global observational dataset. Don’t use a dataset or a data assimilation methodology just because previous work (even big-name papers) have used them. There are enough examples in the literature of problematic uses of weather and climate data (for examples of discussions about these issues see e.g. [Fisher et al. 2012](https://www.aeaweb.org/articles?id=10.1257/aer.102.7.3749), [Burke et al. 2015](https://www.mitpressjournals.org/doi/abs/10.1162/REST_a_00478), etc.).

Furthermore, check your results with multiple datasets from the latest generation! Consider performing your analysis with a purely station-based dataset and one that includes satellite data; or compare results to those from a reanalysis dataset if you are worried about statistical interpolation in your region of interest. This may not make a huge difference for more stable variables in areas with high station coverage (e.g. temperature in North America), but could be a useful robustness check for more problematic ones (e.g. precipitation). If the choice of 'historical' dataset changes your results, think about how their biases may interact with your analysis to figure out what's causing the discrepancy. 

## 1.5 A Warning on Hydrological Variables (Precipitation, Humidity, etc.)
![Hi, I'm your new meteorologist and a former software developer. Hey, when we say 12pm, does that mean the hour from 12pm to 1pm, or the hour centered on 12pm? Or is it a snapshot at 12:00 exactly? Because our 24-hour forecast has midnight at both ends, and I'm worried we have an off-by-one error.](https://imgs.xkcd.com/comics/meteorologist.png)
*As usual, [XKCD](https://imgs.xkcd.com/comics/meteorologist.png) gets it best*

Precipitation is a special beast. It is spatiotemporally highly heterogeneous (it can rain a lot in one place, and not rain at all on the other side of the hill, or an hour or a minute later) and difficult to measure accurately, but is frequently desired for socioeconomic applications.

![Data from [Bosliovich et al. (2015)](https://gmao.gsfc.nasa.gov/pubs/docs/Bosilovich785.pdf); gridded data products disagree on average global monthly precipitation by up to 40%, and aren't always consistent!](images/global_monthly.png)
*Data from [Bosilovich et al. (2015)](https://gmao.gsfc.nasa.gov/pubs/docs/Bosilovich785.pdf); gridded data products disagree on average global monthly precipitation by up to 40%, and aren't always consistent!*

Unlike temperature, which is relatively uniform spatiotemporally and can be interpolated with a relatively high degree of confidence, precipitation data is very difficult to interpolate and requires a much more complex understanding of regional precipitation patterns to assimilate into gridded products. Consequently, gridded precipitation data should be used with ["extreme caution"](https://climatedataguide.ucar.edu/climate-data/atmospheric-reanalysis-overview-comparison-tables), and its uncertainties should not be underestimated. 

Even ‘raw’ precipitation data from weather stations and rain gauges are problematic. Developing a reliable, easily scaled rain gauge network is a difficult task. For example, a common type of rain gauge, the ‘tipping bucket’, only records rain in discrete intervals (when the bucket fills and subsequently ‘tips’), and therefore could record a rainstorm if a drizzle tips an already-full bucket. A meteorologist once told the author of this section that tipping buckets stationed in remote areas may be stuck in the ‘tipped’ position for some time before anyone notices or can repair them.

In general, rain gauges of most types are biased low. In strong wind conditions, many drops may not enter the rain catch in a gauge due to turbulence; in strong storms, point estimates may miss areas of greatest intensity. Rain data averaged over areas with complex terrain is biased because of the vertical profile of precipitation (stations are generally in valleys). Kenji Matsuura (of the UDel dataset fame) in his [expert guidance](https://climatedataguide.ucar.edu/climate-data/global-land-precipitation-and-temperature-willmott-matsuura-university-delaware) on his dataset explains: “Under-catch bias can be nontrivial and very difficult to estimate adequately, especially over extensive areas...”

Bias-correcting is integrated into weather data products, often involving assimilation of multiple data sources (satellites, radar, etc.) but significant biases remain (see above Figure).

Precipitation is often recommended as a control in economic models, but its unique character makes it difficult to work with. Beyond the strong uncertainty in precipitation data, precipitation is highly non-gaussian and its correlation with temperature is time- and space- dependent. When using precipitation in your model, be aware of its limitations, check robustness against multiple data products, or on geographic subsets that have better station coverage and potentially less biased data. Make sure to read studies evaluating your chosen data product - for example [Dinku et al. 2018](https://rmets.onlinelibrary.wiley.com/doi/abs/10.1002/qj.3244) for CHIRPS in Eastern Africa (a useful Google Scholar search for any product could be "[data product name] validation OR evaluation OR bias OR uncertainty"). Finally, make sure you think about what role precipitation plays in your model - see [2.1. Choosing weather variables](#2.1.-Choosing-weather-variables)!

## 1.6 A Final Note on Station Data

Station data (e.g. [Global Historical Climatology Network (GHCN)](https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/global-historical-climatology-network-ghcn) and the Global Summary of the Day) *can* be useful in policy and economic applications, and has been frequently used by especially older studies in the field. It provides a high degree of accuracy in areas of high station density, which generally corresponds to areas with a higher population density and a higher income level. Especially if you are working with urban areas, station data will likely capture the urban heat island effect more accurately than any gridded product. 

However, station data can’t be seen as the ‘true’ weather either; assumptions and calibration methodologies affect data here as well (see e.g. [Parker 2015](https://journals.ametsoc.org/doi/full/10.1175/BAMS-D-14-00226.1)), some variables remain rather uncertain, and the influence of microclimates even in close proximity to stations shouldn’t be underestimated (think for example the Greater Los Angeles region, where temperature can vary up to 35 F between the inland valleys and the coast).

Finally, under normal circumstances, **don’t try to interpolate data yourself**. Interpolated and reanalysis data products covered above were specifically designed for this purpose, and have vetted methodologies and publicly available citable diagnostics and uncertainties.
