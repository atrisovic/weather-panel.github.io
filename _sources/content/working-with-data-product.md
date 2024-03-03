(content:working-with-data)=
# Choosing and downloading weather and climate data products

The following are incredibly useful resources to keep in mind while working with weather data:

📚  [UCAR Climate Data Guide](https://climatedataguide.ucar.edu)
: an encyclopedia for weather and climate data products with expert guidance on strengths and weaknesses for most commonly-used datasets

📚  [Reanalysis.org](https://reanalyses.org)
: a forum and wiki for makers and users of reanalyses with a focus on evaluating data products and comparing them with observational data

📚  [Reanalysis and Observational Datasets and Variables](https://psl.noaa.gov/data/atmoswrit/map/datasets/)
: a "who's who" of historical weather products with basic facts about each

These resources will help you determine which data product is right for you. They will also help you better interpret results from existing studies. (For example, the NCEP2 reanalysis data product, which was commonly used in economics and policy studies, has known issues including larger biases in the Southern Hemisphere).

The following section shows several examples of choosing and downloading weather data given a region and variable of interest. Though there are many more products than the three introduced here, each with their own download procedures and quirks, these examples show a few common setups that you may encounter (CHIRPS: ftp directory; BEST: website browser; ERA5: data storage system). 

Generally, it's good practice to first research which data products are appropriate for your variable and area of interest. Questions you should be thinking of include:
- does the data product have the variable I need? 
- are the data available at the resolution I need? 
- are biases reasonable for the variable and region of interest?

The answers to the first two questions above are easily found on the website of each dataset. The third question is more complex - the [UCAR Climate Data Guide](https://climatedataguide.ucar.edu) introduced above is a good first place to look. A [Google Scholar](https://scholar.google.com/) search of the form `[data product name] validation OR evaluation OR bias OR uncertainty` may be useful as well. 

(content:best-and-chirps)=
## Getting started with an observational data product: BEST and CHIRPS

Say you're looking at agriculture in Ethiopia. You would like both temperature and precipitation data (remember the [warning on hydrological variables](content:warning-on-hydrological)), and would like to use observational datasets. You consider BEST for temperature due to their daily output and CHIRPS, a hybrid station-satellite data product, for precipitation because you found [literature](https://rmets.onlinelibrary.wiley.com/doi/full/10.1002/qj.3244) specifically examining its biases in your region of interest. 

```{list-table}
:header-rows: 1
:widths: 10 20 20

* - 
  - CHIRPS
  - BEST

* - *1. Understand the Data Product*
  - CHIRPS is unfortunately not covered on the UCAR Climate Data Guide. _However_, you find several articles specifically validating it in Ethiopia (e.g., [Dinku et al. 2018](https://rmets.onlinelibrary.wiley.com/doi/full/10.1002/qj.3244) or [Gebrechorkos et al. 2018](https://eprints.soton.ac.uk/435188/)). You see that satellite data products are more biased South of the Rift Valley than North. You also see that CHIRPS tends to overestimate rainfall. You consider how these biases may affect your results.
  - BEST _is_ [covered in the Climate Data Guide](https://climatedataguide.ucar.edu/climate-data/global-surface-temperatures-best-berkeley-earth-surface-temperatures). You see that it is able to provide high-resolution data because it includes incomplete and partial station records that other global data products may throw out. However, you also see that the data is highly smoothed, meaning that it will likely be more biased in areas with large heterogeneity in temperature - for example in the mountainous highlands of Ethiopia. You resolve to use different sources to check for robustness.

* - *2. Prepare to Download the Data*
  - CHIRPS data is stored in a [publicly accessible directory](https://data.chc.ucsb.edu/products/CHIRPS-2.0/). You navigate to the `africa_daily/bils/` directory, and choose between 0.5 degree resolution and 2.5 degree resolution. However, you realize that you may have to write a shell script to download this data, to avoid clicking every file separately (using `ftplib` in Python and similar packages is also an option).  
  - Click on 'Get Data (external)' on the Climate Data Guide website, taking you to Berkley Earth's data overview page. You navigate down to the section on 'Gridded Data'. You'll have to click on every decade separately, but without further ado, clean NetCDF files are being downloaded to your machine.

* - *3. Accessing the Data*
  - Unfortunately, the data is not in `.nc` format, but in `bil` format. This is a raster data format, and it can be opened in the featured languages. For example, `xarray` has `xr.open_rasterio()`, MATLAB has `multibandread`, and `R` has the `raster` package. We suggest you convert the `bil` files into NetCDF, for consistency and ease of access (using `xr.Dataset.to_netcdf()`, for example).
  - The filename, as is typical for observational datasets, is in its own format - so you might want to rename them into CMIP format just for ease of reading. By reading the NetCDF header, you note that the grid variables are stored as `latitude` and `longitude` and the temperature as `temperature`, and you're set to go!
```

```{note}
Most weather products will require some bureaucracy (creating accounts, signing data agreements, etc.) to download data, and most have their own quirks about how they want data to be downloaded. CHIRPS and BEST do not require bureaucracy, but CHIRPS will require some scripting to download.
```

These datasets are stored in different geographical grids and will need to be regridded to a common grid, using tools like `xesmf` in Python. See also [weighting schemes](weighting-schemes). 

(content:working-with-era5)=
## Getting started with a reanalysis data product: ERA-5

Say you’re studying heat waves in the Sahel. Weather station data is low, so you need a gridded data product. You consider ERA5, the most advanced modern reanalysis data product as of 2019, recently released by the [European Centre for Medium-Range Weather Forecasting (ECMWF)](https://www.ecmwf.int/) (which incidentally also produces the world’s most respected hurricane forecast model).

``````{list-table}
:header-rows: 1
:widths: 10 40

* - 
  - ERA-5
* - *1. Understand the Data Product*
  - 1. You first consult the [ERA5 page](https://climatedataguide.ucar.edu/climate-data/era5-atmospheric-reanalysis) on UCAR's Climate Data Guide, and ERA5's [description page](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=overview) on ECMWF's website. These tell you ERA5 has a resolution of about 31 km horizontally (this is about as high as it gets in this generation of data products). It also allows hourly data (this too is uncommon; most only provide daily, or maybe 3-hourly). However, observe caution here: just because the data is available at this resolution does not mean it is reliable at that resolution, and you will likely need to spend time aggregating the data across time to develop your final dataset.
    2. You see that it even gives you an estimate of the internal model uncertainty by rerunning the same analysis 10 times (10 “ensemble members”), though in “weaknesses” you note that the uncertainty may be underestimated.
    3. You notice that ERA5 extends back to 1979 for now (1979 is a common cutoff point due to the start of satellite observations in 1978).
    4. You notice that most of the weaknesses described (temperature in the tropopause, upper stratosphere global average temperature, etc.) don’t seem to affect your region or variables of interest. However, you double-check whether ERA5 is appropriate by searching [Google Scholar](https://scholar.google.com/) for any relevant evaluation studies (sample search: `ERA5 Sahel temperature validation OR evaluation OR bias OR uncertainty`)

* - *2. Prepare to Download the Data*
  - 1. You click on ‘Get Data (external)’ in the Data Guide, or look on ERA5's description page, to find a [link](https://cds.climate.copernicus.eu/#!/search?text=ERA5&type=dataset) to the Copernicus climate data store. There, you realize that you’ll need to sign up for an account (modern data products from larger institutions such as the ECMWF will thankfully have an automated system for this; some smaller products may require you to wait until someone manually approves your account), which just asks you to sign a data use agreement (remember to correctly cite data sources!).
    2. The download page also gives you some documentation for the data product, including variable names - you see “2m air temperature” in Kelvin is the variable you need.
    3. You click on the data you want, which years you want it for, etc., and prepare to check out. Here, there are two options: GRIB, and NetCDF (experimental). You click NetCDF, because after this guide, you feel comfortable working with it. 
    4. Clicking download completes the process. 

    ```{note}
    GRIB is another meteorological data format - it’s less common and less flexible than NetCDF but slightly more efficient in storage. GRIB files can be converted easily to NetCDF files through [command-line tools](https://confluence.ecmwf.int/display/OIFS/How+to+convert+GRIB+to+NetCDF) such as [cdo](https://code.zmaw.de/projects/cdo).
    ```

* - *3. Accessing the Data*
  - 1. You notice that the files have odd automatically-generated filenames. In this case, you may want to rename the file to a format that's more meaningful (for example, following a CMIP convention). If there are multiple files, write a script to do this for you. 
    2. The information in a NetCDF header, which carries the timespan and variables of each file, is always extractable. Use `ncinfo` in Matlab or `nc_open` in R to extract this information. If you're using Python's `xarray`, the function `xr.open_mfdataset()` will let you list multiple files, and it should correctly and automatically sort them into a single dataset.
    3. Reading the NetCDF header shows that your variable is named `t2m` (stored as a `longitude x latitude x time` grid), the grid variables are called `latitude`  and `longitude`, and the time variable is called `time`. You can now access the data!
`````` 

```{caution}
Many datasets, especially those from smaller institutions, will not give up their secrets easily. Be prepared to have to deal with `wget` scripts, `jblob` scripts, writing `ftp` scripts, and so forth, with well-meaning but poorly-written accompanying documentation. In some of these cases, it might be fastest to call up your best climate researcher friend, who may be able to just share their scripts with you.
```

```{caution}
Climate and weather data can be massive. For example, the full, hourly, global record of a set of 9 commonly-used near-surface variables in ERA5 (including temperature and preciptiation) comes out to roughly 7 TB of disk space in total. Consequently, data products tend to be saved in smaller chunks, or allow for subsetting before downloading. Depending on the scale of your analysis, you will likely need additional storage beyond your personal machine, on external servers, for example. More recently, some datasets have also been made available on cloud servers such as [pangeo](https://pangeo-forge.org/catalog) or [Google Earth Engine](https://www.ecmwf.int/en/newsletter/162/news/era5-reanalysis-data-available-earth-engine). 
```

## Thinking ahead to climate projections

Research linking social outcomes to weather variations often aim to project results into the future to estimate the impact of climate change on their variable of interest. We have chosen (at least for now) not to expand this guide to include information on climate projection because of its immense complexity. Oftentimes a more sophisticated understanding of how models work and their uncertainties is needed to avoid underestimating propagated uncertainties in your final estimates. Even more so than with weather data products, there is no *right* or *correct* climate model, or group of models to use (see e.g., [Knutti 2010](https://doi.org/10.1007/s10584-010-9800-2) or [Collins 2017](https://doi.org/10.1002/2017GL073370). Emissions scenarios, the response of the models to emissions scenarios, intermodel variability, and *intra*-model variability all add to the uncertainty in your projection, and their relative strength may depend on the timescale and aims of your study. 

```{seealso}
To get started thinking about incorporating changes in climate into your analysis, we also recommend: [On the use and misuse of climate change projections in international development, by Nissan et al. (2019)](https://onlinelibrary.wiley.com/doi/abs/10.1002/wcc.579) and [Using Weather Data and Climate Model Output in Economic Analyses of Climate Change by Auffhammer et al. (2013)](https://doi.org/10.1093/reep/ret016)
```

However, if you plan to project results into the future, you can start thinking about its logistics now. Climate data comes from imperfect models whose raw output generally has to be "bias-corrected" before being used in econometric or policy research contexts. Bias-correction involves using information from a weather dataset to inform the output of a climate model, either by applying model changes to the weather data (so-called "delta-method" projection) or by adjusting the model output by applying a historical difference between the model and weather data to the future model output. We won't go into details about these methods (like everything in this field, they have their strengths and weaknesses), but you should generally use data that has been bias-corrected to the same weather data set you are using to inform your econometric model. Oftentimes this bias-correction is still conducted by the end user themselves, but some pre-bias-corrected climate projections exist. For example, NASA's [NEX-GDDP](https://doi.org/10.7917/OFSG3345) dataset is bias-corrected to the [Global Meteorological Forcing Dataset (GMFD) for Land Surface Modeling](https://doi.org/10.5065/JV89-AH11) historical dataset.

## A quick summarizing note

This process may seem overwhelming, especially given the large variety of data products that exist, and the sometimes rather opaque processes for figuring out what works best.

If a regional observational dataset exists for the region and variables you wish to examine, you should start off with them. Alternatively, you may use a well-understood global observational dataset. Don't use a dataset or a data assimilation methodology just because previous work (even big-name papers) have used them. There are enough examples in the literature of problematic uses of weather and climate data (for examples of discussions about these issues, see [Fisher et al. 2012](https://www.aeaweb.org/articles?id=10.1257/aer.102.7.3749) and [Burke et al. 2015](https://www.mitpressjournals.org/doi/abs/10.1162/REST_a_00478)).

Furthermore, check your results with multiple datasets from the latest generation! Consider performing your analysis with a purely station-based dataset and one that includes satellite data; or compare results to those from a reanalysis dataset if you are worried about statistical interpolation in your region of interest. This may not make a huge difference for more stable variables in areas with high station coverage (e.g., temperature in North America), but could be a useful robustness check for more problematic ones (e.g., precipitation). If the choice of 'historical' dataset changes your results, think about how their biases may interact with your analysis to figure out what's causing the discrepancy. 

