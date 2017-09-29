%% batch_matexport2beapp (grp_proc_info_in)
% 
% Converts .mat files exported from various file types to BEAPP format. 
% Takes BEAPP grp_proc_info structure and requires corresponding 
% mat_file_info_table (see Running BEAPP With Different Source File Formats
% in the user guide). 
% 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C) 2015, 2016, 2017
% Authors: AR Levin, AS Méndez Leal, LJ Gabard-Durnam, HM O'Leary
% 
% This software is being distributed with the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU General
% Public License for more details.
% 
% In no event shall Boston Children’s Hospital (BCH), the BCH Department of
% Neurology, the Laboratories of Cognitive Neuroscience (LCN), or software 
% contributors to BEAPP be liable to any party for direct, indirect, 
% special, incidental, or consequential damages, including lost profits, 
% arising out of the use of this software and its documentation, even if 
% Boston Children’s Hospital,the Laboratories of Cognitive Neuroscience, 
% and software contributors have been advised of the possibility of such 
% damage. Software and documentation is provided “as is.” Boston Children’s 
% Hospital, the Laboratories of Cognitive Neuroscience, and software 
% contributors are under no obligation to provide maintenance, support, 
% updates, enhancements, or modifications.
% 
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License (version 3) as
% published by the Free Software Foundation.
% 
% You should receive a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function grp_proc_info_in=batch_matexport2beapp(grp_proc_info_in)

% load group information for files
load(grp_proc_info_in.mat_file_info_table)
cd(grp_proc_info_in.src_dir{1});
mat_files_in_src_dir = dir('*.mat');
mat_files_in_src_dir = {mat_files_in_src_dir.name};

%% store information for files listed in both the user input table and the source directory 
[src_fname_all,indexes_in_table] = intersect(mat_file_info_table.FileName,mat_files_in_src_dir,'stable');

if isempty(src_fname_all)
    error (['BEAPP: No data listed in mat_file_info_table found in source directory' grp_proc_info_in.src_dir{1}]);
else 
    grp_proc_info_in.src_fname_all = src_fname_all';
    grp_proc_info_in.beapp_fname_all = grp_proc_info_in.src_fname_all;
end

% store group net types and sampling rates (from table)
grp_proc_info_in.src_net_typ_all = mat_file_info_table.NetType(indexes_in_table);
grp_proc_info_in.src_srate_all = mat_file_info_table.SamplingRate(indexes_in_table);
grp_proc_info_in.src_unique_srates = unique(grp_proc_info_in.src_srate_all);
grp_proc_info_in.src_unique_nets = unique(grp_proc_info_in.src_net_typ_all);

% check if user has given file-specific line noise specifications
if ~isnumeric(grp_proc_info_in.src_linenoise)
    if strcmp(grp_proc_info_in.src_linenoise,'input_table')
       grp_proc_info_in.src_linenoise_all = mat_file_info_table.Line_Noise_Freq(indexes_in_table);  
    end
else
     grp_proc_info_in.src_linenoise_all = grp_proc_info_in.src_linenoise*ones(length(indexes_in_table));
end
clear tmp_flist indexes_in_table mat_file_info_table

% add new nets to library if necessary, load nets being used in dataset
add_nets_to_library(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options,grp_proc_info_in.ref_net_library_dir,grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);
[grp_proc_info_in.src_unique_net_vstructs,grp_proc_info_in.src_unique_net_ref_rows, grp_proc_info_in.src_net_10_20_elecs,grp_proc_info_in.largest_nchan] = load_nets_in_dataset(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options, grp_proc_info_in.ref_net_library_dir);

%% load each .mat file and convert to BEAPP format
for curr_file=1:length(grp_proc_info_in.src_fname_all);
    
    cd(grp_proc_info_in.src_dir{1})
    
    % confirm that file exists before loading
    if exist(strcat(grp_proc_info_in.src_dir{1},filesep,grp_proc_info_in.src_fname_all{curr_file}),'file')
        tic;
        
        % load file and identify variable with EEG data from user list
        load(grp_proc_info_in.src_fname_all{curr_file});        
        file_eeg_vname = intersect(who,grp_proc_info_in.src_eeg_vname);
        
        if length(file_eeg_vname) ~=1
            warning(['BEAPP file ' grp_proc_info_in.src_fname_all{curr_file} ': problem finding EEG data variable with information provided. Skipping file']);
            continue;
        else
            eeg{1}=eval(file_eeg_vname{1});
        end
  
        % save source file variables
        file_proc_info.src_fname=grp_proc_info_in.src_fname_all(curr_file);
        file_proc_info.src_srate=grp_proc_info_in.src_srate_all(curr_file);
        file_proc_info.src_nchan=size(eeg{1},1);
        file_proc_info.src_epoch_nsamps(1)=size(eeg{1},2);
        file_proc_info.src_num_epochs = 1;
        file_proc_info.src_linenoise =  grp_proc_info_in.src_linenoise_all(curr_file); 
        file_proc_info.epoch_inds_to_process = [1]; % assumes mat files only have one recording period
        
        % save starting beapp file variables from source information
        file_proc_info.beapp_fname=grp_proc_info_in.beapp_fname_all(curr_file);
        file_proc_info.beapp_srate=file_proc_info.src_srate;
        file_proc_info.beapp_bad_chans ={[]};
        file_proc_info.beapp_nchans_used=[file_proc_info.src_nchan];
        file_proc_info.beapp_indx={1:size(eeg{1},1)}; % indices for electrodes being used for analysis at current time
        file_proc_info.beapp_num_epochs = 1; % assumes mat files only have one recording period
        
        % save file net information
        file_proc_info.net_typ=grp_proc_info_in.src_net_typ_all(curr_file);
        uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
        file_proc_info.net_vstruct = grp_proc_info_in.src_unique_net_vstructs{uniq_net_ind};
        file_proc_info.net_10_20_elecs = grp_proc_info_in.src_net_10_20_elecs{uniq_net_ind};
        file_proc_info.net_ref_elec_rnum = grp_proc_info_in.src_unique_net_ref_rows(uniq_net_ind);

        % initialize file history information
        file_proc_info.hist_run_tag=grp_proc_info_in.hist_run_tag; % updated in each run
        file_proc_info.hist_run_table = beapp_init_file_hist_table (grp_proc_info_in.beapp_toggle_mods.Properties.RowNames);

        % save beapp formatted files in output directory
        cd(grp_proc_info_in.beapp_toggle_mods{'format','Module_Dir'}{1});
        if ~all(cellfun(@isempty,eeg))
            
            file_proc_info = beapp_prepare_to_save_file('format',file_proc_info, grp_proc_info_in,grp_proc_info_in.src_dir{1});
            save(file_proc_info.beapp_fname{1},'file_proc_info','eeg');
        end
    end
    clearvars -except grp_proc_info_in curr_file 
end

clear grp_proc_info_in.src_srate_all grp_proc_info_in.src_linenoise_all grp_proc_info_in.src_net_typ_all