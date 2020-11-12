# Generating geographical unit data

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

```{seealso}
[Using Weather Data and Climate Model Output in Economic Analyses of Climate Change](https://academic.oup.com/reep/article/7/2/181/1522753) describes the common pitfalls in translating weather data into geographical unit data.
```

## Geographic information systems

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


````{note}
Despite its name indicating a singular file, a shapefile is actually a collection of at least three basic files that need to be stored in the same directory to be used. The three mandatory files have filename extensions `.shp`, `.shx` and `.dbf`. There may be additional files like `.prj` with the shape file’s projection information. All files must have the same name, for example:

```
   states.shp
   states.shx
   states.dbf
```
````


## Finding shapefiles

It is usually possible to find a shapefile corresponding to a set of
socioeconomic data by searching around online. Many governments will
have an internal search engine for their GIS data. Two frequently
useful resources are
the [Global Administrative Regions](https://gadm.org) database, which
has standard administrative units across the globe,
and [Natural Earth](http://www.naturalearthdata.com/) which has
clean physical shape information.


## Creating shapefiles

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

