# 2. Developing a reduced-form specification

This section describes some of the considerations that go into
developing a reduced-form specification using weather panel data. Our
discussion here will be very practical and limited to nonlinear panel
regressions, so also
read
[Estimating the Economic Impacts of Climate Change Using Weather Observations](https://academic.oup.com/reep/article/14/1/1/5718007) for
a review of the available econometric techniques and their strengths
and weaknesses.  For an extensive review of the results available from
the climate econometric literature and the empirical methods used to
identify them, a good resource
is
[Social and Economic Impacts of Climate](http://science.sciencemag.org/content/353/6304/aad9837).

## 2.1. Choosing weather variables

The choice of weather variables depends on the question we are trying
to answer, and there are many forms to represent any given
variable. For example, in the case of temperature, we can use
$T_{avg}$, $T_{min}$, $T_{max}$, days above 30 C, heating and cooling
degree-days, or growing degree-days. Morevoer, it is very important to
first think about possible *mechanism(s)* behind a change witnessed in
the environment, and then only make choices for variables that can
explain that mechanism. A few of the important and frequently-used
weather variables are listed below, and why you might choose them:

- **Temperature:** Temperature relationships are often preferred in
  climate impacts research, because temperature is more predictable
  than many other weather variables. There are various measures of temperature that can be used. Some of them are listed below:
    1. *$T_{min}$, $T_{max}$:*  Many socioeconomic processes are more
       sensitive to extreme temperatures than to variation in the
       average. This is also useful when temperature variation is
       large, leading to significant differences in the cold end and hot end responses. These are important metrics when heterogeneity within time units matters, and may better capture heat waves and cold spells. Also, note that $T_{min}$ better reflects nighttime temperatures while $T_{max}$ better reflects daytime temperatures. Not all datasets include $T_{min}$ or $T_{max}$. 
    2. *$T_{avg}$:*  A good mean metric for seeing average response
       over the temperature support, when there is not much variation
       in temperature within each time unit considered in the
       study. $T_{avg}$ is most appropriate when there is some natural
       inertia in the response, so that the dependent variable is
       responding to a kind of average over the last 24 hours. Note
       that $T_{avg}$ is often just equal to $(T_{min} + T_{max}) / 2$, unless calculated from sub-daily data.
    3. [*HDD/CDD & GDD:*](https://www.degreedays.net/introduction)
       Degree days (DD) are a measure of ’how much’ and for ’how long’
       the outside air temperature was above or below a certain
       level. A sinusoid between $T_{min}$ and $T_{max}$ can be used
       to approximate DDs from daily data.
    4. *Heat Index & Wet Bulb Temperature*: (see below on humidity)

- **Humidity:** There are mainly three metrics for humidity
  measurements: absolute, relative (often "RH"), and
  specific. Absolute humidity describes the water content of air,
  expressed in grams per cubic metre or grams per kilogram. Relative
  humidity is expressed as a percentage relative to a maximum humidity
  value for a given temperature. Specific humidity is the ratio of water vapor mass to total moist air parcel mass. Human (and animal) bodies rely on evaporative cooling to regulate temperature in hot weather, the effectiveness of which depends on how much more moisture the atmosphere can currently hold (1 - RH). As a result, various temperature-humidity metrics have been developed to estimate "apparent" temperature, i.e. the temperature the current weather "feels like": 
    1. *Wet-Bulb Temperature (WBT)*: the temperature read by a thermometer covered in water-soaked cloth (wet-bulb thermometer) over which air is passed. Gives the lowest temperature that can be reached under current conditions by evaporative cooling only. Equals air temperature at 100% relative humidity, and is lower at lower humidity. 
    2. *Wet-Bulb Globe Temperature (WBGT)*: a weighted index that combines WBT with measures of the impact of direct radiative transfer (e.g. sunlight) 
    3. *Heat Index (HI)*: various calculated metrics combining shade temperature and relative humidity

- **Precipitation:** highly local (in space *and* time), non-normal (especially compared to temperature), poorly measured, and poorly predicted (see [Section 1.5](#1.5-A-Warning-on-Hydrological-Variables-(Precipitation,-Humidity,-etc.)). Precipitation is often used as a control since it is correlated with temperature. However, the strength and direction of this correlation varies significantly by region and time of year (see e.g. [Trenberth et al. 2005](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2005GL022760), with implications for collinearity). Furthermore, the same care should be taken when inserting precipitation into a model as any other weather or social variable - what is its expected role? In what form should the data be? etc. Precipitation affects society differently at different spatiotemporal scales - annual precipitation may be useful for studying snowpack trends, drinking water supply, or the effect of droughts on agriculture; maximum precipitation rates may be the relevant metric for flood damages or crop failures. Remember that though means and extremes may be correlated, it's still possible to have a record storm in an unnaturally dry year, or an unnaturally wet year without heavy precipitation. As a result, different metrics of precipitation are often used (incomplete list):  
    1. *Total precipitation (e.g., over a year)*: May be useful for large-scale impacts such as snowpack trends. Often used as a control in responses to extreme weather, despite being unsuited to studying short-term phenomena. 
    2. *Soil water, potential evapotranspiration rate (PET), Palmer drought severity index (PDSI), and water runoff/availability*: often used to capture water stress.
    3. *Number of of rainy/dry days, or moments of the precipitation distribution*: the distribution of precipitation often matters more than total.
Some datasets (such as [HadEX2](https://climatedataguide.ucar.edu/climate-data/hadex2-gridded-temperature-and-precipitation-climate-extremes-indices-climdex-data)) specialize in extremes data. 
    
- **River discharge rate:** River flows are generally measured at the station-level. While runoff is avaialble in gridded products, it is not a good reflection of water availability. Hydrological models (like VIC) can translate precipitation into river discharges across a region.

- **Wind speed:** The process of interest determines how wind speeds should be measured. For example, normal speeds are important for agriculture, squared speeds for distructive force, and cubic speeds for wind turbine power. Also consider gust velocity, which is generally available. Maximum wind speed over some time period has been used as well.  

- **Net primary productivity (NPP):** It is the difference of amount of carbon dioxide that vegetation takes in during photosynthesis and the amount of carbon dioxide released during respiration. The data come from MODIS on NASA’s Terra satellite. Values range from near 0 g of carbon/area/day (tan) to 6.5 g of carbon/area/day (dark green). A negative value means decomposition or respiration overpowered carbon absorption; more carbon was released to the atmosphere than the plants took in.

- **Evapotranspiration rate (ET):** It is the sum of evaporation and
  plant transpiration from the Earth's land and ocean surface to the
  atmosphere. Changes in ET are estimated using water stress measures
  in plants, and are related to the agricultural productivity.

- **Solar radiation:** Shortwave radiation (visible light) contains a lot of energy; longwave radiation (infrared light) contains less energy than shortwave radiation. The sun emits shortwave radiation because it is extremely hot, while the Earth re-emits heat it receives as longwave radiation in the form of infrared rays. Exposure of shortwave radiation is said to cause skin cancer, eye damage, etc. However, UV (shortwave) radiation is important for regulating vitamin D circulation in our body.

- **Sea surface temperature (SST) and ocean temperature:** SST is the water temperature close to the ocean's surface, while ocean temperature is related to ocean heat content, an important topic in the study of global warming. Weather satellites have been available to determine SST information since 1967. NASA and Moderate Resolution Imaging Spectroradiometer (MODIS) SST satellites have been providing global SST data since 2000, available with a day lag. Though SST has a large impact on global weather patterns, other metrics (such as El Niño indices - ENSO3.4, etc. - or various other oscillation indices) may be more useful in understanding its impact.  

- **Climatic indicies:** A wide range of metrics have been developed
  to understand the state of the ocean-atmosphere system at large
  scales. These are measured in a standardized way (e.g., by comparing
  temperature at two points or by extracting a mean over a region),
  and often have long time-series, often at the monthly
  level. However, they do not vary over space. Data for some of the
  most important are available
  through [NOAA](https://www.ncdc.noaa.gov/teleconnections/).  Some of
  the most important are:

    1. *El Niño/Southern Oscillation (ENSO)*: Affects temperature
         and precipitation across the globe, with hotspots on most
         continents. For some applications, the value of the signal
         will be less important than the identification of El Niño and
         La Niña phases. These phases can be somewhat predicted months
         in advance. El Niño events can be subclassified as Modoki or
         not.
    2. *Indian Ocean Dipole (IOD)*: IOD has affects weather
         throughout East Africa, South and Southeast Asia, and
         Oceania.

## 2.2. Dealing with the spatial and temporal scales of economic processes

The process of developing a reduced-form specification starts with a
study of the "true model", or data-generating process, that relates
your dependent variable to your weather variables. A crucial aspect of
that relationship is the question of scale.

Weather data products are generally available in *gridded* form,
developed through careful interpolation and/or reanalysis. The grids
used can vary in size across datasets, but they can be aggregated to
administrative units like county, city, etc., using appropriate
weighted aggregation methods. Think about the scale of your
administrative units, relative to the scale of the grid cells. If the
regions are much bigger than the grid cells, a weighted average across
included cells is appropriate. If the regions are much smaller than
the cells, it will probably be necessary to aggregate the regions,
since the level of variation is only at the grid cell level. If the
two are of similar sizes, it may be necessary to account for the
amount of each grid cell lies within each region. This can be
calculated as a transformation matrix, with a row for each region and
a column for each cell. Once the matrix is calculated, it can be
reused for each time step. More details for this process are described
in sections 3 and 5.

Typically, relating weather to a dependent variable requires some kind
of non-linear transformation. For example, estimating a polynomial
functional form requires raising the temperatures to various powers. 
Importantly, the square of a weighted average of grid-level temperatures 
is not the same as the weighted average of the square of grid-level temperatures.

While doing the spatial aggregation, we need to decide whether we want
to transform the data first and then aggregate it
(transformation-before-aggregation) or aggregate it and then transform
it (aggregation-before-transformation). This decision is based on
whether the phenomenon in consideration is occurring at the local
(grid or individual) scale or at the larger administrative units
(country, state, county, etc.) scale. Also, it matters what variable
is under consideration. For example, doing
aggregation-before-transformation for temperature will distort the
signal less that doing it for precipitation. This is because
precipitation is highly local both temporally and spatially; it could
rain for <1 min in <1 km radius area.

### Transformation-before-aggregation

When an economic process is occurring at the local level (for example,
for individuals or households), we need to first do our estimation at
the grid level. For example, to estimate the effect of temperature on
human mortality at the county level, we should reckon that the effect
of temperature on mortality is a local phenomenon, so the estimation
should happen at the lowest possible level.  Since the dependent
variable is a sum of individual-level outcomes, we should write down
the reduced-form specification for an individual experiencing
high-resolution weather, and then sum across all of those reduced
forms. The result is that we need to do any non-linear transformation of our weather variables at the grid level, then aggregate these values using a weighted averaging method, and feed these into our estimation procedure.

**Mathematical formulation for transformation-before-aggregation method**

We want to understand how local agents respond to weather shocks. Suppose that there exists an agent-level dose-response curve, $y_{js} = f(T_{ps})$, for a socioeconomic outcome for agent $j$, where the temperature affecting agents is in grid cell $p$ and occurs in timestep $s$ (e.g., if the agents respond on a day-by-day basis, $T_{ps}$ is the local weather for a single day).  

However, we do not observe agent-level responses. Instead, we have region-wide sums, $y_{it}$ for region $i$ and reporting period $t$. For example, if $y_{js}$ is death risk for agent $j$ for a given day, we may only observe total deaths across a region in each year, $$y_{it} = \sum_{s \in t} \sum_{j \in i} y_{js}.$$  

We can determine the agent-level response $f(T_{ps})$ if we assume
linearity. First, let us represent this as if we could run a regression with agent-level data, breaking up the dose-response
curve into a sum of terms:  
$$f(T_{ps}) = \beta_1 g_1(T_{ps}) + \beta_2 g_2(T_{ps}) + \cdots + \beta_k g_k(T_{ps})$$  

where $g_k(T_{ps})$ is a transformation of the weather variables. For example, for a cubic response curve, $g_1(T_{ps}) = T_{ps}$, $g_2(T_{ps}) = T_{ps}^2$, and $g_3(T_{ps}) = T_{ps}^3$.  

We know that  
$$y_{it} = \sum_{s\in t} \sum_{j\in i} y_{js} = \sum_{s\in t} \sum_{p\in i}$$
$$\beta_1 g_1(T_{ps}) + \beta_2 g_2(T_{ps}) + \cdots + \beta_k g_k(T_{ps})$$  

We can rearrange this to  
$$y_{it} = \beta_1 (\sum_{s\in t} \sum_{p\in i} g_1(T_{ps})) + $$
$$\beta_2 (\sum_{s\in t} \sum_{p\in i} g_2(T_{ps})) + \cdots + $$
$$\beta_k (\sum_{s\in t} \sum_{p\in i} g_k(T_{ps}))$$  

That is, the variables used in the regression should be the sum over
weather data that has been transformed at the grid level.

### Aggregation-before-transformation

Let us try to understand these two methods using counties (ADM2) as our higher administrative level:

When an economic process is occurring at the regional level, we need
to first aggregate weather variable to that level before transforming
it. For example, to estimate the effect of storm events on public
service employment at the administrative office level, we need to take
into account the fact that hiring/firing of public service employees
happens at the office level only.  Estimating grid-level effects will
lead to wrong estimation, as it should result in zero estimate for
those (almost all) grid cells which do not contain administrative
offices, and extremely large values for those (very few) cells, which
do.

Using the formulation above, here we would regress:
$$y_{it} = \beta_1 g_1(\sum_{s\in t} \sum_{p\in i} T_{ps}) + $$
$$\beta_2 g_2(\sum_{s\in t} \sum_{p\in i} T_{ps}) + \cdots + $$
$$\beta_k g_k(\sum_{s\in t} \sum_{p\in i} T_{ps})$$

Where $T_{ps}$ is the gridded weather for cell $p$ in time step
$s$, $g_k(\cdot)$ is the non-linear transformation (e.g., raising to
powers for polynomials), and $y_{it}$ is the dependent variable
observed for region $i$ in reporting period $t$. Weather data products can have temporal resolution finer than scale of daily observations. Like spatial aggregation, we can do temporal aggregation to month, year, or decade.

![Humor](images/cartoon_sec2.JPG)

## 2.3. Common functional forms (pros, cons, and methods)

Returning to the "true model" of your process, the decisions around how to
generate a linear expression that you can estimate have important
implications. Different functional forms serve different purposes and
describe different underlying processes. Some of the frequently used functional forms along with a good reference for understanding them in detail are listed below.

- **[Bins](https://pubs.aeaweb.org/doi/pdfplus/10.1257/app.3.4.152)**

Bins offer a very flexible functional form, although the choice of bin
edges means that they are not as "non-parametric" as often assumed. It
is also highly sensitive to existence of outliers in data. This can
particularly be an issue for extrapolation when the results are used
for projections: only the estimate for the extreme bins will be used.

The bin widths should generally be even to facilitate easy
understanding, although the lowest and highest bins can go to negative
and positive infinity (or the appropriate analog). You may want to
have smaller size bins around weather values where we expect most of
the response to occur and where there is a lot of data, but be
prepared to also show evenly-spaced bins.

The interpretation of a binned result is in terms of the time unit
used. For example, if daily temperatures are used, then the marginal
effect for a given bin is the additional effect of "one more day" for
which the temperature falls into that bin.

To calculate bin observations, count up the number of timesteps where
the weather predictor falls into each bin:
    $$T_{it} = \sum_{p \in i} \psi_{p} \sum \mathbf{1} \left \{  {T_{p i t} \in Bin_k} \right \}$$
    where $\psi_{p}$ is the weight assigned to the $p$ grid cell.  
    
- **[Polynomial](https://en.wikipedia.org/wiki/Polynomial_regression)**

Polynomial specifications balance smooth dose-response curves with the
flexibility of increasing the effective resolution of the curve by
increasing the degree of the polynomial. Using more degrees improves
the ability of the curve to fit the data, but may lead to
over-fitting. To choose the number of terms in the polynomial,
consider cross-validation.

Another benefit of polynomials for climate change estimates is that
they provide smooth extrapolation to higher temperatures. Again, it is
important to highlight the fact that the evaluation of the
dose-response curve at temperatures outside the bounds of the observed
data reflects assumptions, rather than evidence. Cross-validation that
leaves out the latest periods or most extreme temperatures can improve
confidence in these assumptions.

In calculating the predictor values for a polynomial, consider the
scale of the data-generating process. If it is a local process, the
high-resolution weather values should be raised to powers before
aggregating up to the regions in the economic data. That is, the the
predictor for the $k$-th power of the polynomial is 
    $$f(T_{it}^k)=\sum_{p \in \Theta(i)} \psi_{p} T_{p i t}^k$$ 
    where $\psi_{p}$ is the weight assigned to the $p$ gridcell.  
    
The dose-response regression would then be applied as follows
    $$F(T_{it})=\sum_{k} \beta_k f(T_{it}^k)$$
	
while the coefficients can be interepted as describing a local
dose-response relationship:
    $$F(T_{pit})=\sum_{k} \beta_k T_{pit}^k$$

- **[Restricted cubic spline](https://support.sas.com/resources/papers/proceedings16/5621-2016.pdf)**

Restricted cubic splines produce smooth dose-response curves, like
polynomials, but mitigate some of the problems that polynomials with
many terms have. Whereas polynomials with high-order terms can produce
very extreme results under extrapolation, RCS always produces a linear
extrapolation. RCS also provides additional degrees of freedom through
the placement of knots, and this can be used either to reflect
features of the underlying process being modeled or to improve the
fit.

In the case where knots are choosen to maximize the fit of the curve,
cross-validation is the preferred approach for both selecting the
number of knots and their placement. The reference in this subsection
title on cubic splines can be helpful in deciding the knot
specifications.

Once knot locations are determiend, the weather data needs to be
translated into RCS terms. As before let the gridded weather be $T_{p
i t}$ and let there be $n$ knots, placed at $T_1<T_2<...<T_n$. Then we
have a set of $(n-2)$ terms, here indexed by $k$ and defined as:
    $$f(T_{i t})_k= \sum_{p \in \Theta(i)} \psi_{p} \{(T_{p i
	t}-T_k)^3_+ - (T_{p i t} - T_{n-1})^3_+
	\frac{T_n-T_k}{T_n-T_{n-1}}+(T_{p i t} - T_{n})^3_+ \frac{T_{n-1}-T_k}{T_{n}-T_{n-1}}\}$$ $$\forall k \in \{1,2,...,n-2\}$$ 
    where, $\psi_{p}$ is the weight assigned to the $p$ grid.  
    
Each spline term in the parentheses $(\nabla)^3_+$ e.g. $(T_{p i t} - t_{n-1})^3_+$ is called a truncated           polynomial of degree 3, which is defined as follows:  
    $\nabla^3_+=\nabla^3_+$ if $\nabla^3_+>0$  
    $\nabla^3_+=0$ if $\nabla^3_+<0$  
    
As with the polynomial, the dose-response regression would then be applied as follows
    $$F(T_{it})=\sum_{k} \beta_k f(T_{it})_k$$
	
while the coefficients can be interepted as describing a local
dose-response relationship:

$$F(T_{pit})=\sum_{k} \beta_k {T_{pit}}_k$$

- **[Linear spline](https://web.archive.org/web/20200226044201/http://people.stat.sfu.ca/~cschwarz/Consulting/Trinity/Phase2/TrinityWorkshop/Workshop-handouts/TW-04-Intro-splines.pdf)**

A linear spline provides a balance between the smoothness of RCS and
the direct response curve to temperature correspondance of bins. The
segments between knots here are lines. As with RCS, the choice of knot
locations is very important.

One defition of terms for a linear spline for a spline with $n$ knots at
$T_1<T_2<...<T_n$ is:
    $$f(T_{it})_0=\sum_{p \in \Theta(i)} \psi_{p} T_{p i t}$$
    $$f(T_{it})_k=\sum_{p \in \Theta(i)} \psi_{p} (T_{p i t}-T_k)_+$$
    where, $\psi_{p}$ is the weight assigned to the $p$ gridcell.  

And, each spline term in the parentheses $(\nabla)_+$ e.g. $(T_{p i t} - T_2)_+$ is called a truncated polynomial of degree 1, which is defined as follows:  
    $\nabla_+=\nabla_+$ if $\nabla_+>0$  
    $\nabla_+=0$ if $\nabla_+<0$  

We generally try to work with many functional forms in a paper because it serves dual purpose of being a *sanity check* for researchers' code and a *robustness check* for readers' confirmation. However, we need to take decision on the *main specification* that we want in the paper. To do this, we formally rely on tests such as cross-validation (explained below), but we can also eyeball at the *fit* of different functional forms by printing overlaid graphs in a way that is suitable for the exercise. An example is shown in the figure below:

**Example of reduced-form regression plots for different functional forms**
![Data from  Greenstone et al. (2019)!](images/fform_cil.JPG)
Source: [Carleton et al. (2019)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3224365).

## 2.3. Cross-validation

Cross-validation can be done to check the *internal validity* and the *external validity* of the model estimates. For checking
internal validity, the model can be fit to a subset of the dataset,
and evaluated on the remainder. For example, you can leave particular
regions out of your regression or remove a random *1/k* of your data
(k-fold cross validation) instead of running a full-sample
regression. For gauging external validity, the model is run on some new dataset that has not been not used in the model-evaluation process. For example, by predicting the response for a new country using global regression model estimates and comparing it to the actual observations.  

Cross-validation is not universally performed by researchers, and many
people continue to rely only on R-squared statistics. However,
R-squared statistic can perform poorly even in very simple cases. Therefore, cross-validation can be an effective approach for doing model-selection.  

Some examples on the use of cross-validation exercise include deciding
on degree of polynomial, cutoff knots' positions for splines,
and selecting weather variables for a regression. To do a k-fold cross
validation exercise for deciding on polynomial degree, we run our test
specifications (say polynomials of degree 2, 3, 4 and 5) on the data,
each time excluding a subset, and evaluate how well the fitted model
predicts the excluded data. To fix a metric for making this decision,
we can rely on root-mean-square-error (RMSE) statistic. So, the
specification with the lowest RMSE will be the most preferred
specification here. Having said that, we usually employ combination of
techniques, like eye-balling and RMSE, to take decision on the most preferred specification.
