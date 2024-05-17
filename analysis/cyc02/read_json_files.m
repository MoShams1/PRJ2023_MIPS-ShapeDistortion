% Specify the path to the JSON file
jsonFilePath = 'AC01_task01_20230628_105910.json';

% Open the JSON file and read its content
fileID = fopen(jsonFilePath);
jsonContent = fread(fileID, '*char')';
fclose(fileID);

% Parse the JSON content
jsonData = jsondecode(jsonContent);

% Display the parsed JSON data
disp(jsonData);

% convert structure to arrays
cell_mat = struct2cell(jsonData.contrast);