# 3. Developing a reduced-form specification:

This section describes steps to develop the first reduced-form specification, which is generally a global/country regression without any covariate, such as income.

## Choosing weather variables

Choice of weather variables depends on the question we are trying to answer. For example, in case of temperature, we can use *T_min/T_max, T_avg or HDD/CDD or GDD.* A few of the important weather variables are listed below:

- Temperature
    1. *T_min/T_max:*  Useful when temperature variation is large leading to significant differences in cold end and hot end response. These are important metric when heterogeneity between each time unit matters, such as having events of heat waves and cold storms in the temporal support
    2. *T_avg:*  A good mean metric for seeing average response over the temperature support, when there is not much variation in temperature across time unit considered in the study. Different averaging methods, like Bartlett Kernels, Moving Average, etc. can be used here
    3. *HDD/CDD & GDD:*  Degree Days (DD) are a measure of ’how much’ and for ’how long’ the outside air temperature was below a certain level.  Reference: https://www.degreedays.net/introduction
- Precipitation
    1. Highly local, poorly measured, and poorly predicted
    2. Total precipitation is often not the best variable. Consider soil water, potential evapotranspiration rate (PET), and water runoff/availability
    3. Distribution of precipitation often matters more than total. Consider no. of rainy/dry days, moments of the distribution
    4. Precipitation is an important control to include, even if it’s not the main variable of interest However, we should remember that the properties of precipitation and temperature variables are very different in the way they affect humans. For example, binning of annual temperature variable, keeping high temperature bins small-sized, can explain variation in death rates due to heat waves events. However, if we want to see the variation in death rates due to storm events, using binned annual precipitation is likely not going to give us the variation in death rates, rather we would have to separately account for storm events by using an additional control
- River discharge rate
    1. Still measured at the station-level, so we don’t have gridded products
    2. For example Central Water Commission of India maintains this dataset for some of the Himalayan rivers that flow in India
- Wind speed
- Evapotranspiration rate
- Solar radiation
- Humidity
- Ocean temperature
- Atmospheric CO2
- Storm events
- Sea level
- Ocean currents
- Soil erosion and salinity
- Plant productivity
## Common functional forms (pros, cons, and methods)

We use one/many/combination of different functional forms for weather variables for generating reduced form results. Some of the frequently used functional forms along with a good reference for understanding them in detail are listed below:

- Bins
    1. Assignment of observations to bins. e.g.  15C-20C, 20C-25C, ...  for temperature
    2. Uses the mean metric, so its advantage is non-parametric nature
    3. Highly susceptible to existence of outliers in data

https://pubs.aeaweb.org/doi/pdfplus/10.1257/app.3.4.152

- [Polynomial](https://en.wikipedia.org/wiki/Polynomial_regression)
    1. Fitting an n-degree polynomial function for weather variables
    2. More poly degrees provide better data fitting
    3. Smooth curve nature doesn’t highlight important irregularities in data

- Restricted Cubic Spline
    1. Fitting a piecewise polynomial function between pre-specified knots
    2. More independence compared to poly in choosing function knots
    3. Highly parametric due to freedom of choice of knots

https://support.sas.com/resources/papers/proceedings16/5621-2016.pdf

- Linear Spline
    1. Fitting a line between cutoff values e.g.  25C CDD/0C HDD for temp
    2. Less parametric and very useful for predicting mid-range response
    3. Linear and highly sensitive to choice of cutoff values

http://people.stat.sfu.ca/~cschwarz/Consulting/Trinity/Phase2/TrinityWorkshop/Workshop-handouts/TW-04-Intro-splines.pdf

## Cross-validation
- Cross-validation exercise can be done to check the *internal validity* and the *external validity* of the model estimates
- For checking internal validity, the model can be run on a subset of the dataset. For example, running country-wise regressions or running regressions on *k* partitions of data (k-fold cross validation) instead of running a full-sample global regression
- For gauging external validity, model is run on some new dataset that has not been not used in estimating the model parameters. For example, predicting response for a new country using global regression model estimates, and comparing it to the actual observations
- Although cross-validation exercise is not universally performed by researchers, but good papers have at least a section discussing the internal and the external validity of their models
- Sometimes, researchers tend to rely on the measure of R-squared statistic. However, we know from our basic statistics learning, how badly this it can perform even in very simple cases
## Fixed Effects Regression


## Dealing with the spatial and temporal scales of economic processes

Weather data products are generally available in *gridded* form, developed after careful interpolation and/or reanalysis exercise. The grids used can vary in size across datasets, but they can be aggregated to economic scale of administrative units like county, city, etc., using appropriate weighted aggregation methods. While doing the spatial aggregation, we need to decide whether we want to do transformation-before-aggregation or aggregation-before-transformation based on the whether the phenomenon in consideration is occurring at the local (grid) scale or at the larger administrative units (country, state, county, etc.) scale. Also, it matters what variable is in consideration. For example, doing aggregation-before-transformation for temperature will distort the signal less that doing it for precipitation. It is because precipitation is highly local both temporally and spatially; it could rain for < 1 min in <1 km radius area. Let us try to understand these two methods with county as our higher administrative level:


- *Transformation-before-aggregation:* When an economic process is occurring at the grid level, we need to first do estimation at the grid level. Here, we need to do the required transformation of our weather variables at the grid level, run our estimation procedure on those transformed variables, and then aggregate grid-level estimates using weighted averaging method. For example, to estimate the effect of temperature on human mortality at the county level, we should reckon that the effect of temperature on mortality is a local phenomenon, so the estimation should happen at the lowest possible level. Therefore, we need to estimate the effect of temperature on mortality at the grid level first, and then take population-weighted average of grid-level effects for the grids that are inside the selected county boundaries

**Mathematical formulation for transformation-before-aggregation method**
Consider a grid $\theta$ located in county $i$ with $T_{\theta it}$ as its temperature at time $t$. We want to generate an aggregate temperature transformation, $f(T_{it}^k)$, for county $i$ at time $t$, after aggregating over the grids $\theta \in \Theta$, where $\Theta$ denotes the set of grids that are located inside county $i$.

Here, $k\in\{1,2,...,K\}$ denotes the $k^{th}$ term of transformation. For example, in case of $K$-degree polynomial transformation, it will be $K$ polynomial terms, and in case of $K$-bins transformation, it will be $K$ temperature bins. So, we can write:

$$f(T_{it}^k)=g(T_{\theta it})$$

where, $g(.)$ denotes the transformation mapping on the grid-level temperature data.

Once we have $f(T_{it}^k)$ for each  $k\in\{1,2,...,K\}$, we can use them to generate the full nonlinear transformation $F(T_{it})$, associating $\beta^k$ parameter with $k^{th}$ term of transformation. We have:

$$F(T_{it})=\sum_{k\in \{1,2,...,K\}} \beta^k*f(T_{it}^k)$$

The coefficients, $\beta^k \,\forall k\in \{1,2,...,K\}$ are estimated using an appropriate estimation technique for generating the response functions.

Suppose we want a model for estimating the effect of temperature on human mortality $Y_{it}$.

$$Y_{it}=\sum_{k\in \{1,2,...,K\}} \beta^k*T_{it}^k + \alpha_i + \zeta_t + \varepsilon_{it}$$

We can run a fixed effects estimation on the county-level data for estimating the coefficients, and then generate the response functions for different counties in our data. As pointed out in the cross-validation section, it is important to check for internal validity and the external validity after the estimation is over.

Bin
Consider doing a 6-bins bin transformation of temperature variable. Let us take equal sized bins for simplicity, but in actual binning procedure, we might want to have smaller sized bins around the temperature values where we expect most of the response to occur. For now, the $K=6$ temp bins are: $<-5^\circ C$, $-5^\circ C-5^\circ C$, $5^\circ C-15^\circ C$, $15^\circ C-25^\circ C$, $25^\circ C-35^\circ C$ and $>35^\circ C$.
As defined earlier, the grid $\theta$ temperature is $T_{\theta i t}$. For transformation, we will have to map actual temperature observations to the respective bins that we have defined above. Then, take the weighted average of these terms across all the grids that come under a specific county. The mapping is defined as follows:

$$f(T_{it}^k)=\sum_{\theta \in \Theta} \psi_{\theta} \sum \mathbf{1} \left \{  {T_{\theta i t} \in k} \right \}$$ $$\forall k \in \{1,2,...,6\}$$

where $\psi_{\theta}$ is the weight assigned to the $\theta$ grid. The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2,...,6\}} \beta^k*f(T_{it}^k)$$

Polynomial

Consider doing a 4-degree polynomial transformation of temperature variable. We need to first generate the remaining polynomial terms, namely $$T_{\theta i t}^2$$, $$T_{\theta i t}^3$$ and $$T_{\theta i t}^4$$, by raising original $$T_{\theta i t}$$ to powers 2, 3 and 4 respectively. Then, take the weighted average of these terms across all the grids that come under a county. So, we have:

$$f(T_{it}^k)=\sum_{\theta \in \Theta} \psi_{\theta}*T_{\theta i t}^k$$ $$\forall k \in \{1,2,3,4\}$$

where $\psi_{\theta}$ is the weight assigned to the $\theta$ grid. The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2,3,4\}} \beta^k*f(T_{it}^k)$$

Restricted Cubic Spline
For transforming the temperature data into restricted cubic splines, we need to fix the location and the number of knots. The reference above on cubic splines can be helpful in deciding the knot specifications. As before let the grid $$\theta$$ temperature be $$T_{\theta i t}$$. Let us do this exercise for $$n$$ knots, placed at $$t_1<t_2<...<t_n$$, then for $$T_{\theta i t}$$, which is a continuous variable, we have a set of $$(n-2)$$ new variables. We have:

$$f(T_{i t}^k)= \sum_{\theta \in \Theta} \psi_{\theta}*\{(T_{\theta i t}-t_k)^3_+ - (T_{\theta i t} - t_{n-1})^3_+*\frac{t_n-t_k}{t_n-t_{n-1}}+(T_{\theta i t} - t_{n})^3_+*\frac{t_{n-1}-t_k}{t_{n}-t_{n-1}}\}$$ $$\forall k \in \{1,2,...,n-2\}$$

where, $$\psi_{\theta}$$ is the weight assigned to the $$\theta$$ grid.

And, each spline term in the parentheses $$(\nabla)^3_+$$ e.g. $$(T_{\theta i t} - t_{n-1})^3_+$$ is called a truncated polynomial of degree 3, which is defined as follows:

$$\nabla^3_+=\nabla^3_+$$ if $$\nabla^3_+>0$$
$$\nabla^3_+=0$$ if $$\nabla^3_+<0$$

The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2,...,n-2\}} \beta^k*f(T_{it}^k)$$

Linear Spline
Linear spline is a special kind of spline function, which has two knots, and the segment between these two knots is a linear function. It is also called ‘restricted’ linear spline, since the segments outside the knots are also linear. To implement this, we first decide location of the two knots, say $$t_1<t_2$$. Then, closely following the cubic spline method, we get:

$$f(T_{it}^1)=\sum_{\theta \in \Theta} \psi_{\theta}*(T_{\theta i t}-t_2)_+$$

$$f(T_{it}^2)=-\sum_{\theta \in \Theta} \psi_{\theta}*(T_{\theta i t}-t_1)_+$$

where, $$\psi_{\theta}$$ is the weight assigned to the $$\theta$$ grid.

And, each spline term in the parentheses $$(\nabla)_+$$ e.g. $$(T_{\theta i t} - t_2)_+$$ is called a truncated polynomial of degree 1, which is defined as follows:

$$\nabla_+=\nabla_+$$ if $$\nabla_+>0$$
$$\nabla_+=0$$ if $$\nabla_+<0$$

The aggregate transformation is as below:

$$F(T_{it})=\sum_{k\in \{1,2\}} \beta^k*f(T_{it}^k)$$


- *Aggregation-before-transformation:* When an economic process is occurring at the county level, we need to first do the weather variable aggregation at the county level. We do the weather variable transformation after we have aggregated it to the county level using weighted averaging method, and then run our estimation on the county level data. For example, to estimate the effect of storm events on public service employment at the administrative block level, we need to take into account the fact that hiring/firing of public service employees happens at the block level only.  Estimating grid-level effects will lead to wrong estimation, as it would result in zero estimate for those (almost all) grid cells which do not have the block office coordinates, and extremely large values for those (very few) cells, which comprise of the block office coordinates. The mathematical formulation for aggregation-before-transformation can be learned through transformation-before-aggregation formulation described above, with a change that the aggregation step precedes the transformation step.

Weather data products can have temporal resolution finer than scale of daily observations. Like spatial aggregation, we can do temporal aggregation to month, year, or decade; however, unlike spatial aggregation, the averaging process is standard in all general cases.
