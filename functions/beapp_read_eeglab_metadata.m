function [grp_proc_info_in,file_proc_info] = beapp_read_eeglab_metadata (grp_proc_info_in,file_proc_info, EEG_struct, curr_file)

%% store general eeg source file information

% assumes current number of channels = source number
file_proc_info.src_nchan = EEG_struct.nbchan;
file_proc_info.src_srate = EEG_struct.srate;
file_proc_info.src_eeglab_version = EEG_struct.etc.eeglabvers;
file_proc_info.src_file_offset_in_ms = grp_proc_info_in.src_offsets_in_ms_all(curr_file);
file_proc_info.src_linenoise =  grp_proc_info_in.src_linenoise_all(curr_file);
file_proc_info.src_num_epochs = size(EEG_struct.data,3);

% % assumes net name is the same as the chanlocs_filename
% if isfield(EEG_struct.chaninfo, 'filename')
%     [~,chan_locs_name,~] =fileparts(EEG_struct.chaninfo.filename);
% else
%     error ('need to update this');
% end 
% file_proc_info.net_typ = {chan_locs_name};

% store general file information for beapp
file_proc_info.beapp_srate = file_proc_info.src_srate;
file_proc_info.beapp_nchan = file_proc_info.src_nchan;
file_proc_info.hist_run_tag = grp_proc_info_in.hist_run_tag;
file_proc_info.hist_run_table = beapp_init_file_hist_table (grp_proc_info_in.beapp_toggle_mods.Properties.RowNames);
file_proc_info.epoch_inds_to_process = grp_proc_info_in.epoch_inds_to_process;
file_proc_info.net_typ{1}=grp_proc_info_in.src_net_typ_all{curr_file}; 
grp_proc_info_in.src_srate_all(curr_file)=file_proc_info.src_srate;
file_proc_info.src_format_typ = grp_proc_info_in.src_format_typ;

%% load and store net information locally

% if file net hasn't been seen in dataset or preloaded, check if in library + load
if ~any(strcmp(grp_proc_info_in.src_unique_nets,file_proc_info.net_typ{1}))
    grp_proc_info_in.src_unique_nets{end+1}=file_proc_info.net_typ{1};
    grp_proc_info_in.src_unique_nets(strcmp('',grp_proc_info_in.src_unique_nets)) = [];
    add_nets_to_library(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options,grp_proc_info_in.ref_net_library_dir,grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);
    [grp_proc_info_in.src_unique_net_vstructs,grp_proc_info_in.src_unique_net_ref_rows, grp_proc_info_in.src_net_10_20_elecs,grp_proc_info_in.largest_nchan] = load_nets_in_dataset(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options, grp_proc_info_in.ref_net_library_dir);
    cd(grp_proc_info_in.src_dir{1})
end

% store net information in file_proc_info -- need to use BEAPP version
% because of the 10-20 electrodes
uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
file_proc_info.net_vstruct = grp_proc_info_in.src_unique_net_vstructs{uniq_net_ind};
file_proc_info.net_ref_elec_rnum = grp_proc_info_in.src_unique_net_ref_rows(uniq_net_ind);
file_proc_info.net_10_20_elecs = grp_proc_info_in.src_net_10_20_elecs{uniq_net_ind};
file_proc_info.src_subject_id = EEG_struct.subject;
clearvars -except grp_proc_info_in file_proc_info 
