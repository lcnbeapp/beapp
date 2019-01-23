function  grp_proc_info = beapp_gui_pre_proc_subfunction_save_inputs (current_sub_panel,resstruct_pre_proc_settings,...
    resstruct_adv_pre_proc_settings,strhalt_adv,grp_proc_info)
switch current_sub_panel
    case 'pre_proc_general'
        
        % grab preproc module indicies
        preproc_mod_inds = find(ismember(grp_proc_info.beapp_toggle_mods.Module_Output_Type,'cont'));
        
        % save module on settings
        grp_proc_info.beapp_toggle_mods.Module_On(preproc_mod_inds) = ...
            logical(cell2mat(resstruct_pre_proc_settings.pre_proc_mod_sel_table.data(:,2)));
        
        % save module export on settings
        grp_proc_info.beapp_toggle_mods.Module_Export_On(preproc_mod_inds) = ...
            logical(cell2mat(resstruct_pre_proc_settings.pre_proc_mod_sel_table.data(:,3)));
        
        non_empty_net_inds = cellfun(@ (x) (~isempty(x) && ~isequal(x,'none')),...
            resstruct_pre_proc_settings.pre_proc_net_sel_table.data(:,1),'UniformOutput',1);
        
        if any(non_empty_net_inds)
        
            % save non-empty net parameters
            grp_proc_info.src_unique_nets = resstruct_pre_proc_settings.pre_proc_net_sel_table.data(non_empty_net_inds,1)';
        else
             grp_proc_info.src_unique_nets = {''};
             
             if grp_proc_info.beapp_toggle_mods{'ica','Module_On'} ==1
                 warndlg('ICA/ HAPPE in BEAPP requires entering source nets on main pre-processing page');
             end
        end
   
    case 'format'
        
         % save source file format type from menu
         grp_proc_info.src_format_typ = resstruct_pre_proc_settings.src_format_typ;
        
         % save source file presentation software type from menu
         grp_proc_info.src_presentation_software = resstruct_pre_proc_settings.src_pres_typ-1;
        
        % check and store line noise frequency for dataset, or mark using
        % table for individual information
        if resstruct_pre_proc_settings.use_src_linenoise_table_checkbox ==1
            grp_proc_info.src_linenoise = 'input_table';
        else
            % throw warning if selected dataset linenoise not a number
            tmp_linenoise = str2double(resstruct_pre_proc_settings.src_linenoise_value);
            
            if (isnan(tmp_linenoise)|| (tmp_linenoise  <=0)) && ~isequal(resstruct_pre_proc_settings.src_linenoise_value,'input_table')
                warndlg( ['Line Noise Frequency must be a number greater than 0. BEAPP will use previously entered value: '  num2str(grp_proc_info.src_linenoise)]);
            else
                grp_proc_info.src_linenoise =tmp_linenoise;
            end
        end
        
         % check and store event tag offset for dataset, or mark using
        % table for individual information
        if resstruct_pre_proc_settings.use_file_offset_table_checkbox ==1
            grp_proc_info.event_tag_offsets = 'input_table';
        else
            tmp_offset = str2double(resstruct_pre_proc_settings.src_event_tag_offset_val);
            if (isnan(tmp_offset)|| (  tmp_offset <0)) && ~isequal(resstruct_pre_proc_settings.src_event_tag_offset_val,'input_table')
                warndlg( ['Event offset must be a number greater than or equal to 0 ms. BEAPP will use previously entered value: '  num2str(grp_proc_info.event_tag_offsets)]);
            else
                grp_proc_info.event_tag_offsets = tmp_offset;
            end
        end
        
        input_table_needed = (isequal(grp_proc_info.src_linenoise,'input_table')||...
            isequal(grp_proc_info.event_tag_offsets,'input_table')||...
            grp_proc_info.src_format_typ ==1);
        if  input_table_needed
            path_val = resstruct_pre_proc_settings.file_info_table_text;
            if ~isempty(path_val)
                grp_proc_info.beapp_file_info_table =  path_val;
            else
                warndlg( 'File info table not specified');
            end
        end
        
    case 'prepp'
        % save PREP report table settings
        grp_proc_info.beapp_toggle_mods{'prepp','Module_Xls_Out_On'} =resstruct_pre_proc_settings.prepp_xls_out_on;       
    case 'filt'
        
        % save filter selections and frequency cutoffs
        grp_proc_info.beapp_filters.Filt_On = cell2mat(resstruct_pre_proc_settings.filt_sel_table.data(:,2));
         grp_proc_info.beapp_filters.Filt_Cutoff_Freq = cell2mat(resstruct_pre_proc_settings.filt_sel_table.data(:,3));
         
    case 'rsamp'
        
        % save target resampling rate
        rsamp_srate_input = str2double(resstruct_pre_proc_settings.rsamp_srate);
        
        % throw warning if entered sampling rate is a number <=0
        if isnan(rsamp_srate_input) || (rsamp_srate_input <=0)
            warndlg( ['Target sampling rate must be a number greater than 0.'...
                'BEAPP will use previously set target sampling rate: '  num2str(grp_proc_info.beapp_rsamp_srate)]);
        else
              grp_proc_info.beapp_rsamp_srate = rsamp_srate_input;
        end
        
    case 'ica'
        
        if isfield(resstruct_pre_proc_settings,'ica_type_resp') 
            grp_proc_info.beapp_ica_type = resstruct_pre_proc_settings.ica_type_resp;
        end
        
        if isfield(resstruct_pre_proc_settings,'ica_extra_elec_sel_table') 
                if ~all(all(cellfun(@isempty,resstruct_pre_proc_settings.ica_extra_elec_sel_table.data','UniformOutput',1)))
                    grp_proc_info.beapp_ica_additional_chans_lbls = cellfun(@str2num,resstruct_pre_proc_settings.ica_extra_elec_sel_table.data','UniformOutput',0)';
                else 
                     warndlg(['No additional electrodes (beyond 10-20s) entered for analysis. Please check']);
                end
        end
        
        
    case 'rereference'
         
        grp_proc_info.reref_typ = resstruct_pre_proc_settings.reref_type_resp;
        
        if isfield(resstruct_pre_proc_settings,'ref_elec_sel_table') 
            if resstruct_pre_proc_settings.reref_type_resp ==3
                if ~all(all(cellfun(@isempty,resstruct_pre_proc_settings.ref_elec_sel_table.data','UniformOutput',1)))
                    grp_proc_info.beapp_reref_chan_inds = cellfun(@str2num, resstruct_pre_proc_settings.ref_elec_sel_table.data,'UniformOutput',0);
                else 
                     warndlg(['Specific electrode option selected for rereferencing, but no electrodes entered. Please check']);
                end
            end
        end
    case 'detrend'
        grp_proc_info.dtrend_typ = resstruct_pre_proc_settings.detrend_type_resp;
end

if ~isequal(strhalt_adv,'')
    grp_proc_info = beapp_gui_adv_preproc_settings_save_inputs(current_sub_panel,resstruct_adv_pre_proc_settings,grp_proc_info);
end
end
