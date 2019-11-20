function [adv_out_mod_button_list,adv_out_mod_button_geometry,adv_out_mod_ver_geometry] =...
    beapp_gui_adv_out_mod_settings_prep(current_sub_panel,grp_proc_info)

extra_space_line = {{'style','text','string',''}};
switch current_sub_panel
    case 'psd'
        panel_title = 'Advanced PSD Settings';
        adv_out_mod_button_list = {};
        adv_out_mod_button_geometry = {};
        adv_out_mod_ver_geometry =[];
        
        if get(findobj('tag','psd_win_typ'),'Value') ==3% if multitaper
            
            adv_out_mod_button_list=[{{'style','text','string', 'Number of tapers to use for multitaper windows (integer 3 or greater):'}},...
                {{'style','edit','string',  num2str(grp_proc_info.psd_pmtm_l), 'tag','multitaper_taper_num'}}];
            adv_out_mod_button_geometry(1) = {[.7 .3]};
            adv_out_mod_ver_geometry(1) =1;
        end
        
        if grp_proc_info.beapp_toggle_mods{'psd','Module_Xls_Out_On'}
            
            
            psd_report_type_list = {'Mean', 'StD', 'Median', 'Abs/raw','Norm','Log','Log10'}';
            psd_report_val_list = logical([grp_proc_info.beapp_xlsout_av_on, grp_proc_info.beapp_xlsout_sd_on,...
                grp_proc_info.beapp_xlsout_med_on,  grp_proc_info.beapp_xlsout_raw_on, grp_proc_info.beapp_xlsout_norm_on,...
                grp_proc_info.beapp_xlsout_log_on,grp_proc_info.beapp_xlsout_log10_on])';
            
            adv_out_mod_button_list = [adv_out_mod_button_list,...
                {{'style','checkbox','string', 'Calculate power per frequency?','tag','psd_output_typ',...
                'Value',grp_proc_info.psd_output_typ}}...
                {{'style','text','string', 'Select metrics to report in PSD Excel Outputs:'}},...
                {{'style','uitable','data', [psd_report_type_list num2cell(psd_report_val_list)],...
                'ColumnEditable',[false, true],'ColumnName',{'PSD Report Type','Report Type On'},...
                'ColumnFormat',{'char','logical'},'tag','psd_xls_sel_table'}}];
            adv_out_mod_button_geometry(end+1:end+3) = {1 1 1};
            adv_out_mod_ver_geometry(end+1:end+3) = [1 1 5];
        end
        
    case 'itpc'
            panel_title = 'Advanced ITPC Settings';
        adv_out_mod_button_list = [{{'style','checkbox','string', 'Include Max ITPC in Excel Report?','tag','itpc_xls_max_on','Value',grp_proc_info.beapp_itpc_xlsout_mx_on}},...
            {{'style','checkbox','string', 'Include Mean ITPC in Excel Report?','tag','itpc_xls_mean_on','Value',grp_proc_info.beapp_itpc_xlsout_av_on}}...
            {{'style','checkbox','string', 'Use common baseline (across stimuli)?','tag','itpc_comm_base_on','Value',grp_proc_info.beapp_itpc_params.use_common_baseline}}...
            {{'style','text','string', 'Common baseline index'}},...
            {{'style','edit','string',grp_proc_info.beapp_itpc_params.common_baseline_idx,'tag','itpc_comm_base_idx'}}];
        adv_out_mod_button_geometry = {1 1 1 [.5 .5]};
        adv_out_mod_ver_geometry = [1 1 1 1];
        
       otherwise
        adv_out_mod_button_list = [{{'style','text','string','This panel does not have advanced settings'}}];
        adv_out_mod_button_geometry ={1};
        adv_out_mod_ver_geometry =1;
end
