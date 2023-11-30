function grp_proc_info = beapp_gui_adv_out_mod_settings_save_inputs(current_sub_panel,...
    resstruct_adv_out_mod_settings,grp_proc_info);

    switch current_sub_panel
        case 'psd'
            
            if get(findobj('tag','psd_win_typ'),'Value') ==3% if multitaper
                tmp_taper_num = str2double(resstruct_adv_out_mod_settings.multitaper_taper_num);
                if isnan(tmp_taper_num) || isempty(tmp_taper_num) || tmp_taper_num <3
                    warndlg( ['Number of tapers must be an integer 3 or greater. BEAPP will use previously entered value: '  num2str(grp_proc_info.psd_pmtm_l)]);
                else
                    % number of tapers for multitaper option
                    grp_proc_info.psd_pmtm_l=   tmp_taper_num;
                end
            end
            
            if grp_proc_info.beapp_toggle_mods{'psd','Module_Xls_Out_On'}
                if resstruct_adv_out_mod_settings.psd_output_typ == 1 %if the button is pressed
                    grp_proc_info.psd_output_typ = 1;
                else
                    grp_proc_info.psd_output_typ = 2;
                end
                tmp_psd_rep_flags = double(cell2mat(resstruct_adv_out_mod_settings.psd_xls_sel_table.data(:,2)));
                % save psd xls options, inefficient will eventually turn this into a table
                grp_proc_info.beapp_xlsout_av_on = tmp_psd_rep_flags(1);
                grp_proc_info.beapp_xlsout_sd_on = tmp_psd_rep_flags(2);
                grp_proc_info.beapp_xlsout_med_on = tmp_psd_rep_flags(3);
                grp_proc_info.beapp_xlsout_raw_on = tmp_psd_rep_flags(4);
                grp_proc_info.beapp_xlsout_norm_on =tmp_psd_rep_flags(5);
                grp_proc_info.beapp_xlsout_log_on = tmp_psd_rep_flags(6);
                grp_proc_info.beapp_xlsout_log10_on = tmp_psd_rep_flags(7);
            end
            
        case 'itpc'
            grp_proc_info.beapp_itpc_xlsout_mx_on = resstruct_adv_out_mod_settings.itpc_xls_max_on;
            grp_proc_info.beapp_itpc_xlsout_av_on = resstruct_adv_out_mod_settings.itpc_xls_mean_on;
            grp_proc_info.beapp_itpc_params.use_common_baseline = resstruct_adv_out_mod_settings.itpc_comm_base_on;
            grp_proc_info.beapp_itpc_params.common_baseline_idx= str2double(resstruct_adv_out_mod_settings.itpc_comm_base_idx);

% HS add PAC module 11/6/2023
        case 'pac'
            grp_proc_info.slid_win_on = resstruct_adv_out_mod_settings.slid_win_on;
            grp_proc_info.slid_win_sz = str2double(resstruct_adv_out_mod_settings.slid_win_sz);
            grp_proc_info.pac_calc_zscores = resstruct_adv_out_mod_settings.pac_calc_zscores;
            grp_proc_info.pac_calc_btwn_chans = resstruct_adv_out_mod_settings.pac_calc_btwn_chans;
            grp_proc_info.pac_variable_hf_filt = resstruct_adv_out_mod_settings.pac_variable_hf_filt;
            grp_proc_info.pac_save_amp_dist = resstruct_adv_out_mod_settings.pac_save_amp_dist;
            
    end
end