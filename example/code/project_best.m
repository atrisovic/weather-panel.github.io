% This just creates a simple projection of the BEST data, using
% nearest-neighbor changes in monthly means from CCSM4 (NOTE: I just had
% pre-industrial control data on my laptop as of now - it really should be
% using historical data, to compare with the measurements. But as a
% proof-of-concept it's fine - and I can replace the data with the correct
% historical data later). 


clear
%% Setup
model_loc = '/Volumes/KSssd/climate_data/CCSM4/';

fn_out = '../data/climate_data/BEST/tas_day_BEST-CCSM4_rcp85_proj_20700101-20991231.nc';

%% Load Data
tas_best = ncread('../data/climate_data/BEST/tas_day_BEST_historical_station_19800101-20091231.nc','tas');
lat_best = ncread('../data/climate_data/BEST/tas_day_BEST_historical_station_19800101-20091231.nc','lat');
lon_best = 360+ncread('../data/climate_data/BEST/tas_day_BEST_historical_station_19800101-20091231.nc','lon');
month_best = ncread('../data/climate_data/BEST/tas_day_BEST_historical_station_19800101-20091231.nc','month');

tas_ccsm40 = ncread([model_loc,'tas_Amon_CCSM4_piControl_r2i1p1_095301-110812.nc'],'tas');
tas_ccsm41 = ncread([model_loc,'tas_Amon_CCSM4_rcp85_r2i1p1_200601-210012.nc'],'tas');
% Subset to the last 30 years of the pre-industrial control run and
% 2070-2099 for the rcp8.5 run
tas_ccsm40 = tas_ccsm40(:,:,(end-(30*12)+1):end);
tas_ccsm41 = tas_ccsm41(:,:,((2070-2006)*12+1):((2099-2006+1)*12));
% Get CCSM4 lat/lon grid
lat_ccsm4 = ncread([model_loc,'tas_Amon_CCSM4_rcp85_r2i1p1_200601-210012.nc'],'lat');
lon_ccsm4 = ncread([model_loc,'tas_Amon_CCSM4_rcp85_r2i1p1_200601-210012.nc'],'lon');

%% Get change in temperature by month for CCSM4
% This calculates the difference between the 30-year means of each month of
% each run (future - pre-industrial) 
dtas_ccsm4 = mean(reshape(tas_ccsm41,[length(lon_ccsm4),length(lat_ccsm4),12,30]),4) - ...
             mean(reshape(tas_ccsm40,[length(lon_ccsm4),length(lat_ccsm4),12,30]),4);

         
%% Identify closest pixel 
[lons_ccsm4,lats_ccsm4] = ndgrid(lon_ccsm4,lat_ccsm4);
[lons_best,lats_best] = ndgrid(lon_best,lat_best);
idx = knnsearch([lons_ccsm4(:) lats_ccsm4(:)],[lons_best(:) lats_best(:)]);

%% Project

tas_best1 = reshape(tas_best,[size(tas_best,1)*size(tas_best,2) size(tas_best,3)]);
dtas_ccsm4_tmp = reshape(dtas_ccsm4,[size(dtas_ccsm4,1)*size(dtas_ccsm4,2) size(dtas_ccsm4,3)]);

tas_best1 = reshape(tas_best1 + dtas_ccsm4_tmp(idx,month_best),...
                    [size(tas_best,1) size(tas_best,2) size(tas_best,3)]);

%% Save
% Write temperature data to netcdf 
nccreate(fn_out,'tas','Dimensions',{'lon',size(tas_best1,1),'lat',size(tas_best1,2),'time',size(tas_best1,3)})
ncwrite(fn_out,'tas',tas_best1);
% These attributes aren't strictly necessary, but very helpful to have in
% the file
ncwriteatt(fn_out,'tas','long_name','near-surface air temperature');
ncwriteatt(fn_out,'tas','units','C');

% Write lat/lon data to netcdf file
nccreate(fn_out,'lat','Dimensions',{'lat',size(tas_best1,2)})
nccreate(fn_out,'lon','Dimensions',{'lon',size(tas_best1,1)})
ncwrite(fn_out,'lat',lat_best);
ncwrite(fn_out,'lon',lon_best);
ncwriteatt(fn_out,'lat','long_name','latitude')
ncwriteatt(fn_out,'lon','long_name','longitude')
ncwriteatt(fn_out,'lat','units','degrees')
ncwriteatt(fn_out,'lon','units','degrees')

% Write time dimension to netcdf file
time_idxs = 0:(size(tas_best1,3)-1);

nccreate(fn_out,'time','Dimensions',{'time',size(tas_best1,3)})
ncwrite(fn_out,'time',time_idxs)
ncwriteatt(fn_out,'time','units','days since 2070-01-01')

nccreate(fn_out,'month','Dimensions',{'time',size(tas_best1,3)})
ncwrite(fn_out,'month',month_best)
ncwriteatt(fn_out,'month','units','month number')

% Write global attributes (again, not strictly necessary, but very useful);
% using the '/' name for global
ncwriteatt(fn_out,'/','variable','tas')
ncwriteatt(fn_out,'/','variable_long','near-surface air temperature')
ncwriteatt(fn_out,'/','source','Berkeley Earth Surface Temperature Project')
ncwriteatt(fn_out,'/','origin_script','project_best.m')
ncwriteatt(fn_out,'/','projecting_model','CCSM4') 
ncwriteatt(fn_out,'/','projection_method','change monthly means in nearest neighbor') 
ncwriteatt(fn_out,'/','calendar','gregorian of 1980-2009')