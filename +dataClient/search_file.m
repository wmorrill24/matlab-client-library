function results_table = search_file(varargin)
    % Searches the metadata catalog using keyword arguments.
    
    % 1. Define and parse optional input arguments
    p = inputParser;
    addParameter(p, 'file_id', '');
    addParameter(p, 'research_project_id', '');
    addParameter(p, 'author', '');
    addParameter(p, 'file_type', '');
    addParameter(p, 'experiment_type', '');
    addParameter(p, 'tags_contain', '');
    addParameter(p, 'date_after', ''); % YYYY-MM-DD
    addParameter(p, 'date_before', ''); % YYYY-MM-DD
    parse(p, varargin{:});
    
    params = p.Results;
    
    % Remove any empty parameters
    fields = fieldnames(params);
    for i = 1:numel(fields)
        field = fields{i};
        if isempty(params.(field))
            params = rmfield(params, field);
        end
    end
    % 2. Get the API server URL
    api_url = dataClient.get_api_url();
    search_endpoint = string(api_url) + '/search';

    % 3. Make the web request
    try
        options = weboptions('Timeout', 30);
        
        % Convert our cleaned-up struct of parameters to a cell array
        param_fields = fieldnames(params);
        param_values = struct2cell(params);
        queryParams = cell(1, 2 * numel(param_fields));
        for i = 1:numel(param_fields)
            queryParams{2*i - 1} = param_fields{i};
            queryParams{2*i} = param_values{i};
        end
            
        
        response_data = webread(search_endpoint, queryParams{:}, options);

        % 4. Format the output
        if isempty(response_data)
            disp("Search returned no results.");
            results_table = table(); 
        else
            results_table = struct2table(response_data, 'AsArray', true);
            disp(['Search successful. Found ', num2str(height(results_table)), ' results.']);
        end

    catch ME
        % 5. Handle errors
        fprintf('An error occurred during search: %s\n', ME.message);
        if isprop(ME, 'cause') && ~isempty(ME.cause)
            % This part helps print the detailed error message from the server
            cause = ME.cause{1};
            if isprop(cause, 'Body') && isprop(cause.Body, 'Data')
                fprintf('Server Response: %s\n', cause.Body.Data);
            end
        end
        results_table = table();
    end
end