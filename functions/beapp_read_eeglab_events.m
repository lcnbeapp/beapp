function [evt_info] = beapp_read_eeglab_events(eeglab_event_struct,behav_coding_bad_value,...
    src_eeglab_cond_info_field,src_eeglab_latency_units,file_proc_info)

%% read in eeglab events

if ~isempty(eeglab_event_struct)
    % event sub function
    % add event label, time latency, and sample number to EEGLAB structure
    for curr_event=1:length(eeglab_event_struct)
        
        % assumes .type field either contains actual type (condition
        % specific) or presentation tag name
        evt_info(curr_event).evt_codes= eeglab_event_struct(curr_event).type;
        %evt_info(curr_event).type= eeglab_event_struct(curr_event).type;
        
        if isfield(eeglab_event_struct,'duration')
            evt_info(curr_event).duration = eeglab_event_struct(curr_event).duration;
        else
            evt_info(curr_event).duration = NaN;
        end
        
        if isfield(eeglab_event_struct,'begintime')
            evt_info(curr_event).evt_times = eeglab_event_struct(curr_event).begintime;
        else
            evt_info(curr_event).evt_times = {''};
        end
        
        % assumes init_time is in seconds
        if isfield(eeglab_event_struct, 'init_time')
            evt_info(curr_event).evt_times_micros_rel = eeglab_event_struct(curr_event).init_time*1000;
        elseif isfield(eeglab_event_struct, 'init_time_micros')
            evt_info(curr_event).evt_times_micros_rel = eeglab_event_struct(curr_event).init_time_micros;
        else
            evt_info(curr_event).evt_times_micros_rel = NaN;
        end
        
        
        if isfield (eeglab_event_struct,'epoch')
            
            % should only be 1 for unsegmented files
            evt_info(curr_event).evt_times_epoch_rel = eeglab_event_struct(curr_event).epoch;
            if  ~grp_proc_info_in.src_format_typ ==3 && (eeglab_event_struct(curr_event).epoch > 1)
                warning ([file_proc_info.beapp_fname{1} ': src format typ indicated as unsegmented .set but file contains more than one segment, confirm unsegmented']);
            end
        else
            evt_info(curr_event).evt_times_epoch_rel = 1;
        end
        
        switch src_eeglab_latency_units
            case 1 % units are samples (default)
                evt_info(curr_event).evt_times_samp_rel = round(eeglab_event_struct(curr_event).latency)+ round(file_proc_info.src_file_offset_in_ms *(file_proc_info.src_srate/1000));
                evt_info(curr_event).evt_times_micros_rel = round(eeglab_event_struct(curr_event).latency/(file_proc_info.beapp_srate/(10^6)));
                
            case 2 % units are seconds
                evt_info(curr_event).evt_times_micros_rel = eeglab_event_struct(curr_event).latency *10^6;
                evt_info(curr_event).evt_times_samp_rel = time2samples(evt_info(curr_event).evt_times_micros_rel,file_proc_info.beapp_srate,6,'round')+ round(file_proc_info.src_file_offset_in_ms *(file_proc_info.src_srate/1000));
                
            case 3 %units are milliseconds
                evt_info(curr_event).evt_times_micros_rel = eeglab_event_struct(curr_event).latency*1000;
                evt_info(curr_event).evt_times_samp_rel = time2samples(evt_info(curr_event).evt_times_micros_rel,file_proc_info.beapp_srate,6,'round')+ round(file_proc_info.src_file_offset_in_ms *(file_proc_info.src_srate/1000));
                
            case 4 % microseconds
                evt_info(curr_event).evt_times_micros_rel = eeglab_event_struct(curr_event).latency;
                evt_info(curr_event).evt_times_samp_rel = time2samples(evt_info(curr_event).evt_times_micros_rel,file_proc_info.beapp_srate,6,'round')+ round(file_proc_info.src_file_offset_in_ms *(file_proc_info.src_srate/1000));
                
        end
        
        if isfield(eeglab_event_struct, 'urevent')
            evt_info(curr_event).evt_ind = eeglab_event_struct(curr_event).urevent;
        else
            evt_info(curr_event).evt_ind = curr_event;
        end
        
        %         if isfield(eeglab_event_struct, 'duration')
        %             evt_info(curr_event).evt_duration_samps = eeglab_event_struct(curr_event).duration;
        %         else
        %             evt_info(curr_event).evt_duration_samps = 0;
        %         end
        
        if isfield(eeglab_event_struct, src_eeglab_cond_info_field)
            evt_info(curr_event).evt_cel_type = getfield(eeglab_event_struct,curr_event,src_eeglab_cond_info_field);
        else
            evt_info(curr_event).evt_cel_type = NaN;
        end
        
        % compare event index and sample for temporal sorting
        if isempty(evt_info(curr_event).evt_times_samp_rel)
            event_samps_inds(curr_event,1) = nan;
        else
            event_samps_inds(curr_event,1) = evt_info(curr_event).evt_times_samp_rel;
        end
        
        event_samps_inds(curr_event,2) = curr_event;
        
        if isfield(eeglab_event_struct,'behav_code')
            if ~isempty(eeglab_event_struct(curr_event).behav_code)
                
                evt_info(curr_event).behav_code = ismember(eeglab_event_struct(curr_event).behav_code,behav_coding_bad_value);
            else
                evt_info(curr_event).behav_code = NaN;
            end
        else
            evt_info(curr_event).behav_code = NaN;
        end
        
    end
    
    % sort events by sample time -- can be made more efficient
    event_samps_inds = sortrows(event_samps_inds);
    sortedEvents = evt_info;
    for p = 1:length(eeglab_event_struct)
        nextEventInd = event_samps_inds(p,2);
        sortedEvents(p) = evt_info(nextEventInd);
    end
    evt_info = sortedEvents;
    
    clear record_time all_events event event_obj all_keys curr_key key
    clear event_epoch curr_event MFFUtil event_tracks event_time
    clear p event_samps_inds sortedEvents nextEventInd tmp_behav_code
end