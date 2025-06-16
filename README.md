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

Methods can be called from a script or in the command-line with "dataClient.<method_name>(args)" i.e: dataClient.search_file('author', 'wkm2109')

## Features
### Generate a Metadata Template 
This creates a blank .yml file to guide you in filling out required metadata for an upload
```matlab
% This command creates the template file 'new_experiment.yml' in your current folder.
>> data_ingestion.generate_metadata_template('new_experiment.yml');
```

