% PIXEL_OVERLAPS    calculate the area overlaps between geographic vector
%                   structs and a lat-lon pixel grid
%   
%   [geo_struct,issues,simps] = PIXEL_OVERLAPS(geo_struct,lat,lon) takes
%   the struct of geographic vector data given by [geo_struct] in standard
%   MATLAB geographic vector polygon format ([geo_struct].Geometry =
%   'Polygon', can use either .X/.Y or .lon/.lat) and, for each element,
%   finds all pixels in a grid given by lat/lon that overlap with the
%   vector, and calculates for each pixel the overlapping area in km^2 with
%   the vector. [issues] and [simps] give information about calculation
%   issues (see the section on LOGGING AREAS... below). The following
%   fields area added to [geo_struct] before output (both are [num_pix x 1]
%   vectors):
%       - [tested_pix]: the linear indices (in lon x lat space) of the
%                       pixels that have a non-zero overlap with the vector 
%                       polygon
%       - [pix_areas]: the area (in km^2, assuming WGS84 ellipsoid) of
%                      overlap between the pixel given by each element in
%                      [tested_pix] and the vector polygon
%   
%   [issues,simps] = PIXEL_OVERLAPS(geo_struct,lat,lon,'output_struct',0) 
%   doesn't return the modified geo_struct. 
%
%   [___] = PIXEL_OVERLAPS(geo_struct,lat,lon,'bounds',lat_bnds,lon_bnds)
%   allow for the explicit input of latitude and longitude bounds
%   (especially useful if a non-rectangular grid is used to ensure
%   calculations are as accurate as possible). [lat_bnds] and [lon_bnds]
%   should be [nlon/nlat x 2] vectors with the minimum and maximum extend
%   of each (square) pixel given by each column, respectively.
%
%   [___] = PIXEL_OVERLAPS(geo_struct,lat,lon,'centroids',centroids) allows
%   for the explicit input of centroids of each polygon (used to set a
%   starting guess for pixels to test for overlaps). If no centroids are
%   inputted, then the program calculates them (2017a+) or calculates the
%   center of the bounding box (before 2017a). It is suggested to input
%   centroids manually, since they can be calculated much faster in other
%   programs (GIS, R's spatial data tools, etc.). If inputted, centroids
%   should be a [n_polygon x 2] matrix with columns giving the [lon] and
%   [lat] coordinates of each centroid, respectively.
%
%   SAVING OPTIONS (see flags below for full function options): 
%   If 'save_struct' is set to true (see flags), then the output
%   [geo_struct] from above in addition to [issues], [simps], [lat], and
%   [lon] is saved to a matfile given by [filenameS] (see flags).
%
%   PIXEL_OVERLAPS(...,'[flag]',[params],...) modify program run as below:
%       Input options
%           - 'bounds',[lat_bnds],[lon_bnds] - explicitly set the latitude
%                                              and longitude bounds of each
%                                              pixel (they are otherwise
%                                              derived as being equidistant
%                                              between pixel vertices).
%                                              [lat_bnds] and [lon_bnds]
%                                              are [nlat/nlon x 2]
%                                              matrices.
%           - 'centroids',centroids          - input already calculated
%                                              centroids (they are
%                                              otherwise derived using
%                                              CENTROID if > 2017a or just
%                                              as the center of the
%                                              Bounding Box if not).
%                                              Centroids is a [n_polygon x
%                                              2] matrix with columns
%                                              giving the [lon] and [lat]
%                                              coordinates, respectively).
%
%       Data processing and efficiency options
%           - 'acc_dev',[num]        - set the acceptable deviation of the
%                                      sum of the overlapping pixel areas
%                                      and the area of the polygon. If the
%                                      distance between sum of the
%                                      overalpping pixel areas and the area
%                                      of the polygon is less than
%                                      [acc_dev], then the function moves
%                                      on to the next polygon. If the
%                                      function doesn't manage to find
%                                      overlapping pixels with overlapping
%                                      areas summing to within this number
%                                      of the region area, warnings are
%                                      thrown and the program run
%                                      continues. By default 0.01 (1%).
%           - 'deg_thresh',[num]     - set the first search radius for
%                                      pixels (in degrees) starting from
%                                      the pixel centroid (by default 3)
%           - 'deg_thresh_set',[char]- set whether additional increments of
%                                     the pixel search radius are based on
%                                     0.5*[deg_thresh] ('static') or
%                                     0.5*[long diameter of bounding box]
%                                     ('dynamic'). By default == 'dynamic'.
%           - 'max_deg_search',[num]- set the maximum search radius (in
%                                     degrees) before the run breaks and
%                                     moves on (set to a number beyond
%                                     which aggregating a variable across
%                                     pixels makes no more sense)
%           - 'simplify_polygons',[log],([num])
%                                   - set whether to simplify polygons
%                                     using REDUCEM (by default true) and,
%                                     if true, what to set as the tolerance
%                                     (see REDUCEM documentation for more
%                                     info). 
%           - 'simp_thresh',[int]   - set number of vertices that a polygon
%                                     must have before it is simplified (by
%                                     default, 0, to ensure unfiorm
%                                     treatment across polygons).
%           - 'same_thresh',[int]   - set the maximum number of times the
%                                     pixel search radius is increased
%                                     after the previous increase hasn't
%                                     changed the sum of pixel overlaps
%                                     before breaking and moving on. By
%                                     default 4. 
%
%       Output options
%           - 'save_struct',[log],([filenameS])
%                                   - set whether to save the struct. If
%                                     true, the filename must be set
%                                     ([filenameS] is a string). 
%           - 'struct_name',[char]  - set what to call the output
%                                     [geo_struct] variable in the output
%                                     file (by default 'regions').
%           - 'output_struct',[log] - set whether to output struct as a
%                                     function output in the MATLAB
%                                     environment (by default true). If
%                                     true, the outputs are
%                                     [geo_struct,issues,simps], if false,
%                                     the outputs are [issues,simps]. 
%           - 'export_original_polygons',[log]
%                                   - set whether to export the original
%                                     polygons (before simplification and
%                                     fortification) or the processed
%                                     polygons (used in calculating
%                                     overlaps) in the output [geo_struct].
%                                     By default false, meaning the
%                                     processed polygons are exported.
%
%       Display options
%           To make warnings more useful, the function is able to display
%           the full name of an affected region if it is either in a common
%           format (see below) or if the names of the fields of the
%           inputted [geo_struct] containing identifying information for
%           each polygon are inputted below. This is not necessary
%           (otherwise just the element number of a problematic polygon is
%           printed in the warning), but nevertheless useful in diagnosing
%           problems. Field outputs are separated by commas in warnings
%           (i.e. "Cook, Illinois" for the 'cb_uscounties' setting's "NAME"
%           and "STATE_NAME" fields, respectively).
%
%           - 'struct_naming_convention',[char] - set if the struct is
%                                                 taken from a supported
%                                                 source, in which case,
%                                                 those naming conventions
%                                                 will be used to write
%                                                 warnings.
%                   Currently supported conventions with field names: 
%                          'gadm' - any field that starts with
%                                   "NAME_", in numerical order
%                          'cb_uscounties' - census data; fields
%                                            "NAME" and "STATE_NAME"
%
%           - 'reg_name_fields',[cell]          - a cell array giving the
%                                                 names of the fields (in
%                                                 desired display order)
%                                                 containg identifying
%                                                 information for each
%                                                 polygon in [geo_struct].
%                                               
%       
%       Other options
%           - 'show_simp_warnings',[log]    - set whether to show warnings
%                                             if a polygon is simplified
%                                             (by default, false)
%
%   DETAILED FUNCTION DESCPTION:
%       ALGORITHM:
%           1) Polygon centroids are calculated if they are not already
%              inputted using the flag 'centroids' (it is suggested to
%              calculated centroids in a different language / program,
%              since MATLAB isn't that great at it, and the built-in
%              function is only 2017a+)
%           2) For each polygon (centroid), the linear indices of all
%              pixels within [deg_thresh] are calculated
%           3) The area of the polygon is calculated using AREAINT (using
%              the WGS84 reference ellipsoid in km^2 as the surface). To
%              deal with enclaves / lakes / lakes in islands, each section
%              of the polygon (delimted by NaNs) is considered separately:
%              if a majority of max(5,# of vertices) randomly chosen
%              vertices of the subpolygon are within an even number of
%              other subpolygons (including 0), it is considered positive
%              area, and negative area if the number of subpolygons is odd.
%           4) Region vertices are forced to be clockwise if they
%              are not (a requirement of polybool) - POLY2CW is relatively
%              computationally intensive, so make sure vertices in regions
%              in [geo_struct] are CW from the start if you can for
%              efficiency.
%           5) If the area of the polygon is large enough
%              ([convex_hull_thresh]), convex hulls are calculated for each
%              subpolygon (see EFFICIENCY PROCEDURES below)
%           6) If the area of the polygon is smaller than the maximum pixel
%              area, it is tested if the bounding box of the polygon is 
%              entirely within the bounding box of the first tested pixel,
%              and if so, the [pix_areas] of the first pixel is set to the
%              area of the polygon, and the calculation is set to continue
%              with the next polygon
%           7) If a region crosses the prime meridian, it is moved an
%              arbitrarily large longitudinal distance away ([reg_shift])
%              (in addition to all tested pixels) to avoid issues with
%              double counting pixels because the overlapping area is
%              calculated the "wrong way" around the globe
%           8) Starting with the closest pixel to the polygon centroid, the
%              area overlap between each pixel and the polygon is
%              calculated, again using AREAINT and the same procedure to
%              deal with holes/etc. as above.  
%           9) If the sum of tested pixel overlap areas does not reach
%              within [acc_dev] of the area of the polygon within the
%              initial pixels tested (those within [deg_thresh] of the
%              polygon centroid), the search radius is expanded by
%              increments of 1/2 * the original search radius [deg_thresh]
%              ([deg_thresh_set] == 'static') or by increments of 1/2 * the
%              length of a line going through opposite vertices of the
%              bounding box ([deg_thresh_set] == 'dynamic'), and the
%              procedure is contined. 
%           10) The calculation stops when the sum of the tested pixel
%               overlap areas is within [acc_dev] of the area of the 
%               polygon.
%           11) The overlapping areas of all other pixels are set to 0,
%               pixels wtih 0 area overlap are removed, and the remaining
%               pixels have their indices and overlapping areas saved to
%               [tested_pix] and [pix_areas], respectively
%
%       EFFICIENCY PROCEDURES:
%       Due to the large computational cost of calculating areas of
%       polygons on the surfaces of spheres and calculating the overlap
%       between two polygons, several techniques are used to speed up the
%       process. 
%           - Simplification of polygons: if a polygon has more than
%             [simp_thresh] (by default 0) vertices, it is simplified using
%             REDUCEMEM to the tolerance given by [poly_simp_tol] (by
%             default 0.002). Set [simp_thresh]=Inf if no simplification is
%             desired.
%           - 1-pixel calculation: if the area of the polygon is less than
%             the maximum pixel area, and all vertices are within the
%             vertices of the closest pixel to the polygon centroid,
%             [pix_areas] is set to the area of the polygon and no overlaps
%             are further calculated.
%           - Exclusion of pixels outside of bounding box: if the vertices
%             of a pixel are more than the maximum pixel diameter away from
%             the edge of the bounding box of the polygon, it is skipped
%           - Exclusion of pixels outside convex hulls: if the polygon is
%             larger than [convex_hull_thresh] (due to added computation
%             time related to processing of convex hulls (especially use of
%             POLYXPOLY below), this only results in performance
%             improvement for large polygons), the convex hulls of every
%             subpolygon of the polygon are found, and pixels are only
%             processed if 1) any of the 4 pixel vertices are within a
%             convex hull, 2) the boundary of the pixel intersects any
%             convex hull (POLYXPOLY), or 3) the pixel wholly contains a
%             convex hull.
%           - Giving up the search if [same_thresh] expansions of the pixel
%             search radius in a row do not change the (incorrect) sum of
%             the pixel overlap areas (this might happen due to accuracy
%             issues with [areaint] for regions with fewer vertices,
%             simplification causing the polygon to become
%             self-intersecting, among other potential problems. Usually
%             the error is within 2-3%.).
%
%
%       LOGGING AREAS WITH CALCULATION ISSUES
%       Warnings are thrown during calculation if 
%           1) the sum of overlapping areas of the tested pixels > the area
%              of the vector
%           2) the sum of overlapping areas of the tested pixels is not
%              within [acc_dev] (by default 1%), the acceptable deviation
%              in area, after a certain number of tries (set by
%              [same_thresh]) or beyond a search area (set by
%              [max_deg_search])
%       If this occurs, information about the region and failed calculation
%       is added to [issues], a [num_issue_regions x 4] table with columns:
%           INDEX         PIX_AREA             REG_AREA        AREA_RATIO
%           element #     sum of overlapping   area of         pix_area /  
%           of issue in   areas of pixels      region          reg_area 
%           [geo_struct]  with region
%       
%       LOGGING AREAS WITH SIGNIFICANT CHANGES THROUGH SIMPLIFICATION
%       Warnings are thrown after simplification of vectors with more than
%       [simp_thresh] vertices if
%           - the resultant "error" in path length is larger than 0
%       If this occurs, information about the region and simplification
%       calcualtion is added to [simps], a [num_simplified_regions x 2]
%       table with columns: 
%           INDEX               D_ARCLENGTH
%           element # of        change in arclength of vector 
%           simplified area     due to simplification calculation
%           in [geo_struct]
%
%   DIAGNOSTIC FIGURE: 
%       If a polygon calculation warning seems worrying, you can use this
%       code to produce a diagnostic figure plotting the polygon itself
%       with filled circles at each pixel coordinate colored by the area of
%       the pixel overlap with the polygon, the linear index of each pixel,
%       and the convex hulls of the polygon (the program run must be
%       interrupted within the loop over polygons):
%
%           figure; 
%           mapshow(geo_struct_tmp); hold on; 
%           scatter(lonxx(closest_pixs_tmp),latyy(closest_pixs_tmp),50,pix_area,'filled'); 
%           colormap(jet(10)); colorbar
%           for i = 1:length(closest_pixs_tmp);
%               text(double(lonxx(closest_pixs_tmp(i))),double(latyy(closest_pixs_tmp(i))),num2str(i));
%           end
%           for i = 1:length(convex_hulls)
%               plot(convex_hulls{i,1}(convex_hulls{i,2},1),...
%                convex_hulls{i,1}(convex_hulls{i,2},2),'-r');
%           end
%
%   NOTE: it looks like sometime between 2014b and 2017a, MATLAB decided to
%   change what it considers 'CCW/CW' in polygon vertices (or I'm just
%   going crazy); if there are errors or warnings talking about a missing
%   contour or a lot of "not CW" warnings are shown, switch the commented
%   and uncommented lines in the section "Generate polygon for each pixel".
%
%   FUNCTIONS REQUIRED (on path); derive_bnds (if no lat/lon bounds are
%   inputted)
%
%   SEE ALSO derive_bnds, reducem, areaint, polyxpoly, centroid
%                                  
%   For questions/comments, contact Kevin Schwarzwald
%   kschwarzwald@uchicago.edu
%   Last modified 12/26/2017

function varargout = pixel_overlaps(geo_struct,lat,lon,varargin)

%% Set defaults
%Empty lat/lon bounds by default
lat_bnds = [];
lon_bnds = [];
%Empty centroids by default
centroids = [];

%Set point search threshhold (picking how far, in degrees, away from the
%county the program searches for grid cells)
deg_thresh = 3;
deg_thresh_set = 'dynamic'; %deg_thresh_set = 'static';
max_deg_search = 25;
poly_simp = true;
poly_simp_tol = 0.002;
simp_thresh = 0;
convex_hull_thresh = 1e5; %(inpolygon can slow this thing down, so only use it when the benefits are large, i.e. in large polygons)
reg_shift = 42.139; %How much to move regions/pixels westward if they cross the prime meridian (Should be bigger than max_deg_search / any width of region to avoid the problem you're trying to avoid by moving it)
%Set pixel area vs. county acceptable area deviation (relative) above which
%farther pixels will be searched for
acc_dev = 0.01; %acc_dev = 0.001
%Set how many times you accept an expansion of the search radius not
%changing the area found before breaking
same_thresh = 4;

%Output conventions
output_struct = true;
save_struct = false;
filenameS = [];
region_struct_name = 'regions';
export_original_polygons = false; 

%Display conventions
cust_regname_fields = false;
%Struct naming convention
struct_names = 'gadm';

%Other run conventions
show_simp_warnings = false;

%% Set behavior of optional function flags
if (~isempty(varargin))
    for in_idx = 1:length(varargin)
        switch varargin{in_idx}
            %Input data options
            case {'bounds'}
                lat_bnds = varargin{in_idx+1}; varargin{in_idx+1} = 0;
                lon_bnds = varargin{in_idx+2}; varargin{in_idx+2} = 0;
            case {'centroids'}
                centroids = varargin{in_idx+1}; varargin{in_idx+1} = 0;
                
                %Data processing / efficiency options
            case {'deg_thresh'}
                deg_thresh = varargin{in_idx+1};
            case {'deg_thresh_set'}
                deg_thresh_set = varargin{in_idx+1};
            case {'max_deg_search'}
                max_deg_search = varargin{in_idx+1};
            case {'simplify_polygons'}
                poly_simp = varargin{in_idx+1};
                if poly_simp
                    poly_simp_tol = varargin{in_idx+2};
                end
            case {'simp_thresh'}
                simp_thresh = varargin{in_idx+1};
            case {'acc_dev'}
                acc_dev = varargin{in_idx+1};
            case {'same_thresh'}
                same_thresh = varargin{in_idx+1};
                
                %Output conventions
            case {'save_struct'}
                save_struct = varargin{in_idx+1};
                if save_struct
                    filenameS = varargin{in_idx+2};
                end
            case {'struct_name'}
                region_struct_name = varargin{in_idx+1};
            case {'output_struct'}
                output_struct = varargin{in_idx+1};
            case {'export_original_polygons'}
                export_original_polygons = varargin{in_idx+1};
                
                %Display conventions
            case {'reg_name_fields'}
                cust_regname_fields = true;
                reg_names = varargin{in_idx+1}; varargin{in_idx+1} = 0;
            case {'struct_naming_convention'}
                struct_names = varargin{in_idx+1};
                
                %Other run conventions
            case {'show_simp_warnings'}
                show_simp_warnings = varargin{in_idx+1};
                
        end
    end
end
%% Fortify struct to generalizability + determine name fields for better warning message creation
%Calculations assume map coordinates (field names of X,Y) instead of
%geographic coordinates (field names of lat,lon)
if ~any(cell2mat(cellfun(@(x) isequal(x,'X'),fieldnames(geo_struct),'UniformOutput',0))) && any(cell2mat(cellfun(@(x) isequal(x,'lat'),fieldnames(geo_struct),'UniformOutput',0)))
    geo_struct.X = geo_struct.lon;
    geo_struct.Y = geo_struct.lat;
end

%For warnings, if not set manually, find the fields corresponding to
%the names of the region from defaults (or leave them blank) (the
%reg_names variable can have any length, since strjoin is used for
%outputting it in the end)
if ~cust_regname_fields
    if strcmp(struct_names,'gadm')
        %This method is robust to administrative level
        fns = fieldnames(geo_struct);
        %reg_names = fns(startsWith(fns,'NAME_'));
        reg_names = fns(~cellfun(@isempty,regexp(fns,'^NAME_.*')));
    elseif strcmp(struct_names,'cb_uscounties')
        reg_names = {'NAME','STATE_NAME'};
    else
        reg_names = {''};
    end
end

%% Process lat / lon grid
%Make grid [0,360]
lon(lon<0) = lon(lon<0)+360;
%Get geographic grid (if size 2 ~= 1, then the grid isn't rectangular
%and is already in array form)
if size(lat,2)==1
    [lonxx,latyy] = ndgrid(lon,lat);
else
    lonxx = lon;
    latyy = lat;
end
%Linearize lat / lon grid
lon_lat = double([lonxx(:) latyy(:)]);

%If need to interpolate lat/lon bounds, do so
if isempty(lat_bnds)
    [lat_bnds,lon_bnds] = derive_bnds(lat,lon,'set_positive');
end

%Get max distance between adjacent points
max_lat_step = abs(max(lat(2:end)-lat(1:(length(lat)-1))));
max_lon_step = abs(max(lon(2:end)-lon(1:(length(lon)-1))));

%% Calculate centroids, if necessary
if isempty(centroids)
    centroids = zeros(numel(geo_struct),2);
    for reg_idx = 1:numel(geo_struct)
        [centroids(reg_idx,1),centroids(reg_idx,2)] = centroid(polyshape(geo_struct(reg_idx).X,geo_struct(reg_idx).Y));
    end
end

%Change centroid lons to [0 360] to avoid antimeridian issues
centroids(centroids(:,1)<0,1) = centroids(centroids(:,1)<0,1)+360;

%% Populate initial guesses for pixels to look at
closest_pixs = rangesearch(lon_lat,centroids(:,1:2),deg_thresh);

%% Generate polygon for each pixel
%Get total number of pixels (supporting both vector and matrix grids)
if size(lon,2)==1
    num_pixels = length(lon)*length(lat);
else
    num_pixels = numel(lon);
end
%Preallocate struct
pix_polys(num_pixels).Lat = 0;
%Generate struct for each pixel
for poly_idx = 1:num_pixels
    if size(lon,2) == 1
        [lon_idx,lat_idx] = ind2sub([length(lon) length(lat)],poly_idx);
    else %for matrix geographic grids, the linear index is already the correct one
        lon_idx = poly_idx; lat_idx = poly_idx;
    end
    pix_polys(poly_idx).Lat = [lat_bnds(lat_idx,1); lat_bnds(lat_idx,2); lat_bnds(lat_idx,2); lat_bnds(lat_idx,1); lat_bnds(lat_idx,1);NaN];
    pix_polys(poly_idx).Lon = [lon_bnds(lon_idx,1); lon_bnds(lon_idx,1); lon_bnds(lon_idx,2); lon_bnds(lon_idx,2); lon_bnds(lon_idx,1);NaN];
    %pix_polys(poly_idx).Lat = [lat_bnds(lat_idx,1); lat_bnds(lat_idx,1); lat_bnds(lat_idx,2); lat_bnds(lat_idx,2); lat_bnds(lat_idx,1);NaN];
    %pix_polys(poly_idx).Lon = [lon_bnds(lon_idx,1); lon_bnds(lon_idx,2); lon_bnds(lon_idx,2); lon_bnds(lon_idx,1); lon_bnds(lon_idx,1);NaN];
    pix_polys(poly_idx).Geometry = 'Polygon';
end

%Find area of largest pixel (at equator)
mid_idx_tmp = sub2ind([length(lon) length(lat)],round(length(lat)/2),1);
max_pix_area = areaint(pix_polys(mid_idx_tmp).Lat,pix_polys(mid_idx_tmp).Lon,wgs84Ellipsoid('kilometer'));
clear mid_idx_tmp

%% Process by country
%Pre-allocate output arrays summarizing calculation issues
issue_areas = [0 0 0 0];
simplified_areas = [0 0];
geo_struct(1).tested_pix = [];
geo_struct(1).pix_areas = [];
start_proc = tic;
tic
for reg_idx = 1:numel(geo_struct)
    initial_vars = who;
    geo_struct_tmp = geo_struct(reg_idx);
    
    %% Make longitudes positive to minimize issues at the antimeridian
    geo_struct_tmp.X(geo_struct_tmp.X<0) = geo_struct_tmp.X(geo_struct_tmp.X<0)+360;
    
    %% Simplify paths of overly complicated polygons to increase calc speeds
    if poly_simp && length(geo_struct_tmp.X)>simp_thresh
        [geo_struct_tmp.Y,geo_struct_tmp.X,red_err] = reducem(geo_struct_tmp.Y(:),geo_struct_tmp.X(:),poly_simp_tol);
        if red_err>0
            simplified_areas = [simplified_areas;reg_idx, red_err]; %#ok<AGROW>
            if show_simp_warnings
                warning(['The polygon for ',strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),' (ID = ',num2str(reg_idx),...
                    ') is too complex for computational efficiency, and was simplified to a tolerance of 0.1 deg arclength. The resultant error (% diff in arclength) is ',num2str(red_err)])
            end
        end
    end
    
    %If polygon has no vertices (oversimplification through reducem
    %above; error in shapefile; etc.), continue, with warning
    if isempty(geo_struct_tmp.X)
        warning(['The polygon for ',strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),' (ID = ',num2str(reg_idx),...
            ') has no vertices, likely due to either an oversimplification of the polygon using reducem or some issue with the shapefile. Breaking and moving on.'])
        issue_areas = [issue_areas;reg_idx,0,0,0]; %#ok<AGROW>
        continue
    end
    
    %% Calculate area of region (post-simplifaction)
    if ~isnan(geo_struct_tmp.X(end))
        geo_struct_tmp.X(end+1) = NaN;
        geo_struct_tmp.Y(end+1) = NaN;
    end
    area_sign = zeros(sum(isnan(geo_struct_tmp.X)),1);
    poly_delims = [0;find(isnan(geo_struct_tmp.X))];
    if sum(isnan(geo_struct_tmp.X))>=2
        for poly_delim = 1:sum(isnan(geo_struct_tmp.X))
            %For each separate polygon section, calculate if it is within any
            %other polygon section by using up to 5 randomly chosen vertices
            %and inpolygon
            area_sign_tmp = zeros(sum(isnan(geo_struct_tmp.X)),1);
            test_poly_rand_vertices = randperm(length((poly_delims(poly_delim)+1):(poly_delims(poly_delim+1))),min(5,length((poly_delims(poly_delim)+1):(poly_delims(poly_delim+1)))))+poly_delims(poly_delim);
            for poly_delim2 = 1:sum(isnan(geo_struct_tmp.X))
                if poly_delim2~=poly_delim
                    %Define a polygon as being in another one if a majority of
                    %the tested vertices are within the other one...
                    test_vertices_tmp = inpolygon(geo_struct_tmp.X(test_poly_rand_vertices),geo_struct_tmp.Y(test_poly_rand_vertices),...
                        geo_struct_tmp.X((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)),geo_struct_tmp.Y((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)));
                    area_sign_tmp(poly_delim2) = sum(test_vertices_tmp)>(min(5,length((poly_delims(poly_delim)+1):(poly_delims(poly_delim+1))))/2);
                    %area_sign_tmp(poly_delim2) = inpolygon(geo_struct_tmp.X(poly_delims(poly_delim)+1),geo_struct_tmp.Y(poly_delims(poly_delim)+1),...
                    %    geo_struct_tmp.X((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)),geo_struct_tmp.Y((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)));
                end
            end
            %If a polygon is within an even number of other polygons, then it
            %is to be counted; otherwise its area should be subtracted.
            if rem(sum(area_sign_tmp),2)==0
                area_sign(poly_delim) = 1;
            else
                area_sign(poly_delim) = -1;
            end
        end
        %Sum the areas of the individual sections multiplied by the
        %corresponding factor (+1 for region sections, -1 for holes)
        reg_area = areaint(geo_struct_tmp.Y,geo_struct_tmp.X,wgs84Ellipsoid('kilometer'))'*area_sign;
    else
        reg_area = areaint(geo_struct_tmp.Y,geo_struct_tmp.X,wgs84Ellipsoid('kilometer'));
    end
    
    %% Make reg boundaries ccw for polybool (it's moody like that)
    if ~ispolycw(geo_struct_tmp.X,geo_struct_tmp.Y)
        [geo_struct_tmp.X,geo_struct_tmp.Y] = poly2cw(geo_struct_tmp.X,geo_struct_tmp.Y);
    end
    
    %% Set counters, etc.
    %Extract closest pixels
    closest_pixs_tmp = closest_pixs{reg_idx};
    if isempty(closest_pixs_tmp)
        warning('PIXEL_OVERLAPS:NoPixelsFound',['No pixels were found within ',...
            num2str(deg_thresh),' of the centroid of the polygon for ',...
            strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),...
            ' (ID = ',num2str(reg_idx),...
            '), skipping for now. There should probably be additional safeguards to make sure this isn''t just a centroid misplacement problem.'])
        continue
    end
    %Seed original total pixel area as 0s (for while loop)
    pix_area = zeros(length(closest_pixs_tmp),1);
    %Set a counter for the while loop, to make sure higher computations
    %are only done when necessary
    cntr = 0;
    %Set a counter for how many times an expansino of the test radius
    %doesn't change the result
    same_counter = 0;
    prev_sum = 0;
    %Reset degree threshhold for original guess
    deg_thresh_tmp = deg_thresh;
    %Set starting pixel to count
    start_pix = 1;
    
    %% Calculate convex hulls for particularly large regions
    if reg_area>convex_hull_thresh
        %Separate out each individual portion of the region (separated by NaNs)
        try
            nan_idxs = [0;find(isnan(geo_struct_tmp.X))];
        catch
            nan_idxs = [0,find(isnan(geo_struct_tmp.X))];
        end
        
        %For each of these portions, calculate the convex hull
        convex_hulls = cell(length(nan_idxs)-1,2);
        convex_hull_areas = zeros(length(nan_idxs)-1,1);
        for sub_hull_idx = 1:(length(nan_idxs)-1)
            convex_hulls{sub_hull_idx,1} = [geo_struct_tmp.X((nan_idxs(sub_hull_idx)+1):(nan_idxs(sub_hull_idx+1)-1)) geo_struct_tmp.Y((nan_idxs(sub_hull_idx)+1):(nan_idxs(sub_hull_idx+1)-1))];
            convex_hulls{sub_hull_idx,2} = convhull(geo_struct_tmp.X((nan_idxs(sub_hull_idx)+1):(nan_idxs(sub_hull_idx+1)-1)),...
                geo_struct_tmp.Y((nan_idxs(sub_hull_idx)+1):(nan_idxs(sub_hull_idx+1)-1)));
            convex_hull_areas(sub_hull_idx) =  areaint(convex_hulls{sub_hull_idx,1}(convex_hulls{sub_hull_idx,2},1),...
                convex_hulls{sub_hull_idx,1}(convex_hulls{sub_hull_idx,2},2),wgs84Ellipsoid('kilometer'));
        end
        hulls_smaller_than_pixels = find(convex_hull_areas<max_pix_area);
    end
    
    %% Find overlap with pixels until area within [acc_dev] is found
    if reg_area < max_pix_area
        %If the region is entirely within the first pixel, then don't
        %bother with the stuff below, it's just the first pixel that will
        %be kept.
        if all(geo_struct_tmp.X(~isnan(geo_struct_tmp.X))<max(pix_polys(closest_pixs_tmp(1)).Lon)&geo_struct_tmp.X(~isnan(geo_struct_tmp.X))>min(pix_polys(closest_pixs_tmp(1)).Lon))&&...
                all(geo_struct_tmp.Y(~isnan(geo_struct_tmp.Y))<max(pix_polys(closest_pixs_tmp(1)).Lat)&geo_struct_tmp.Y(~isnan(geo_struct_tmp.Y))>min(pix_polys(closest_pixs_tmp(1)).Lat))
            %Save the resultant pixel indices and areas in the struct (dropping
            %ones with 0 area)
            geo_struct(reg_idx).tested_pix = closest_pixs_tmp(1);
            geo_struct(reg_idx).pix_areas = reg_area;
            
            %Progress message
            if rem(reg_idx,100)==0
                toc
                disp([num2str(reg_idx),' regions processed!'])
                tic
            end
            
            %Continue (already calculated the pixel overlap)
            continue
        end
    end
    
    %If region crosses the prime meridian, just shift it over a bit to
    %avoid that, since polybool uses cartesian coordinates and can't deal
    %with that?
    if any(geo_struct_tmp.X<20)&&any(geo_struct_tmp.X>340)
        reg_shift_tmp = reg_shift;
        lon_lat_tmp = lon_lat;
        lon_lat_tmp(:,1) = lon_lat_tmp(:,1) - reg_shift_tmp;
        lon_lat_tmp(lon_lat_tmp(:,1)<0,1) = lon_lat_tmp(lon_lat_tmp(:,1)<0,1)+360;
        centroids_tmp = centroids(reg_idx,1:2);
        centroids_tmp(1) = centroids_tmp(1) - reg_shift_tmp;
        if centroids_tmp(1)<0; centroids_tmp(1) = centroids_tmp(1)+360; end
        
        %Redo rangesearch as well (it otherwise cuts off at 360/0)
        closest_pixs_tmp = rangesearch(lon_lat_tmp,centroids_tmp,deg_thresh_tmp*(1+0.5*cntr));
        closest_pixs_tmp = closest_pixs_tmp{1};
    else
        reg_shift_tmp = 0;
        centroids_tmp = centroids(reg_idx,1:2);
        lon_lat_tmp = lon_lat;
    end
    geo_struct_tmp_postshift = geo_struct_tmp;
    geo_struct_tmp_postshift.X = geo_struct_tmp_postshift.X - reg_shift_tmp;
    geo_struct_tmp_postshift.X(geo_struct_tmp_postshift.X<0) = geo_struct_tmp_postshift.X(geo_struct_tmp_postshift.X<0)+360;
    
    %While loop to make sure pixels chosen actually cover all of the
    %country (starting with a low number, for code efficiency).
    %Sensitivity to this discrepancy is set by [acc_dev].
    while abs(sum(pix_area)-reg_area)/reg_area>acc_dev
        %If the counter is above 0, then the first tried minimum
        %centroid distance did not cover all overlapping pixels, in
        %which case a higher number is attempted.
        if cntr>0
            prev_sum = sum(pix_area);
            
            %First check to make sure the centroid is even in the right
            %spot....
            centroid_reset = false;
            if cntr==1&&((centroids(reg_idx,1))>max(geo_struct_tmp_postshift.X+reg_shift_tmp) ||...
                    (centroids(reg_idx,1))<min(geo_struct_tmp_postshift.X+reg_shift_tmp) ||...
                    centroids(reg_idx,2)>max(geo_struct_tmp_postshift.Y) ||...
                    centroids(reg_idx,2)<min(geo_struct_tmp_postshift.Y))
                if isempty(strfind(version,'2017b'))
                    warning(['The centroid for ',strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),' (ID = ',num2str(reg_idx),...
                        ') is not within the bounding box of the region. Unfortunately, the matlab function "centroid" is only available starting in 2017b, which this run is not on. The centroid will be estimated by the average of the vertices in the region. There may therefore be issues in finding overlaps...'])
                    centroids_tmp(1:2) = [nanmean(geo_struct_tmp_postshift.X),nanmean(geo_struct_tmp_postshift.Y)];
                    centroid_reset = true;
                else
                    [centroids_tmp(1),centroids_tmp(2)] = centroid(polyshape(geo_struct_tmp.X+reg_shift_tmp,geo_struct_tmp.Y));
                    centroid_reset = true;
                end
            end
            
            %If dynamic, use longest diameter / 2 as a starting guess
            %if larger than original starting guess
            if strcmp(deg_thresh_set,'dynamic')
                if cntr==1 && deg_thresh_tmp < 0.5*sqrt((max(geo_struct_tmp_postshift.X)-min(geo_struct_tmp_postshift.X))^2+(max(geo_struct_tmp_postshift.Y)-min(geo_struct_tmp_postshift.Y))^2)
                    deg_thresh_tmp =  0.5*sqrt((max(geo_struct_tmp_postshift.X)-min(geo_struct_tmp_postshift.X))^2+(max(geo_struct_tmp_postshift.Y)-min(geo_struct_tmp_postshift.Y))^2);
                end
            end
            %Break if looking past the max search threshold
            if deg_thresh_tmp*(1+0.5*cntr) > max_deg_search
                if cntr==1
                    deg_thresh_tmp = max_deg_search/(1+0.5*cntr);
                else
                    %Break if you're searching a pixel radius of
                    %greater than max search (in degrees) threshold;
                    warning(['***********ERROR WITH ',strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),' (ID = ',num2str(reg_idx),...
                        '); clearly not finding the right overlap (search pattern had been expanded to beyond ',num2str(max_deg_search),').'])
                    issue_areas = [issue_areas;reg_idx,sum(pix_area),reg_area,sum(pix_area)/reg_area]; %#ok<AGROW>
                    break
                end
            end
            
            %Warning is included - if most pixels trigger warning, then
            %setting a higher original [deg_thresh] may be more
            %efficient
            if ~centroid_reset
                warning(['The sum of the intersects of the pixels with the region, ',...
                    num2str(sum(pix_area)),', is not within ',num2str(acc_dev*100),...
                    '% of the area of the region, ',num2str(reg_area),...
                    ' for ',strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),' (ID = ',num2str(reg_idx),...
                    '). Calculation redone with pixels within ',num2str((1+0.5*cntr)*deg_thresh_tmp),' degrees.'])
            end
            
            %Make sure that pixels aren't doubly processed (don't worry,
            %rangesearch is consistent, and will have the same first n
            %pixels every time)
            if centroid_reset && cntr==1
                start_pix = 1;
                %Get pixels within the new radius
                closest_pixs_tmp = rangesearch(lon_lat_tmp,centroids_tmp,deg_thresh_tmp);
                closest_pixs_tmp = closest_pixs_tmp{1};
                pix_area = zeros(length(closest_pixs_tmp),1);
            else
                %Get pixels within the new radius
                start_pix = length(closest_pixs_tmp)+1;
                closest_pixs_tmp = rangesearch(lon_lat_tmp,centroids_tmp,deg_thresh_tmp*(1+0.5*cntr));
                closest_pixs_tmp = closest_pixs_tmp{1};
            end
            
            %Expand the pre-allocated pix_area vector to include the newly
            %added pixels
            pix_area(start_pix:length(closest_pixs_tmp)) = zeros(length(start_pix:length(closest_pixs_tmp)),1);
        end
        
        %For each of the subsetted pixels (within deg_thresh of country
        %centroid), get the intersection of the pixel with the country,
        %and calculate its area (0% is possible/okay).
        for pix_idx = start_pix:length(closest_pixs_tmp)
            pix_polys_tmp = pix_polys(closest_pixs_tmp(pix_idx));
            pix_polys_tmp.Lon = pix_polys_tmp.Lon-reg_shift_tmp;
            pix_polys_tmp.Lon(pix_polys_tmp.Lon<0) = pix_polys_tmp.Lon(pix_polys_tmp.Lon<0)+360;
            
            %If the boundaries of the pixel are clearly beyond the
            %scope of the polygon, skip it ("clearly" == more than the
            %max distance between pixels in that dimension away)
            if ((min(pix_polys_tmp.Lon)-nanmax(geo_struct_tmp_postshift.X))>max_lon_step || ...
                    (nanmin(geo_struct_tmp_postshift.X)-max(pix_polys_tmp.Lon))>max_lon_step || ...
                    (min(pix_polys_tmp.Lat)-nanmax(geo_struct_tmp_postshift.Y))>max_lat_step || ...
                    (nanmin(geo_struct_tmp_postshift.Y)-max(pix_polys_tmp.Lat))>max_lat_step)
                pix_area(pix_idx) = 0;
                continue
            end
            
            %If the boundaries of the pixel are all outside of the convex
            %hulls of all the individual bits, then skip as well
            if reg_area>convex_hull_thresh
                %Test first if the 4 vertices of the pixel are within any
                %of the convex hulls...
                tmp_overlaps = zeros(size(convex_hulls,1),1);
                for sub_hull_idx = 1:size(convex_hulls,1)
                    if any(inpolygon(pix_polys_tmp.Lon,pix_polys_tmp.Lat,...
                            convex_hulls{sub_hull_idx,1}(convex_hulls{sub_hull_idx,2},1),convex_hulls{sub_hull_idx,1}(convex_hulls{sub_hull_idx,2},2)))
                        tmp_overlaps(sub_hull_idx) = 1;
                        continue %just need one vertex inside one on the convex hulls
                    end
                end
                
                %...if not, check to see if the boundary of the pixel
                %intersect any convex hull...
                if sum(tmp_overlaps)==0
                    tmp_overlaps = zeros(size(convex_hulls,1),1);
                    for sub_hull_idx = 1:size(convex_hulls,1)
                        %Sees if any of the convex hulls intersect the pixel
                        %line. If so (just need one), break, and calculate area
                        %as normal.
                        if ~isempty(polyxpoly(convex_hulls{sub_hull_idx,1}(convex_hulls{sub_hull_idx,2},1),convex_hulls{sub_hull_idx,1}(convex_hulls{sub_hull_idx,2},2),...
                                pix_polys_tmp.Lon(1:5),pix_polys_tmp.Lat(1:5)))
                            tmp_overlaps(sub_hull_idx) = 1;
                            continue
                        end
                    end
                end
                
                %...and finally if any of the smallest convex hulls
                %(smaller than the max pixel area, because otherwise they'd
                %show up above) are within the pixel boundary.
                if sum(tmp_overlaps)==0
                    tmp_overlaps = zeros(length(hulls_smaller_than_pixels),1);
                    for sub_hull_idx = 1:length(hulls_smaller_than_pixels)
                        if any(inpolygon(convex_hulls{hulls_smaller_than_pixels(sub_hull_idx),1}(convex_hulls{hulls_smaller_than_pixels(sub_hull_idx),2},1),...
                                convex_hulls{hulls_smaller_than_pixels(sub_hull_idx),1}(convex_hulls{hulls_smaller_than_pixels(sub_hull_idx),2},2),...
                                pix_polys_tmp.Lon,pix_polys_tmp.Lat))
                            tmp_overlaps(sub_hull_idx) = 1;
                            continue
                        end
                    end
                end
                
                %If this is the case for none of them, skip the pixel,
                %since it doesn't overlap with the region
                if sum(tmp_overlaps)==0
                    continue
                end
            end
            
            %Get new polygon that's the overlap between the pixel and the
            %region
            [int_tmp_x,int_tmp_y] = polybool('intersection',geo_struct_tmp_postshift.X,geo_struct_tmp_postshift.Y,...
                pix_polys_tmp.Lon,pix_polys_tmp.Lat);
            
            %Calculate area of overlap with pixel
            if ~isempty(int_tmp_x)
                if any(isnan(int_tmp_x))
                    if ~isnan(int_tmp_x(end))
                        int_tmp_x(end+1) = NaN; %#ok<AGROW>
                        int_tmp_y(end+1) = NaN; %#ok<AGROW>
                    end
                    area_sign = zeros(sum(isnan(int_tmp_x)),1);
                    poly_delims = [0;find(isnan(int_tmp_x))];
                    for poly_delim = 1:sum(isnan(int_tmp_x))
                        %For each separate polygon section, calculate if it is within any
                        %other polygon section by using the first vertex and inpolygon
                        %area_sign_tmp = zeros(sum(isnan(int_tmp_x)),1);
                        %for poly_delim2 = 1:sum(isnan(int_tmp_x))
                        %    if poly_delim2~=poly_delim
                        %        area_sign_tmp(poly_delim2) = inpolygon(int_tmp_x(poly_delims(poly_delim)+1),int_tmp_y(poly_delims(poly_delim)+1),...
                        %            int_tmp_x((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)),int_tmp_y((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)));
                        %    end
                        %end
                        %For each separate polygon section, calculate if it is within any
                        %other polygon section by using up to 5 randomly chosen vertices
                        %and inpolygon
                        area_sign_tmp = zeros(sum(isnan(int_tmp_x)),1);
                        test_poly_rand_vertices = randperm(length((poly_delims(poly_delim)+1):(poly_delims(poly_delim+1))),min(5,length((poly_delims(poly_delim)+1):(poly_delims(poly_delim+1)))))+poly_delims(poly_delim);
                        for poly_delim2 = 1:sum(isnan(int_tmp_x))
                            if poly_delim2~=poly_delim
                                %Define a polygon as being in another one if a majority of
                                %the tested vertices are within the other one...
                                test_vertices_tmp = inpolygon(int_tmp_x(test_poly_rand_vertices),int_tmp_y(test_poly_rand_vertices),...
                                    int_tmp_x((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)),int_tmp_y((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)));
                                area_sign_tmp(poly_delim2) = sum(test_vertices_tmp)>(min(5,length((poly_delims(poly_delim)+1):(poly_delims(poly_delim+1))))/2);
                                %area_sign_tmp(poly_delim2) = inpolygon(geo_struct_tmp.X(poly_delims(poly_delim)+1),geo_struct_tmp.Y(poly_delims(poly_delim)+1),...
                                %    geo_struct_tmp.X((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)),geo_struct_tmp.Y((poly_delims(poly_delim2)+1):poly_delims(poly_delim2+1)));
                            end
                        end
                        %If a polygon is within an even number of other polygons, then it
                        %is to be counted; otherwise its area should be subtracted.
                        if rem(sum(area_sign_tmp),2)==0
                            area_sign(poly_delim) = 1;
                        else
                            area_sign(poly_delim) = -1;
                        end
                    end
                    %Sum the areas of the individual sections multiplied by the
                    %corresponding factor (+1 for region sections, -1 for holes)
                    pix_area(pix_idx) = areaint(int_tmp_y,int_tmp_x,wgs84Ellipsoid('kilometer'))'*area_sign;
                else
                    pix_area(pix_idx) = areaint(int_tmp_y,int_tmp_x,wgs84Ellipsoid('kilometer'));
                end
                
            else
                pix_area(pix_idx) = 0;
            end
            
            %If the calculated area is within the threshold, break (not
            %done every time to not overdo it and slow down the program too
            %much
            if rem(pix_idx,100)==0
                if abs(sum(pix_area)-reg_area)/reg_area<acc_dev
                    break
                end
            end
        end
        
        %If expansions of the test pixel radius does nothing for a few
        %times, just break and move on.
        if sum(pix_area)==prev_sum
            same_counter = same_counter+1;
        end
        if same_counter > same_thresh
            warning(['***********ERROR WITH ',strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),' (ID = ',num2str(reg_idx),...
                '); the last ',num2str(same_thresh),' expansions of the test radius have not resulted in any changes in the total pixel area; it is still smaller than the subdivision area. Breaking and moving on.'])
            issue_areas = [issue_areas;reg_idx,sum(pix_area),reg_area,sum(pix_area)/reg_area]; %#ok<AGROW>
            break
        end
        
        %Break if sum of pixel overlap areas is greater than sum of the
        %original subdivision itself (within an accuracy threshhold;
        %areaint does use some estimations that aren't always great)
        if (sum(pix_area)-reg_area)>0 && abs(1-sum(pix_area)/reg_area)>acc_dev
            warning(['***********ERROR WITH ',strjoin(cellfun(@(x) geo_struct_tmp.(x),flipud(reg_names),'UniformOutput',0),', '),' (ID = ',num2str(reg_idx),...
                '); overlapping area too big. Breaking and moving on.'])
            issue_areas = [issue_areas;reg_idx,sum(pix_area),reg_area,sum(pix_area)/reg_area]; %#ok<AGROW>
            break
        end
        
        %Increase counter
        cntr = cntr+1;
    end
    
    %Save the resultant pixel indices and areas in the struct (dropping
    %ones with 0 area)
    if export_original_polygons
        geo_struct(reg_idx).tested_pix = closest_pixs_tmp(pix_area~=0);
        geo_struct(reg_idx).pix_areas = pix_area(pix_area~=0);
    else
        geo_struct_tmp.tested_pix = closest_pixs_tmp(pix_area~=0);
        geo_struct_tmp.pix_areas = pix_area(pix_area~=0);
        geo_struct(reg_idx) = geo_struct_tmp; 
    end
    
    %Progress message
    if rem(reg_idx,100)==0
        toc
        disp([num2str(reg_idx),' regions processed!'])
        tic
    end
    clearvars('-except',initial_vars{:})
end
toc(start_proc)
disp(['All ',num2str(numel(geo_struct)),' regions processed!'])

%% Output
%Remove the 0 seed row
if size(issue_areas,1)>1
    issue_areas = array2table(issue_areas(2:end,:),'VariableNames',{'index','pix_area','reg_area','area_ratio'});
else
    issue_areas = [];
end
if size(simplified_areas,1)>1
    simplified_areas = array2table(simplified_areas(2:end,:),'VariableNames',{'index','d_arclength'});
else
    simplified_areas = [];
end
%Output
if output_struct
    varargout{1} = geo_struct;
    varargout{2} = issue_areas;
    varargout{3} = simplified_areas;
else
    varargout{1} = issue_areas;
    varargout{2} = simplified_areas;
end

if save_struct
    output_struct = struct('lat',lat,'lon',lon,'issue_areas',issue_areas,'simplified_areas',simplified_areas,region_struct_name,geo_struct); %#ok<NASGU>
    save(filenameS,'-v7.3','-struct','output_struct')
    disp(['variables lat, lon, issue_areas, simplified_areas, and ',region_struct_name,' saved to ',filenameS,'!'])
end

end

