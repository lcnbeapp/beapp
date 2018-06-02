function eeg_msk_w_cond = beapp_create_condition_mask (grp_proc_info_in,file_proc_info,eeg_msk_curr_epoch,curr_epoch,curr_condition)

if grp_proc_info_in.src_data_type ==3
    
    curr_cond_curr_epoch_msk = ones(1,size(eeg_msk_curr_epoch,2));
    
    if ~isempty(file_proc_info.evt_info{curr_epoch})
        target_label_ind = find(ismember({file_proc_info.evt_info{curr_epoch}.type},file_proc_info.grp_wide_possible_cond_names_at_segmentation{curr_condition}));  
    else
        target_label_ind = [];
    end
    
    % for each tag associated with this condition
    for curr_target_label = 1:length(target_label_ind)
        
        % get the name and index of the relevant event tag in onset strs 
        curr_tag = file_proc_info.evt_info{curr_epoch}(target_label_ind(curr_target_label)).evt_codes; 
        curr_tag_ind_in_onset_strs = find(strcmp(grp_proc_info_in.beapp_event_code_onset_strs,curr_tag));
        
        % find the nearest paired end tag that goes with that start tag
        inds_of_end_tag = find(ismember({file_proc_info.evt_info{curr_epoch}.evt_codes},grp_proc_info_in.beapp_event_code_offset_strs{curr_tag_ind_in_onset_strs}));
        curr_end_tag_ind = inds_of_end_tag(find((inds_of_end_tag-target_label_ind(curr_target_label))>0,1));
        
        % mark all data in between sample number of start and nearest end
        % tag
        curr_cond_curr_epoch_msk (1,[file_proc_info.evt_info{curr_epoch}(target_label_ind(curr_target_label)).evt_times_samp_rel]:...
            [file_proc_info.evt_info{curr_epoch}(curr_end_tag_ind).evt_times_samp_rel])=0;
    end
else 
    curr_cond_curr_epoch_msk = zeros(1,size(eeg_msk_curr_epoch,2));
end

eeg_msk_w_cond = any([curr_cond_curr_epoch_msk; eeg_msk_curr_epoch],1);