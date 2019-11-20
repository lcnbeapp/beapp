function [evt_info] = beapp_extract_nth_trial(event_info,select_nth_trial,...
    beapp_event_code_onset_strs,segment_stim_relative_to,segment_nth_stim_str)
post_rel_stim_count = 0;
new_event_idx = 1;
new_event_info = struct();
stim_occurred = 0;
for fn = fieldnames(event_info)'
   new_event_info.(fn{1}) = event_info.(fn{1});
end
%jump to first stim_relative_to...THEN do this
for evt = 1:size(event_info,2)
    if stim_occurred == 0
        if strcmp(event_info(evt).evt_codes,segment_stim_relative_to{1,1})
          %  if post_rel_stim_count < min_num_trials
             %   min_num_trials = post_rel_stim_count;
           % end
            post_rel_stim_count = 0;
            stim_occurred = 1;
        end
    else
        if strcmp(event_info(evt).evt_codes,segment_stim_relative_to{1,1})
            post_rel_stim_count = 0;
        else
            if strcmp(event_info(evt).evt_codes,segment_nth_stim_str{1,1})
                post_rel_stim_count = post_rel_stim_count+1;
                if any(post_rel_stim_count == select_nth_trial) %add it to the new event struct
                    new_event_info(new_event_idx) = event_info(evt);
                    new_event_info(1,new_event_idx).evt_codes = strcat(new_event_info(1,new_event_idx).evt_codes,'_',num2str(post_rel_stim_count));
                    new_event_info(1,new_event_idx).type = strcat(new_event_info(1,new_event_idx).type,'_',num2str(post_rel_stim_count));
                    new_event_idx = new_event_idx+1;
                end
            end
        end

    end

end
evt_info = new_event_info;