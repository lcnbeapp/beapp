function grp_proc_info = beapp_gui_adv_preproc_settings_save_inputs(current_sub_panel,resstruct_adv_pre_proc_settings,grp_proc_info)

% store information on advanced panel close
switch current_sub_panel
    
    case 'pre_proc_general'
        % save bad channel removal option
        grp_proc_info.beapp_rmv_bad_chan_on =resstruct_adv_pre_proc_settings.rmv_bad_chan_on;
    case 'format'
        % settings for file type (mat or non-mat)
          selected_src_format_typ = get(findobj('tag','src_format_typ'),'Value');
        
        if isequal(selected_src_format_typ,[])
            selected_src_format_typ = grp_proc_info.src_format_typ;
        end
         
        % if mat (assumes .mat files don't have the option to export behavioral coding information,
        %or multiple epochs, for now
        if isfield(resstruct_adv_pre_proc_settings,'mat_var_name_table')
            empty_inds = cellfun(@isempty,resstruct_adv_pre_proc_settings.mat_var_name_table.data(:,1),'UniformOutput',1);
            resstruct_adv_pre_proc_settings.mat_var_name_table.data(empty_inds,:) = [];
            grp_proc_info.src_eeg_vname = resstruct_adv_pre_proc_settings.mat_var_name_table.data(:,1)';
            
        elseif isfield(resstruct_adv_pre_proc_settings,'behavioral_coding_table')
            
            % save behavioral coding information
            if all(all(cellfun(@isempty,resstruct_adv_pre_proc_settings.behavioral_coding_table.data,'UniformOutput',1)))
                grp_proc_info.behavioral_coding.events = {''}; % def = {''}. Ex {'TRSP'} Events containing behavioral coding information
                grp_proc_info.behavioral_coding.keys = {''}; % def = {''} Keys in events containing behavioral coding information
                grp_proc_info.behavioral_coding.bad_value = {''}; % def = {''}. Value that marks behavioral coding as bad. must be string - number values must be listed as string, ex '1'
            else
                non_empty_inds = cellfun(@ (x) ~isempty(x),resstruct_adv_pre_proc_settings.behavioral_coding_table.data(:,1),'UniformOutput',1);
                grp_proc_info.behavioral_coding.events = resstruct_adv_pre_proc_settings.behavioral_coding_table.data(non_empty_inds,1)';
                grp_proc_info.behavioral_coding.keys =resstruct_adv_pre_proc_settings.behavioral_coding_table.data(non_empty_inds,2)';
                grp_proc_info.behavioral_coding.bad_value =resstruct_adv_pre_proc_settings.behavioral_coding_table.data(non_empty_inds,3)';
            end
            
            % save epoch selection
            tmp_epochs = str2num(resstruct_adv_pre_proc_settings.epoch_inds_to_process);
            if ~all(isnan(tmp_epochs)) && ~isempty(tmp_epochs)
                grp_proc_info.epoch_inds_to_process = tmp_epochs;
            elseif ~ strcmp(resstruct_adv_pre_proc_settings.epoch_inds_to_process,'')
                warndlg(['Recording period selection must be empty or an array of integers. BEAPP will use previously set value ', num2str(grp_proc_info.epoch_inds_to_process)]);
            end
        end
    case 'detrend'
        if ~isnan(str2double(resstruct_adv_pre_proc_settings.kalman_b_val))
            grp_proc_info.kalman_b=str2double(resstruct_adv_pre_proc_settings.kalman_b_val); %used to determine smoothing in the Kalman filter
        else
            waitfor(warndlg(['Kalman b value must be a number. BEAPP will use previously set value ', num2str(grp_proc_info.kalman_b)]));
        end
        
        if ~isnan(str2double(resstruct_adv_pre_proc_settings.kalman_q_init))
            grp_proc_info.kalman_q_init=str2double(resstruct_adv_pre_proc_settings.kalman_q_init); %used to determine smoothing in Kalman filter
        else
            waitfor(warndlg(['Kalman b value must be a number. BEAPP will use previously set value ', num2str(grp_proc_info.kalman_q_init)]));
        end
    case 'ica'
        grp_proc_info.happe_plotting_on =resstruct_adv_pre_proc_settings.happe_plotting_on;
    case 'filt'
        
        if ~isnan(str2double(resstruct_adv_pre_proc_settings.filt_buff_start_nsec))
            %number of seconds buffer at the start of the EEG recording that can be excluded after filtering and artifact removal (buff1_nsec)
            grp_proc_info.src_buff_start_nsec=str2double(resstruct_adv_pre_proc_settings.filt_buff_start_nsec);
        else
            waitfor(warndlg(['Buffer at Recording Period Start Must Be a Number (in Seconds) >=0 . BEAPP will use previously set value ', num2str(grp_proc_info.src_buff_start_nsec)]));
        end
        
        if ~isnan(str2double(resstruct_adv_pre_proc_settings.filt_buff_end_nsec))
            %number of seconds buffer at the end of the EEG recording that can be excluded after filtering and artifact removal (buff2_nsec)
            grp_proc_info.src_buff_end_nsec=str2double(resstruct_adv_pre_proc_settings.filt_buff_end_nsec);
        else
            waitfor(warndlg(['Buffer at Recording Period End Must Be a Number (in Seconds) >=0 . BEAPP will use previously set value ', num2str(grp_proc_info.src_buff_end_nsec)]));
        end
    case 'rereference'
        
        if ~isnan(str2double(resstruct_adv_pre_proc_settings.csd_lambda))
            % CSD lambda smoothing parameter/learning rate def = 1e-5;
            grp_proc_info.beapp_csdlp_lambda =str2double(resstruct_adv_pre_proc_settings.csd_lambda);
        else
            waitfor(warndlg(['CSD Laplacian parameter lambda must be a number. BEAPP will use previously set value ', num2str( grp_proc_info.beapp_csdlp_lambda)]));
        end
        
        if ~isnan(str2double(resstruct_adv_pre_proc_settings.csdlp_interp_flex))
            if (str2double(resstruct_adv_pre_proc_settings.csdlp_interp_flex) >= 2) && (str2double(resstruct_adv_pre_proc_settings.csdlp_interp_flex) <= 10)
                % m=2...10, 4 spline. def = 4; Used in CSD toolbox only
                grp_proc_info.beapp_csdlp_interp_flex=str2double(resstruct_adv_pre_proc_settings.csdlp_interp_flex);
            else
                waitfor(warndlg(['CSD Laplacian parameter m must be a number 2-10 . BEAPP will use previously set value ', num2str(grp_proc_info.beapp_csdlp_interp_flex)]));
            end
        else
            waitfor(warndlg(['CSD Laplacian parameter m must be a number 2-10 . BEAPP will use previously set value ', num2str(grp_proc_info.beapp_csdlp_interp_flex)]));
        end
end