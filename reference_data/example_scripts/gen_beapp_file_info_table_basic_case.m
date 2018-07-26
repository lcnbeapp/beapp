%% example script for beapp_file_info_table generation -- basic case
% will need to be modified according to dataset specifications

% this example assumes all nets, sampling rates, and line noise frequencies
% are the same in your dataset. For an example with multiple net and
% sampling rate types, please see ISP_gen_mat_file_info_table.m in this folder.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% user inputs

file_ext = '.mat';

% source directory for your files (full path)
table_files_src_dir = 'C:\BEAPP_manuscript_baseline';

% where would you like to save your table (typically the user inputs
% folder)
table_save_directory = 'C:\beapp\user_inputs';

% net type name -- the exact name of your net as it appears in the net
% library and/or your source data file
net_type_name = 'HydroCel GSN 128 1.0'; 

% sampling rate for your files
samplingRate = 500;

% linenoise frequency for your files
linenoise_freq = 60;

file_offset = 0; % NaN if file is all-baseline
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% 
cd (table_files_src_dir);
flist = dir(['*' file_ext]);
flist = {flist.name}';
FileName = flist;
SamplingRate = ones(length(flist),1)*samplingRate;
NetType= cell(length(flist),1);
NetType(:) = {net_type_name};
Line_Noise_Freq = ones(length(flist),1)*linenoise_freq;
FileOffset = ones(length(flist),1)*file_offset;

beapp_file_info_table = table(FileName, SamplingRate, NetType,Line_Noise_Freq,FileOffset);
beapp_file_info_table.Properties.VariableNames = {'FileName','SamplingRate','NetType','Line_Noise_Freq','FileOffset'};

cd (table_save_directory)

save('beapp_file_info_table.mat','beapp_file_info_table')

clearvars
