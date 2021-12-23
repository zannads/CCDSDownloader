classdef file_handler
    %FILE_HANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rawFile_path
        procFile_path
        
        %this part will become an array of classes
        product % efrf or efsr ecc 
        dates %array of datetime
        lead_times %array of leadtimes
        types
        %variables
        %model levels
        %soil levels
        %format
        
        list2download
    end
    
    methods
        function obj = file_handler()
            %FILE_HANDLER Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
        function obj = process_dates(obj, period)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            %based on type, select the dates.
            % efrf is issued on mondays (2nd day of the week according to english
            % calendar) and thursdays (fifth) of the 2019. every number of the day for
            % all the previous years.
            
            [~,m,d] = ymd(period);
            
            mon_thur = (weekday( datetime(2019, m, d) ) == 2 | weekday( datetime(2019, m, d) ) == 5);
            
            obj.dates = period( mon_thur );
        end
        
        function obj = generate_list(obj)
            
            period = obj.dates;
            % genera tabella
            [y,m,d] = ymd(period');
            fname_ = strcat( string(y), num2str(m,  '%0.2d'), num2str(d,  '%0.2d') );
            fname  = [strcat( "raw_efrf_", fname_, "_c"); strcat( "raw_efrf_", fname_, "_e")];
            
            obj.list2download = table( fname, ... %name to save
                false( length(fname), 1), ... %download started
                false( length(fname), 1), ... %download completed
                NaT(length(fname), 1), NaT(length(fname), 1), ... % datetime array for starting and ending time of download
                repmat( string, length(fname), 1), ... %location of download
                'VariableNames', {'FileName', 'Dwn_s', 'Dwn_e', 'Dwn_sT', 'Dwn_eT', 'Location'} );
        end
        
        function [obj, map] = search_downloaded( obj, map) 
           
            %filla tabella con già scaricati
            % at first raw data
            obj = obj.search_rawData;
            
            [obj, map] = obj.search_processed( map );
            
        end
    end
    
    methods (Access = private )
        
        function obj = search_rawData(obj)
            
            for path_ = 1:length( obj.rawFile_path )
                ls = dir( fullfile( obj.rawFile_path( path_ ), '*.nc' ) );
                
                for l = 1:length(ls) 
                    % try to open
                    try 
                        ncinfo( fullfile( ls(l).folder, ls(l).name ) );
                    catch
                        %if doesn't delete file
                        continue
                    end
                    %if it works, save that you have succesfully downloaded
                    %it
                    [~, name, ~] = fileparts(ls(l).name);
                    obj.list2download{ strcmpi(obj.list2download{:,"FileName"}, name), "Dwn_s"} = true;
                    obj.list2download{ strcmpi(obj.list2download{:,"FileName"}, name), "Dwn_e"} = true;
                    obj.list2download{ strcmpi(obj.list2download{:,"FileName"}, name), "Location"} = string(fullfile(ls(l).folder, ls(l).name));
                end
            end
        end
        
        function [obj, map] = search_processed(obj, map)
            
            for path_ = 1:length( obj.procFile_path )
                ls = dir( fullfile( obj.procFile_path( path_ ), '*.nc' ) );
                
                for l = 1:length(ls) 
                    % try to open
                    try 
                        ncinfo( fullfile( ls(l).folder, ls(l).name ) );
                    catch
                        %if doesn't delete file
                        continue
                    end
                    %if it works, save that you have succesfully downloaded
                    %it
                    [~, name, ~] = fileparts(ls(l).name);
                   
                    wh = strcmpi(map{:,"FileName"}, name);
                    if any( wh )
                        map{ wh, "Location"} = string(fullfile(ls(l).folder, ls(l).name));
                        dwn_files = map{ wh , 2:3 };
                        
                        for idx = 1:length(dwn_files)
                            obj.list2download{ strcmpi(obj.list2download{:,"FileName"}, dwn_files(idx)), "Dwn_s"} = true;
                            obj.list2download{ strcmpi(obj.list2download{:,"FileName"}, dwn_files(idx)), "Dwn_e"} = true;
                        end
                    end
                    
                    
                end
            end
        end
        
    end
end

