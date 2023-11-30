function grp_proc_info_in =  batch_eeglab2beapp (grp_proc_info_in)

% get file list and extract file specific information from input tables
[grp_proc_info_in.src_fname_all,grp_proc_info_in.src_linenoise_all,...
    grp_proc_info_in.src_offsets_in_ms_all,grp_proc_info_in.beapp_fname_all,grp_proc_info_in.src_net_typ_all] = ...
    beapp_load_nonmat_flist_and_evt_table(grp_proc_info_in.src_dir,'.set',...
    grp_proc_info_in.event_tag_offsets,grp_proc_info_in.src_linenoise,grp_proc_info_in.beapp_file_info_table,...
    grp_proc_info_in.src_format_typ,grp_proc_info_in.beapp_run_per_file,grp_proc_info_in.beapp_file_idx);

if isempty(grp_proc_info_in.src_net_typ_all)
    error('Please include sensor layout information in beapp_file_info_table');
end
grp_proc_info_in.src_unique_nets = unique(grp_proc_info_in.src_net_typ_all);

% if user wants to ignore specific channels, store which channels for which
% nets (otherwise get all net information from beapp_file_info_table)
if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)
    if ~(isequal(length(grp_proc_info_in.src_unique_nets),length(grp_proc_info_in.beapp_indx_chans_to_exclude))&& ~isempty(grp_proc_info_in.src_unique_nets))
        if isempty(grp_proc_info_in.src_unique_nets)
            error ('User has asked to exclude channels but not included net information in grp_proc_info.src_unique_nets');
        elseif ~isequal(length(grp_proc_info_in.src_unique_nets),length(grp_proc_info_in.beapp_indx_chans_to_exclude))
            error ('User has asked to exclude channels but number of nets in grp_proc_info.src_unique_nets does not \n%s',...
                'correspond to number of nets expected from grp_proc_info.beapp_indx_chans_to_exclude');
        end
    end
end

% load nets the user has input, for speed
if ~isempty(grp_proc_info_in.src_unique_nets{1})
    
    % add new nets if not in library, load nets used into grp_proc_info_in
    add_nets_to_library(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options,grp_proc_info_in.ref_net_library_dir,grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);
    [grp_proc_info_in.src_unique_net_vstructs,grp_proc_info_in.src_unique_net_ref_rows, grp_proc_info_in.src_net_10_20_elecs,grp_proc_info_in.largest_nchan] = load_nets_in_dataset(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options, grp_proc_info_in.ref_net_library_dir);
    cd(grp_proc_info_in.src_dir{1});
end


%% convert each file to BEAPP structure

for curr_file = 1: length(grp_proc_info_in.src_fname_all)
    
    tic;
    
    % save filename and path

    file_proc_info.src_fname=grp_proc_info_in.src_fname_all(curr_file);
    file_proc_info.beapp_fname=grp_proc_info_in.beapp_fname_all(curr_file);
    full_filepath=strcat(grp_proc_info_in.src_dir{1},filesep,file_proc_info.src_fname{1});
    EEG_struct = pop_loadset(full_filepath);
    
    %% read eeglab file metadata
    [grp_proc_info_in,file_proc_info] = beapp_read_eeglab_metadata (grp_proc_info_in,file_proc_info, EEG_struct,curr_file);
      
    
    %% initialize file channel related variables
    
    beapp_indx_init = 1:file_proc_info.src_nchan;
    if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)
        uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
        chans_to_exclude = grp_proc_info_in.beapp_indx_chans_to_exclude{uniq_net_ind};
        beapp_indx_init  = setdiff(beapp_indx_init,chans_to_exclude,'stable');
    end
    
    file_proc_info.beapp_indx= cell(file_proc_info.src_num_epochs,1);
    file_proc_info.beapp_indx(:) = {[beapp_indx_init]};
    file_proc_info.beapp_bad_chans= cell(file_proc_info.src_num_epochs,1);
    file_proc_info.beapp_bad_chans(:) = {[]};
    file_proc_info.beapp_nchans_used=length(beapp_indx_init)*ones(1,file_proc_info.src_num_epochs);
    file_proc_info.beapp_filt_max_freq = NaN;
    clear beapp_indx_init
    
    %% read in eeglab events
    
    % event sub function
    % add event label, time latency, and sample number to EEGLAB structure
    if ~ isempty(EEG_struct.event)
        [file_proc_info.evt_info{1}] = beapp_read_eeglab_events(EEG_struct.event,grp_proc_info_in.behavioral_coding.bad_value,...
            grp_proc_info_in.src_eeglab_cond_info_field,grp_proc_info_in.src_eeglab_latency_units,file_proc_info,grp_proc_info_in.src_format_typ);
    end
    
%     if grp_proc_info_in.src_eeglab_cond_info_loc ==1 % condition information already embedded in .type tags
%         
%         for curr_tag = 1:length(EEGLAB TAGS_SET_BY_USER)
%             
%             get_curr_tag_in
%         
%         
%     else % condition info should already be read in
%         
%         
%     end
    
    
%     % if file has been pre-segmented (should this be assumed if 3-D data in
%     % eeglab?)
%     if grp_proc_info_in.src_format_typ ==3
%         seg_cond_names =
%         unique({file_proc_info.seg_info.condition_name});
%         file_proc_info.evt_conditions_being_analyzed= table();
%         file_proc_info.evt_conditions_being_analyzed.Condition_Name
%         (1:length(seg_cond_names),1)= seg_cond_names';
%         file_proc_info.evt_conditions_being_analyzed((length(seg_cond_names)+1):end,:)
%         =[];
%     end
    clear curr_file_obj record_time
    
    %% load actual eeg data
    eeg = {EEG_struct.data};
    
    % wipe out (NaN) channels appropriately
    if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)
        eeg = cellfun(@(x) exclude_data_for_chans(chans_to_exclude,x),eeg,'UniformOutput',0);
    end
    %% format and save
    
%    % delete data inside recording periods not selected
%     if ~ isempty(file_proc_info.epoch_inds_to_process)
%         try
%             eeg = eeg(file_proc_info.epoch_inds_to_process);
%             file_proc_info.evt_info = file_proc_info.evt_info(file_proc_info.epoch_inds_to_process);
%             file_proc_info.beapp_num_epochs = length(file_proc_info.epoch_inds_to_process);
%             file_proc_info.beapp_indx = file_proc_info.beapp_indx(file_proc_info.epoch_inds_to_process);
%             file_proc_info.beapp_bad_chans = file_proc_info.beapp_bad_chans(file_proc_info.epoch_inds_to_process);
%             file_proc_info.beapp_nchans_used =  file_proc_info.beapp_nchans_used(file_proc_info.epoch_inds_to_process);
%         catch ME
%             if strcmp(ME.identifier,'MATLAB:badsubscript')
%                 warning ([file_proc_info.beapp_fname{1} ' : does not contain one or all of recording selected in user inputs. Skipping this file in this analysis']);
%                 continue;
%             end
%         end
%     end
  
    file_proc_info = beapp_prepare_to_save_file('format',file_proc_info, grp_proc_info_in,grp_proc_info_in.src_dir{1});
    
    % if segmented files, make data into condition x epoch array containing
    % 3d data arrays, as produces in segmentation modules
    % throw out bad segments if desired
    if grp_proc_info_in.src_format_typ ==5
        
        if ndims (eeg{1,1}) <3 && ~isempty(eeg{1,1})
            % if only one segment, let the user know in case it's
            % unsegmented data
            warning ([file_proc_info.beapp_fname{1} ': src format typ indicated as segmented .set. File only contains one segment, confirm pre-segmented']);
        end

        % Read in epoch information - YB added
file_proc_info = beapp_read_set_segment_info(EEG_struct,file_proc_info,grp_proc_info_in);        
        [eeg_w, file_proc_info] = format_segmented_set_data (eeg{1,1},file_proc_info,...
            grp_proc_info_in.beapp_event_eprime_values.condition_names,0,grp_proc_info_in.src_data_type);
        if ~all(cellfun(@isempty,eeg_w))
            save(file_proc_info.beapp_fname{1},'file_proc_info','eeg_w');
        end
    elseif ~all(cellfun(@isempty,eeg))
        save(file_proc_info.beapp_fname{1},'file_proc_info','eeg');
    end
    
    clearvars -except grp_proc_info_in curr_file grp_proc_info_in.src_offsets_in_ms_all ref_dir
end
clear grp_proc_info_in.src_srate_all file_proc_info
end

function eeg_curr_rec_period = exclude_data_for_chans(chans_to_exclude,eeg_curr_rec_period)
eeg_curr_rec_period(chans_to_exclude ,:) = deal(NaN);
end

