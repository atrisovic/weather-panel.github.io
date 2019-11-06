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