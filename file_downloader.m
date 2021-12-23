classdef file_downloader
    %FILE_DOWNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        py_path
        
        dwn_file
        
        max_download
        cmd_base
    end
    
    methods
        function obj = file_downloader()
            %FILE_DOWNLOADER Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
        function request = get(obj, request)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if  obj.isfree & ~isempty( request )
                
                nf = char(request{ 1, "FileName"});
                nf = nf(10:end-2);
                
                [y,m,d] = ymd(datetime(nf, 'InputFormat', 'yyyyMMdd'));
                
                %perturbed ensamble reforecasts
                request{1, "Dwn_sT" } = datetime();
                request{1, "Dwn_s" } = true;
                cmd_arg = strcat( string(y), " ", num2str(m,  '%0.2d'), " ", num2str(d,  '%0.2d') );
                
                cmmd = strcat(obj.cmd_base, "e ", cmd_arg, " & ");
                system(cmmd);
                
                file_downloader.current_download(+1);
            end
            
        end

        function outputArg = isfree( obj )
            outputArg = (file_downloader.current_download < obj.max_download);
        end
        
        function outputArg = newFile_available( obj )
            fid = fopen(obj.dwn_file);
            fseek( fid, 0, 'eof');
        
            n = file_downloader.fl_old;
            outputArg = (ftell(fid) > n);
            fclose(fid);
        end
        
        function outputArg = list_newFile( obj )
            
            outputArg = string.empty;
            fid = fopen(obj.dwn_file);
            fseek( fid, file_downloader.fl_old, 'bof');
            
            while ~feof(fid)
                outputArg(end+1) = fgetl(fid);
            end
            
            file_downloader.fl_old(ftell(fid));
            if strcmpi( outputArg, "-1" )
                outputArg = string.empty;
            end
            
            fclose(fid);
            
        end
        
    end
    
    methods (Static)
        
        function outputArg = current_download( varargin )
            
            persistent cd;
            if isempty(cd)
                cd = 0;
            end
            
            if nargin 
                cd = cd + varargin{1};
            end
            outputArg = cd;
        end
        
        function outputArg = fl_old( varargin )
            
            persistent fl;
            if isempty(fl)
                fl = 0;
            end
            
            if nargin 
                fl = varargin{1};
            end
            outputArg = fl;
        end
    end
end

