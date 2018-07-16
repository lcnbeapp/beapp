%% Run the statistics for a version of the NCTU
pop_editoptions('option_single', false, 'option_savetwofiles', false);
saveFile = 'dataStatistics.mat';

%% Setup the directories and titles
ess2Dir = 'N:\ARLAnalysis\NCTU\NCTU_Robust_1Hz';
outDir = 'N:\ARLAnalysis\NCTU\NCTU_Robust_1Hz';
theTitle = 'NCTU_Robust_1Hz';
fieldPath = {'etc', 'noiseDetection', 'reference', 'noisyStatistics'};

%% Create a level 2 study
obj2 = level2Study('level2XmlFilePath', ess2Dir);
obj2.validate();

%% Get the files out
[filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = ...
    getFilename(obj2);

%% Consolidate the results in a single structure for comparative analysis
collectionStats = createCollectionStatistics(theTitle, filenames, fieldPath);
%% Save the statistics in the specified file
save([outDir filesep saveFile], 'collectionStats', '-v7.3');

%% Display the reference statistics
showNoisyStatistics(collectionStats);

