function beapp_update_ica_report(evt_conditions_being_analyzed,root_dir,beapp_genout_dir,...
    beapp_prev_run_tag,beapp_curr_run_tag,filename)
%TODO: UPDATE CHANNELS TOO
    %check for ica output table in current runs output folder
    curr_dir = pwd;
    cd(beapp_genout_dir{1,1})
   if exist(['ICA_Report_Table ',beapp_curr_run_tag,'.csv'], 'file') == 2
      % File exists.
        %open it and update it with seg info
        ica_report = readtable(['ICA_Report_Table ',beapp_curr_run_tag '.csv']);
        %add segment columns
        Exist_Column = strcmp('Num_Segs_Pre_Rej',ica_report.Properties.VariableNames);
        if ~Exist_Column(Exist_Column==1) 
            ica_report.Num_Segs_Pre_Rej = NaN(size(ica_report,1),1);
            ica_report.Num_Segs_Post_Rej = NaN(size(ica_report,1),1);
        end
        file_idx = find(strcmp(filename,ica_report.BEAPP_Fname));
        if ~isempty(file_idx)
           ica_report.Num_Segs_Pre_Rej(file_idx) = sum(evt_conditions_being_analyzed.Num_Segs_Pre_Rej);
           ica_report.Num_Segs_Post_Rej(file_idx) = sum(evt_conditions_being_analyzed.Num_Segs_Post_Rej);
           writetable(ica_report,['ICA_Report_Table ',beapp_curr_run_tag '.csv']);
        end
    end
    %check for ica output table in previous run's output folder

%     cd(root_dir)
%     
%     
     cd(curr_dir)
end