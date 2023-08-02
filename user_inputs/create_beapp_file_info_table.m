%% mat_file_info_table generation

% directory where files are stored (check me!)
table_files_src_dir = 'Path\to\Directory';
% full path to eeglab.m within BEAPP-HAPPE (check me!)
eeglab_path = 'Path\to\beapp\Packages\eeglab14_1_2b\eeglab.m';

%% Do not edit me
cd(fileparts(which(mfilename)));

% possible names for EEG variables
table_save_directory = cd;
cd(table_files_src_dir)
src_eeg_vname_pos={'Category_1_Segment1', 'EEG_Segment1', 'Category_1', 'Category1'};  

flist = dir('*.mat');
flist = {flist.name}';
FileName = flist;
SamplingRate = NaN(length(flist),1);
NetType= cell(length(flist),1);
LineNoise = 60*ones(length(flist),1);%USA
Diagnosis=NaN(length(flist),1); %TH

beapp_file_info_table = table(FileName, SamplingRate, NetType,LineNoise,Diagnosis); %TH 
beapp_file_info_table.Properties.VariableNames = {'FileName','SamplingRate','NetType','Line_Noise_Freq','Diagnosis'}; %TH
beapp_file_info_table.FileName = flist;

for curr_file = 1: length(flist)
    
    file_eeg_vname = intersect(who,src_eeg_vname_pos);
    load (flist{curr_file});
    disp(['Reading file number ' int2str(curr_file)]);
    if length(file_eeg_vname) ~=1
        disp(flist{curr_file})
        warning(['problem finding EEG data variable with information provided. Skipping']);
        continue;
    else
        eeg=eval(file_eeg_vname{1});
    end
    
    % modify here depending on how
    if (size(eeg,1) == 64) || (size(eeg,1) == 65)
        beapp_file_info_table.NetType(curr_file) = {'Geodesic Sensor Net 64 2.0'};
    elseif (size(eeg,1) == 128) || (size(eeg,1) == 129)
        beapp_file_info_table.NetType(curr_file) = {'HydroCel GSN 128 1.0'};
    end
    
    beapp_file_info_table.SamplingRate(curr_file) = samplingRate;
    clear samplingRate Category_1_Segment1 EEG_Segment1 eeg Category_1 Category1
end
cd(table_save_directory);
save('beapp_file_info_table.mat','beapp_file_info_table');

