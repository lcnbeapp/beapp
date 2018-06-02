function grp_proc_info = beapp_gui_set_adv_gen_settings(grp_proc_info)

scrsz = get(groot,'ScreenSize');
win_width = scrsz(3)/4;

adv_gen_settings_el_list = [{{'style','checkbox','Value',grp_proc_info.beapp_dir_warn_off,...
    'string','Mute Directory Overwrite Warnings?','tag','beapp_mute_dir_warn'}},...
    {{'style','checkbox','string',sprintf(['Use Re-Run File Selection Table' '\n' '(See Guide)']),...
    'Value', grp_proc_info.beapp_use_rerun_table,'tag','beapp_use_rerun_fselect_table'}}];
    

 [~, ~, strhalt_adv_gen, resstruct_adv_gen_settings, ~] = inputgui_mod_for_beapp...
     ('title', 'BEAPP Advanced General Settings', 'geometry',[1,1],...
     'uilist',adv_gen_settings_el_list ,'geomvert',[1,1],'skipline','on',...
     'minwidth',win_width);
 
if ~strcmp(strhalt_adv_gen,'')
    
     % def = 0; if 1, mute directory warnings
    grp_proc_info.beapp_dir_warn_off = resstruct_adv_gen_settings.beapp_mute_dir_warn;
     
    % def = 0; if 1, use rerun table to run a subset of files. not needed for normal reruns
    grp_proc_info.beapp_use_rerun_table = resstruct_adv_gen_settings.beapp_use_rerun_fselect_table; 
end

end