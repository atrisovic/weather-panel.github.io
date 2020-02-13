# 3. Weighting schemes

This section describes how to use different weighting schemes when aggregating gridded data to data regions.

## 3.1 Why spatial weighting schemes matter

Taking the unweighted average of weather within a region can misrepresent what populations, firms, or other phenomena of interest are exposed to. For example, an unweighted annual average temperature for Canada is about -8°C, but most of the population and agricultural activity is in climate zones with mean temperatures over 6°C, and the urban heat island effect can raise temperatures by another 4°C. The time of year matters too, and you should consider a weighting scheme across days within a year, or even hours within a day.

As described in section [Dealing with the spatial and temporal scales of economic processes](reduced-form-specification#Dealing-with-the-spatial-and-temporal-scales-of-economic-processes), the scale of a phenomenon matters. Many processes occur at a more local scale than that which data is collected. The motivation for weighting is different for aggregation that represents averaged phenomena vs. phenomena that respond to averaged weather, and the sequence of analysis changes.

In the first case, the phenomenon occurs locally, in response to local weather. In this case, we perform weighted aggregations to reflect the amount of the phenomenon in each location. For example, we would use population weighting to model the effects of heat on people. In this case, the order of operations is:

1. Transform weather into the terms of the model specification.
2. Average these transformed terms across space using a weighting scheme.

In the second case, the phenomenon occurs at a data region level, in response to averaged weather. In this case, the weighting scheme reflects the relative importance of weather in different regions to the whole. For example, weighting rainfall by the distance from a shore could be important to predict the declaration of states of emergency. The order of operations is:

1. Average the weather across space using a weighting scheme.
2. Transform the averaged weather to the model specification.

In either case, the weighting scheme is the same:

$$T_{it} = \sum_{p \in P(i)} w_p T_{pt} \text{ such that } \sum_p w_{p \in P(i)} = 1 \,\,\,\forall i$$

where $w_p$ is the weight for pixel $p$, and $P(i)$ is the set of pixels in data region $i$.


## 3.2 Kinds of weight schemes and data sources

Weighting data files come in a wide range of file formats, since any gridded data file is appropriate. The most common data types are CSV, ASC, GeoTIFF, and BIL files. In each case, you (or your code) need to know (1) the format of the data values, (2) the spatial gridding scheme, (3) the projection, and (4) how missing data is handled.


1. Format of the data values: Data values can be written out in text (as with CSV and ASC files) or in a binary representation (GeoTIFF and BIL). If the values are written as text, delimiters will be used to separate them (comma for CSV, spaces for ASC).
2. The spatial gridding scheme is determined by 6 numbers: a latitude and longitude of an origin point, a horizontal and vertical cell lengths, and a number of rows and columns.
    - The most common origin point is the location of the lower-left corner of the lower-left grid cell. For example, for a global dataset, that might be 90°S, 180°W, which is represented in x, y coordinates as (-180, -90). Sometimes (particularly with NetCDF files), grid cell center locations will be used instead.
    - Grid cell sizes are often given as decimal representation of fractions of a degree, such as 0.0083333333333 = 1 / 120 of a degree. This is the grid cell size needed globally to ensure a km-scale resolution. Usually the horizontal and vertical grid cell lengths are the same, and reported as a single number.
    - The number of grid cells is the most common way to describe the spatial coverage of the dataset. A global dataset will have 180 / cellsize rows and 360 / cellsize columns.


Based on this information, you can calculate which grid cell any point on the globe falls into:

$$\text{row} = \text{floor}\left(\frac{\text{Latitude} - y_0}{\text{CellSize}}\right),$$ 

$$\text{column} = \text{floor}\left(\frac{\text{Longitude} - x_0}{\text{CellSize}}\right)$$


where $x_0, y_0$ is lower-left corner point. If the center of the lower-left cell was given, $x_0 = x_\text{llcenter} - \frac{\text{CellSize}}{2}$, $y_0 = y_\text{llcenter} - \frac{\text{CellSize}}{2}$.


For CSV files, you will need to keep track of this data yourself. ASC files have it at the top of the file, BIL files have a corresponding HDR file with the data, and GeoTIFF files have it embedded in the file which you can read with various software tools.


3. Projections are a way to map points on the globe (in latitude-longitude space) to a point in a flat x, y space. While this is important for visualizing maps, it can just be a nuisance for gridded datasets. The most common “projection” for gridded datasets is an equirectangular projection, and we have been assuming this above. This is variously referred to as `1`, `ll`, `WGS 84`, and `EPSG: 4326` (techically, WGS 84 species how latitude and longitude are defined, and EPSG:4326 specifies a drawing scheme where x = longitude and y = latitude). However, you will sometimes enounter grids in terms of km north and km east of a point, and then you may need to project these back to latitude-longitude and regrid them.
4. All of these allow missing data to be handled. Typically, a specific numerical representation, like -9999, will be used. This is specified the same way that the gridding scheme is.

Implementation Notes: Reading gridded data.

| R                         | Python                                                                                |
| ------------------------- | ------------------------------------------------------------------------------------- |
| Use the `raster` library. | Take a look at https://github.com/jrising/research-common/tree/master/python/geogrid. |

In some cases, it is appropriate and possible to use time-varying weighting schemes. For example, if population impacts are being studied, and the scale of the model is individuals, annual estimate of population can be used. This kind of data is often either in NetCDF format (see above), or as a collection of files.

Implementation Notes: Downloading multiple files and reading them.

```R
library(raster)
for (year in 1980:2010) {
  download.file(paste0("http://archive.org/awesome/", year, ".zip"), "temp.zip")
  filename <- paste0("prefix-", year, ".asc")
  zip.file.extract(filename, "temp.zip")
  r <- raster(filename)
  <perform weighting>
}
```

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

## 3.3 Aligning weather and weighting grids

The first step to using a gridded weighting dataset is to make it
conform to data grid definition used by your weather data.  Here we
assume that both are regular latitude-longitude
grids. See
[Kinds of weight schemes and data sources](#Kinds-of-weight-schemes-and-data-sources) to
understand the grid scheme for your weighting file; note that gridded
weather data often reports the center of each grid cell, rather than
the corner.

The following recipe should work for most cases to align weighting data with a weather grid.


### Step 1: **Resample the weighting data until the grid of the weighting data evenly divides up the weather data.**

Resampling in this case means increasing the resolution of the weighting grid by some factor. You want to do this so that two conditions to be met after resampling: (A) The new resolution should be an integer multiple of the weather resolution. (B) The horizontal and vertical grid lines of the weather data coincide with the resampled grid lines of the weighting data.

Example: Suppose the weather data is nearly global, from 180°W to 180°E, 90°S to 86°N, as the case with LandScan population data. The resolution is 1/120th of a degree. You want to use this to weight PRISM data for the USA, with an extent 125.0208 to 66.47917°W, 24.0625 to 49.9375°N, with a resolution of 1/24th of a degree.

```R
landscan <- raster("…/w001001.adf")
landscan
## class       : RasterLayer
## dimensions  : 21120, 43200, 912384000  (nrow, ncol, ncell)
## resolution  : 0.008333333, 0.008333333  (x, y)
## extent      : -180, 180, -90, 86  (xmin, xmax, ymin, ymax)
prism <- raster("PRISM_tmax_stable_4kmM2_2000_all_asc")
prism
## class       : RasterLayer
## dimensions  : 621, 1405, 872505  (nrow, ncol, ncell)
## resolution  : 0.04166667, 0.04166667  (x, y)
## extent      : -125.0208, -66.47917, 24.0625, 49.9375  (xmin, xmax, ymin, ymax)
```

Start by throwing away extraneous data, by cropping the LandScan to, say,
126 to 66°W, 24 to 50°N.

```R
landscan <- crop(landscan, extent(-126, -66, 24, 50))
```

Now, note that the edge of the PRISM data is in the middle of the LandScan grid cells:
    120 * (180 - 125.0208) = 6597.5
    That means that you need to increase the resolution of the LandScan data by 2 to line it up. In general, you will need to increase it by 1 / (the trailing decimal).

```R
landscan <- disaggregate(landscan, fact=2) / 4
```

We divide by 4 so that the total population remains the same.


### Step 2: **Clip the two datasets so that they line up.**


In the example above, after increasing the resolution of the LandScan data, we clip it again.

```R
landscan <- crop(landscan, extent(-125.0208, -66.47917, 24.0625, 49.9375))
```

### Step 3: **Re-aggregate the weighting data, so that it has the same resolution as the weather data.**


In the example above, the resolution of the dataset has become 1/240th, and we can write aggregate by a factor of 10 for it to match the PRISM data:

```R
landscan <- aggregate(landscan, fact=10, fun=sum)
```

## 3.4 Plotting your results

Now take a moment to visualize the data that you have created. This is
a good way to make sure you haven't made any mistakes and to wow your
less climate-adept colleagues in presentations.

To get an initial view of your data, you can just plot your data as a
matrix. In R, use the `image` function; similar functions exist in
other languages. The trick is to make sure that you specify the
coordinates when you plot the map.

Here's an easy case, using population data from the (Gridded
Population of the
World)[https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-rev11/data-download]
dataset.

```R
library(raster)
## Load the data
rr <-
raster("gpw_v4_population_density_adjusted_to_2015_unwpp_country_totals_rev11_2020_2pt5_min.asc")

## Display it!
image(rr)
```

![Result of `image(rr)`.](images/examples/image-gpw.png)

But that wasn't any fun. Let's try again with something more
complicated.

First, we'll download (historical maximum temperature)[https://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NCEP-NCAR/.CDAS-1/.pc6190/.Diagnostic/.above_ground/.maximum/.temp/[T+]average/] data from the
easy-to-use IRI data library.

```R
library(ncdf4)

## Load the data
nc <- nc_open("data.nc")
temp <- ncvar_get(nc, 'temp')

## Display it!
image(temp)
```

![Result of `image(temp)`.](images/examples/image-tmax.png)

This is R's default way of showing matrices, with axes that go from
0 - 1. What's worse, the map is up-side-down, though it will take some
staring to convince yourself ot this. The reason is that NetCDFs
usually have the upper-left corner representing the extreme
North-West. But R's `image` command shows the upper-left corner in the
lower-left.

We are also going to plot the countries, so this is easier to
interpret. And to do that, we need to rearrange the data so it goes
from -180 to 180, rather than 0 to 360 as currently. Here's our second
attempt:

```R
## Extract the coordinate values
lon <- ncvar_get(nc, "X")
lat <- ncvar_get(nc, "Y")

## Rearrange longitude to go from -180 to 180
lon2 <- c(lon[lon >= 180] - 360, lon[lon < 180])
temp2 <- rbind(temp[lon >= 180,], temp[lon < 180,])

## Display it, with map!
library(maps)
image(lon2, rev(lat), temp2[,ncol(temp2):1])
map("world", add=T)
```

![Result after `map(world)`.](images/examples/image-tmax-flip.png)

Now, for our production-ready map, we're going to switch to
`ggplot2`. In `ggplot`, all data needs to be as dataframes, so we need
to convert the matrix into a dataframe (with `melt`) and the map into
a dataframe (with `map_data`):

```R
## Convert temp2 to a dataframe
library(reshape2)
rownames(temp2) <- lon2
colnames(temp2) <- lat
temp3 <- melt(temp2, varnames=c('lon', 'lat'))

## Convert world map to a dataframe
library(ggmap)
world <- map_data("world")

## Plot everything
ggplot() +
    geom_raster(data=temp3, aes(x=lon, y=lat, fill=value)) +
    geom_polygon(data=world, aes(x=long, y=lat, group=group), colour='black', fill=NA)
```

![Result after `ggplot`.](images/examples/ggplot-tmax.png)

And now we're ready to production-ready graph. The biggest change
will be the addition of a map projection. You'll want to choose your
projection carefully, since people are bound to judge you for it.

![Considerations for projections.](https://imgs.xkcd.com/comics/map_projections.png)

Using the projection, we can now make the final version of this
figure. Note that you will need to use `geom_tile` rather than
`geom_raster` when plotting grids over projections, and this can be
quite a bit slower. I also use a color palette from
(ColorBrewer)[http://colorbrewer2.org/], an excellent resource for
choosing colors.

```R
library(RColorBrewer)
ggplot() +
    geom_tile(data=temp3, aes(x=lon, y=lat, fill=value - 273.15)) +
    geom_polygon(data=world, aes(x=long, y=lat, group=group), colour='black', fill=NA, lwd=.2) +
    coord_map(projection="mollweide", ylim=c(-65, 65)) + xlim(-180, 180) +
    theme_light() + theme(panel.ontop=TRUE, panel.background=element_blank()) +
    xlab(NULL) + ylab(NULL) + scale_fill_distiller(name="Average\nMax T.", palette="YlOrRd", direction=1) +
    theme(legend.justification=c(0,0), legend.position=c(.01,.01))
```

![Result after `ggplot`.](images/examples/ggplot-tmax-final.png)
