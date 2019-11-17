# Weather Panel Tutorial

# 1. Introduction to the Tutorial

Welcome to the weather panel data regression tutorial! This tutorial
will walk you through the steps necessary to relate socioeconomic
outcomes to weather data at high resolution. We will cover:

1. How to find and read weather data, and what you should be aware of when using it.
2. How to relate your socioeconomic outcomes to weather variables, and
   develop your regression specification.
3. How to work with shapefiles, and use them to generate your predictor variables.

This tutorial will assume a knowledge of econometrics and basic
experience with one scientific programming language (Stata, R, Matlab,
Julia, python). We try to provide examples in more than one language,
so you can get started.

At the same time, this tutorial asks you to perform every step
yourself. In particular, we do not provide prepared weather data or a
ready-made script to prepare it. Each particular case is too specific,
so you, the researcher, need to think through everything. This
tutorial is aimed at helping you do that.

For a theoretical foundation for the work of estimating weather and
climate responses,
read
[Climate Econometrics](https://www.annualreviews.org/doi/10.1146/annurev-resource-100815-095343) by
Solomon Hsiang. This tutorial complements this kind of theoretical
foundation with more practical advice.

## Definitions and conventions

We will use the following terms throughout this tutorial.

### Point data, region data, and gridded data

The data being related in climate econometric studies comes in three
forms:
1. Point data describes the conditions at a particular geographic
   point in space. For weather data, this is typically the location of
   a weather station or gauge. For socioeconomic data, it may be a
   field, factory, or household.
2. Region data describes an aggregate over an irregular space. Typical
   natural science regions include basins and water/land bodies. But
   economic region data is much more common, where quantities are
   totalled across an entire political unit before they are
   reported. The region over which a data point is provided is the
   geographic unit.
3. Gridded data provides information on a regular grid, almost always
   either across latitude and longitude, or distance north and
   east. Gridded data can come from remote sensing products or other
   models or analyses. In the latter case, it often is not clear
   exactly what is being measured (e.g., the point data at the
   centroid, or the average over a rectangular region). Keeping
   information at high resolution is important to avoid this question.
   
It is always appropriate to analyze data in the spatial structure it
is offered, even if translating it to another structure would be
easier. We will discuss this more later.

### Mathematical notation

In many cases, it will be useful to describe how to work with weather
variables irrespective of the specific data being represented. For
this, we introduce the following notation:

- $T_{it}$: Any weather variable for geographic unit $i$ in reporting period $t$.
- $T_{ps}$: Point or grid-level weather data for location/grid cell
  $p$, at a native temporal resolution indexed by $s$.
