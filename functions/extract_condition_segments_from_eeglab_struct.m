function [curr_epoch_curr_cond_eeg_w,segs_to_keep] = extract_condition_segments_from_eeglab_struct (EEG_tmp, cond_types_all_segs,curr_cond_id, num_chans_input_eeg,beapp_indx_curr_epoch)

% mark segments that are from this condition
targ_cond_logical = ismember(cond_types_all_segs, curr_cond_id);

if isempty(EEG_tmp.reject.rejglobal)
    % if no segment rejection was run, keep all
    % segments
    tmp_EEG_struct_rejglobal = ones(1,size(EEG_tmp.data,3));
else
    % get segments to keep, not segments to
    % reject
    tmp_EEG_struct_rejglobal = not([EEG_tmp.reject.rejglobal]);
end

% keep good segments of this condition type
segs_to_keep = all([targ_cond_logical; tmp_EEG_struct_rejglobal]);

%convert back to BEAPP format
if ~isempty(segs_to_keep)
    if length(EEG_tmp.chanlocs) == num_chans_input_eeg
         curr_epoch_curr_cond_eeg_w = EEG_tmp.data(:,:,segs_to_keep);
    else
        tmp_eeg_arr = NaN(num_chans_input_eeg,size(EEG_tmp.data,2),sum(segs_to_keep));
        tmp_eeg_arr(beapp_indx_curr_epoch,:,:) = EEG_tmp.data(:,:,segs_to_keep);
        curr_epoch_curr_cond_eeg_w = tmp_eeg_arr;
    end
else
     curr_epoch_curr_cond_eeg_w = [];
end