## setwd("~/groups/weatherpanels/weather-panel.github.io/example/code")

library(ncdf4)

nc <- nc_open("../data/climate_data/Complete_TAVG_Daily_LatLong1_1980.nc")

time <- seq(as.Date("1980-01-01"), length.out=nc$dim$time$len, by="1 day")

doy <- ncvar_get(nc, 'day_of_year')
tas.anom <- ncvar_get(nc, 'temperature')
tas.clim <- ncvar_get(nc, 'climatology')

tas.clim.all <- tas.clim[,, doy]
tas <- tas.anom + tas.clim.all

longitude <- ncvar_get(nc, 'longitude')
latitude <- ncvar_get(nc, 'latitude')

latlims = c(23, 51)
lonlims <- c(-126,-65)

tas2 <- tas[longitude >= lonlims[1] & longitude <= lonlims[2], latitude >= latlims[1] & latitude <= latlims[2],]

dimlon <- ncdim_def("lon", "degrees_east", longitude[longitude >= lonlims[1] & longitude <= lonlims[2]], longname='longitude')
dimlat <- ncdim_def("lat", "degrees_north", latitude[latitude >= latlims[1] & latitude <= latlims[2]], longname='latitude')
dimtime <- ncdim_def("time", "days since 1980-01-01 00:00:00", as.numeric(time - as.Date("1980-01-01")),
                     unlim=T, calendar="proleptic_gregorian")
vartas <- ncvar_def("tas", "C", list(dimlon, dimlat, dimtime), NA, longname="temperature")

ncnew <- nc_create("../data/climate_data/tas_day_BEST_historical_station_19800101-19891231.nc", vartas)
ncvar_put(ncnew, vartas, tas2)
nc_close(ncnew)
