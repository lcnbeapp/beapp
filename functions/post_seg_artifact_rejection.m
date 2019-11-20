function EEG_tmp = post_seg_artifact_rejection(EEG_tmp, grp_proc_info_in, beapp_indx,beapp_fname,curr_epoch)
% post segmentation amplitude artifact rejection, with stopgap fix during beta testing
if size(beapp_indx{curr_epoch},1) > size(beapp_indx{curr_epoch},2)
    % add ROI option
    [EEG_tmp,bad_inds] = pop_eegthresh(EEG_tmp,1, beapp_indx{curr_epoch}',-1* grp_proc_info_in.art_thresh,grp_proc_info_in.art_thresh,[EEG_tmp.xmin],[EEG_tmp.xmax],2,0);
else
    [EEG_tmp,bad_inds] = pop_eegthresh(EEG_tmp,1, beapp_indx{curr_epoch},-1* grp_proc_info_in.art_thresh,grp_proc_info_in.art_thresh,[EEG_tmp.xmin],[EEG_tmp.xmax],2,0);
end

if grp_proc_info_in.beapp_happe_segment_rejection
    tmp_chk = EEG_tmp.data;
    tmp_chk(isnan(tmp_chk)) = 1000;
    
    % run pop_jointprob if no all zero channels, take out
    % any NaNs
    if all(any(any(tmp_chk,3),2))
        chan_labels = {EEG_tmp.chanlocs(beapp_indx{curr_epoch}).labels};
        EEG_tmp = pop_select(EEG_tmp,'channel', chan_labels);
        EEG_tmp = pop_jointprob(EEG_tmp,1,[1:length(chan_labels)],3,3,grp_proc_info_in.beapp_happe_seg_rej_plotting_on,0,...
            grp_proc_info_in.beapp_happe_seg_rej_plotting_on,[],0);
    else
        warning([beapp_fname{1} ': cannot run pop_jointprob because at least one channel contains all zeros']);
    end
end

EEG_tmp = eeg_rejsuperpose(EEG_tmp, 1, 0, 1, 1, 1, 1, 1, 1);

