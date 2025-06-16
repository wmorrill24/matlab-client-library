function downloaded_filepath = download_file(file_id, varargin)
    % Downloads a file from the server using its file_id. (Robust version)
    
    % Import required libraries for making HTTP requests
    import matlab.net.http.*
    import matlab.net.http.ResponseMessage
    import matlab.net.URI

    % 1. Handle optional destination path
    if nargin > 1
        destination_path = varargin{1};
    else
        destination_path = pwd; % Default to current directory
    end
    
    file_id = char(file_id);
    api_url = data_ingestion.get_api_url();
    download_endpoint = string(api_url) + '/download/' + string(file_id);
    
    final_output_path = ''; % Initialize variable

    try
        % 2. Determine the full output file path BEFORE downloading
        if isfolder(destination_path)
            % If the user gave a folder, we need to find the filename
            fprintf('Destination is a folder. Querying server for filename...\n');
            
            % Make a lightweight HEAD request to get headers without the file body
            request = RequestMessage('HEAD');
            uri = URI(download_endpoint);
            response = send(request, uri);

            search_result = data_ingestion.search_file('file_id', file_id);

            if ~isempty(search_result) && ismember('file_name', search_result.Properties.VariableNames)
                % If we found the file, use its real name
                filename = search_result.file_name{1};
            else
                % As a fallback, use the file_id itself
                filename = file_id;
                fprintf('Could not find metadata for file_id. Using ID as filename.\n');
            end

            headers = response.Header;
            disposition_idx = find(strcmpi({headers.Name}, 'Content-Disposition'), 1);
           
            if ~isempty(disposition_idx)
                disposition_value = headers(disposition_idx).Value;
                % Use a regular expression to extract the filename from the header
                token = regexp(disposition_value, 'filename="([^"]+)"', 'tokens', 'once');
                if ~isempty(token)
                    filename = token{1};
                end
            end
            
            % Use fullfile() to correctly join the path and filename
            final_output_path = fullfile(destination_path, filename);
            
        else
            % If the user provided a full path, use it directly
            final_output_path = destination_path;
        end

        % 3. Download the file to the explicit path
        fprintf('Downloading from: %s\n', download_endpoint);
        fprintf('Saving to: %s\n', final_output_path);
        
        options = weboptions('Timeout', 300);
        downloaded_filepath = websave(final_output_path, download_endpoint, options);
        
        fprintf('File successfully downloaded.\n');

    catch ME
        fprintf('\n--- AN ERROR OCCURRED DURING DOWNLOAD ---\n');
        fprintf('Error Message: %s\n\n', ME.message);
        
        downloaded_filepath = ''; % Return empty on error
    end
end