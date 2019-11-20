function beapp_update_ica_report(evt_conditions_being_analyzed,root_dir,beapp_genout_dir,...
    beapp_prev_run_tag,beapp_curr_run_tag,filename)
%TODO: UPDATE CHANNELS TOO
    %check for ica output table in current runs output folder
    curr_dir = pwd;
    cd(beapp_genout_dir{1,1})
    if isfile(['ICA_Report_Table ',beapp_curr_run_tag '.csv'])
        %open it and update it with seg info
        [num,txt,ica_report] = xlsread(['ICA_Report_Table ',beapp_curr_run_tag '.csv']);
        %add segment columns
        if isempty(find(cellfun(@(s) strcmp('Num_Segs_Pre_Rej',s), ica_report(1,:))))
            ica_report(1,size(ica_report,2)+1) = {'Num_Segs_Pre_Rej'};
            ica_report(1,size(ica_report,2)+1) = {'Num_Segs_Post_Rej'};
        end
        
        file_idx = find(cellfun(@(s) strcmp(filename,s), ica_report(:,1)));
        if ~isempty(file_idx)
            ica_report(file_idx,size(ica_report,2)-1) = {sum(evt_conditions_being_analyzed.Num_Segs_Pre_Rej)};
            ica_report(file_idx,size(ica_report,2)) = {sum(evt_conditions_being_analyzed.Num_Segs_Post_Rej)};
            xlswrite(['ICA_Report_Table ',beapp_curr_run_tag '.csv'],ica_report);
        end
    end
    %check for ica output table in previous run's output folder

%     cd(root_dir)
%     
%     
     cd(curr_dir)
end