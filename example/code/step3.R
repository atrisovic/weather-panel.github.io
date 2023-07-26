## setwd("~/groups/weatherpanels/weather-panel.github.io/example/data")

## install.packages("devtools")
## devtools::install_github("tcarleton/stagg")

library(stagg)
library(raster)
library(tigris)

## Load data and expand to global grid
global.extent <- extent(-180, 180, -90, 90)

rr.tas <- stack("climate_data/tas_day_BEST_historical_station_19800101-19891231.nc")
rr.tas.padded <- extend(rr.tas, global.extent)
rr.pop <- raster("pcount/usap90ag.nc")
rr.pop.padded <- extend(rr.pop, global.extent)
rr.pop.padded[is.na(rr.pop.padded)] = 0

## Load counties
counties <- tigris::counties()
counties$FIPS <- paste0(counties$STATEFP, counties$COUNTYFP)

## Calculate grid weights
grid.weights <- secondary_weights(secondary_raster=rr.pop.padded, grid=rr.tas.padded)
county.weights <- overlay_weights(polygons=counties, polygon_id_col="FIPS", grid=rr.tas.padded, secondary_weights=grid.weights)

## Shift axis of climate data to conform to stagg expectations
rr.tas.padded2 <- shift(rr.tas.padded, dx = 360)

## Calculate aggregation
county.tas <- staggregate_polynomial(data=rr.tas.padded2, daily_agg="none", time_agg='year', overlay_weights=county.weights, degree=2)

## Only write out valid entries
county.tas.valid <- subset(county.tas, !is.na(order_1))
write.csv(county.tas, 'climate_data/agg_poly.csv', row.names=F)

