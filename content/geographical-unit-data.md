# 4. Generating geographical unit data

## 4.1 Introduction

A geographical unit, area or region, is a portion of a country or other region delineated for the purpose of administration, and as such, it is a common unit for recording economic outcome data.  These geographic regions may be defined in subtle, non-intuitive ways.  For example, a “[city](https://ec.europa.eu/eurostat/web/cities/spatial-units)” is a local administrative unit where the majority of the population lives in an urban center, while the “[greater city](https://ec.europa.eu/eurostat/web/cities/spatial-units)” is an approximation of the urban center beyond the administrative city boundaries.

One kind of geographic region is simply called an "administrative
unit", and refers to states and provinces, or counties and
municipalities. The top-level of this hierarchy of administrative
units is "ADM0", referring to countries; "ADM1" is the first level of
political division, usually called states or provinces; "ADM2" is the
second level of division, and has a wider range of names across the
globe.
 Administrative units in economics analyses are typically politically-defined regions, rather than regular grids, because socioeconomic data is collected and corresponding to the political regions. They can also be more effective for communicating results, since politically defined regions are also more relevant for policy-makers.

 Administrative unit data can capture existing administrative units (high granularity) or groups of those units (lesser granularity). For example, the administrative unit database, [Global Administrative Regions](https://gadm.org), offers a granularity of 386,735 administrative areas for the entire world, that can be grouped according to the needs of a study.
When aggregating administrative units, it is important to capture
territories with homogeneous features that are relevant to the
study. For example, if the weather is relevant for the study, the
administrative unit should be fairly homogeneous concerning mean temperature and precipitation.

[Using Weather Data and Climate Model Output in Economic Analyses of Climate Change](https://academic.oup.com/reep/article/7/2/181/1522753) describes
the common pitfalls in translating weather data into geographical unit data.

## 4.2 Geographic information systems

Much is made of geographic information system (GIS), but these have
long since become unnotably common parts of spatial research. GIS
refers to the representation of polygons, curves, and points, and
their use in data analysis.

Describing shapes requires specialized data formats. The most common
data format is an ESRI Shapefile, and we will focus on these for this
tutorial. You may also encounter GDB (common in hydrology), GeoJSON
(used with web interfaces), KXML (used by Google Earth), and OSM (from
OpenStreetMap) files. All of these can be converted to Shapefiles,
using GIS software like QGIS.

A [shapefile](https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf) also stores geometry and attribute information for the spatial features in a data set. The geometry for a feature is stored as a shape comprising a vector of coordinates. Area features are represented as a closed-loop, double-digitized polygons. The shapes together with data attributes linked to each shape create the representation of geographic data like countries, rivers and lakes.

Despite its name indicating a singular file, a shapefile is actually a collection of at least three basic files that need to be stored in the same directory to be used. The three mandatory files have filename extensions `.shp`, `.shx` and `.dbf`. There may be additional files like `.prj` with the shape file’s projection information. All files must have the same name, for example:

> `states.shp` 

> `states.shx` 

> `states.dbf` 

## 4.3 Finding shapefiles

It is usually possible to find a shapefile corresponding to a set of
socioeconomic data by searching around online. Many governments will
have an internal search engine for their GIS data. Two frequently
useful resources are
the [Global Administrative Regions](https://gadm.org) database, which
has standard administrative units across the globe,
and [Natural Earth](http://www.naturalearthdata.com/) which has
clean physical shape information.


## 4.4 Creating shapefiles

In some cases, you will have to make the shapefile from scratch. The
most common ways of doing this is by clicking out the shape of each
polygon. This generally requires a few steps.

1. Find an image that shows the regions that you want to digitize and
   import the image into QGIS or ArcGIS.
2. Typically, published images will not report the projection that was
   used, but you will need to find a mapping between points in the
   image and latitude-longitude coordinates. Use
   the
   [GDAL Georeferencer](https://www.qgistutorials.com/en/docs/georeferencing_basics.html) to
   make this a point-and-click task.
3. Create new polygons by clicking around the edges of the polygon.


## 4.5 Working with shapefiles

Your first step should be to view your shapefile in a software system
like QGIS or ArcGIS.
QGIS is a free and open-source desktop geographic information system application that supports viewing, editing and analysis of geospatial data. ArcGIS is proprietary software for working with maps and geographic data.

These systems also allow you to perform many kinds of spatial
analysis. Some of the most commonly useful are calculating Zonal
Statistics, such as the average of a gridded dataset across each
shapefile region, and Merging units, and translating points to
polygons with Voronoi Polygons.

 Shapefiles can be opened with Python packages like the following

- **Fiona**,

```python
import fiona
shape = fiona.open("my_shapefile.shp")
print shape.schema
{'geometry': 'LineString', \ 
'properties': OrderedDict([(u'FID', 'float:11')])}
```

- **PyShp** or

```python
import shapefile
shape = shapefile.Reader("my_shapefile.shp")
```

- **geopandas** (among other packages).

```python
import geopandas as gpd
shapefile = gpd.read_file("/my_shapefile.shp")
print(shapefile)
```

Data analysis software R also supports working with spatial data. To
read shape files you could use a package like `maptools`,  `rgdal`,
`sf`, or `PBSmapping`.

- **maptools**
```R
library(maptools)
shapefile <- readShapePoly("/my_shapefile.shp")
```

- **PBSmapping**
```R
library(PBSmapping)
shapefile <- importShapefile("/my_shapefile.shp")
```

## 4.6 Constructing averages within spatial units

Now, you probably have a gridded spatiotemporal dataset of historical
weather and economic output data specific to shapefile regions.  The
next step is construct the weather measures that will correspond to
each of your economic data observations.  To do this, you will need to
construct a weighted average of the weather in each region for each
timestep.

In some cases, there are tools available that will help you do
this. If you are using area weighting (i.e., no weighting grid) and
your grid is fine enough that every region fully contains at least one
cell, one tool you can use is
[regionmask](http://www.matteodefelice.name/post/aggregating-gridded-data/).

If your situation is more complicated, or if you just want to know how
to do it yourself, it is important to set up the mathematical process
efficiently since this can be a computationally expensive step.

The regional averaging process is equivalent to a matrix
transformation: $$w_\text{region} = A w_\text{gridded}$$

where $w_\text{region}$ is a vector of weather values across
regions, in a given timestep; and $w_\text{gridded}$ is a vector of
weather values across grid cells.  Suppose there are $N$ regions and
$R C$ grid cells, then the transformation matrix $A$ will be $N x
R C$. The $A$ matrix does not change over time, so once you
calculate it, the process for generating each time step is faster.

Below, we sketch out two approaches to generating this matrix, but a
few comments are common no matter how you generate it.

1. The sum of entries across each row should be 1. Missing values can
   cause reasonable-looking calculations to produce rows sums that are
   less than one, so make sure you check.
   
2. This matrix is huge, but it is very sparse: most entries
   are 0. Make sure to use a sparse matrix implementation (e.g.,
   `sparseMatrix` in R, `scipy.sparse` in python, `sparse` in Matlab).
   
3. The $w_\text{gridded}$ data starts as a matrix, but here we use
   it as a vector.  It is easy (in any language) to convert a matrix
   to a vector with all of its values, but you need to be careful
   about the order of the entries, and order the columns of $A$ the
   same way.
   
   In R, `as.vector` will convert from a matrix to a vector, with each
   *column* being listed in full before moving on to the next column.
   
   In python, `numpy.flatten` will convert a numpy matrix to a vector,
   with each *row* being listed in full before moving on to the next
   row.
   
   In Matlab, indexing the grid with `(:)` will convert from an array
   to a vector, with each *column* being listed in full before moving
   on to the next column.

### Version 1. Using grid cell centers

The easiest way to generate weather for each region in a shapefile is
to generate a collection of points at the center of each grid
cell. This approach can be used without generating an $A$ matrix,
but the matrix method improves efficiency.

As an example, in R, you generate these points like so:
```R
longitudes <- seq(longitude0, longitude1, gridwidth)
latitudes <- seq(latitude0, latitude1, gridwidth)
pts <- expand.grid(x=longitudes, y=latitudes)
```

Now, you can iterate through each region, and get a list of all of the
points within each region. Here's how you would do that with the
`PBSmapping` library in R:
```R
events <- data.frame(EID=1:nrow(pts), X=pts$x, Y=pts$y)
events <- as.EventData(events, projection=attributes(polys)$projection)
eids <- findPolys(events, polys, maxRows=6e5)
```

Then you can use the cells that have been found (which, if you've set
it up right, will be in the same order as the columns of $A$) to
fill in the entries of your transformation matrix.

If your regions are not much bigger than the grid cells, you may get
regions that do not contain any cell centers. In this case, you need
to find whichever grid cell is closest. For example, in R, using
`PBSmapping`:
```R
centroid <- calcCentroid(polys, rollup=1)
dists <- sqrt((pts$x - centroid$X)^2 + (pts$y - centroid$Y)^2)
closest <- which.min(dists)[1]
```

### Version 2. Allowing for partial grid cells

Just using the grid cell centers can result in a poor representation
of the weather that overlaps each region, particularly when the
regions are of a similar size to the grid cells. In this case, you
need to determine how much each grid cell overlaps with each region.

There are different ways for doing this, but one is to use QGIS.
Within QGIS, you can create a shapefile with a rectangle for each grid
cell. Then intersect those with the region shapefile, producing a
separate polygon for each region-by-grid cell combination. Then have
QGIS compute the area of each of those regions: these will give you
the portion of grid cells to use.

## 4.7 Matching names

It is often necessary to match names within two datasets with geographical unit observations. For example, a country’s statistics ministry may report values by administrative unit, but to find out the actual spatial extent of those units, you may need to use the GADM shapefiles.

Matching observations by name can be annoyingly time-consuming. These problems even exist at the level of countries, where, for example, North Korea is regularly listed as “Democratic People's Republic of Korea”, “Korea, North”, and “Korea, Dem. Rep.”; and information is indiscriminately reported for isolated regions or sovereign states (Guadeloupe’s data may or may not be included in France). Reporting units may not correspond to standard administrative units at all, and you will need to aggregate or disaggregate regions to match between datasets.

Here are some suggestions for dealing with the mess that is political geography:

First, try to perform all merging on abbreviation codes rather than names. At the level of countries, use [ISO alpha-3 codes](https://www.nationsonline.org/oneworld/country_code_list.htm) if possible.

Second, use fuzzy string matching. However, in this case, you will need to inspect all of the matches to make sure that they are correct.

Third, construct “translation functions” for each dataset, which map the regional names in that dataset to a canonical list of region names. I usually choose the names in one dataset as my canonical list, and name the matching functions as `<dataset>2canonical` and `canonical2<dataset2>`.

