% STILL NEED TO DO SOMETHING ABOUT COMPLETE VS. INCOMPLETE GRIDS - SUGGEST
% CHECKING IF THE BOUNDARIES ARE WITHIN THE MAX INTERPIXEL SEPARATION OF
% THE LAST ELEMENTS IN EACH; IN WHICH CASE THE BOUNDARY_OPTIONS THING COMES
% INTO PLAY; OTHERWISE JUST SET THE END BOUNDARY TO THAT PIXEL COORD + THE
% DISTANCE BEFORE IT. 

%If need to interpolate lat/lon bounds, do so
function [lat_bnds,lon_bnds] = derive_bnds(lat,lon,varargin)
set_positive = false;    
    if ~isempty(varargin) && strcmp(varargin{1},'set_positive')
        set_positive = true;
    end

    %Pre-allocate lat/lon bound array
    lat_bnds = zeros(numel(lat),2);
    lon_bnds = zeros(numel(lon),2);
    if size(lon,2) == 1
        %% Calculate latitude bounds from vector lat
        if min(abs(lon(1)-[0 -90 90]))>2*max(diff(lon))
            lat_bnds(1,1) = lat(1)-0.5*(lat(2)-lat(1));
        else
            %Have support for different lat counters
            if lat(1) < 0; lat_bnds(1,1) = -90; else lat_bnds(1,1) = 90; end
        end
        %Interpolate lat boundaries by taking the
        %average of subsequent pixels
        for lat_idx = 1:(numel(lat)-1)
            lat_bnds(lat_idx,2) = (lat(lat_idx+1)-lat(lat_idx))/2+lat(lat_idx);
            if lat_idx < length(lat) && lat_idx>1
                lat_bnds(lat_idx,1) = lat_bnds(lat_idx-1,2);
            end
        end
        %Set last element
        lat_bnds(numel(lat),1) = lat_bnds(numel(lat)-1,2);
        % If subset, just copy last distance; otherwise set to 0, -90 or 90
        if min(abs(lat(end)-[0 90 -90]))>2*max(diff(lat))
            lat_bnds(numel(lat),2) = lat_bnds(numel(lat),1) + lat_bnds(numel(lat)-1,2)-lat_bnds(numel(lat)-1,1);
        else
            if lat(numel(lat)) < 0; lat_bnds(numel(lat),2) = -90; else lat_bnds(numel(lat),2) = 90; end
        end
        
        %% Calculate longitude bounds from vector lon
        %It gets messy especially if the longitude vector is saved
        %[0:180/-180:0], so this just converts everything to >0, with
        %hopefully fewer antimeridian/meridian issues.
        if any(lon<0)
            lon(lon<0) = lon(lon<0)+360;
            remap_lon =true;
        else 
            remap_lon = false;
        end
        %Have support for different lon counters
        boundary_options = [-180 0 180 360];
        if min(abs(lon(1)-boundary_options))>2*max(diff(lon))
            lon_bnds(1,1) = lon(1)-0.5*(lon(2)-lon(1));
        else
            [~,bound_idx] = min(abs(lon(1)-boundary_options));
            lon_bnds(1,1) = boundary_options(bound_idx);
        end
        %Interpolate lon boundaries by taking the
        %average of subsequent pixels
        for lon_idx = 1:numel(lon)-1
            lon_bnds(lon_idx,2) = (lon(lon_idx+1)-lon(lon_idx))/2+lon(lon_idx);
            if lon_idx < numel(lon) && lon_idx>1
                lon_bnds(lon_idx,1) = lon_bnds(lon_idx-1,2);
            end
        end
        
        %Set last element
        lon_bnds(numel(lon),1) = lon_bnds(numel(lon)-1,2);
        if min(abs(lon(end)-boundary_options))>2*max(diff(lon))
            lon_bnds(numel(lon),2) = lon_bnds(numel(lon),1) + lon_bnds(numel(lon)-1,2)-lon_bnds(numel(lon)-1,1);
        else
            [~,bound_idx] = min(abs(lon(end)-boundary_options));
            lon_bnds(numel(lon),2) = boundary_options(bound_idx); %Had to be made more generally since no idea what form that lon grid would go. Main assumption is that lon spacing < 90/pixel, which hopefully is always true.
        end
        
        %Returns to the original format if the longitude was remapped to
        %only positive values
        if remap_lon && ~set_positive
            lon_bnds(lon_bnds>180) = lon_bnds(lon_bnds>180)-360;
            if lon_bnds(lon_bnds(:,1)==180,2)<0
                lon_bnds(lon_bnds(:,1)==180,1)=-180;
            end
        end
        
        %Make sure everything is the short way around (by setting [x, 0] to
        %[x, 365] and [360,x] to [0,x])
        lon_bnds(lon_bnds(:,2)==0,2) = 360;
        lon_bnds(lon_bnds(:,1)==360,1) = 0;
        
    else
        %% Calculate latitude bounds from matrix lat
        %Have support for different lat/lon counters
        if lat(1) < 0; lat_bnds(1:size(lat,2),1) = -90; else lat_bnds(1:size(lat,2),1) = 90; end %#ok<*SEPEX>
        %Interpolate lat boundaries by taking the
        %average of subsequent pixels
        for lat_idx = 1:(numel(lat)-1)
            lat_bnds(lat_idx,2) = (lat(lat_idx+1)-lat(lat_idx))/2+lat(lat_idx);
            if lat_idx < length(lat) && lat_idx>1
                lat_bnds(lat_idx,1) = lat_bnds(lat_idx-1,2);
            end
        end
        %Set last element
        lat_bnds(numel(lat),1) = lat_bnds(numel(lat)-1,2);
        if lat(numel(lat)) < 0; lat_bnds(numel(lat),2) = -90; else lat_bnds(numel(lat),2) = 90; end
        
        %% Calculate longitude bounds from matrix lon
        % ASSUMES SUBSET (SO NOT BOUNDED AT 90,-90,180,-180,etc.)
        for lon_idx = 2:size(lon,1)
            for lat_idx = 1:size(lon,2)
                if lon_idx < size(lon,1)
                    lon_bnds(sub2ind(size(lon),lon_idx,lat_idx),2) = (lon(lon_idx+1,lat_idx)-lon(lon_idx,lat_idx))/2+lon(lon_idx,lat_idx);
                else
                    lon_bnds(sub2ind(size(lon),lon_idx,lat_idx),2) = abs(lon(lon_idx-1,lat_idx)-lon(lon_idx,lat_idx))/2+lon(lon_idx,lat_idx);
                end
                if lon_idx>1
                    if lon_idx < numel(lon) && lon_idx>1
                        lon_bnds(sub2ind(size(lon),lon_idx,lat_idx),1) = lon_bnds(sub2ind(size(lon),lon_idx-1,lat_idx),2);
                    end
                else
                    lon_bnds(sub2ind(size(lon),lon_idx,lat_idx),1) = lon(lon_idx,lat_idx)-(lon(lon_idx+1,lat_idx)-lon(lon_idx,lat_idx))/2;
                    
                end
            end
        end
        for lat_idx = 2:size(lat,2)
            for lon_idx = 1:size(lat,1)
                if lat_idx < size(lat,2)
                    lat_bnds(sub2ind(size(lat),lon_idx,lat_idx),1) = (lat(lon_idx,lat_idx+1)-lat(lon_idx,lat_idx))/2+lat(lon_idx,lat_idx);
                else
                    
                end
                if lat_idx < numel(lat) && lat_idx>1
                    lat_bnds(sub2ind(size(lat),lon_idx,lat_idx),1) = lat_bnds(sub2ind(size(lon),lon_idx,lat_idx-1),2);
                end
            end
        end
        
    end
end
