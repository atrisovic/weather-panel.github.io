% This code takes three decades of BEST data (1980-2009) and saves them in
% one single netcdf file, in CMIP5 filename format, subset to just the
% continental United States

clear
%% Setup
% Set geographic boundaries, in a [lon1,lon2,lat1,lat2] format (with a
% buffer space to account for resolution differences)
geo_lims = [-126,-65,23,51];

% Set location of files
data_dir = '../data/climate_data/';
fns = {'Complete_TAVG_Daily_LatLong1_1980.nc';...
       'Complete_TAVG_Daily_LatLong1_1990.nc';...
       'Complete_TAVG_Daily_LatLong1_2000.nc'};
   
% Set output filename
fn_out = '../data/climate_data/tas_day_BEST_historical_station_19800101-20091231.nc';
   
  
%% Load Data
tas = cell(length(fns),1); months = cell(length(fns),1);
for file_idx = 1:length(fns)
   % BEST data is given in terms of anomalies from the underlying
   % climatology. So, the climatology has to be loaded first.
   clim_tmp = ncread([data_dir,fns{file_idx}],'climatology');
   
   % The climatology is given per day of year over the period of the file - 
   % so the 'temperature' variable (the anomaly) is added to its
   % corresponding climatology, using the included 'day_of_year' variable
   tas{file_idx} = ncread([data_dir,fns{file_idx}],'temperature') + ...
                   clim_tmp(:,:,ncread([data_dir,fns{file_idx}],'day_of_year')); 
               
   % Also loading the "months" variable - most datasets don't have it, but
   % it will make more sophisticated projecting methods easier. This is
   % particularly useful because of the gregorian calendar (which includes
   % leap days, and therefore would otherwise add an extra step to
   % determining which month each datastep is)
   months{file_idx} = ncread([data_dir,fns{file_idx}],'month');
               
   clear clim_tmp
end

lat = ncread([data_dir,fns{file_idx}],'latitude');
lon = ncread([data_dir,fns{file_idx}],'longitude');


%% Concatenate the three files
tas = cat(3,tas{:});
months = cat(1,months{:});

%% Subset to continental United States
lon_idxs = ((lon>=geo_lims(1)) & (lon<=geo_lims(2)));
lat_idxs = ((lat>=geo_lims(3)) & (lat<=geo_lims(4)));

tas = tas(lon_idxs,lat_idxs,:);
lon = lon(lon_idxs);
lat = lat(lat_idxs);

%% Export to a new NetCDF file
% Write temperature data to netcdf 
nccreate(fn_out,'tas','Dimensions',{'lon',size(tas,1),'lat',size(tas,2),'time',size(tas,3)})
ncwrite(fn_out,'tas',tas);
% These attributes aren't strictly necessary, but very helpful to have in
% the file
ncwriteatt(fn_out,'tas','long_name','near-surface air temperature');
ncwriteatt(fn_out,'tas','units','C');

% Write lat/lon data to netcdf file
nccreate(fn_out,'lat','Dimensions',{'lat',size(tas,2)})
nccreate(fn_out,'lon','Dimensions',{'lon',size(tas,1)})
ncwrite(fn_out,'lat',lat);
ncwrite(fn_out,'lon',lon);
ncwriteatt(fn_out,'lat','long_name','latitude')
ncwriteatt(fn_out,'lon','long_name','longitude')
ncwriteatt(fn_out,'lat','units','degrees')
ncwriteatt(fn_out,'lon','units','degrees')

% Write time dimension to netcdf file
time_idxs = 0:(size(tas,3)-1);

nccreate(fn_out,'time','Dimensions',{'time',size(tas,3)})
ncwrite(fn_out,'time',time_idxs)
ncwriteatt(fn_out,'time','units','days since 1980-01-01')

nccreate(fn_out,'month','Dimensions',{'time',size(tas,3)})
ncwrite(fn_out,'month',months)
ncwriteatt(fn_out,'month','units','month number')

% Write global attributes (again, not strictly necessary, but very useful);
% using the '/' name for global
ncwriteatt(fn_out,'/','variable','tas')
ncwriteatt(fn_out,'/','variable_long','near-surface air temperature')
ncwriteatt(fn_out,'/','source','Berkeley Earth Surface Temperature Project')
ncwriteatt(fn_out,'/','origin_script','preprocess_best.m')
ncwriteatt(fn_out,'/','calendar','gregorian')

