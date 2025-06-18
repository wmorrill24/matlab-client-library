function response_data = upload_folder(folder_path, metadata_filepath)
% Uploads a folder (as a ZIP) and its corresponding metadata file to the server.
%
% This function first compresses the specified folder into a temporary ZIP file,
% then uploads it along with the metadata to the /upload_folder/ endpoint.
% The temporary ZIP file is automatically deleted after the upload attempt.
%
% Usage:
%   response = upload_folder('C:\data\my_folder', 'C:\data\folder_metadata.yml')

    % Import the required libraries for building an HTTP multipart request
    import matlab.net.http.*
    import matlab.net.http.forms.*
    import matlab.net.http.io.*
    import matlab.net.URI

    % 1. Validate that the input folder and file exist before proceeding
    if ~isfolder(folder_path)
        error('Source folder not found: %s', folder_path);
    end
    if ~exist(metadata_filepath, 'file')
        error('Metadata file not found: %s', metadata_filepath);
    end

    % 2. Get the API endpoint
    api_url = dataClient.get_api_url();
    upload_endpoint = string(api_url) + "/upload_folder/";
    uri = URI(upload_endpoint);

    % Define a temporary path for our ZIP file
    temp_zip_path = [tempname, '.zip'];

    % Use onCleanup to ensure the temporary zip file is always deleted,
    % even if the function errors out. This is a robust way to manage temp files.
    cleanup_obj = onCleanup(@() delete(temp_zip_path));

    try
        % 3. Compress the specified folder into the temporary ZIP file
        fprintf('Compressing folder ''%s'' ...\n', folder_path);
        zip(temp_zip_path, folder_path);
        fprintf('Compression complete.\n');

        % 4. Build the multipart/form-data request
        % Note the use of 'zip_file' to match the API endpoint's parameter name
        request = RequestMessage('POST');
        zip_provider = FileProvider(temp_zip_path);
        metadata_provider = FileProvider(metadata_filepath);
        form = MultipartFormProvider('zip_file', zip_provider, 'metadata_file', metadata_provider);
        request.Body = form;
        
        fprintf('Uploading folder to %s ...\n', upload_endpoint);
        options = matlab.net.http.HTTPOptions('ConnectTimeout', 600); % Increased timeout for larger uploads

        % 5. Send the request and get the response
        response_raw = send(request, uri, options);
        status = response_raw.StatusCode;

        % 6. Process the response
        if status == 200 % HTTP OK
            fprintf('Upload successful!\n');
            response_data = response_raw.Body.Data;
            disp('Server Response:');
            disp(response_data);
        else
            fprintf('Upload failed. Server returned HTTP Status %d.\n', status);
            % Attempt to parse and display error message from server if available
            try
                err_data = response_raw.Body.Data;
                fprintf('Server Message: %s\n', err_data.detail);
            catch
                fprintf('Could not parse error message from server.\n');
            end
            error('APIError: Upload failed with status code %d.', status);
        end

    catch ME
        fprintf('\n--- AN ERROR OCCURRED DURING FOLDER UPLOAD ---\n');
        disp(ME.getReport());
        rethrow(ME);
    end
end