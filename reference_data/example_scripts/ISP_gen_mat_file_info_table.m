%% example script for mat_file_info_table generation
% will need to be modified according to dataset specifications
% assumes sampling rate is stored in variable samplingRate
% assumes EEG files with 64 or 65 channels were collected with 'Geodesic Sensor Net 64 2.0'
% assumes EEG files with 128 or 129 channels were collected with HydroCel GSN 128 1.0'


% directory where files are stored
table_files_src_dir = 'B:\ISP_BEAPRun11.03.2016\MatLab Files';
table_save_directory = 'C:\beapp_beta_ISP\user_inputs';
% possible names for EEG variables
src_eeg_vname_pos={'Category_1_Segment1','EEG_Segment1', 'Category_1','Category1'};  


%%
cd (table_files_src_dir);

flist = dir('*.mat');
flist = {flist.name}';
FileName = flist;
SamplingRate = NaN(length(flist),1);
NetType= NaN(length(flist),1);

mat_file_info_table = table(FileName, SamplingRate, NetType);
mat_file_info_table.Properties.VariableNames = {'FileName','SamplingRate','NetType'};
mat_file_info_table.FileName = flist;

for curr_file = 1: length(flist)
load (flist{curr_file});
file_eeg_vname = intersect(who,src_eeg_vname_pos);
disp(['Reading file number' int2str(curr_file)]);
if length(file_eeg_vname) ~=1
    disp(flist{curr_file})
    warning(['problem finding EEG data variable with information provided. Skipping']);
    continue;
else
    eeg=eval(file_eeg_vname{1});
end

% modify here depending on how 
if (size(eeg,1) == 64) || (size(eeg,1) == 65)
    mat_file_info_table.NetType(curr_file) = {'Geodesic Sensor Net 64 2.0'};
elseif (size(eeg,1) == 128) || (size(eeg,1) == 129)
    mat_file_info_table.NetType(curr_file) = {'HydroCel GSN 128 1.0'};
end

mat_file_info_table.SamplingRate{curr_file} = samplingRate;

clear samplingRate Category_1_Segment1 EEG_Segment1 eeg Category_1 Category1
end
cd(table_save_directory);
save('mat_file_info_table.mat','mat_file_info_table');