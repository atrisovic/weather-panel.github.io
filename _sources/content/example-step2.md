# Hands-on exercise, step 2: preparing the demographic data

## Thinking about the data-generating process

First, let us think about the process that relates mortality to
weather. Weather fluctations can have impacts on all scales, but
generally when we are thinking of heat waves killing people, it is
because of direct exposure. The main data-generating process is local.

It is also non-linear. Both cold and hot weather kills people,
relative to deaths at moderate (pleasant) temperatures. We can model
this with a quadratic relationship. We need to choose some baseline
temperature for comparison purposes. For our example, we will use 20
$^{\circ}$C. The dose-response function will describe excess mortality, relative
to a day with an average temperature of 20 $^{\circ}$C.

We also need to weight our pixel data. We want the dose-response
function to be representative of a random individual, not a random
region-year data point, so we will weight gridcells by population.

Finally, the mortality data we will use is annual, while the weather
data is daily. We still want to estimate a daily dose-response
function, so we will say that take sums over all days of both the
weather and outcome data. The sum over daily death data is annual
death data, which is what we have.

Then, we want to transform the weather data by creating two predictor
variables, for the linear and quadratic terms relative to 20 $^{\circ}$C.

$$X_{1, i, y} = \sum_{t \in \text{Year}(y)} \sum_{p \in \Theta(i)} w_p (T_{p i t} - 20)$$
$$X_{2, i, y} = \sum_{t \in \text{Year}(y)} \sum_{p \in \Theta(i)} w_p (T_{p i t}^2 - 20^2)$$

where $w_p$ is the population in gridcell $p$.

## Download the population data

We can use the gridded population data from Gridded Population of the
World, since the weather data is not very high resolution. Download it
from
<https://sedac.ciesin.columbia.edu/data/set/gpw-v3-population-count>.

```{note}
Raster data is a type of digital image represented by reducible and 
enlargeable grids. Each cell (often referred to as a pixel) within this 
grid contains a value representing information, such as temperature, 
elevation, or a color value for image data. Each pixel stores a single 
value, and when visualized collectively, these pixels can represent 
complex images or spatial information. See more 
[here](https://desktop.arcgis.com/en/arcmap/latest/manage-data/raster-and-images/what-is-raster-data.htm) 
and [here](https://datacarpentry.org/organization-geospatial/01-intro-raster-data).

Common file formats for raster data include GeoTIFF, NetCDF, HDF, JPEG2000, 
and BIL, among others.
```

The code below assumes that you download the USA population count grid
as a `.bil` format at 2.5' resolution for 1990 (these are all options
on the Gridded Population of the World download form). The zip file
produced will contain a `usap90ag.bil` file, along with other
associated files that are required for this file to be loaded. For the
code below to work, the contents of the zip file should be placed in a
`data/pcount` directory.

Although this is US-specific data, the coverage extends far beyond the
contiguous US. It will be useful to clip it more tightly and aggregate
it to the scale of the weather. We also need it in NetCDF format, for
the aggregation step. Again, this code assumes that it is being run
from a directory `code`, sister to the `data` directory.

`````{tab-set}
````{tab-item} R

The R library `raster` is used for reading, writing, manipulating, analyzing 
and modeling of spatial data. 

```{code-block} R
library(raster)
rr <- raster("../data/pcount/usap90ag.bil")

rr2 <- aggregate(rr, fact=24, fun=sum)
rr3 <- crop(rr2, extent(-126, -65, 23, 51))

writeRaster(rr3, "../data/pcount/usap90ag.nc",
 overwrite=TRUE, format="CDF", varname="Population", varunit="people",
 xname="lon", yname="lat")
```
````
 
````{tab-item} Python
You will need to install the `rioxarray` package, using `pip install
rioxarray`, to open the `.bil` files.

```{code-block} python
import rioxarray
rr = rioxarray.open_rasterio("../data/pcount/usap90ag.bil")
rr = rr.sel(band=1, drop=True)

# Crop to US bounding box
xmin = -126
xmax = -65
ymin = 23
ymax = 51

sel_lon = (rr.x >= xmin) & (rr.x <= xmax)
sel_lat = (rr.y >= ymin) & (rr.y <= ymax)
rr2 = rr[sel_lat, sel_lon]

# Aggregate to 1-degree cells
rr3 = rr2.coarsen(x=24, y=24).sum()

rr3 = rr3.rename(x='lon', y='lat')
rr3.to_dataset(name="Population").to_netcdf("../data/pcount/usap90ag.nc4")
```
````
`````

Further details on the use of geographic data are discussed in the next chapter.

## Downloading the mortality data

The Compressed Mortality File (CMF) provides comprehensive,
county-scale mortality data for the United States. The data through
1988 is publically available, so we will use this for our analysis.

1. Go to the CMF information page,
   <https://www.cdc.gov/nchs/data_access/cmf.htm>.
2. Under "Data Availability", find the mortality and population files
   for 1979 - 1988, and download these.
3. Unzip these files, and place the resulting text files,
   `Mort7988.txt` and `Pop7988.txt` into the `data/cmf` folder.

These files report data as fixed-width ASCII text, meaning that spans
of characters on each line represent columns of the data.

In the mortality data file, `Mort7988.txt`, here are the elements of
interest: Characters 1 - 5 provide the FIPS code (FIPS is a 5 digit
code uniquely identifying each county in the US). Characters 6 - 9
report the year of death. The next few columns give the race, age, and
cause of death, but we will combine results across all of
these. Characters 20 - 23 report the number of deaths that correspond
to that county, year, race, age, and cause.

In the population data file, `Pop7988.txt`, the lines start with FIPS
codes and years, like the mortality data. But then the age groups are
all listed on the line: starting with character 19, the population in
each of 12 age groups is reported with 8 characters per age group
number (so, the first age group, 1 - 4 year-olds, is characters 19 -
26; then 5 - 9 year-olds is reported in characters 27 - 34; and so
on).

The population file also contains US-wide population numbers,
state-wide numbers, and county-level numbers. These are identified by
a column in the data with a 1 (US), 2 (state), or 3 (county). In the
code below, we label this the `type` column and only include type = 3
data.

## Preparing the mortality data

Here we sum across all races and ages and merge the mortality and
population data.

`````{tab-set}
````{tab-item} R
```{code-block} R
library(dplyr)

df.mort <- read.fwf("../data/cmf/Mort7988.txt",
   c(5, 4, 10, 4), col.names=c('fips', 'year', 'ignore', 'deaths'))

df2.mort <- df.mort %>% group_by(fips, year) %>% summarize(deaths=sum(deaths))

df.pop <- read.fwf("../data/cmf/Pop7988.txt",
   c(5, 4, 9, rep(8, 12), 25, 1), col.names=c('fips', 'year',
   'ignore', paste0('pop', 1:12), 'county', 'type'))

df2.pop <- df.pop %>% group_by(fips, year) %>% summarize(pop=sum(pop1 +
    pop2 + pop3 + pop4 + pop5 + pop6 + pop7 + pop8 + pop9 + pop10 +
    pop11 + pop12), type=type[1])

df3 <- df2.pop %>% left_join(df2.mort, by=c('fips', 'year'))
df3$deaths[is.na(df3$deaths)] <- 0

df4 <- subset(df3, type == 3)

write.csv(df4[, -which(names(df4) == 'type')], "../data/cmf/merged.csv", row.names=F)
```
````
 
````{tab-item} Python
```{code-block} python
import pandas as pd
df_mort = pd.read_csv("../data/cmf/Mort7988.txt", names = ['input'])

# parse input
df_mort2 = pd.DataFrame(df_mort.input.apply(
    lambda x: [
        x[slice(*slc)] for slc in [(0,5), (5,9), (20,len(x))]]).tolist(),
	columns=['fips', 'year', 'deaths'])

df_mort3 = df_mort2.apply(pd.to_numeric, errors='coerce')

df_mort4 = df_mort3.groupby(['fips', 'year']).sum().reset_index()
df_mort4.head()
```
| fips | year  |   deaths |
|:-----|-------|---------:|
| 1001 |  1979 |      225 |
| 1001 |  1980 |      221 |
| 1001 |  1981 |      221 |
| 1001 |  1982 |      223 |
| 1001 |  1983 |      267 |

```{code-block} python
df_pop = pd.read_csv("../data/cmf/Pop7988.txt", names = ['input'])

slices = [(0, 5), (5, 9), (9,18)] + \
         [(n, n+8) for n in range(18, 114, 8)] + \
         [(114, 139), (139, 140)]

# parse input
df_pop2 = pd.DataFrame(df_pop.input.apply(
    lambda x: [
        x[slice(*slc)] for slc in slices]).tolist(),
	columns=['fips', 'year', 'ignore'] + ["pop" + str(i) for i in range(1,13)] + ['county', 'type'])

cols = ['fips', 'year'] + ["pop" + str(i) for i in range(1,13)] + ['type']
df_pop3 = df_pop2[cols].apply(pd.to_numeric, errors='coerce')
df_pop4 = df_pop3[df_pop3.type == 3]

df_pop5 = df_pop4.groupby(['fips', 'year', 'type']).sum().reset_index()
df_pop5['pop'] = df_pop5.pop1 + df_pop5.pop2 + df_pop5.pop3 + df_pop5.pop4 + df_pop5.pop5 + df_pop5.pop6 + df_pop5.pop7 + df_pop5.pop8 + df_pop5.pop9 + df_pop5.pop10 + df_pop5.pop11 + df_pop5.pop12

df_pop5.head()
```
| fips | year | type |   pop1 |   pop2 |   pop3 |   pop4 |   pop5 |   pop6 |   pop7 |   pop8 |   pop9 |   pop10 |   pop11 |   pop12 |   pop |
|:-----|------|------|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|--------:|--------:|--------:|------:|
| 1001 | 1979 |    3 |   2022 |   2982 |   3248 |   3491 |   2640 |   4414 |   4211 |   3310 |   2457 |    1813 |     779 |     178 | 31545 |
| 1001 | 1980 |    3 |   2021 |   2952 |   3184 |   3495 |   2663 |   4463 |   4293 |   3373 |   2487 |    1848 |     795 |     181 | 31755 |
| 1001 | 1981 |    3 |   2037 |   2776 |   3132 |   3320 |   2664 |   4646 |   4210 |   3330 |   2516 |    1829 |     824 |     192 | 31476 |
| 1001 | 1982 |    3 |   2042 |   2707 |   3098 |   3190 |   2651 |   4714 |   4343 |   3327 |   2565 |    1835 |     856 |     201 | 31529 |
| 1001 | 1983 |    3 |   2044 |   2670 |   3054 |   3063 |   2625 |   4815 |   4408 |   3325 |   2613 |    1833 |     882 |     215 | 31547 |


```{code-block} python
df = df_pop5.merge(df_mort4, how='left', on=['fips', 'year'])
df.to_csv("../data/cmf/merged.csv", header=True)
```
````
`````

The final dataset (`merged.csv`) should look like:
		
| fips | year |   pop1 |   pop2 |   pop3 |   pop4 |   pop5 |   pop6 |   pop7 |   pop8 |   pop9 |   pop10 |   pop11 |   pop12 |   pop |   deaths |
|:-----|------|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|--------:|--------:|--------:|------:|---------:|
| 1001 | 1979 |   2022 |   2982 |   3248 |   3491 |   2640 |   4414 |   4211 |   3310 |   2457 |    1813 |     779 |     178 | 31545 |      225 |
| 1001 | 1980 |   2021 |   2952 |   3184 |   3495 |   2663 |   4463 |   4293 |   3373 |   2487 |    1848 |     795 |     181 | 31755 |      221 |
| 1001 | 1981 |   2037 |   2776 |   3132 |   3320 |   2664 |   4646 |   4210 |   3330 |   2516 |    1829 |     824 |     192 | 31476 |      221 |
| 1001 | 1982 |   2042 |   2707 |   3098 |   3190 |   2651 |   4714 |   4343 |   3327 |   2565 |    1835 |     856 |     201 | 31529 |      223 |
| 1001 | 1983 |   2044 |   2670 |   3054 |   3063 |   2625 |   4815 |   4408 |   3325 |   2613 |    1833 |     882 |     215 | 31547 |      267 |

You may also have a `type` column, if you used the python code.
