function [tmp_EEG_struct_rejglobal] = remove_evt_seqs_in_groups(group_size,num_epochs,tmp_EEG_struct_rejglobal,EEG_epoch_struct,group_code_onset_strs)
%% HERE, ALSO TAG SEGMENTS IN GROUP WHERE >=1 SEG IS TAGGED
%(and tag any segments that don't occur in a whole sequence)
%...sorry
evt_group = 1;
evt = 1;
evt_group_idx = 1; %already checked 1
%find grp_proc_info.beapp_event_group_code_onset_strs
while evt<length(EEG_epoch_struct)+1
    if strcmp(EEG_epoch_struct(evt).eventevt_codes,group_code_onset_strs{1,evt_group_idx})
        %see if it makes a full sequence
        sequence = 1;
        while sequence && (evt_group_idx <= group_size) && (evt<length(EEG_epoch_struct)+1)
            if ~strcmp(EEG_epoch_struct(evt).eventevt_codes,group_code_onset_strs{1,evt_group_idx})
                sequence = 0;
            end
            evt_group_idx = evt_group_idx+1;
            evt = evt+1;
        end
        if sequence == 1 && (evt_group_idx == group_size+1)
            if any(tmp_EEG_struct_rejglobal(1,evt-evt_group_idx+1:evt-1)==0)
                tmp_EEG_struct_rejglobal(1,evt-evt_group_idx+1:evt-1) = 0;
            end
            evt_group_idx = 1;
        else
            tmp_EEG_struct_rejglobal(1,evt-evt_group_idx+1:evt-1) = 0;
        end
    else
        tmp_EEG_struct_rejglobal(1,evt) = 0;
        evt = evt+1;
    end
end
% while evt_group*group_size < num_epochs
%     if any(tmp_EEG_struct_rejglobal(1,((evt_group-1)*group_size)+1:(evt_group*group_size))==0)
%         tmp_EEG_struct_rejglobal(1,((evt_group-1)*group_size)+1:(evt_group*group_size)) = 0;
%     end
%     evt_group = evt_group+1;
% end
