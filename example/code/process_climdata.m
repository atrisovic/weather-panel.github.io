% This code takes historical temperature data, calculates the average
% number of bin-days per year, and aggregates those bin-days/year to the
% county level (for only counties in the continental United States). 


clear
%% Load Data
% Set filename of temperature data
fn_tas = '../data/climate_data/BEST/tas_day_BEST_historical_station_19800101-20091231.nc';

% Load temperature data
tas = ncread(fn_tas,'tas');

lat = ncread(fn_tas,'lat');
lon = ncread(fn_tas,'lon');

% Load counties
counties = shaperead('../data/geo_data/UScounties.shp');
% Remove Alaska and Hawaii
counties = counties(cellfun(@(x) ~strcmp(x,'Alaska'),{counties.STATE_NAME}));
counties = counties(cellfun(@(x) ~strcmp(x,'Hawaii'),{counties.STATE_NAME}));

%% Calculate bin-days
% Identify bins (every 10 degrees Farenheit from < 10 to > 90)
% Convert to C, which is what the BEST data is in
bin_edges = ([-Inf 10:10:90 Inf]-32)*5/9;

% Get number of years in data (this rescales across leap years as well)
nyears = size(tas,3)/365;

% Preallocate bin array - lon x lat x bin
bincounts = zeros(size(tas,1),size(tas,2),length(bin_edges)-1)*nan;

% Calculate number of days / year in each bin
for bin_idx = 1:(length(bin_edges)-1)
    bincounts(:,:,bin_idx) = sum(tas>=bin_edges(bin_idx) & tas<bin_edges(bin_idx+1),3)/nyears;
end

% Replace pixels with all 0s with nan (this avoids issues with the
% aggregation below) 
bincounts(sum(reshape(bincounts,[length(lon)*length(lat) 10]),2)==0) = nan;

%% Aggregate to county level
% pixel_overlaps takes a shapefile (counties) and a lat/lon grid, and
% calculates for each polygon in the shapefile which pixels overlap it, and
% by how much; output is a struct with each element corresponding to a
% polygon, giving the indices of each pixel that overlaps with it, and the
% relative overlap between the pixels and it.
county_aggs = pixel_overlaps(counties,lat,lon);
% geo_agg takes the pixel overlap struct calculated above, and aggregates
% the [lon x lat x bin] array of dbins to give a [county x bin] array
% giving the aggregated change per county of bin-days/year.
% The data is saved 'long' - each row of the csv uniquely identifies one
% county/bin combination, with a new column created giving a counter for
% the bin number.
bincounts_agg = geo_agg(bincounts,county_aggs,...
                           'save_csv',true,'../data/climate_data/BEST/tas_bindays_BEST_historical_bycounty_1980-2009.csv',...
                           'field_name','bin_days');

%% Verification
% Check to make sure the aggregation was succesful. This is done by
% checking whether the average of the sum across bins is 365. 
problem_idxs = find(abs(sum(bincounts_agg,2)-365)>0.01);    
% Figure to identify the problematic counties over a backdrop of the
% temperature data
if ~isempty(problem_idxs)
    figure; axesm('bsam'); pcolorm(lat,lon,mean(tas{1},3).'); shading flat; hold on;
    geoshow(counties(problem_idxs),'DefaultFaceColor','none') 
end