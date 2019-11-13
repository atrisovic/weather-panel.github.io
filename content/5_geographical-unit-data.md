# 5. Generating geographical unit data


Geographical units are necessary for conducting location-specific economic analyses. A geographical unit, area or region, is a portion of a country or other region delineated for the purpose of administration, and as such, it is a common unit for recording economic outcome data.  For example, a“city” is a local administrative unit where the majority of the population lives in an urban center, while the“greater city” is an approximation of the urban center beyond of the administrative city boundaries[1](https://ec.europa.eu/eurostat/web/cities/spatial-units).

 Administrative units in economics analyses are typically politically defined regions, rather than regular grids, because socioeconomic data is collected and corresponding to the political regions. Besides, politically defined regions are also more relevant for policy-makers.

 When generating an administrative unit, it is important to capture territory with homogeneous features that are relevant to the study. For example, if the weather is relevant for the study, the administrative unit should be homogeneous concerning mean temperature and precipitation[2](https://bfi.uchicago.edu/wp-content/uploads/WP_2018-51_0.pdf).

 Administrative unit data can capture existing administrative units(high granularity) or groups of those units(lesser granularity). For example, the administrative unit database, [Global Administrative Regions](https://gadm.org), offers a granularity of 386,735 administrative areas for the entire world, that can be grouped according to the needs of a study.


## Finding and preparing a shapefile


A shapefile stores nontopological geometry and attribute information for the spatial features in a data set. The geometry for a feature is stored as a shape comprising a set of vector coordinates. Shapefiles can support point, line, and area features. Area features are represented as closed loop, double-digitized polygons [technical guide]. The shapes together with data attributes linked to each shape create the representation of geographic data like countries, rivers and lakes.

Despite its name indicating a singular file, a shapefile is actually a collection of at least three basic files that need to be stored in the same directory to be used. The three mandatory files have filename extensions `.shp`, `.shx` and `.dbf`. There may be additional files like `.prj` with the shape file’s projection information. All files must have the same name, for example:


    states.shp
    states.shx
    states.dbf


Technical description for shapefiles can be found [*HERE*](https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf)


## Software

The shapefile format is a commonly used to capture geospatial vector-data in geographic information system (GIS) software. QGIS is a free and open-source desktop geographic information system application that supports viewing, editing and analysis of geospatial data. ArcGIS is a proprietary software for working with maps and geographic data.

## Creating shapefiles

Shapefiles can be created with these methods [3](https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf):


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

First, try to perform all merging on abbreviation codes rather than names. At the level of countries, use [ISO alpha-3 codes](https://www.nationsonline.org/oneworld/country_code_list.htm) if possible.

Second, use fuzzy string matching. However, in this case you will need to inspect all of the matches to make sure that they are correct.

Third, construct “translation functions” for each dataset, which map the regional names in that dataset to a canonical list of region names. I usually choose the names in one dataset as my canonical list, and name the matching functions as `<dataset>2canonical` and `canonical2<dataset2>`.

# Suggestions when producing a panel dataset

1. Keep your code and your data separate. A typical file organization will be:
    - code/ - all of your analysis
    - sources/ - the original data files, along with information so you can find them again
    - data/ - merged datasets and intermediate results
    - figures/ - formatted figures and LaTeX tables.

2. If you aren’t sure what predictors you will need, create your dataset with a lot of possible predictors and decide later. Often merging together your panel dataset is laborious, and you do not want to do it more times than necessary.

