## setwd("~/groups/weatherpanels/weather-panel.github.io/example/data")

## install.packages("devtools")
## devtools::install_github("tcarleton/stagg")

library(stagg)
library(raster)
library(tigris)
library(dplyr)

## Load data and expand to global grid
global.extent <- extent(-180, 180, -90, 90)

rr.tas <- brick("climate_data/tas_day_BEST_historical_station_19800101-19891231.nc")
rr.tas.padded <- rr.tas #extend(rr.tas, global.extent)
rr.pop <- raster("pcount/usap90ag.nc")
rr.pop.padded <- rr.pop #extend(rr.pop, global.extent)
## rr.pop.padded[is.na(rr.pop.padded)] = 0

## Load counties
counties <- tigris::counties()
counties$FIPS <- paste0(counties$STATEFP, counties$COUNTYFP)

## Calculate grid weights
grid.weights <- secondary_weights(secondary_raster=rr.pop.padded, grid=rr.tas.padded)
county.weights <- overlay_weights(polygons=counties, polygon_id_col="FIPS", grid=rr.tas.padded, secondary_weights=grid.weights)

## Shift axis of climate data to conform to stagg expectations
##rr.tas.padded2 <- shift(rr.tas.padded, dx = 360)

## Calculate aggregation
##county.tas <- staggregate_polynomial(data=rr.tas.padded2, daily_agg="none", time_agg='year', overlay_weights=county.weights, degree=2)
county.tas <- staggregate_polynomial(data=rr.tas.padded, daily_agg="none", time_agg='year', overlay_weights=county.weights, degree=2)

## Only write out valid entries
county.tas.valid <- subset(county.tas, !is.na(order_1))

## Remove 20 deg per day
daysperyear <- table(substring(names(rr.tas), 2, 5))
county.tas.base <- data.frame(year=as.numeric(names(daysperyear)), order_1=20*as.numeric(daysperyear), order_2=(20^2)*as.numeric(daysperyear))

county.tas.final <- county.tas.valid %>% left_join(county.tas.base, by='year', suffix=c('', '.base'))

county.tas.final$tas_adj <- county.tas.final$order_1 - county.tas.final$order_1.base
county.tas.final$tas_sq <- county.tas.final$order_2 - county.tas.final$order_2.base
names(county.tas.final)[2] <- 'FIPS'

write.csv(county.tas.final, 'climate_data/agg_vars.csv', row.names=F)

