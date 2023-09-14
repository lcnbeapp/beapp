function [dirNames] = set_happe_v3_path(grp_proc_info_in,params)
%Refactored - Copied from HAPPE V3 
%% SET FOLDERS FOR HAPPE AND EEGLAB PATHS
fprintf('Preparing HAPPE...\n') ;
% SET HAPPE AND EEGLAB PATHS USING THE RUNNING SCRIPT
addpath(genpath(grp_proc_info_in.ref_HAPPE_V2_3_loc_dir))
cd(grp_proc_info_in.ref_HAPPE_V2_3_loc_dir)
happeDir =grp_proc_info_in.ref_HAPPE_V2_3_loc_dir; % fileparts(which(mfilename('fullpath'))) ;
eeglabDir = [grp_proc_info_in.ref_HAPPE_V2_3_loc_dir filesep 'Packages' filesep 'eeglab2022.0'] ;

% ADD HAPPE AND REQUIRED FOLDERS TO PATH
addpath([happeDir filesep 'acquisition_layout_information'], ...
    [happeDir filesep 'scripts'], ...
    [happeDir filesep 'scripts' filesep 'UI_scripts'], ...
    [happeDir filesep 'scripts' filesep 'pipeline_scripts'], ...
    eeglabDir, genpath([eeglabDir filesep 'functions'])) ;
rmpath(genpath([eeglabDir filesep 'functions' filesep 'octavefunc'])) ;

% ADD EEGLAB FOLDERS TO PATH
pluginDir = dir([eeglabDir filesep 'plugins']) ;
pluginDir = strcat(eeglabDir, filesep, 'plugins', filesep, {pluginDir.name}, ';') ;
addpath([pluginDir{:}]) ;

% ADD CLEANLINE FOLDERS TO PATH
if exist('cleanline', 'file')
    cleanlineDir = which('eegplugin_cleanline.m') ;
    cleanlineDir = cleanlineDir(1:strfind(cleanlineDir, 'eegplugin_cleanline.m')-1) ;
    addpath(genpath(cleanlineDir)) ;
else; error('Please make sure cleanline is on your path') ;
end

%% DETERMINE AND SET PATH TO DATA
% Use input from the command line to set the path to the data. If an 
% % invalid path is entered, repeat until a valid path is entered.YB
% COMMENTED
% while true
%     srcDir = input('Enter the path to the folder containing the dataset(s):\n> ','s') ;
%     if exist(srcDir, 'dir') == 7; break ;
%     else; fprintf(['Invalid input: please enter the complete path to the ' ...
%             'folder containing the dataset(s).\n']) ;
%     end
% end
srcDir = fullfile(grp_proc_info_in.src_dir{1,1},strcat('HAPPE_V3_',grp_proc_info_in.beapp_curr_run_tag)); % YB ADDED enters path to folder containing datasets
cd (srcDir) ;

%% CREATE OUTPUT FOLDERS
% Create the folders in which to store intermediate and final outputs.
% If you aren't running ERP analyses, don't add the ERP_filtered folder.
cd(srcDir) ;
fprintf('Creating output folders...\n') ;
allDirNames = {'intermediate_processing', 'wavelet_cleaned_continuous', ...
    'muscIL', 'ERP_filtered', 'segmenting', 'processed', ...
    } ;
if ~params.paradigm.ERP.on; allDirNames(ismember(allDirNames, 'ERP_filtered')) = []; end
if ~params.muscIL; allDirNames(ismember(allDirNames, 'muscIL')) = []; end
dirNames = cell(1,size(allDirNames,2)) ;
for i=1:length(allDirNames)
    dirNames{i} = [num2str(i) ' - ' allDirNames{i}] ;
    if ~isfolder([srcDir filesep num2str(i) ' - ' allDirNames{i}])
        mkdir([srcDir filesep num2str(i) ' - ' allDirNames{i}]) ;
    end
end
clear('allDirNames') ;
fprintf('Output folders created.\n') ;