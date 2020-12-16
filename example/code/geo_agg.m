% GEO_AGG   area-average gridded variables over vector polygons
%
%   geo_struct = GEO_AGG(agg_var,geo_struct) aggregates the gridded
%   variable(s) [agg_var] over the polygons in [geo_struct]. [agg_var] can
%   either be a [lon x lat (x 3rd dim)] array or a struct containing
%   multiple [lon x lat (x 3rd dim)] arrays in separate fields.
%   [geo_struct] is a structure containing at least the fields
%   [tested_pixs], giving the linear index (in [lon x lat] space) of all
%   pixels that overlap with the given polygon and [pix_areas], giving the
%   overlapping area of each of these pixels. [geo_struct] can contain any
%   other fields, which will also be outputted, subject to output options
%   below. Each polygon is one element in [geo_struct]. 
%   
%   Explicitly, GEO_AGG calculates the weighted average of the variable(s)
%   [agg_var] over pixels that overlap with each polygon, with the wieghts
%   given by the [geo_struct] field [pix_areas]. 
%
%   Crucially, the [geo_struct] and [agg_var] *must* be calculated using
%   the same lat/lon grid. Unfortunately, there is as of yet no check to
%   make sure this is the case (the code would fail if by happenstance
%   linear indices of pixels beyond the size of the [agg_var] grid are
%   used, but in other cases no immediate indication of error would be
%   returned).
%
%   Output options (see flags below for full function options):
%       - default output behavior - by default, the only output is the
%                                   inputted [geo_struct], with the
%                                   aggregated [agg_var] data added as new
%                                   fields.
%       - shapefile:              - optionally, the data can be saved in a
%                                   shapefile format. This requires the
%                                   [geo_struct] to be in the format needed
%                                   for the matlab shapewrite function
%                                   (including fields 'Geometry'
%                                   ('Polgyon'), X, and Y). Shapefiles do
%                                   not support vector fields / attributes;
%                                   so if the data has a 3rd dimension the
%                                   program will save separate shapefiles
%                                   for every element of the third
%                                   dimension (by default appending a
%                                   counter to the end of the filename for
%                                   each one). [pix_areas] and [tested_pix]
%                                   are of course removed from the struct
%                                   before shapewrite is applied.
%       - csv:                    - optionally, the data can be saved in a
%                                   .csv format. The data is saved 'long' -
%                                   meaning that if the inputted data is
%                                   three-dimensional, each row of the file
%                                   uniquely identifies one region/3rd
%                                   dimension step combination, with a new
%                                   column created giving a counter for the
%                                   member of the 3rd dimension. 
%
%   GEO_AGG(...,'[flag]',[params],...) modify program run as below:
%       Data processing options
%       - 'zero_nans',[log]       - set whether to set NaNs in the
%                                   [agg_var](s) to 0 before processing / 
%                                   aggregating (by default: false)
%       - 'nan_threshold',[num]   - set a value for the [agg_vals] below
%                                   which they are changed to NaNs (this
%                                   happens before the zero_nans command
%                                   above)
%       - 'remove_nan_pixels',[log] - set whether to ignore NaN valued
%                                   pixels when calculating weighted
%                                   averages (by default: true; if false,
%                                   regions that overlap with a NaN-valued
%                                   pixel will also have NaN as their
%                                   output value)
%       - 'dim3_range',[num]      - if desired set a subset of the 3rd
%                                   dimension to process; all indices must
%                                   be inputted, so if the first year of
%                                   monthly data should be used, (1:12)
%                                   must be inputted (left blank /
%                                   processing the entire input variable by
%                                   default; does nothing if no 3-dim
%                                   variables are inputted)
%       
%       Output options
%       - 'field_name',[char]     - *if* [agg_vals] is an array, this sets
%                                   the name of the field in [geo_struct]
%                                   (and in the .csv or .shp outputs)
%                                   assigned to the aggregated value. If
%                                   [agg_vals] is a struct, then the field
%                                   names are just taken from that input. 
%       - 'output_struct',[log]   - set whether to output struct as an
%                                   output of the function (by default,
%                                   true)
%       - 'save_shapefile',[log],([char])
%                                 - set whether to save the [geo_struct]
%                                   with the aggregated data from
%                                   [agg_vals] as a shapefile. If true,
%                                   [char] is the filename to be used. If
%                                   any of the inputted variables in
%                                   [agg_vals] is 3-dimensional, and
%                                   'force_break_on_vector_shape' is set to
%                                   false, then one shapefile is saved for
%                                   every element in the 3rd dimension of
%                                   the [agg_vals] (if 2d variables are
%                                   included in [agg_vals], they are
%                                   repeated across the elements of that
%                                   3rd dimension), with a counter
%                                   increasing by one from the value set by
%                                   'shape_filename_count_start' (by
%                                   default, 1) added to the filename.
%       - 'shape_filename_count_start',[num]
%                                 - if an inputted variable is
%                                   3-dimensional, this sets the first
%                                   counter added to the filename for each
%                                   separate saved shapefile (see
%                                   'save_shapefile' above)
%       - 'force_break_on_vector_shape',[log]
%                                 - if true, 'save_shapefile' is also
%                                   set to true, and an inputted variable
%                                   is 3-dimensional, the program run is
%                                   interrupted to avoid multiple
%                                   shapefiles being created. By default,
%                                   false.
%       - 'save_csv',[log],([char])
%                                 - set whether to save the aggregated
%                                   variable(s) in a .csv; if true, [char]
%                                   is the filename (by default, false). By
%                                   default, 'save_complete_struct' is
%                                   true, which means that all fields of
%                                   the [geo_struct] with fields explicitly
%                                   related to its geography (currently
%                                   hardcoded as the fields 'Geometry,'
%                                   'BoundingBox','X','Y') removed are
%                                   saved as columns in the .csv. Other
%                                   options include only exporting the
%                                   aggregated variables with region and
%                                   3rd-dimension counters (by setting
%                                   'save_complete_struct' to true without
%                                   specifying other fields in
%                                   'keep_col_names') or by only saving a
%                                   subset of struct fields into the .csv
%                                   (by setting their names in 'csv_cols'). 
%       - 'csv_cols',[cell]       - if only a limited number of the
%                                   [geo_struct] fields are desired in the 
%                                   output .csv, set their names in a cell
%                                   array using this flag. Implicitly sets
%                                   'save_complete_struct' to false.
%       - 'save_complete_struct',[log] 
%                                 - if true (by default), all non-geometric
%                                   fields of the [geo_struct] are saved in
%                                   the .csv. If false without 'csv_cols'
%                                   set, then only the aggregated input
%                                   variables are saved with counters
%                                   uniquely identifying the regions and
%                                   possible 3rd dimension of [agg_vars].
%                                   If 'csv_cols' are set, then
%                                   'save_complete_struct' is set to true
%                                   implicitly, so this call is not needed.
%
%   See also PIXEL_OVERLAPS
%                                   
%   For questions/comments, contact Kevin Schwarzwald
%   kschwarzwald@uchicago.edu
%   Last modified 12/01/2017

function varargout = geo_agg(agg_var,geo_struct,varargin)

%% Set defaults
%Data processing
zero_nans = false;
nan_threshold = [];
remove_nan_pixels = true;
dim3_range = [];

%Output
struct_field_name = 'aggregated_variable';
output_struct = false;
output_as_array = true;
save_shapefile = false;
force_break_on_vector_shape = false;
num_files_threshold = 24; %Warning set if attempting to create more than this number of files
shp_count_start = 1;
save_csv = false; save_complete_struct = true; keep_col_names = [];
output_filename = [];

%% Set behavior of optional function flags
if (~isempty(varargin))
    for in_idx = 1:length(varargin)
        switch varargin{in_idx}
            %Data processing
            case {'zero_nans'}
                zero_nans = varargin{in_idx+1};
            case {'nan_threshold'}
                nan_threshold = varargin{in_idx+1};
            case {'remove_nan_pixels'}
                remove_nan_pixels = varargin{in_idx+1};
            case {'dim3_range'}
                dim3_range = varargin{in_idx+1}; varargin{in_idx+1} = 0;
                
                %Output
            case {'field_name'}
                struct_field_name = varargin{in_idx+1};
            case {'output_struct'}
                output_struct = varargin{in_idx+1};
            case {'output_as_array'}
                output_as_array = varargin{in_idx+1};
            case {'save_shapefile'}
                save_shapefile = varargin{in_idx+1};
                if save_shapefile && length(varargin)>(in_idx+1) && isa(varargin{in_idx+2},'char')
                    output_filename = varargin{in_idx+2};
                else
                    error('GEOAGG:MissingFilename','No filename provided for shapefile! The flag ''save_shapefile'' is followed by a true/false + a filename if true.')
                end
            case {'shape_filename_count_start'}
                shp_count_start = varargin{in_idx+1};
            case {'force_break_on_vector_shape'}
                force_break_on_vector_shape = varargin{in_idx+1};
            case {'save_csv'}
                save_csv = varargin{in_idx+1};
                if save_csv
                    if length(varargin)>(in_idx+1) && isa(varargin{in_idx+2},'char')
                        output_filename = varargin{in_idx+2};
                    else
                        error('GEOAGG:MissingFilename','No filename provided for .csv! The flag ''save_csv'' is followed by a true/false + a filename if true.')
                    end
                end
            case {'save_complete_struct'}
                save_complete_struct = varargin{in_idx+1};
            case {'csv_cols'}
                keep_col_names = varargin{in_idx+1}; varargin{in_idx+1} = 0;
                save_complete_struct = false;
                
                
        end
    end
end

%% Setup
%Fortify agg_var into a struct; to standardize between 1 and multi-input
%variables
if ~isa(agg_var,'struct')
    agg_var = struct(struct_field_name,agg_var);
end
input_vars = fieldnames(agg_var);

%Find out if there's a third dimension in the input variables (i.e. time)
var_dim3s = zeros(numel(input_vars),1);
for var_idx = 1:numel(input_vars)
    var_dim3s(var_idx) = size(agg_var.(input_vars{var_idx}),3);
end
if length(unique(var_dim3s))>2
    error('GEOAGG:InconsistentInputDims',['The third dimension of the input variables must either have size 1 or one set size ~=1 that is equal across input variables. Instead, the input variables had size: ',num2str(var_dim3s),'.'])
end

%Find out if there's a fourth dimension! (BETA)
var_dim4s = zeros(numel(input_vars),1);
for var_idx = 1:numel(input_vars)
    var_dim4s(var_idx) = size(agg_var.(input_vars{var_idx}),4);
end

%Change certain values to NaNs if a nan threshold is set
if ~isempty(nan_threshold)
    for var_idx = 1:numel(input_vars)
        agg_var.(input_vars{var_idx})(agg_var.(input_vars{var_idx})<nan_threshold) = NaN;
    end
end

% Subset to a certain dim3 length if desired
if max(var_dim3s)>1 && ~isempty(dim3_range)
    if max(dim3_range)<=max(var_dim3s)
        dim3_idxs = find(var_dim3s == max(var_dim3s));
        for dim3_idx = 1:length(dim3_idxs)
            agg_var.(input_vars{dim3_idxs(dim3_idx)}) = agg_var.(input_vars{dim3_idxs(dim3_idx)})(:,:,dim3_range);
            %Update size of that input variable in the counter
            var_dim3s(dim3_idxs(dim3_idx)) = size(agg_var.(input_vars{dim3_idxs(dim3_idx)}),3);
        end
    else
       error('GEOAGG:BadDim3Range',['The inputted [dim3_range] intended to subset the [agg_var], [',num2str(dim3_range(1)),',',num2str(dim3_range(2)),'], goes beyond the size of the 3rd dimension, ',num2str(max(var_dim3s)),'. Please choose a range that doesn''t exceed this length.']) 
    end
end


%% Aggregate!
issue_regs = [];
for var_idx = 1:numel(input_vars)
    agg_vector.(input_vars{var_idx}) = zeros(length(geo_struct),var_dim3s(var_idx),var_dim4s(var_idx));
    tic
    for reg_idx = 1:length(geo_struct)
        try
            %Get number of pixels that overlap with the country
            n_tpoints = length(geo_struct(reg_idx).tested_pix);
            
            %Get subscript indices of overlapping pixels
            [tlon,tlat] = ind2sub([size(agg_var.(input_vars{var_idx}),1) size(agg_var.(input_vars{var_idx}),2)],geo_struct(reg_idx).tested_pix);
            
            %Calculate area-weighted average
            if ~isempty(geo_struct(reg_idx).pix_areas)
                pixel_overlaps = zeros(n_tpoints,var_dim3s(var_idx),var_dim4s(var_idx));
                for pix_idx = 1:n_tpoints
                    pixel_overlaps(pix_idx,:,:) = squeeze(agg_var.(input_vars{var_idx})(tlon(pix_idx),tlat(pix_idx),:,:));
                end
                %Change NaNs to 0s
                if zero_nans
                    pixel_overlaps(isnan(pixel_overlaps))=0;
                end
                %Remove NaN elements of pix_areas/pixel_overlaps
                pixel_areas = geo_struct(reg_idx).pix_areas;
                if remove_nan_pixels
                    pixel_overlaps = pixel_overlaps(~isnan(pixel_overlaps(:,1,1)),:,:);
                    pixel_areas = pixel_areas(~isnan(pixel_overlaps(:,1,1)));
                end
                
                %Calculate area weighted average of data
                if all(var_dim4s==0)
                    agg_vector.(input_vars{var_idx})(reg_idx,:) = (pixel_overlaps'*pixel_areas)./sum(pixel_areas);
                else
                   for dim4_idx = 1:var_dim4s(var_idx)
                       agg_vector.(input_vars{var_idx})(reg_idx,:,dim4_idx) = (squeeze(pixel_overlaps(:,:,dim4_idx))'*pixel_areas)./sum(pixel_areas);
                   end
                end
            end
            
            if rem(reg_idx,500)==0
                toc
                disp([num2str(reg_idx),' regions processed!'])
                tic
            end
        catch ME
            disp(['Issue with region ',num2str(reg_idx)])
            issue_regs = [issue_regs,reg_idx];
        end
    end
    toc
    disp(['All ',num2str(length(geo_struct)),' regions processed for variable ',input_vars{var_idx},'!'])
end
disp(['All inputted variables aggregted across all ',num2str(length(geo_struct)),' regions!'])

%% Output
%Add to struct if outputting as struct or shapefile
if save_shapefile || output_struct
    for var_idx = 1:numel(input_vars)
        for reg_idx = 1:length(geo_struct)
            geo_struct(reg_idx).(input_vars{var_idx}) = agg_vector.(input_vars{var_idx})(reg_idx,:);
        end
    end
end

%Set standard output
if output_struct
    varargout{1} = geo_struct;
else
    if output_as_array && length(fieldnames(agg_vector))==1
        varargout{1} = agg_vector.(input_vars{1});
    else
        varargout{1} = agg_vector;
    end
end

%Export issue areas if desired
if nargout>1
    varargout{2} = issue_regs;
end

%Remove tested_pix and pix_areas because the following save options can't deal with
%vector fields
geo_struct_novec = rmfield(geo_struct,{'tested_pix','pix_areas'});

%Save as shapefile
if save_shapefile
    if any(var_dim3s~=1)
        if force_break_on_vector_shape
            error('GEOAGG:ShapeArray','Shapefiles cannot include vector fields. Set ''force_break_on_vector_shape'' to true if you want separate shape files saved for each element in the third dimension of inputted variables.')
        else
            warning('GEOAGG:ShapeArray',['Shapefiles cannot include vector fields, so data will be split up by the third dimension of the [agg_vector] input, with output_filenames ',output_filename,num2str(shp_count_start),' - ',output_filename,num2str(shp_count_start+max(var_dim3s)-1)])
            if max(var_dim3s)>num_files_threshold
                prompt = ['Warning: the function is about to save ',num2str(max(var_dim3s)),' separate shapefiles. Is this desired?\n[0] no; break\n[1] yes'];
                size_continue = input(prompt);
                if ~size_continue
                    error('GEOAGG:Interrupted','Function run interrupted.')
                end
            end
            %If the data to be aggregated has a non-geometric dimension (i.e.
            %time), split up and save with one value along that dimension in
            %a separate shape file, with a name set by the inputted [output_filename]
            %+ a counter starting at [shp_count_start] (by default 1)
            for t = 1:max(var_dim3s)
                geo_struct_tmp = geo_struct_novec;
                for var_idx = 1:numel(input_vars)
                    %Only need shortening for variavbles with a 3rd dim;
                    %otherwise it's the same for every output file
                    if size(geo_struct_tmp(reg_idx).(input_vars{var_idx}),2)~=1
                        for reg_idx = 1:length(geo_struct_tmp)
                            geo_struct_tmp(reg_idx).(input_vars{var_idx}) = geo_struct_tmp(reg_idx).(input_vars{var_idx})(t);
                        end
                    end
                end
                %Write shapefile
                shapewrite(geo_struct_tmp,[output_filename,num2str(shp_count_start+t-1)]);
                disp([output_filename,num2str(shp_count_start+t-1),'.shp saved!'])
            end
        end
    else
        %Write shapefile
        shapewrite(geo_struct_novec,output_filename);
        disp([output_filename,'.shp saved!'])
    end
end

%Save as a csv
if save_csv
    %Remove the output data to more easily make table long
    if any(contains(fieldnames(geo_struct_novec),input_vars))
        geo_struct_tmp = rmfield(geo_struct_novec,input_vars);
    else
        geo_struct_tmp = geo_struct_novec;
    end
    if ~save_complete_struct
        %Create counter for time/dim 3 in general steps
        t_step = repmat(1:max(var_dim3s),length(geo_struct),1);
        if isempty(keep_col_names)
            warning('GEOAGG:NoColsKept','No struct fields to keep as ID variables were chosen for output table. Counters for region and possible 3rd dimension used instead.')
            %Create counter for geographic region
            output_var{1} = repmat(1:length(geo_struct),max(var_dim3s),1);
            output_var{1} = output_var{1}(:);
            output_var{2} = t_step(:);
            for var_idx = 1:numel(input_vars)
                %If input variable has a 3rd dimension, linearize
                if var_dim3s(var_idx)~=1
                    output_var{var_idx+2} = agg_vector.(input_vars{var_idx})(:); 
                else %If input variable doesn't have a 3rd dimension, repeat the max length of 3rd dimension times
                    output_var{var_idx+2} = repmat(agg_vector.(input_vars{var_idx})(:),length(geo_struct),1);
                end
            end
            T = table(output_var{:},'VariableNames',[{'region'},{'step'},input_vars]);
        else
            %Allow for multiple identifying columns
            keep_cols = cell(length(keep_col_names),1);
            for col_idx = 1:length(keep_col_names)
                keep_cols{col_idx} = repmat({geo_struct_tmp.(keep_col_names{col_idx})},1,max(var_dim3s))';
            end
            keep_cols{col_idx+1} = t_step(:); keep_col_names{col_idx+1} = 'step'; %If input variable has a 3rd dimension, linearize
            for var_idx = 1:numel(input_vars)
                if var_dim3s(var_idx)~=1
                    keep_cols{col_idx+var_idx+1} = agg_vector.(input_vars{var_idx})(:);
                else %If input variable doesn't have a 3rd dimension, repeat the max length of 3rd dimension times
                    keep_cols{col_idx+var_idx+1} = repmat(agg_vector.(input_vars{var_idx})(:),max(var_dim3s),1);
                end
            end
            T = table(keep_cols{:},'VariableNames',[keep_col_names,input_vars']);
        end
        
    else
        %Remove geographic info (CHANGE THIS EVENTUALLY TO DEAL WITH
        %LAT/LON/ MISSING BOUNDINGBOX/ETC.)
        geo_struct_tmp = rmfield(geo_struct_tmp,{'Geometry','BoundingBox','X','Y'});
        T = struct2table(geo_struct_tmp);
        %Reshape long
        T = repmat(T,max(var_dim3s),1);
        %Add aggregated data
        for var_idx = 1:numel(input_vars)
            %If input variable has a 3rd dimension, linearize
            if var_dim3s(var_idx)~=1
                T.(input_vars{var_idx}) = agg_vector.(input_vars{var_idx})(:);
            else %If input variable doesn't have a 3rd dimension, repeat the max length of 3rd dimension times
                T.(input_vars{var_idx}) = repmat(agg_vector.(input_vars{var_idx}),max(var_dim3s),1);
            end
        end
        %Create counter for time/dim 3 in general steps if it exists in any
        %input variable
        if max(var_dim3s)~=1
            t_step = repmat(1:max(var_dim3s),length(geo_struct),1);
            T.step = t_step(:);
        end
    end
    
    %Write table to .csv
    writetable(T,output_filename);
    disp([output_filename,' created!'])
end


end