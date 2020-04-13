% EMO Toys mat_file_info_table generation
%10/18/2017 LB from sample script from BEAPP 4.0

% directory where files are stored (check me!)
table_files_src_dir = 'D:\Datasets\PTEN\Cleveland\just_baseline';% E:\050_Emotion\Infant
% full path to eeglab.m within BEAPP-HAPPE (check me!)
%eeglab_path = '/Users/LGD/Documents/beapp-master 2/Packages/eeglab14_1_2b/eeglab.m';

% Do not edit me
cd(fileparts(which(mfilename)));

% possible names for EEG variables
table_save_directory = cd;
cd(table_files_src_dir)

file_dir = dir(pwd);
SamplingRate = NaN(1,1);
NetType= cell(1,1);
FileName = cell(1,1);
LineNoise = 60*ones(1,1);%USA

beapp_file_info_table = table(FileName, SamplingRate, NetType,LineNoise);
beapp_file_info_table.Properties.VariableNames = {'FileName','SamplingRate','NetType','Line_Noise_Freq'};
%beapp_file_info_table.FileName = flist;
file_idx = 1;
for curr_file = 1:length(file_dir)
    if ~(file_dir(curr_file).isdir)
        try
            load (file_dir(curr_file).name);
        catch
            disp('error')
        end
        disp(['Reading file number ' int2str(curr_file)]);
    %     if length(file_eeg_vname) ~=1
    %         disp(flist{curr_file})
    %         warning(['problem finding EEG data variable with information provided. Skipping']);
    %         continue;
    %     else
    %        % eeg=eval(file_eeg_vname{1});
    %     end
    %     
        % modify here depending on how
        if (size(eeg{1,1},1) == 64) || (size(eeg{1,1},1) == 65)
            beapp_file_info_table.NetType(file_idx) = {'Geodesic Sensor Net 64 2.0'};
        elseif (size(eeg{1,1},1) == 128) || (size(eeg{1,1},1) == 129)
            beapp_file_info_table.NetType(file_idx) = {'HydroCel GSN 128 1.0'};
        end

        beapp_file_info_table.SamplingRate(file_idx) = file_proc_info.src_srate;
        beapp_file_info_table.FileName(file_idx) = {file_dir(curr_file).name};
        beapp_file_info_table.Line_Noise_Freq(file_idx) = 60;
        clearvars file_proc_info eeg
        file_idx = file_idx+1;
    end
end
cd(table_save_directory);
save('beapp_file_info_table.mat','beapp_file_info_table');

