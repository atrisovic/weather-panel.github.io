# Some pointers when performing regressions

```{admonition} Key objectives
:class: note
- Avoid common pitfalls when running regressions and plotting results.
```

Once you have translated physical weather data into observations that
match the geographic units, much of the work of climate econometrics
follows the patterns laid down in other econometrics. This section
just provides a few pointers for problems that are common when working
with weather relationships.

## Unobserved heterogeneity

Weather regressions require careful fixed-effect (FE) definitions. A
geographic unit fixed effect is essential, but several other fixed
effects are important to consider:

 - Time unit FEs, or high-order polynomial trends.
 - FEs or trends as above, at the level of groups of geographic units
   (e.g. **ADM1**, if the observations are at **ADM2**).
 - Day of week or day of year FEs, for many social/economic behaviors.

If you have multiple groups (e.g., data for different ages, races, or
sexes) and want to estimate different effects for different groups,
make sure you use Seemingly Unrelated Regressions.

## Spatial and temporal error term covariance

As the resolution of the spatial and temporal units increases, the
coviariance between them will also increase. Those additional
observations may not provide as much unique information as they appear
to. In most cases, it is necessary to use Conley-White standard
errors, which correct for spatially- and temporally-correlated error
terms.

`````{tab-set}
````{tab-item} R
For code to calculate Conley standard errors in R, see <https://github.com/darinchristensen/conley-se>.
````
````{tab-item} Python
For code to calculate Conley standard errors in python, see <https://www.danielmsullivan.com/econtools/metrics.html#spatial-hac-conley-errors>.
````
````{tab-item} Matlab and Stata
Sol Hsiang has code that has been widely re-used (e.g., for R),
originally developed for Matlab and Stata:
<http://www.fight-entropy.com/2010/06/standard-error-adjustment-ols-for.html>.
````
`````

## Plotting dose-response functions

Regression results are always relative to some baseline, and for
dose-response functions, that baseline is often defined as a
particular value of the weather variable (e.g., a day at 20 C). At
this same point, the standard errors go to 0 (if there are no other
variables being projected). To produce this effect, when predicting
the dose-response function (e.g., with `predict` in R), define
variables that are 0 at the point. So, for example, if you are
plotting a quadratic in temperature relative to 20 C, define your
linear term as $T-20^\circ C$ and your quadratic term as $T^2 -
(20^\circ C)^2$.

See Step 4 of the Hands-On Exercise for an example.
