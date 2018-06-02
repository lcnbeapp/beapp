function [adv_pre_proc_button_list,adv_pre_proc_button_geometry,adv_pre_proc_ver_geometry] =...
    beapp_gui_adv_preproc_settings_prep(current_sub_panel,grp_proc_info)
extra_space_line = {{'style','text','string',''}};

switch current_sub_panel
    
    case 'pre_proc_general'
        adv_pre_proc_button_list = [{{'style','checkbox','string','Remove Bad Channels Instead of Interpolating?     ',...
            'tag','rmv_bad_chan_on','value',grp_proc_info.beapp_rmv_bad_chan_on}}];
        adv_pre_proc_button_geometry = {1};
        adv_pre_proc_ver_geometry = [2];
        panel_title = 'Advanced General Pre-Processing Settings';
    case 'format'
        empty_10_cell = cell(10,1);
        empty_10_cell(:) = deal({''});
       
        % crude way of getting the currently selected source format type-- will change after
        % initial revision
        selected_src_format_typ = get(findobj('tag','src_format_typ'),'Value');
        
        if isequal(selected_src_format_typ,[])
            selected_src_format_typ = grp_proc_info.src_format_typ;
        end
        
        % display settings for file type (mat or non-mat)
        
        % if mat (assumes .mat files don't have the option to export behavioral coding information,
        %or multiple epochs, for now
        
        if selected_src_format_typ ==1
            mat_name_disp_list =empty_10_cell;
            mat_name_disp_list(1:length(grp_proc_info.src_eeg_vname)) = grp_proc_info.src_eeg_vname;
            
            adv_pre_proc_button_list=[{{'style','text','string', ...
                'Enter all possible variable names of EEG data in .mat files (e.g. EEGSegment1 etc.) below'}},...
                {{'style','uitable','data',mat_name_disp_list,'tag','mat_var_name_table', ...
                'ColumnFormat',{'char'},'ColumnEditable',true,'ColumnName',{'VariableNames'}}}];

            adv_pre_proc_button_geometry = {1 1};
            adv_pre_proc_ver_geometry = [1 6];
            
        else % if non-mat
  
            beh_events = empty_10_cell;
            beh_events(1:length(grp_proc_info.behavioral_coding.events)) =grp_proc_info.behavioral_coding.events;
            beh_keys = empty_10_cell;
            beh_keys(1:length(grp_proc_info.behavioral_coding.keys)) =grp_proc_info.behavioral_coding.keys;
            beh_bad_values = empty_10_cell;
            beh_bad_values(1:length( grp_proc_info.behavioral_coding.bad_value)) = grp_proc_info.behavioral_coding.bad_value;
            
            adv_pre_proc_button_list=[{{'style','text','string', ...
                'Enter events, keys, and bad values for behavioral coding information below(leave blank if N/A) '}},...
                {{'style','uitable','data',[beh_events,beh_keys,beh_bad_values],'tag','behavioral_coding_table', ...
                'ColumnFormat',{'char','char','char'},'ColumnEditable',[true,true,true],'ColumnName',{'EventTag','Key','BadValue'}}},...
                extra_space_line,...
                {{'style','text','string', 'Recording Periods to Analyze (ex. [1:3,4,6] def: []; to process all periods): '}},...
                {{'style','edit','string', mat2str(grp_proc_info.epoch_inds_to_process), 'tag','epoch_inds_to_process'}}];
            %% ADD IN fILE INFORMATION TAbLE SELECTION
            adv_pre_proc_button_geometry = { 1 1 1 [.7 .3]};
            adv_pre_proc_ver_geometry = [1 6 1 1];
        end
        panel_title = 'Optional Format Settings';
        
    case 'filt'
        panel_title = 'Advanced Filtering Settings';
        
        % Sets the buffer at the begining and end of the source files when
        % making segments for baseline
        % This should only be set to 0 if no filtering is applied to the data.
        adv_pre_proc_button_list=[{{'style','text','string', 'Buffer at Recording Period Start to be Removed after Filtering (Seconds, default: 2) ', 'tag','filt_buff_start_nsec_prompt'}},...
            {{'style','edit','string',  num2str(grp_proc_info.src_buff_start_nsec), 'tag','filt_buff_start_nsec'}},...
            {{'style','text','string', 'Buffer at Recording Period End to be Removed after Filtering (Seconds, default: 2)', 'tag','filt_buff_end_nsec_prompt'}}...
            {{'style','edit','string', num2str(grp_proc_info.src_buff_end_nsec), 'tag','filt_buff_end_nsec'}}];
        
        adv_pre_proc_button_geometry = {[.7 .3] [.7 .3]};
        adv_pre_proc_ver_geometry = [1 1];
    case 'ica'
        panel_title = 'Advanced ICA Settings';
        % def = 0; turns on HAPPE/MARA visualisations - will then require user feedback for each file
        adv_pre_proc_button_list = [{{'style','checkbox','string', 'Turn On HAPPE/MARA visualizations? Note: This will require user feedback for each file ',...
            'tag','happe_plotting_on','value', grp_proc_info.happe_plotting_on}}];
        adv_pre_proc_button_geometry = {1};
        adv_pre_proc_ver_geometry = [1];
        
        
    case 'rereference'
        panel_title = 'Advanced Re-Reference Settings';
        adv_pre_proc_button_list=[{{'style','text','string', 'CSD Laplacian Smoothing Constant Lambda (default: 1e-5)', 'tag','csd_lambda_prompt'}},...
            {{'style','edit','string',  num2str(grp_proc_info.beapp_csdlp_lambda), 'tag','csd_lambda'}},...
            {{'style','text','string', 'CSD  Laplacian Spline Flexibility Parameter m (default: 4, values 2-10)', 'tag','csdlp_interp_flex_prompt'}}...
            {{'style','edit','string', num2str(grp_proc_info.beapp_csdlp_interp_flex), 'tag','csdlp_interp_flex'}}];
        
        adv_pre_proc_button_geometry = {[.7 .3] [.7 .3]};
        adv_pre_proc_ver_geometry = [1 1];
        
    case 'detrend'
        
        % select Kalman detrend parameters
        adv_pre_proc_button_list=[{{'style','text','string', 'Kalman Filter B Value (default .9999): ', 'tag','kal_b_prompt'}},...
            {{'style','edit','string',  num2str(grp_proc_info.kalman_b), 'tag','kalman_b_val'}},...
            {{'style','text','string', 'Kalman Q Init Value (default: 1): ', 'tag','kalman_q_init_prompt'}}...
            {{'style','edit','string', num2str(grp_proc_info.kalman_q_init), 'tag','kalman_q_init'}}];
        
        panel_title = 'Advanced Detrend Settings';
        adv_pre_proc_button_geometry = {[.7 .3] [.7 .3]};
        adv_pre_proc_ver_geometry = [1 1];
        
    otherwise
        adv_pre_proc_button_list = [{{'style','text','string','This panel does not have advanced settings'}}];
        adv_pre_proc_button_geometry ={1};
        adv_pre_proc_ver_geometry =1;
end