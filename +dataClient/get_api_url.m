function url = get_api_url(varargin)
    % Sets or gets the API URL for the session.
    % Usage:
    %   data_ingestion.get_api_url("http://your.api.url:8001") % To set
    %   current_url = data_ingestion.get_api_url()             % To get
    
    persistent api_url;
    default_url = 'http://156.145.114.75:8001';

    if nargin > 0
        new_url = varargin{1};
        if isstring(new_url) || ischar(new_url)
            api_url = string(new_url);
            fprintf('API URL set to: %s\n', api_url);
        else
            error('Invalid input. URL must be a string.');
        end
    end

    % This is the "getter"
    if isempty(api_url)
        % If the user has NOT set a URL yet, return the default.
        url = default_url;
    else
        % If the user HAS set a URL, return that one.
        url = api_url;
    end
end


   