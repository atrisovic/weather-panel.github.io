## Weather Mortality in the United States, Step 2: Understanding the outcomes

### Thinking about the data-generating process

First, let us think about the process that relates mortality to
weather. Weather fluctations can have impacts on all scales, but
generally when we are thinking of heat waves killing people, it is
because of direct exposure. The main data-generating process is local.

It is also non-linear. Both cold and hot weather kills people,
relative to deaths at moderate (pleasant) temperatures. We can model
this with a quadratic relationship. We need to choose some baseline
temperature for comparison purposes. For our example, we will use 20
C. The dose-response function will describe excess mortality, relative
to a day with an average temperature of 20 C.

We also need to weight our pixel data. We want the dose-response
function to be representative of a random individual, not a random
region-year data point, so we will weight gridcells by population.

Finally, the mortality data we will use is annual, while the weather
data is daily. We still want to estimate a daily dose-response
function, so we will say that take sums over all days of both the
weather and outcome data. The sum over daily death data is annual
death data, which is what we have.

Then, we want to transform the weather data by creating two predictor
variables, for the linear and quadratic terms relative to 20 C.

$$X_{1, i, y} = \sum_{t \in \text{Year}(y)} \sum_{p \in \Theta(i)} \psi_{p} (T_{p i t} - 20)$$
$$X_{2, i, y} = \sum_{t \in \text{Year}(y)} \sum_{p \in \Theta(i)} \psi_{p} (T_{p i t}^2 - 20^2)$$

where $\psi_{p}$ is the population in gridcell $p$.

### Download the population data

https://sedac.ciesin.columbia.edu/data/set/gpw-v3-population-count

```R
library(raster)
rr <- raster("~/groups/weatherpanels/weather-panel.github.io/example/data/pcount/usap90ag.bil")

rr2 <- aggregate(rr, fact=24, fun=sum)
rr3 <- crop(rr2, extent(-126, -65, 23, 51))

writeRaster(rr3, "~/groups/weatherpanels/weather-panel.github.io/example/data/pcount/usap90ag.nc4",
 overwrite=TRUE, format="CDF", varname="Population", varunit="people",
 xname="lon", yname="lat")
```

### Downloading the mortality data

The Compressed Mortality File (CMF) provides comprehensive,
county-scale mortality data for the United States. The data through
1988 is publically available, so we will use this for our analysis.

1. Go to the CMF information page,
   https://www.cdc.gov/nchs/data_access/cmf.htm
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
