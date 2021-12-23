%efrf
clear
fh = file_handler;
fh.rawFile_path = string(fullfile( '/Volumes', 'HD', 'EFAS_reforecast', 'RawData' ));
fh.rawFile_path(2) = string( cd );
fh.procFile_path = string(fullfile( '/Volumes', 'HD', 'EFAS_reforecast', 'Processed', 'LakeComo' ));
fh.procFile_path(2) = string( fullfile(cd, 'LakeComo') );

fp = file_processer;
%%
fd = file_downloader;
fd.py_path = fullfile(cd, 'efas_simple_download.py');
fd.cmd_base = strcat("python3  ", fd.py_path, " ");
fd.max_download = 5;
fd.dwn_file = 'efrf_downloaded.txt';
fd.list_newFile;
%%
st_year = 2000;
end_year = 2018;
period = datetime(st_year, 1, 1):caldays(1):datetime(end_year,12,31);
%period = datetime(st_year, 11, 26):caldays(1):datetime(end_year,12,31);

fh = process_dates(fh, period);
fh = fh.generate_list;
fp = fp.generate_map( fh.list2download );
clear st_year end_year period
[fh, fp.process_map] = search_downloaded( fh, fp.process_map );
%%
if fp.any( fh.list2download )
    
    %estrai
    wh = fp.ready( fh.list2download);
    unproc = fp.process_map( wh, :);
    
    %processa
    for r = 1:size( unproc, 1)
        
        files2proc = false( size(fh.list2download, 1), 1);
        for c = 1:size( unproc, 2)-2
            files2proc = files2proc | strcmpi(fh.list2download{:, "FileName"}, unproc{r,c+1});
        end
        
        %proc
        disp("elaborating")
        fh.list2download(files2proc, :)
        % save new infos:
        %in unproc save location of new file returned, by processed
        %files
        unproc{ r, "Location"} = fp.process( fh.list2download(files2proc, :), unproc{r, "FileName"} );
        %delete locations from list2download and files(done inside
        %process)
        fh.list2download{files2proc, "Location"} = "";
    end
    %update info on those that were unprocessed
    fp.process_map( wh, :) = unproc;
end

%%
file_downloader.current_download
%until I have downloaded all the elements
while sum( fh.list2download{:, "Dwn_e"} ) < size( fh.list2download, 1)
    
    while fd.isfree & any( ~fh.list2download{:, "Dwn_s"} )
        % get the last not started (will be first once it is sorted)
        idx = find( fh.list2download{:, "Dwn_s"} == false, 1, 'last' );
        
        %disp
        disp('Starting download of:');
        fh.list2download(idx, "FileName")
        
        % start download;
        fh.list2download(idx, :) = fd.get( fh.list2download(idx, :) );
        
        save fh.mat fh
        pause('on');
    end
    
    %new file available
    if fd.newFile_available
        
        tline = fd.list_newFile;
        
        for idx = 1:length(tline)
            m = strcmpi(fh.list2download{:, "FileName"}, tline(idx));
            fh.list2download{ m , "Dwn_e"} = true;
            fh.list2download{ m , "Dwn_eT"} = datetime;
            fh.list2download{ m , "Location"} = string(fullfile(cd, strcat(fh.list2download{ m , "FileName"}, '.nc') ));
        end
        
        file_downloader.current_download( -length(tline) );
        %%
        if fp.any( fh.list2download )
            
            %estrai
            wh = fp.ready( fh.list2download);
            unproc = fp.process_map( wh, :);
            
            %processa
            for r = 1:size( unproc, 1)
                
                files2proc = false( size(fh.list2download, 1), 1);
                for c = 1:size( unproc, 2)-2
                    files2proc = files2proc | strcmpi(fh.list2download{:, "FileName"}, unproc{r,c+1});
                end
                
                %proc
                disp("elaborating")
                fh.list2download(files2proc, :)
                % save new infos:
                %in unproc save location of new file returned, by processed
                %files
                unproc{ r, "Location"} = fp.process( fh.list2download(files2proc, :), unproc{r, "FileName"} );
                %delete locations from list2download and files(done inside
                %process)
                fh.list2download{files2proc, "Location"} = "";
            end
            %update info on those that were unprocessed
            fp.process_map( wh, :) = unproc;
            save fp.mat fp
            save fh.mat fh
            download_statistics
        end
        %%
        pause('off');
    end
    pause(180);
end

