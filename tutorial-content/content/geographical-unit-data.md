# Generating geographical unit data
 
```{admonition} Key objectives and decision points
:class: note

Objectives:
- Understand what geographical unit and administrative unit data are
- Understand shapefiles, how to obtain them and how to work with them
- Understand how to incorporate weights into your data.
- Understand how to match up gridded data with different grids.

Decision points:
- How to incorporate geographical and administrative units in your analysis?
- How to generate weather measures that will correspond to your economic data and geographical regions?
- Does your data-generating process occur locally or regionally?
- Select the weighting scheme most appropriate for your data.
```

Socioeconomic data is collected corresponding to geographical units, such as states, countries, provinces, or municipalities, which is a portion of a country delineated for administration, and hence, often called  "administrative units". For that reason, administrative units (or politically-defined regions) are frequently used in economic analysis rather than regular grids. Communicating data analysis results in administrative units is also particularly effective since politically defined regions are relevant for policy-makers. 

The top-level of this hierarchy of administrative units is **ADM0**, referring to countries; **ADM1** is the first level of political division, usually called states or provinces; **ADM2** is the second level of division, and has a wider range of names across the globe (see example below).
 
```{list-table} Example of administrative units table for [Philippines](http://www.eki.ee/knab/adm2.htm)
:header-rows: 1
 
* - ADM0
  - ADM1
  - ADM2
* - Philippines (PH)
  - Ilocos, Iloko
  - Ilocos Norte, Hilagang Iloko (ILN)
* -
  -
  - Ilocos Sur, Timog Iloko (ILS)
* -
  -
  - ...
* - 
  - Cagayan Valley, Lambak ng Kagayan
  - Batanes (BTN)
* -
  -
  - Cagayan, Kagayan (CAG)
* -
  -
  - Isabela (ISA)
* -
  - ...
  - ...
```
 
Administrative unit data can capture existing administrative units (high granularity) or groups of those units (lesser granularity). For example, the administrative unit database, [Global Administrative Regions](https://gadm.org), offers a granularity of 386,735 administrative areas for the entire world, that can be grouped according to the needs of a study.

When aggregating administrative units, it is important to capture territories with homogeneous features that are relevant to the study. For example, if the weather is relevant for the study, the administrative units should be fairly homogeneous concerning mean temperature and precipitation.
 
```{seealso}
[Using Weather Data and Climate Model Output in Economic Analyses of Climate Change](https://doi.org/10.1093/reep/ret016) describes the common pitfalls in translating weather data into geographical unit data.
```
 
## Geographic information systems (GIS)
 
Geographic information system (GIS) is a computer system for capturing, storing, analyzing and displaying geographical data, and it has been commonly used for spatial research. GIS refers to the representation of polygons, curves, and points, and their use in data analysis.

QGIS is a free and open-source desktop geographic information system application that supports viewing, editing and analysis of geospatial data. ArcGIS is proprietary software for working with maps and geographic data. These systems also allow you to perform many kinds of spatial analysis. Some of the most commonly useful are calculating Zonal Statistics, such as the average of a gridded dataset across each shapefile region, and Merging units, and translating points to polygons with Voronoi Polygons.

The boundaries of administrative units are described in specialized files that store geometry and attribute information for spatial features. The geometry for a feature is represented by a vector of coordinates, and area features are represented as closed-loop, double-digitized polygons. These shapes and their data attributes create the representation of geographic features like countries, rivers, and lakes.

Describing shapes requires specialized data formats. The most common data format is an [ESRI Shapefile](https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf), and we will focus on these in the tutorial. You may also encounter GDB (common in hydrology), GeoJSON (used with web interfaces), KXML (used by Google Earth), and OSM (from OpenStreetMap) files. All of these can be converted to Shapefiles, using GIS software like QGIS.
  
 
## Obtaining shapefiles
 
It is usually possible to find online a shapefile that corresponds to a set of socioeconomic data. Many governments have an internal search engine for their GIS data. Two generally useful resources are the [Global Administrative Regions](https://gadm.org) database, which has standard administrative units across the globe, and [Natural Earth](http://www.naturalearthdata.com/), which has clean physical shape information.
 
In some cases, you will need to create a shapefile from scratch. The most common way of doing this is by defining ("clicking out") the shape of each polygon in QGIS or ArcGIS, which can be done in the following steps:
 
1. Find an image that shows the regions that you want to digitize and import it into QGIS or ArcGIS.
2. Typically, published images will not report the projection that was used, but you will need to find a mapping between points in the image and latitude-longitude coordinates. Use the [GDAL Georeferencer](https://www.qgistutorials.com/en/docs/3/georeferencing_basics.html) to make this a point-and-click task.
3. Create new polygons by clicking around the edges of the polygon.


## Working with shapefiles

Once you obtain your shapefiles, you should first view them in a software system like QGIS or ArcGIS to ensure everything is in order. Both R and Python support working with shapefiles and spatial data. See the following examples:

`````{tab-set}
````{tab-item} R
To read shapefiles you could use a package like `maptools`, `rgdal`, `sf`, or `PBSmapping`.
 
```{code-block} R
library(maptools)
shapefile <- readShapePoly("/my_shapefile.shp")
 
# or
 
library(PBSmapping)
shapefile <- importShapefile("/my_shapefile.shp")
```
````
 
````{tab-item} Python
 
Shapefiles can be opened with Python packages in a few different ways:
 
```{code-block} python
import fiona
shape = fiona.open("my_shapefile.shp")
print shape.schema
{'geometry': 'LineString', \
'properties': OrderedDict([(u'FID', 'float:11')])}
 
# or
 
import shapefile
shape = shapefile.Reader("my_shapefile.shp")
 
# or
 
import geopandas as gpd
shapefile = gpd.read_file("my_shapefile.shp")
print(shapefile)
```
````
`````

````{caution}
Despite its name indicating a singular file, a shapefile is actually a collection of at least three basic files that need to be stored in the same directory to be used. The three mandatory files have filename extensions `.shp`, `.shx` and `.dbf`. There may be additional files like `.prj` with the shape file’s projection information. All files must have the same name, for example:
 
```
  states.shp
  states.shx
  states.dbf
```
````