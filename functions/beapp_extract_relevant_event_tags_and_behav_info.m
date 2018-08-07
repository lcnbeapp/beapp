function [file_proc_info, skip_file] = beapp_extract_relevant_event_tags_and_behav_info ...
    (file_proc_info,src_data_type,beapp_event_eprime_values,beapp_event_code_onset_strs,src_format_typ, beapp_event_use_tags_only)

skip_file = 0;
% make sure eeg outputs line up across all files being processed in
% this run
if src_data_type ==1 %standard baseline, not between tags
    file_proc_info.grp_wide_possible_cond_names_at_segmentation = {'baseline'};
    file_proc_info.evt_conditions_being_analyzed = table(NaN,{'baseline'},{''},...
        NaN(1,1),NaN(1,1),NaN(1,1),...
        'VariableNames',{'Eprime_Cell_Name','Condition_Name','Evt_Codes',...
        'Num_Segs_Pre_Rej','Num_Segs_Post_Rej','Good_Behav_Trials_Pre_Rej'});
else
    % determine what condition sets in user inputs are present in this
    % file (greatest overlap) -- only done if tags are relevant
    if isfield(file_proc_info,'evt_info')
        
%         % if source file was an eeglab file
%         if src_format_typ==4
%             % if cel type information was not previously provided
%             % map string and cell information from user inputs to each other
%             if ~any(cellfun(@(x) any(~isnan([x.evt_cel_type])),file_proc_info.evt_info))|| beapp_event_use_tags_only
%                 % warning ('BEAPP segmenting: no condition info provided in EEGLAB source file, using event tags from user inputs as conditions');
%                 
%                 %                  file_proc_info.conditions_being_analyzed = table(NaN,{''},{''}, NaN(1,1),NaN(1,1),NaN(1,1),NaN(1,1),...
%                 %                 'VariableNames',{'Eprime_Cell_Name','Condition_Name','Evt_Codes','All_Evt_Codes_for_Cond','Num_Segs_Pre_Rej','Num_Segs_Post_Rej','Good_Behav_Trials_Pre_Rej'});
%                 %
%                 
%                 
%             end
%         end
%         
        if ~beapp_event_use_tags_only
            [file_proc_info.evt_info,file_proc_info.evt_conditions_being_analyzed,skip_file] =...
                beapp_extract_condition_labels(file_proc_info.beapp_fname{1},src_data_type,...
                file_proc_info.evt_header_tag_information,file_proc_info.evt_info,...
                beapp_event_eprime_values,beapp_event_code_onset_strs);
        else
             [file_proc_info.evt_info,file_proc_info.evt_conditions_being_analyzed,skip_file] = beapp_extract_conditions_tags_only ...
                (beapp_event_code_onset_strs, file_proc_info.evt_info, beapp_event_eprime_values,file_proc_info.beapp_fname{1});
        end
    else
        warning([file_proc_info.beapp_fname{1} ': file does not contain any event tag information']);
        skip_file = 1;
    end
    
    if skip_file
        return;
    end
    
    % incorporate behavioral information
    [file_proc_info.evt_info,behav_coding] = beapp_exclude_trials_using_behavioral_codes (file_proc_info.evt_info);
    file_proc_info.grp_wide_possible_cond_names_at_segmentation = unique(beapp_event_eprime_values.condition_names,'stable');
    %
    if src_data_type ==2
        if behav_coding
            file_proc_info.evt_conditions_being_analyzed.Good_Behav_Trials_Pre_Rej=zeros(length(file_proc_info.evt_conditions_being_analyzed.Condition_Name),1);
        end
        
        file_proc_info.evt_conditions_being_analyzed.Num_Segs_Post_Rej=zeros(length(file_proc_info.evt_conditions_being_analyzed.Condition_Name),1);
    else
        % conditioned baseline
        file_proc_info.evt_conditions_being_analyzed.Num_Segs_Pre_Rej=NaN(length(file_proc_info.evt_conditions_being_analyzed.Condition_Name),1);
    end
end
