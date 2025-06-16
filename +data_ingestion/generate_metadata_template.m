function generate_metadata_template(filepath, varargin)
    % Generates a blank metadata YAML file to guide the user.
    % This function is designed to be identical to the Python client's version.
    %
    % Usage:
    %   generate_metadata_template('C:\data\my_file.yml')
    %   generate_metadata_template('C:\data\my_file.yml', 'overwrite', true)

    % --- Input Parsing for optional 'overwrite' flag ---
    p = inputParser;
    addRequired(p, 'filepath', @ischar);
    addParameter(p, 'overwrite', false, @islogical);
    parse(p, filepath, varargin{:});
    
    overwrite = p.Results.overwrite;
    
    % --- File Existence Check ---
    if exist(filepath, 'file') && ~overwrite
        fprintf('File ''%s'' already exists. Use ''overwrite'', true to replace it. Aborting.\n', filepath);
        return;
    end

    % --- Directory Creation Logic (Matches Python's os.makedirs) ---
    try
        directory = fileparts(filepath);
        if ~isempty(directory) && ~exist(directory, 'dir')
            fprintf('Directory not found. Creating: %s\n', directory);
            mkdir(directory);
        end
    catch ME
        fprintf('Error creating directory: %s\n', ME.message);
        return;
    end
    
    % --- YAML Template Content (Matches Python Version Exactly) ---
    template_content = [ ...
        '# --- Metadata for the associated data file ---\n' ...
        '# Please fill out the values for each field.\n' ...
        '# Required fields are marked. Others are optional.\n' ...
        '# Date format should be YYYY-MM-DD.\n\n' ...
        '# --- Project & Author (Required) ---\n' ...
        'research_project_id: "" # e.g., "Frequency Sweep"\n' ...
        'author: ""            # e.g., "wkm2109"\n\n' ...
        '# --- Experiment Details (Optional) ---\n' ...
        'experiment_type: ""   # e.g., "Data Calibration"\n' ...
        'date_conducted: ""    # e.g., "2025-01-15"\n\n' ...
        '# --- Descriptive Metadata (Optional) ---\n' ...
        'custom_tags: ""       # e.g., "1.5 mHZ, 2V, simulation, NHP, etc."\n' ...
    ];

    % --- Write the File ---
    try
        fileID = fopen(filepath, 'w');
        fprintf(fileID, template_content);
        fclose(fileID);
        fprintf('Template YAML created at: %s\n', filepath);
    catch ME
        fprintf('Error creating template file: %s\n', ME.message);
    end
end