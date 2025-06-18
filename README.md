# MATLAB Data Ingestion and Access Tool

Client library for uploading, searching, and downloading files from the data lake.

## Requirements
- MATLAB R2019a or newer
- Network Adress of running API server

## Setup and Usage
The client is distributed as a MATLAB Toolbox file (`.mltbx`) for easy installation.

1.  Navigate to the [**Releases Page**](https://github.com/wmorrill24/matlab-client-library/releases) of this GitHub repository.
2.  Under the latest release, download the `.mltbx` file from the "Assets" section.
3.  Open MATLAB, navigate to the folder where you saved the downloaded file, and simply **double-click the `.mltbx` file**.

Methods can be called from a script or in the command-line with "dataClient.<method_name>(args)" 
i.e: dataClient.search_file('author', 'wkm2109')

## Features
### 1. Generate a Metadata Template (generate_metadata_template)
This creates a blank .yml file to guide you in filling out required metadata for an upload
```matlab
% This command creates the template file 'new_experiment.yml' in your current folder.
>> data_ingestion.generate_metadata_template('new_experiment.yml');
```
After running this, open `new_experiment.yml` in a text editor and fill out the fields.

### 2. Upload a File (upload_file)
Uploads a data file along with its completed metadata file.
```matlab
% Assumes 'my_data.csv' and 'my_data.yml' are in the current folder.
>> response = dataClient.upload_file('my_data.csv', 'my_data.yml');

% The 'response' variable will contain a struct with details from the server,
% including the new file's unique ID.
```

### 5. Upload a Folder (upload_folder)
Compresses a folder into a ZIP file and uploads it with its metadata. This is useful for uploading complex datasets, such as those from a full experiment, that include multiple files and subdirectories.
```matlab
% Example: Upload a folder named 'my_experiment_data' 
% with its corresponding metadata file 'my_experiment_data.yml'.

% First, create and fill out your metadata file. You can use the
% generate_metadata_template method for this. Metadata will apply to
% every file in your folder.
>> dataClient.generate_metadata_template('my_experiment_data.yml');
% (Now, manually edit 'my_experiment_data.yml' to add your metadata)

% Once the metadata is ready, upload the folder:
>> response = dataClient.upload_folder('path/to/my_experiment_data', 'my_experiment_data.yml');

% The 'response' variable will contain a struct with details for each 
% file that was uploaded from the folder.
```

### 3. Search for Files (search_file)
Searches the database based on metadata criteria. 
The function returns a `table` containing the results.
```matlab
% Example 1: Find all files from a specific author
>> author_results = dataClient.search_file('author', 'MATLAB-Tester');
>> disp(author_results);

% Example 2: Find all '.txt' files for a specific project
>> project_files = data_ingestion.search_file('research_project_id', 'Client-Test-Project', 'file_type', 'txt');
>> disp(project_files);
```
Search Criteria:
- `project_id: str`
- `author: str`
- `file_type: str`
- `experiment_type: str`
- `tags_contain: str`
- `date_after: str` (YYYY-MM-DD)
- `date_before: str` (YYYY-MM-DD)

### 4. Download a file (download_file)
Downloads a file using the unique `file_id` obtained from a search. 
Defaults to working directory if no filepath is provided.
Sample workflow: 
```matlab
% First, get a file_id from a search result
>> search_results = dataClient.search_file('author', 'wkm2109');
>> id_to_download = search_results.file_id{1};

% Example 1: Download the file to the current MATLAB folder
>> dataClient.download_file(id_to_download);

% Example 2: Download the file to a specific 'downloads' subfolder
>> mkdir('downloads'); % Create the folder first if it doesn't exist
>> dataClient.download_file(id_to_download, 'downloads');
```
