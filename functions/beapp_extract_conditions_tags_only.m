function [evt_info, conditions_being_analyzed,skip_file] = beapp_extract_conditions_tags_only ...
    (beapp_event_code_onset_strs, evt_info, beapp_event_eprime_values,beapp_fname)
skip_file = 0;
conditions_being_analyzed = [];

if ~isempty(evt_info)
    % here, assumes condition names are the same as the tags
    for curr_cond = 1:length(beapp_event_code_onset_strs)
        for curr_rec_period = 1:length(evt_info)
            
            if curr_cond ==1
                [evt_info{curr_rec_period}(:).type]= deal('Non_Target');
            end
            cond_idxs =  strcmp(beapp_event_code_onset_strs{curr_cond},{evt_info{curr_rec_period}(:).evt_codes});
            [evt_info{curr_rec_period}(cond_idxs).type] = deal(beapp_event_eprime_values.condition_names{curr_cond});
            clear cond_idxs
        end
        clear cond_idxs
    end
    
    % extract tags that exist in dataset and corresponding condition names
    all_uni_tags = {};
    for curr_rec_per = 1: length(evt_info)
        tags_rec_per = unique({evt_info{curr_rec_per}.evt_codes});
        all_uni_tags = unique([tags_rec_per all_uni_tags]);
    end
    
    [tags_used, tags_used_inds] = intersect(beapp_event_code_onset_strs,all_uni_tags);
    
    if isempty(tags_used)
        warning([beapp_fname ' : no events with the selected tags were found in the selected track, skipping file']);
        skip_file = 1;
        return;
    else
        
        conditions_being_analyzed = table(NaN(length(tags_used),1),beapp_event_eprime_values.condition_names(tags_used_inds)',beapp_event_code_onset_strs(tags_used_inds)', NaN(length(tags_used),1),NaN(length(tags_used),1),NaN(length(tags_used),1),NaN(length(tags_used),1),...
            'VariableNames',{'Eprime_Cell_Name','Condition_Name','Evt_Codes','All_Evt_Codes_for_Cond','Num_Segs_Pre_Rej','Num_Segs_Post_Rej','Good_Behav_Trials_Pre_Rej'});
        
        % check to see if user is collapsing conditions from the native
        % file -- not used ir
        if ~isequal(unique(conditions_being_analyzed.Condition_Name,'stable'),conditions_being_analyzed.Condition_Name)
            
            rows_to_delete = zeros(length(conditions_being_analyzed.Condition_Name),1);
            % if yes, collapse them in conditions_being_analyzed
            [vals,~,un_cond_inds] = unique(conditions_being_analyzed.Condition_Name,'stable');
            repeated_conds = find(hist(un_cond_inds,unique(un_cond_inds))>1);
            
            for curr_rep_cond = 1:length(repeated_conds)
                
                cond_inds_rep = ismember(un_cond_inds,repeated_conds(curr_rep_cond));
                first_occurence = find(cond_inds_rep,1,'first');
                conditions_being_analyzed.All_Evt_Codes_for_Cond(first_occurence) = {horzcat(conditions_being_analyzed.Evt_Codes(cond_inds_rep))};
                conditions_being_analyzed.Evt_Codes(first_occurence) = NaN;
                conditions_being_analyzed.Native_File_Condition_Name(first_occurence) =...
                    {strjoin(cellfun(@(x) mat2str(x),conditions_being_analyzed.Native_File_Condition_Name(cond_inds_rep),'UniformOutput',0),',')};
                cond_inds_rep(first_occurence) =0;
                
                rows_to_delete = or(rows_to_delete,cond_inds_rep);
            end
            
            % delete extra rows
            conditions_being_analyzed(rows_to_delete,:) = [];
        end
        
    end
else
    warning([beapp_fname ': expected events but no events in event track, skipping file']);
    skip_file = 1;
    return;
end