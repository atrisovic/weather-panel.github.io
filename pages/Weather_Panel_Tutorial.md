# Weather Panel Tutorial 

# 1. Introduction to the Tutorial

Welcome to the weather panel data regression tutorial! This tutorial will walk you through the steps behind relating socioeconomic outcomes to weather data at high resolution. We will cover:

1. How to find and read weather data, and what you should be aware of when using it.
2. How to relate your socioeconomic outcomes to weather variables, and develop your specification.
3. How to work with shapefiles, and use them to generate your predictor variables.

We assume a knowledge of econometrics and basic experience with one econometrics-ready programming language (Stata, R, Matlab, Julia, python).

You should also go through **Sol Hsiang's Climate Impacts Tutorial reading lis****t** to understand the principles of weather regressions:


1. [An Economist’s Guide to Climate Change Science](https://www.aeaweb.org/articles?id=10.1257/jep.32.4.3)  (*what is the physical problem?*)
2. [Using Weather Data and Climate Model Output in Economic Analyses of Climate Change](https://academic.oup.com/reep/article/7/2/181/1522753) (*how do we look at the data for that problem?*)
3. [Climate Econometrics](https://www.annualreviews.org/doi/10.1146/annurev-resource-100815-095343) (*how does one analyze that data to learn about the problem?*)
4. [Social and Economic Impacts of Climate](http://science.sciencemag.org/content/353/6304/aad9837) (*what did we learn when we did that?*)

The following tutorial complements these papers with more practical advice.

## Definitions and conventions


- Point data
- Gridded data
- Region data. Geographic unit. “data regions”
- $$T_{it}$$: any weather variable for data region $$i$$ in reporting period $$t$$.
- $$T_{ps}$$: Pixel-level weather for pixel $$p$$, at a native resolution indexed by $$s$$.
----------
# 2. Using Weather and Climate Data
## Introduction 

When using weather data as independent variables in an economic model, or climate data to project your research results into the future, please note:


- There is no universally *right* or *correct* weather or climate data product
- Every weather or climate data product has its use cases, limitations, uncertainties, and quirks

This section will introduce you to the right questions to ask when deciding on climate or weather data to use in your research. 

## Quick Aside on the netCDF Data Format

Almost all climate and weather datasets are released in [netCDF](https://climatedataguide.ucar.edu/climate-data-tools-and-analysis/netcdf-overview) format. It's efficient, self-describing, and supported by any major programming language, though you’ll have to pre-process data into another format before you can use it in STATA. If you get familiar with the commands to read the header and access data in the language you’re most comfortable with, you will be able to work with almost any climate or weather dataset published in the world. 

**Supported Languages**
Through this section, the relevant commands for working with netCDF files are listed for:

- Matlab (native support)
- python 
    - [netCDF4-python](https://unidata.github.io/netcdf4-python/netCDF4/index.html) module 
    - [xarray](http://xarray.pydata.org/en/stable/) (recommended) - a package for dealing with N-dimensional data that natively supports netCDF
- R ([ncdf4](https://cran.r-project.org/web/packages/ncdf4/index.html) package)
- [nco](http://nco.sourceforge.net) (“netCDF operators”) - command line tools
    - documentation may look overwhelming, but at its core it’s an easy way to check the contents of a file, collate different netCDF files, and extract individual variables without having to go through a full language. 
    - important commands: `ncks` (“nc kitchen sink” - to split or concatenate files command line) and `ndump` (to print contents of the file)

For any R code chunks, it’s assumed the ncdf4 package is loaded (`library(ncdf4)`). For any python code chunks, it’s assumed that the netCDF4-python module is loaded as `nc` (`import netCDF4 as nc`) and/or the xarray package is loaded as `xr` (`import xarray as xr`). 

**netCDF File Structure**
The netCDF file structure is self-describing, meaning all the information you need to understand what data are within are contained within the file as well (in theory). *However*, the format doesn’t require any information be put there, so names of attributes, which attributes are included, etc., may vary between files, especially if they’re ‘unofficial’ files not created by a major modeling group as part of a larger project.

But fear not: thankfully, most data you will be facing has standardized to something akin to the format used by CMIP5 (a ‘model intercomparison project’ in which different modeling groups agreed to run their models on identical climate ‘experiments’ and publish their data in a uniform format). 

For example, most climate data you will encounter will also follow a CMIP5 filename format, of the form (and this terminology will be useful to recognize even when filenames are not of this format, as is likely for weather data products): 
`[variable shorthand]_[frequency]_[model name]_[experiment]_[run]_[timeframe].nc` 

- most commonly encountered **variable shorthands:** 
    - `tas` = temperature; “[air] temperature at surface,” which is different from “surface temperature” (the temperature of the ground) or temperature at other heights. Sometimes also listed as `t2m` for 2m air temperature or `TREFHT` for reference height temperature. (for a discussion on why ‘(near-) surface temperature’ is taken at a ‘reference height’, see here[XX])
    - `pr` = precipitation rate (often in *kg/m^2s* - multiply by 3600 to get mm/hour, or 141.7323 to get in/hour)
- **frequency**: *day* for daily, *ann* for annual. **mon* for monthly; is sometimes listed as *Amon* for atmospheric variables; feel free to ignore this distinction. 
- **experiment**: some descriptor of the forcing used (forcing = profile of greenhouse gases), e.g. *rcp85* for the RCP8.5 scenario frequently used in projections.
- **run**: if the same model was run multiple times with the same forcing, but different physics or initial conditions, it will be noted here (e.g. *r1i1p1*). Don’t worry about this. 
- **timeframe**: frequently in `yyyymmdd-yyyymmdd` format. 

There are two common ways in which data is stored in netCDF files: 

- variables: each file contains a single variable over the whole (or a large chunk) of the time domain
- time slices: each file contains a single timestep with a suite of variables 
- combination: file contains many variables over a large time domain (rare due to size constraints)

To figure out which file saving convention your netCDF file uses, and what is contained, you can check the header of the file: 

**The netCDF Header**
netCDF files are self-describing, meaning that they contain information about the data contained within. Every netCDF file has a header that describes these contents. This will often be the first aspect of the file you look at, to verify the file has the variables you need, in what order the dimensions of the variables are stored, etc. Here are the commands to print the header for netCDF filename `fn`, for each mentioned tool above: 

| nco            | Matlab       | R                                          | python (netCDF4)               | python (xarray)                     |
| -------------- | ------------ | ------------------------------------------ | ------------------------------ | ----------------------------------- |
| `ncdump -h fn` | `ncdisp(fn)` | `ncfile <- nc_open(fn)`<br>`print(ncfile)` | `ds = nc.Dataset(fn))`<br>`ds` | `ds = xr.open_dataset(fn))`<br>`ds` |

The header will open with ‘global attributes,’ which are just text fields that primarily tell you housekeeping information (modeling groups, copyright information, etc.). Then, for each variable contained within the file, the header will tell you what dimensions they contain and their respective sizes, plus variable-specific attributes, like units. 

Use the header to check what the variable you want is called, and what dimensions it has. For a variable-focused netCDF file (see above), the dimensions will likely be `lon,lat,time` (though always verify - some will save their data with the `time` variable first and non-gridded data may be saved as `location,time`). The file will also contain populated variables for each of these dimensions, giving the values of `lon,lat,time`  at each point (be aware - for non-rectangular grids, the *variables* `lon` and `lat` may each be 2-D arrays as well). 

*Attributes* ****
Here are some important common “attributes” of netCDF files or variables:

- **Calendar** - probably the most important and inconsistent attribute for climate data (for historical ‘weather’ data products, one would hope it just follows the Gregorian calendar). Either global, or attached to the “record-keeping dimension” (`time` ). Common formats include
    - *365_day* / *noleap* / *365day* / *no_leap* / etc. **- the years are magically shortened so they all have 365 days (most common for climate data)
    - g*regorian* / *proleptic_gregorian -* modern calendar with leap years 
    - *360_day* - rare calendar in which the year has 360 days (so all months have equal lengths). To my knowledge, the Hadley Model is the only major recent model to use this, but be aware of its existence.  
- **Units** - generally attached to the variable in question. Common variable units:
    - *Temperature -* almost always in Kelvin
    - *Precipitation* - often in *kg/m^2s*, which is the SI unit for precipitation rate (volume per time). Multiply by 3600 to get mm/hour, or 141.7323 to get in/hour (the density of water is 1000 kg/m^3, multiplying by the density gets you the rate in m/s, or depth/time - the rest is just accounting to your desired units of depth and time). 
- **Missing / Fill Value** - if there are some crazy high or low values in your data, you may want to check if those just represent the missing / fill value, a common sub-attribute of variables. 

**Reading netCDF data**
netCDF files can be easily imported as numeric data in any language. Here are some common ways: 

| Matlab            | R                                                         | python (netCDF4)                                                                                                                                           | python (xarray)                                                                                                                             |
| ----------------- | --------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `ncread(fn,var);` | `ncfile <- nc_open(fn)`<br>`var <- ncvar_get(ncfile,var)` | `ncf = nc.Dataset(fn)` <br>`ncf.variables\[var\][:]`<br>(`ncf.variables[var]` will return a `float` object that keeps the attributes from the netCDF file) | `ds = xr.open_dataset(fn))`<br>(data is loaded lazily and only fully loaded when calculations are done - to force loading, run `ds.load()`) |

You’ll often only want or need a subset of a variable. In this case, make sure you know in what order the dimensions of the variable are saved at (see above). Say, if you want only a 5 x 5 x 365 subset of the data, you’d use:

| Matlab                                     | R                                                                                                           | python (xarray)                                                                                                                                                                                                                                        |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ncread(fn,var,…`<br>`[1 1 1],[5 5 365]);` | `ncfile <- nc_open(fn)`<br>`vardata <- ncvar_get(ncfile,var,             start=c(1,1,1), count=c(5,5,365))` | `ds = xr.open_dataset(fn))`<br>`ds.loc[0:5,0:5,0:365]` <br>(data is loaded lazily and only fully loaded when calculations are done, so you can slice data without loading it into memory. Slicing can be done by time, variable, etc.; check the docs) |

As mentioned above, these files also include populated variables that give values for indices along each dimension (`lon, lat` / `location` and `time`), which can be extracted like any other variable using the functions listed above. Make sure to double-check the name of those dimensions in the netCDF header first (the author has seen grid variables listed for example as `lat`, `latitude`, `Latitude`, `Lat`, `latitude_1`, and any number of other names). 

The `time` variable can also be listed in a few different formats. An integer representation of “days since [some date, often 1850-01-01]” is common, as is an integer representation of the form [YYYYMMDD], among others. The key is to always check the description of the variable in the header, and adjust your methods accordingly until it’s in a format you want it in. 

## Introduction to Gridded Data

Weather data is collected at weather stations. Weather stations are imperfect, unevenly distributed point sources of data whose raw output may not be suitable for economic and policy applications. Weather stations are more likely to be located in wealthier and more populated areas, which makes them less useful for work in developing countries or for non-human variables such as agriculture. Their number and coverage constantly changes, making it difficult to weigh or to compare across regions. Despite being the most accurate tool for measuring the current weather at their location, they may hide microclimates nearby. 

Thankfully, a large suite of data products have been developed to mitigate these issues. These generally consist of ‘assimilating’ many data sources and analysis method into a ‘gridded dataset’ - the earth is divided into a latitude x longitude (x height) grid, and one value for a variable (temperature, precipitation, etc.) is provided at each gridpoint and timestep. These data products generally cover either the whole globe or all land areas, and provide consistent coverage at each grid point location. *(NB: Some variables, especially relating to hydrology, may be better suited to station data, by providing single values for large regions such as river basins)*. 

However, since the world is not made up of grids (i.e. the world is not broken up into 50 x 50 km chunks, within which all weather conditions are identical), some processing has to be done even for historical “weather” data, and other limitations arise. For historical data, this processing is one of the sources of differences between data products, and for climate data, the simulation of sub-grid processes is the greatest source of uncertainty between models. 

The next section will briefly introduce how these products are generated, how to choose between them, and best practices for using “historical” data. 

## Weather Data Products

**The Interpolation - Reanalysis Spectrum**
Data products differ by how they assimilate data, and how much “additional” information is added beyond (pre-processed) station data. They can be thought of as a rough spectrum ranging from ‘observational’ data products that merely statistically interpolate data into a grid to ‘reanalysis’ products that feed data products into a sort of climate model to produce a more complete set of variables. Some datasets are observational but include topographic and other physical information in their statistical methods, while some reanalysis datasets use pure model output for only some variables. 

Both ends of their spectrum have tradeoffs, and generalizable statements about these tradeoffs are hard to make because of differences in methodologies. The following are a few simplified rules of thumb: 

*“Observational” / Interpolated Datasets*
Examples: Wilmot and Matsuura (aka “UDel”), Berkeley Earth (aka “BEST”), HadCrut4, GISTEMP, etc.

- Observations are statistically interpolated into a grid with little or no physical information added (though topography and - less commonly - wind speed are occasionally included) 
- Products generally differ by which stations or other data sources are included and excluded

*Strengths*: 

- Simple, biases well-understood 
- High correlation with source station data in areas with strong station coverage

*Weaknesses*: 

- Less realistic outside areas with strong station coverage 
- Statistical interpolation means data not bound by physicality 

*Reanalysis Datasets* **
Examples: ERA-INTERIM, ERA-5, JRA-55, MERRA-2, NCEP2 (outdated), etc.

- Observational data are combined with climate models to produce a full set of atmospheric variables in a more physically plausible way than through mere interpolation  
- Products differ by data is included (as with interpolated datasets), but now also differ by which underlying models are used as well

*Strengths*:  **

- Large extant literature on most major reanalysis products; limitations are generally well-understood (though not always well-estimated)
- Coverage in areas with low station coverage (generally poorer or less populated areas) is more physically reasonable
- Covers a large number of variables (though uncertainties differ between them)

*Weaknesses*: 

- Not fully physical either - laws of conservation e.g. are relaxed
- Limited by biases in underlying models
- Accuracy in areas of high station density may be lower than in interpolated products

**Where to Even Begin - Resources and How to Start Working with a Data Product**
Some incredibly useful resources to keep in mind while working with weather data are the following two sites: 

- https://climatedataguide.ucar.edu - an encyclopedia for weather and climate data products with expert guidance on strengths and weaknesses for most commonly-used datasets
- https://reanalyses.org - a forum and wiki for makers and users of reanalyses with a focus on evaluating data products and comparing them with observational data
- https://www.esrl.noaa.gov/psd/data/writ/moncomp/datasets/ - a “who’s who” of historical weather products with basic facts about each

These resources will help you determine which data product is right for you (and better interpret results from existing studies - for example, NCEP2, which was commonly used in economics and policy studies, has known issues including larger biases in the Southern Hemisphere). 

*Getting Started with a Data Product - Sample Process Using ERA-5*
Say you’re studying heat waves in the Sahel. Weather station data is low, so you need a gridded data product, and probably want a reanalysis data product for the same reasons. You consider ERA5, the most advanced modern reanalysis data product as of 2019, recently released by the European Centre for Medium-Range Weather Forecasting (ECMWF, which incidentally also produces the world’s most respected hurricane forecast model). 


1. *Understand the Data Product* - you look up ERA5 on the UCAR Climate Data Guide https://climatedataguide.ucar.edu/climate-data/era5-atmospheric-reanalysis; 
    1. It tells you the product has a resolution of about 31 km horizontally (this is about as high as it gets in this generation of data products) and includes 137 pressure levels (this is the vertical resolution; you can safely ignore this if you just care about temperature by the surface). It also allows hourly data (this too is uncommon; most only provide daily, or maybe 3-hourly). 
    2. You see that it even gives you an estimate of the internal model uncertainty by rerunning the same analysis 10 times (10 “ensemble members”), though in “weaknesses” you note that the uncertainty may be underestimated. 
    3. It extends back to 1979 for now (1979 is a common cutoff point due to it being roughly coterminous with the start of modern satellite observationsXXXX). 
    4. The summary describes it as an ‘extraordinary product’, so you feel good in your choice, especially since most of the weaknesses described (temperature in the tropopause, upper stratosphere global average temperature, etc.) don’t seem to affect your region or variables of interest (near-surface temperature).
2. *Prepare to Download the Data* - most weather products will require some bureaucracy to download data, and most have their own weird quirks about how they want data to be downloaded
    1. You click on ‘Get Data (external)’ in the Data Guide to find a [link](https://cds.climate.copernicus.eu/#!/search?text=ERA5&type=dataset) to the Copernicus climate data store. There, you realize that you’ll need to sign up for an account (modern data products from larger institutions such as the ECMWF will thankfully have an automated system for this; some smaller products may require you to wait until someone manually approves your account), which just asks you to sign a data use agreement (remember to correctly cite data sources!). 
    2. The download page also gives you some documentation for the data product, including variable names - you see “2m air temperature” in Kelvin is the variable you need. 
    3. You click on the data you want, which years you want it for, etc., and prepare to check out. Here, there are two options: GRIB, and NetCDF (experimental). You click NetCDF, because after this guide, you feel comfortable working with it (*NB: GRIB is another meteorological data format - it’s less common and less flexible than NetCDF, but slightly more efficient in storage. The author has yet to see it as the only option for a data product; NetCDF is still dominant*). 
    4. You click download, and voila! (*NB: Many datasets, especially those from smaller institutions, will not give up their secrets so easily. Be prepared to have to deal with “wget” scripts, “jblob” scripts, writing ftp scripts, and so forth, with well-meaning but poorly-written accompanying documentation. In some of these cases, it might be fastest to call up your best climate researcher friend, who may be able to just copy their scripts to you*). 
3. *Accessing the Data* 
    1. However, you see an issue - your climate data is named some weird automatically generated filename. In this case, you may want to rename the file following the CMIP5 convention introduced above, or, if there are multiple files, write a script to do this for you (pro tip: the information in a netCDF header, which will tell you the timespan and variables of each file, is always extractable; using i.e. `ncinfo` in Matlab, [XXXXX]) (*NB: this is uncommon but not unheard of for weather products. Be prepared to deal with inconsistent and weird filenames)*
    2. Reading off the netCDF header (as detailed above) shows that your variable is named `t2m` (stored as a `longitude x latitude x time` grid), the grid variables are called `latitude`  and `longitude`, and the time variable is called `time`. Now you can access the data as detailed above!

**A Quick Summarizing Note**
This process may seem overwhelming, especially given the large variety of data products that exist, and the sometimes rather opaque processes for figuring out what works best. 

The author’s personal suggestion is to start off with a latest-generation reanalysis data product such as ERA5, unless there is a compelling reason not to. Don’t use a dataset or a data assimilation methodology just because previous work (even big-name papers) have used them. There are enough examples (XXXX various citations, including Burke/Hsiang on climate data, Burke’s response to Deschenes and Greenstone, etc. XXXX) in the literature of problematic uses of weather and climate data. 

And, when in doubt, check your results with multiple datasets from the latest generation! This may not make a huge difference for more stable variables in areas with high station coverage (i.e. temperature in North America), but could be a useful robustness check for more problematic ones (i.e. precipitation). 

**A Warning on Hydrological Variables (Precipitation, Humidity, etc.)**
Precipitation is a special beast. It is spatiotemporally highly heterogeneous (it can rain a lot in one place, and not rain at all on the other side of the hill, or an hour or a minute later) and difficult to measure accurately, but is frequently desired for socioeconomic applications. 


![Data from Bosliovich et al. (2015); gridded data products disagree on average global monthly precipitation by up to 40%, and aren't always consistent!](https://paper-attachments.dropbox.com/s_68BC671A1663C9697A33A33E2D6C239622EC497BC251908A341D68D3A838B5CF_1569337731829_global_monthly_precip_reanalysis_models.png)


Unlike temperature, which is relatively uniform spatiotemporally and can be interpolated with a relatively high degree of confidence, precipitation data is very difficult to interpolate and requires a much more complex understanding of regional precipitation patterns. Consequently,  [text on common issues with assimilated precipitation products]

Finally, even the ‘raw’ precipitation data from weather stations and rain gauges is problematic. Developing a reliable, easily scaled rain gauge network is a difficult task. As an example, a common type of rain gauge, the ‘tipping bucket’, only records rain in discrete intervals (when the bucket fills and subsequently ‘tips’), and therefore can record a large rainstorm when a drizzle happened if that drizzle happens to be the straw that tips the bucket. A meteorologist once told the author of this section that tipping buckets stationed in remote areas may be stuck in the ‘tipped’ position for some time before anyone notices or can repair it. 

In general, rain gauges of most types are biased low. In strong wind conditions, many drops may not enter the rain catch in a gauge due to turbulence; in strong storms, point estimates may miss areas of greatest intensity. Rain data averaged over areas with complex terrain is biased because of the vertical profile of precipitation (stations are generally in valleys). Kenji Matsuura (of the UDel dataset fame) in his [expert guidance](https://climatedataguide.ucar.edu/climate-data/global-land-precipitation-and-temperature-willmott-matsuura-university-delaware) on his dataset explains: “Under-catch bias can be nontrivial and very difficult to estimate adequately, especially over extensive areas...”

Bias-correcting is integrated into weather data products, often involving assimilation of multiple data sources (satellites, radar, etc.) but significant biases remain (see above Figure). 

If you have to include precipitation data, be aware of its limitations, check robustness against multiple data products, or on geographic subsets that have better station coverage and potentially less biased data. 

**A Quick Final Note on Station Data**
Station data (e.g. the Global Summary of the Day) *can* be useful in policy and economic applications, and has been frequently used by especially older studies in the field. It provides a high degree of accuracy in areas of high station density, which generally corresponds to areas with a higher population density and a higher income level. However, station data can’t be seen as the ‘true’ weather either; assumptions and calibration methodologies affect data here as well (see e.g. [Parker 2015](https://journals.ametsoc.org/doi/full/10.1175/BAMS-D-14-00226.1)), some variables remain rather uncertain, and the influence of microclimates even in close proximity to stations shouldn’t be underestimated (think for example the Greater Los Angeles region, where temperature can vary up to 35 F between the inland valleys and the coast). 

Finally, under normal circumstances, **don’t try to interpolate data yourself**. Interpolated and reanalysis data products covered above were specifically designed for this purpose, and have vetted methodologies and publicly available citable diagnostics and uncertainties. 

----------
# 3. Developing a reduced-form specification: 

This section describes steps to develop the first reduced-form specification, which is generally a global/country regression without any covariate, such as income.

## Choosing weather variables

Choice of weather variables depends on the question we are trying to answer. For example, in case of temperature, we can use *T_min/T_max, T_avg or HDD/CDD or GDD.* A few of the important weather variables are listed below:

- Temperature
    1. *T_min/T_max:*  Useful when temperature variation is large leading to significant differences in cold end and hot end response. These are important metric when heterogeneity between each time unit matters, such as having events of heat waves and cold storms in the temporal support
    2. *T_avg:*  A good mean metric for seeing average response over the temperature support, when there is not much variation in temperature across time unit considered in the study. Different averaging methods, like Bartlett Kernels, Moving Average, etc. can be used here
    3. *HDD/CDD & GDD:*  Degree Days (DD) are a measure of ’how much’ and for ’how long’ the outside air temperature was below a certain level.  Reference: https://www.degreedays.net/introduction
- Precipitation
    1. Highly local, poorly measured, and poorly predicted
    2. Total precipitation is often not the best variable. Consider soil water, potential evapotranspiration rate (PET), and water runoff/availability
    3. Distribution of precipitation often matters more than total. Consider no. of rainy/dry days, moments of the distribution
    4. Precipitation is an important control to include, even if it’s not the main variable of interest However, we should remember that the properties of precipitation and temperature variables are very different in the way they affect humans. For example, binning of annual temperature variable, keeping high temperature bins small-sized, can explain variation in death rates due to heat waves events. However, if we want to see the variation in death rates due to storm events, using binned annual precipitation is likely not going to give us the variation in death rates, rather we would have to separately account for storm events by using an additional control
- River discharge rate
    1. Still measured at the station-level, so we don’t have gridded products
    2. For example Central Water Commission of India maintains this dataset for some of the Himalayan rivers that flow in India
- Wind speed
- Evapotranspiration rate
- Solar radiation
- Humidity
- Ocean temperature
- Atmospheric CO2
- Storm events
- Sea level
- Ocean currents
- Soil erosion and salinity
- Plant productivity
## Common functional forms (pros, cons, and methods)

We use one/many/combination of different functional forms for weather variables for generating reduced form results. Some of the frequently used functional forms along with a good reference for understanding them in detail are listed below:

- Bins
    1. Assignment of observations to bins. e.g.  15C-20C, 20C-25C, ...  for temperature
    2. Uses the mean metric, so its advantage is non-parametric nature
    3. Highly susceptible to existence of outliers in data

https://pubs.aeaweb.org/doi/pdfplus/10.1257/app.3.4.152

- Polynomial
    1. Fitting an n-degree polynomial function for weather variables
    2. More poly degrees provide better data fitting
    3. Smooth curve nature doesn’t highlight important irregularities in data

https://en.wikipedia.org/wiki/Polynomial_regression

- Restricted Cubic Spline
    1. Fitting a piecewise polynomial function between pre-specified knots
    2. More independence compared to poly in choosing function knots
    3. Highly parametric due to freedom of choice of knots

https://support.sas.com/resources/papers/proceedings16/5621-2016.pdf

- Linear Spline
    1. Fitting a line between cutoff values e.g.  25C CDD/0C HDD for temp
    2. Less parametric and very useful for predicting mid-range response
    3. Linear and highly sensitive to choice of cutoff values

http://people.stat.sfu.ca/~cschwarz/Consulting/Trinity/Phase2/TrinityWorkshop/Workshop-handouts/TW-04-Intro-splines.pdf

## Cross-validation
- Cross-validation exercise can be done to check the *internal validity* and the *external validity* of the model estimates
- For checking internal validity, the model can be run on a subset of the dataset. For example, running country-wise regressions or running regressions on *k* partitions of data (k-fold cross validation) instead of running a full-sample global regression
- For gauging external validity, model is run on some new dataset that has not been not used in estimating the model parameters. For example, predicting response for a new country using global regression model estimates, and comparing it to the actual observations
- Although cross-validation exercise is not universally performed by researchers, but good papers have at least a section discussing the internal and the external validity of their models
- Sometimes, researchers tend to rely on the measure of R-squared statistic. However, we know from our basic statistics learning, how badly this it can perform even in very simple cases
## Fixed Effects Regression


## Dealing with the spatial and temporal scales of economic processes

Weather data products are generally available in *gridded* form, developed after careful interpolation and/or reanalysis exercise. The grids used can vary in size across datasets, but they can be aggregated to economic scale of administrative units like county, city, etc., using appropriate weighted aggregation methods. While doing the spatial aggregation, we need to decide whether we want to do transformation-before-aggregation or aggregation-before-transformation based on the whether the phenomenon in consideration is occurring at the local (grid) scale or at the larger administrative units (country, state, county, etc.) scale. Also, it matters what variable is in consideration. For example, doing aggregation-before-transformation for temperature will distort the signal less that doing it for precipitation. It is because precipitation is highly local both temporally and spatially; it could rain for < 1 min in <1 km radius area. Let us try to understand these two methods with county as our higher administrative level:


- *Transformation-before-aggregation:* When an economic process is occurring at the grid level, we need to first do estimation at the grid level. Here, we need to do the required transformation of our weather variables at the grid level, run our estimation procedure on those transformed variables, and then aggregate grid-level estimates using weighted averaging method. For example, to estimate the effect of temperature on human mortality at the county level, we should reckon that the effect of temperature on mortality is a local phenomenon, so the estimation should happen at the lowest possible level. Therefore, we need to estimate the effect of temperature on mortality at the grid level first, and then take population-weighted average of grid-level effects for the grids that are inside the selected county boundaries

**Mathematical formulation for transformation-before-aggregation method**
Consider a grid $$\theta$$ located in county $$i$$ with $$T_{\theta it}$$ as its temperature at time $$t$$. We want to generate an aggregate temperature transformation, $$f(T_{it}^k)$$, for county $$i$$ at time $$t$$, after aggregating over the grids $$\theta \in \Theta$$, where $$\Theta$$ denotes the set of grids that are located inside county $$i$$.

Here, $$k\in\{1,2,...,K\}$$ denotes the $$k^{th}$$ term of transformation. For example, in case of $$K$$-degree polynomial transformation, it will be $$K$$ polynomial terms, and in case of $$K$$-bins transformation, it will be $$K$$ temperature bins. So, we can write:

$$f(T_{it}^k)=g(T_{\theta it})$$

where, $$g(.)$$ denotes the transformation mapping on the grid-level temperature data.

Once we have $$f(T_{it}^k)$$ for each  $$k\in\{1,2,...,K\}$$, we can use them to generate the full nonlinear transformation $$F(T_{it})$$, associating $$\beta^k$$ parameter with $$k^{th}$$ term of transformation. We have:

$$F(T_{it})=\sum_{k\in \{1,2,...,K\}} \beta^k*f(T_{it}^k)$$

The coefficients, $$\beta^k \,\forall k\in \{1,2,...,K\}$$ are estimated using an appropriate estimation technique for generating the response functions.

Suppose we want a model for estimating the effect of temperature on human mortality $$Y_{it}$$.

$$Y_{it}=\sum_{k\in \{1,2,...,K\}} \beta^k*T_{it}^k + \alpha_i + \zeta_t + \varepsilon_{it}$$

We can run a fixed effects estimation on the county-level data for estimating the coefficients, and then generate the response functions for different counties in our data. As pointed out in the cross-validation section, it is important to check for internal validity and the external validity after the estimation is over.

Bin
Consider doing a 6-bins bin transformation of temperature variable. Let us take equal sized bins for simplicity, but in actual binning procedure, we might want to have smaller sized bins around the temperature values where we expect most of the response to occur. For now, the $$K=6$$ temp bins are: $$<-5^\circ C$$, $$-5^\circ C-5^\circ C$$, $$5^\circ C-15^\circ C$$, $$15^\circ C-25^\circ C$$, $$25^\circ C-35^\circ C$$ and $$>35^\circ C$$.
As defined earlier, the grid $$\theta$$ temperature is $$T_{\theta i t}$$. For transformation, we will have to map actual temperature observations to the respective bins that we have defined above. Then, take the weighted average of these terms across all the grids that come under a specific county. The mapping is defined as follows:

$$f(T_{it}^k)=\sum_{\theta \in \Theta} \psi_{\theta} \sum \mathbf{1} \left \{  {T_{\theta i t} \in k} \right \}$$ $$\forall k \in \{1,2,...,6\}$$

where $$\psi_{\theta}$$ is the weight assigned to the $$\theta$$ grid. The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2,...,6\}} \beta^k*f(T_{it}^k)$$

Polynomial
Consider doing a 4-degree polynomial transformation of temperature variable. We need to first generate the remaining polynomial terms, namely $$T_{\theta i t}^2$$, $$T_{\theta i t}^3$$ and $$T_{\theta i t}^4$$, by raising original $$T_{\theta i t}$$ to powers 2, 3 and 4 respectively. Then, take the weighted average of these terms across all the grids that come under a county. So, we have:

$$f(T_{it}^k)=\sum_{\theta \in \Theta} \psi_{\theta}*T_{\theta i t}^k$$ $$\forall k \in \{1,2,3,4\}$$

where $$\psi_{\theta}$$ is the weight assigned to the $$\theta$$ grid. The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2,3,4\}} \beta^k*f(T_{it}^k)$$

Restricted Cubic Spline
For transforming the temperature data into restricted cubic splines, we need to fix the location and the number of knots. The reference above on cubic splines can be helpful in deciding the knot specifications. As before let the grid $$\theta$$ temperature be $$T_{\theta i t}$$. Let us do this exercise for $$n$$ knots, placed at $$t_1<t_2<...<t_n$$, then for $$T_{\theta i t}$$, which is a continuous variable, we have a set of $$(n-2)$$ new variables. We have:

$$f(T_{i t}^k)= \sum_{\theta \in \Theta} \psi_{\theta}*\{(T_{\theta i t}-t_k)^3_+ - (T_{\theta i t} - t_{n-1})^3_+*\frac{t_n-t_k}{t_n-t_{n-1}}+(T_{\theta i t} - t_{n})^3_+*\frac{t_{n-1}-t_k}{t_{n}-t_{n-1}}\}$$ $$\forall k \in \{1,2,...,n-2\}$$

where, $$\psi_{\theta}$$ is the weight assigned to the $$\theta$$ grid.

And, each spline term in the parentheses $$(\nabla)^3_+$$ e.g. $$(T_{\theta i t} - t_{n-1})^3_+$$ is called a truncated polynomial of degree 3, which is defined as follows:

$$\nabla^3_+=\nabla^3_+$$ if $$\nabla^3_+>0$$
$$\nabla^3_+=0$$ if $$\nabla^3_+<0$$

The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2,...,n-2\}} \beta^k*f(T_{it}^k)$$

Linear Spline
Linear spline is a special kind of spline function, which has two knots, and the segment between these two knots is a linear function. It is also called ‘restricted’ linear spline, since the segments outside the knots are also linear. To implement this, we first decide location of the two knots, say $$t_1<t_2$$. Then, closely following the cubic spline method, we get:

$$f(T_{it}^1)=\sum_{\theta \in \Theta} \psi_{\theta}*(T_{\theta i t}-t_2)_+$$

$$f(T_{it}^2)=-\sum_{\theta \in \Theta} \psi_{\theta}*(T_{\theta i t}-t_1)_+$$

where, $$\psi_{\theta}$$ is the weight assigned to the $$\theta$$ grid.

And, each spline term in the parentheses $$(\nabla)_+$$ e.g. $$(T_{\theta i t} - t_2)_+$$ is called a truncated polynomial of degree 1, which is defined as follows:

$$\nabla_+=\nabla_+$$ if $$\nabla_+>0$$
$$\nabla_+=0$$ if $$\nabla_+<0$$

The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2\}} \beta^k*f(T_{it}^k)$$


- *Aggregation-before-transformation:* When an economic process is occurring at the county level, we need to first do the weather variable aggregation at the county level. We do the weather variable transformation after we have aggregated it to the county level using weighted averaging method, and then run our estimation on the county level data. For example, to estimate the effect of storm events on public service employment at the administrative block level, we need to take into account the fact that hiring/firing of public service employees happens at the block level only.  Estimating grid-level effects will lead to wrong estimation, as it would result in zero estimate for those (almost all) grid cells which do not have the block office coordinates, and extremely large values for those (very few) cells, which comprise of the block office coordinates. The mathematical formulation for aggregation-before-transformation can be learned through transformation-before-aggregation formulation described above, with a change that the aggregation step precedes the transformation step.

Weather data products can have temporal resolution finer than scale of daily observations. Like spatial aggregation, we can do temporal aggregation to month, year, or decade; however, unlike spatial aggregation, the averaging process is standard in all general cases.

----------
# 4. Weighting schemes

This section describes how to use different weighting schemes when aggregating gridded data to data regions.

## Why spatial weighting schemes matter

Taking the unweighted average of weather within a region can misrepresent what populations, firms, or other phenomena of interest are exposed to. For example, an unweighted annual average temperature for Canada is about -8°C, but most of the population and agricultural activity is in climate zones with mean temperatures over 6°C, and the urban heat island effect can raise temperatures by another 4°C. The time of year matters too, and you should consider a weighting scheme across days within a year, or even hours within a day.

As described in section [+Weather Panel Tutorial: Dealing-with-the-spatial-and-t](https://paper.dropbox.com/doc/Weather-Panel-Tutorial-Dealing-with-the-spatial-and-t-Y19yJIcW3pV0TW76gmp5H#:uid=202980750047650372256790&amp;h2=Dealing-with-the-spatial-and-t), the scale of a phenomenon matters. Many processes occur at a more local scale than that which data is collected. The motivation for weighting is different for aggregation that represents averaged phenomena vs. phenomena that respond to averaged weather, and the sequence of analysis changes.

In the first case, the phenomenon occurs locally, in response to local weather. In this case, we perform weighted aggregations to reflect the amount of the phenomenon in each location. For example, we would use population weighting to model the effects of heat on people. In this case, the order of operations is:

1. Transform weather into the terms of the model specification.
2. Average these transformed terms across space using a weighting scheme.

In the second case, the phenomenon occurs at a data region level, in response to averaged weather. In this case, the weighting scheme reflects the relative importance of weather in different regions to the whole. For example, weighting rainfall by the distance from a shore could be important to predict the declaration of states of emergency. The order of operations is:

1. Average the weather across space using a weighting scheme.
2. Transform the averaged weather to the model specification.

In either case, the weighting scheme is the same:

    $$T_{it} = \sum_{p \in P(i)} w_p T_{pt} \text{ such that } \sum_p w_{p \in P(i)} = 1 \,\,\,\forall i$$

where $$w_p$$ is the weight for pixel $$p$$, and $$P(i)$$ is the set of pixels in data region $$i$$.

## Kinds of weight schemes and data sources

Weighting data files come in a wide range of file formats, since any gridded data file is appropriate. The most common data types are CSV, ASC, GeoTIFF, and BIL files. In each case, you (or your code) need to know (1) the format of the data values, (2) the spatial gridding scheme, (3) the projection, and (4) how missing data is handled.


1. Format of the data values: Data values can be written out in text (as with CSV and ASC files) or in a binary representation (GeoTIFF and BIL). If the values are written as text, delimiters will be used to separate them (comma for CSV, spaces for ASC).
2. The spatial gridding scheme is determined by 6 numbers: a latitude and longitude of an origin point, a horizontal and vertical cell lengths, and a number of rows and columns.
    - The most common origin point is the location of the lower-left corner of the lower-left grid cell. For example, for a global dataset, that might be 90°S, 180°W, which is represented in x, y coordinates as (-180, -90). Sometimes (particularly with NetCDF files), grid cell center locations will be used instead.
    - Grid cell sizes are often given as decimal representation of fractions of a degree, such as 0.0083333333333 = 1 / 120 of a degree. This is the grid cell size needed globally to ensure a km-scale resolution. Usually the horizontal and vertical grid cell lengths are the same, and reported as a single number.
    - The number of grid cells is the most common way to describe the spatial coverage of the dataset. A global dataset will have 180 / cellsize rows and 360 / cellsize columns.


    Based on this information, you can calculate which grid cell any point on the globe falls into:
        $$\text{row} = \text{floor}\left(\frac{\text{Latitude} - y_0}{\text{CellSize}}\right)$$, $$\text{column} = \text{floor}\left(\frac{\text{Longitude} - x_0}{\text{CellSize}}\right)$$
    where $$x_0, y_0$$ is lower-left corner point. If the center of the lower-left cell was given, $$x_0 = x_\text{llcenter} - \frac{\text{CellSize}}{2}$$, $$y_0 = y_\text{llcenter} - \frac{\text{CellSize}}{2}$$.


    For CSV files, you will need to keep track of this data yourself. ASC files have it at the top of the file, BIL files have a corresponding HDR file with the data, and GeoTIFF files have it embedded in the file which you can read with various software tools.


3. Projections are a way to map points on the globe (in latitude-longitude space) to a point in a flat x, y space. While this is important for visualizing maps, it can just be a nuisance for gridded datasets. The most common “projection” for gridded datasets is an equirectangular projection, and we have been assuming this above. This is variously referred to as `1`, `ll`, `WGS 84`, and `EPSG: 4326` (techically, WGS 84 species how latitude and longitude are defined, and EPSG:4326 specifies a drawing scheme where x = longitude and y = latitude). However, you will sometimes enounter grids in terms of km north and km east of a point, and then you may need to project these back to latitude-longitude and regrid them.
4. All of these allow missing data to be handled. Typically, a specific numerical representation, like -9999, will be used. This is specified the same way that the gridding scheme is.

Implementation Notes: Reading gridded data.

| R                         | Python                                                                                |
| ------------------------- | ------------------------------------------------------------------------------------- |
| Use the `raster` library. | Take a look at https://github.com/jrising/research-common/tree/master/python/geogrid. |

In some cases, it is appropriate and possible to use time-varying weighting schemes. For example, if population impacts are being studied, and the scale of the model is individuals, annual estimate of population can be used. This kind of data is often either in NetCDF format (see above), or as a collection of files.

Implementation Notes: Downloading multiple files and reading them.

| R                                                                                                                                                                                                                                                                                                                              |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `library(raster)`<br>`for (year in 1980:2010) {`<br>  `download.file(paste0(``"``http://archive.org/awesome/``"``, year,` `"``.zip``"``), "temp.zip")`<br>  `filename <- paste0("prefix-", year, ".asc")`<br>  `zip.file.extract(filename,` `"``temp.zip``"``)`<br>  `r <- raster(filename)`<br>  `<perform weighting>`<br>`}` |


Below are some common datasources for various weighting schemes.

- Population is an important weighting scheme for social impacts.
    - Gridded Population of the World: https://sedac.ciesin.columbia.edu/data/collection/gpw-v4
        This is open-source, available at 30 arc-second resolution every 5 years from 2000 (or before with their previous version).
    - LandScan: https://landscan.ornl.gov/landscan-datasets
        LandScan is available at 30 arc-second resolution, annually, but previous years need to be purchased. As at your institution, as many already have it.
- Gridded agriculture information
    - Global Agricultural Lands in the Year 2000: https://sedac.ciesin.columbia.edu/data/collection/aglands
    - Also consider gridded land use datasets: https://www.atmos.illinois.edu/~meiyapp2/datasets.htm
- Look at the IRI Data Library for a large variety of datasets, available in any format: https://iridl.ldeo.columbia.edu/
## Aligning weather and weighting grids

The first step to using a gridded weighting dataset is to make it conform to data grid definition used by your weather data. Here we assume that both are regular latitude-longitude grids. See [+Weather Panel Tutorial: Kinds-of-weight-schemes-and-da](https://paper.dropbox.com/doc/Weather-Panel-Tutorial-Kinds-of-weight-schemes-and-da-Y19yJIcW3pV0TW76gmp5H#:uid=481082604230980012799322&amp;h2=Kinds-of-weight-schemes-and-da) to understand the grid scheme for your weighting file; note that gridded weather data often reports the center of each grid cell, rather than the corner.

The following recipe should work for most cases to align weighting data with a weather grid.


1. **Resample the weighting data until the grid of the weighting data evenly divides up the weather data.**
    Resampling in this case means increasing the resolution of the weighting grid by some factor. You want to do this so that two conditions to be met after resampling: (A) The new resolution should be an integer multiple of the weather resolution. (B) The horizontal and vertical grid lines of the weather data coincide with the resampled grid lines of the weighting data.


    Example: Suppose the weather data is nearly global, from 180°W to 180°E, 90°S to 86°N, as the case with LandScan population data. The resolution is 1/120th of a degree. You want to use this to weight PRISM data for the USA, with an extent 125.0208 to 66.47917°W, 24.0625 to 49.9375°N, with a resolution of 1/24th of a degree.
| R                                                                                                                                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `landscan <- raster(``"``…/w001001.adf``"``)`<br>`landscan`                                                                                                                                                                  |
| `class       : RasterLayer` <br>`dimensions  : 21120, 43200, 912384000  (nrow, ncol, ncell)`<br>`resolution  : 0.008333333, 0.008333333  (x, y)`<br>`extent      : -180, 180, -90, 86  (xmin, xmax, ymin, ymax)`             |
| `prism <- raster(``"``PRISM_tmax_stable_4kmM2_2000_all_asc")`<br>`prism`                                                                                                                                                     |
| `class       : RasterLayer` <br>`dimensions  : 621, 1405, 872505  (nrow, ncol, ncell)`<br>`resolution  : 0.04166667, 0.04166667  (x, y)`<br>`extent      : -125.0208, -66.47917, 24.0625, 49.9375  (xmin, xmax, ymin, ymax)` |

    Start by throwing away extraneous data, by cropping the LandScan to, say, 
    126 to 66°W, 24 to 50°N.
| R                                                       |
| ------------------------------------------------------- |
| `landscan <- crop(landscan, extent(-126, -66, 24, 50))` |

    Now, note that the edge of the PRISM data is in the middle of the LandScan grid cells: 
    120 * (180 - 125.0208) = 6597.5
    That means that you need to increase the resolution of the LandScan data by 2 to line it up. In general, you will need to increase it by 1 / (the trailing decimal).
| R                                                |
| ------------------------------------------------ |
| `landscan <- disaggregate(landscan, fact=2) / 4` |

    We divide by 4 so that the total population remains the same.


2. **Clip the two datasets so that they line up.**


    In the example above, after increasing the resolution of the LandScan data, we clip it again.
| R                                                                            |
| ---------------------------------------------------------------------------- |
| `landscan <- crop(landscan, extent(-125.0208, -66.47917, 24.0625, 49.9375))` |

3. **Re-aggregate the weighting data, so that it has the same resolution as the weather data.**


    In the example above, the resolution of the dataset has become 1/240th, and we can write aggregate by a factor of 10 for it to match the PRISM data:
| R                                                   |
| --------------------------------------------------- |
| `landscan <- aggregate(landscan, fact=10, fun=sum)` |

----------
# 5. Generating geographical unit data

 
Geographical units are necessary for conducting location-specific economic analyses. A geographical unit, area or region, is a portion of a country or other region delineated for the purpose of administration, and as such, it is a common unit for recording economic outcome data.  For example, a“city” is a local administrative unit where the majority of the population lives in an urban center, while the“greater city” is an approximation of the urban center beyond of the administrative city boundaries[https://ec.europa.eu/eurostat/web/cities/spatial-units]. 
 
 Administrative units in economics analyses are typically politically defined regions, rather than regular grids, because socioeconomic data is collected and corresponding to the political regions. Besides, politically defined regions are also more relevant for policy-makers. 
 
 When generating an administrative unit, it is important to capture territory with homogeneous features that are relevant to the study. For example, if the weather is relevant for the study, the administrative unit should be homogeneous concerning mean temperature and precipitation[https://bfi.uchicago.edu/wp-content/uploads/WP_2018-51_0.pdf]. 
 
 Administrative unit data can capture existing administrative units(high granularity) or groups of those units(lesser granularity). For example, the administrative unit database, Global Administrative Regions[https://gadm.org], offers a granularity of 386,735 administrative areas for the entire world, that can be grouped according to the needs of a study. 


## Finding and preparing a shapefile

 
A shapefile stores nontopological geometry and attribute information for the spatial features in a data set. The geometry for a feature is stored as a shape comprising a set of vector coordinates. Shapefiles can support point, line, and area features. Area features are represented as closed loop, double-digitized polygons [technical guide]. The shapes together with data attributes linked to each shape create the representation of geographic data like countries, rivers and lakes.

Despite its name indicating a singular file, a shapefile is actually a collection of at least three basic files that need to be stored in the same directory to be used. The three mandatory files have filename extensions `.shp`, `.shx` and `.dbf`. There may be additional files like `.prj` with the shape file’s projection information. All files must have the same name, for example:
 

    states.shp
    states.shx
    states.dbf

 
Technical description for shapefiles can be found at: https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf


## Software

The shapefile format is a commonly used to capture geospatial vector-data in geographic information system (GIS) software. QGIS is a free and open-source desktop geographic information system application that supports viewing, editing and analysis of geospatial data. ArcGIS is a proprietary software for working with maps and geographic data.

## Creating shapefiles

Shapefiles can be created with these methods [https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf]:


1. “Export to a shapefile” from programs like ARC/INFO, Spatial Database Engine, GIS, ArcView etc.
2. Digitize: shapefiles can be created directly by digitizing shapes using ArcView GIS feature creation tool
3. Programming: ArcView GIS, MapObjects allow you to create shapefiles within your programs, **Matlab**
## Working with shapefiles from python and R

 
 Shapefiles can be opened with Python packages like 
 1. **Fiona**, 
 

    import fiona
    shape = fiona.open("my_shapefile.shp")
    print shape.schema
    {'geometry': 'LineString', 'properties': OrderedDict([(u'FID', 'float:11')])}

 
 2. **PyShp** or 
 

    import shapefile
    shape = shapefile.Reader("my_shapefile.shp")

 
 3. **geopandas** (among other packages).
 

    import geopandas as gpd
    shapefile = gpd.read_file("/my_shapefile.shp")
    print(shapefile)

 
 Data analysis software R also supports working with spatial data. To read shape files you could use a package like `maptools`,  `rgdal` or `sf`.
 

    library(maptools)
    shapefile=readShapePoly("/my_shapefile.shp")

 
 - 5b. Weighted aggregations within spatial units 

## Matching names

It is often necessary to match names within two datasets with geographical unit observations. For example, a country’s statistics ministry may report values by administrative unit, but to find out the actual spatial extent of those units, you may need to use the GADM shapefiles.

Matching observations by name can be annoyingly time-consuming. These problems even exist at the level of countries, where, for example, North Korea is regularly listed as “Democratic People's Republic of Korea”, “Korea, North”, and “Korea, Dem. Rep.”; and information is indiscriminately reported for isolated regions or sovereign states (Guadeloupe’s data may or may not be included in France). Reporting units may not correspond to standard administrative units at all, and you will need to aggregate or disaggregate regions to match between datasets.

Here are some suggestions for dealing with the mess that is political geography:

First, try to perform all merging on abbreviation codes rather than names. At the level of countries, use ISO alpha-3 codes if possible (https://www.nationsonline.org/oneworld/country_code_list.htm).

Second, use fuzzy string matching. However, in this case you will need to inspect all of the matches to make sure that they are correct.

Third, construct “translation functions” for each dataset, which map the regional names in that dataset to a canonical list of region names. I usually choose the names in one dataset as my canonical list, and name the matching functions as `<dataset>2canonical` and `canonical2<dataset2>`.

# Suggestions when producing a panel dataset
1. Keep your code and your data separate. A typical file organization will be:
    - code/ - all of your analysis
    - sources/ - the original data files, along with information so you can find them again
    - data/ - merged datasets and intermediate results
    - figures/ - formatted figures and LaTeX tables.
    
2. If you aren’t sure what predictors you will need, create your dataset with a lot of possible predictors and decide later. Often merging together your panel dataset is laborious, and you do not want to do it more times than necessary.


