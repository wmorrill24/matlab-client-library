function response_data = upload_file(data_filepath, metadata_filepath)
% Uploads a data file and its corresponding metadata file to the server.
    %
    % Usage:
    %   response = upload_file('C:\data\my_file.csv', 'C:\data\my_file.yml')

    % Import the required libraries for building an HTTP multipart request
    import matlab.net.http.*
    import matlab.net.http.forms.*
    import matlab.net.http.io.*
    import matlab.net.URI

    % 1. Validate that the input files exist before trying to upload
    if ~exist(data_filepath, 'file')
        error('Data file not found: %s', data_filepath);
    end
    if ~exist(metadata_filepath, 'file')
        error('Metadata file not found: %s', metadata_filepath);
    end

    % 2. Get the API endpoint
    api_url = dataClient.get_api_url();
    upload_endpoint = string(api_url) + "/uploadfile/";
    uri = URI(upload_endpoint);

    try
        % 3. Build the multipart/form-data request
        request = RequestMessage('POST');
        data_provider = FileProvider(data_filepath);
        metadata_provider = FileProvider(metadata_filepath);
        form = MultipartFormProvider('data_file', data_provider, 'metadata_file', metadata_provider);
        request.Body = form;

        fprintf('Uploading files to %s ...\n', upload_endpoint);

        options = matlab.net.http.HTTPOptions('ConnectTimeout', 300);

    % 4. Send the request and get the response
        response_raw = send(request, uri, options);
        status = response_raw.StatusCode;

    % 5. Process the response
        if status == 200 % HTTP OK
            fprintf('Upload successful!\n');
            response_data = response_raw.Body.Data;
            disp('Server Response:');
            disp(response_data);
        else
            fprintf('Upload failed. Server returned HTTP Status %d.\n', status);
            fprintf('Server Message: %s\n', response_raw.Body.Data);
            error('APIError: Upload failed with status code %d.', status);
        end

    catch ME
        fprintf('\n--- AN ERROR OCCURRED DURING UPLOAD ---\n');
        disp(ME.getReport());
        rethrow(ME);
    end
end