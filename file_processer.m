classdef file_processer
    %FILE_PROCESSER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        process_map
    end
    
    methods
        function obj = file_processer()
            %FILE_PROCESSER Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
        function obj = generate_map(obj, list2download)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %now its quite easy so
            rawNames = reshape( list2download{:,"FileName"}, [], 2 );
            
            obj.process_map = table( 'Size', [size(rawNames, 1), 4], ...
                'VariableTypes', {'string', 'string', 'string', 'string'}, ...
                'VariableNames', {'FileName', 'RawFileName_1', 'RawFileName_2', 'Location'} );
            
            newNames = cellstr(rawNames(:,1));
            for idx = 1:length( newNames )
                obj.process_map{idx, "FileName"}= string(newNames{idx}(5:end-2));
                obj.process_map{idx, "RawFileName_1"} = rawNames(idx, 1);
                obj.process_map{idx, "RawFileName_2"} = rawNames(idx, 2);
            end
            
        end
        
        function outputArg = ready( obj, list )
            
            %array of strings that may be downloaded but not processed
            unproc = obj.process_map{ :, 2:(end-1)};
            outputArg = false(size( unproc, 1), 1);
            % make available only those that have not been processed yet
            outputArg = outputArg | ismissing(obj.process_map{:, "Location"});
            
            for r = 1:size( unproc, 1)
                
                %chekc only those that have been not processed yet
                if outputArg(r)
                    for c = 1:size( unproc, 2)
                        
                        % if download has finished is ok
                        if list{ strcmpi( list{:, "FileName"}, unproc(r,c)), "Dwn_e"}
                            %do nothing leave it true
                        else
                            outputArg(r) = false;
                            break; %no more need to check all the other files
                        end
                    end
                end
            end
        end
        
        function outputArg = any( obj, list )
            
            outputArg = obj.ready( list );
            
            outputArg = any( outputArg );
        end
        
        function outputArg = process( obj, list, nts )
            
            pos = {'/Fuentes/', '/Mandello/', '/LakeComo/', '/Olginate/' };
            ro = [356, 354, 355, 356];
            co = [589, 594, 595, 596];
            
            sch1 = ncinfo( list{2, "Location"} );
            
            % remove useless things
            % remove the 2 first dimensions
            sch1.Dimensions(1:2) = [];
            % remove y and x and ens num
            sch1.Variables(1:3) = [];
            % % remove surface
            % sch1.Variables(4) = []
            % % remove valid_time
            % sch1.Variables(4) = []
            % %remove lat, lon, land, up area
            % sch1.Variables(end-4:end) = []
            % save only data and valid time
            sch1.Variables(2) = sch1.Variables(5);
            sch1.Variables(3:end) = [];
            
            
            % load
            de = ncread( list{2, "Location"}, 'dis06' );
            dc = ncread( list{1, "Location"}, 'dis06' );
            
            
            for idx = 1:4
                % extract 1 2D-array for point.
                de_ = squeeze( de( ro(idx), co(idx), :, : ) );
                dc_ = squeeze( dc( ro(idx), co(idx), : ) );
                
                
                % move from dis06 to dis24 and remove lead 0
                d = cat(2, dc_, de_);
                d = d(2:end, :);
                d = reshape( d, 4, 46, 11 );
                d = squeeze( mean( d, 1 ) );
                
                % change dimensions and co
                % dim step
                sch1.Dimensions(2).Length = 46;
                sch1.Variables(2).Dimensions(1:2) = [];
                sch1.Variables(2).Dimensions(1) = sch1.Dimensions(2);
                
                
                % ens num
                sch1.Dimensions(1).Length = 11;
                sch1.Variables(2).Dimensions(2) = sch1.Dimensions(1);
                
                % size
                sch1.Variables(2).Size = size(d);
                
                % name change
                sch1.Variables(2).Name = 'dis24';
                
                % writeschema
                
                n = strcat( cd, pos{idx} , nts, '.nc');
                if idx == 3
                    outputArg = string(n);
                end
                ncwriteschema( n , sch1 );
                
                % write data: di24 and time
                ncwrite( n, 'dis24', d );
                ncwrite( n, 'time', ncread(  list{2, "Location"}, 'time' ) );
                
            end
            
            % delete the files
            delete( list{2, "Location"} );
            delete( list{1, "Location"} );
        end
    end
end

