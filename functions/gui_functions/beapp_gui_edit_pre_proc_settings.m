function grp_proc_info = beapp_gui_edit_pre_proc_settings (grp_proc_info)

% globals -- will find a way to pass them automatically later
scrsz = get(groot,'ScreenSize');
win_width = scrsz(3)/4;

pre_proc_sub_panel_ctr = 1;
show_back_button = 'off';
strhalt_pre_proc_out = '';
skipline_panel = 'on';

% pull a list of pre-processing modules
pre_proc_sub_panel_list = ['pre_proc_general'; grp_proc_info.beapp_toggle_mods.Mod_Names(ismember(grp_proc_info.beapp_toggle_mods.Module_Output_Type,'cont'))];

if length(pre_proc_sub_panel_list) ==1
    show_next_button = 'off';
else
    show_next_button = 'on';
end


while ~strcmp(strhalt_pre_proc_out,'returninginputui_done')
   
current_sub_panel = pre_proc_sub_panel_list{pre_proc_sub_panel_ctr};
    
    [pre_proc_button_list,pre_proc_button_geometry,pre_proc_ver_geometry,skipline_panel,...
       adv_pre_proc_button_list,adv_pre_proc_button_geometry,adv_pre_proc_ver_geometry] =...
       beapp_gui_pre_proc_subfunction_prep (current_sub_panel,grp_proc_info);
    
    [~, ~, strhalt_pre_proc, resstruct_pre_proc_settings, ~,strhalt_adv,resstruct_adv_pre_proc_settings] = inputgui_mod_for_beapp('geometry',pre_proc_button_geometry ,...
        'uilist',pre_proc_button_list,'minwidth',win_width,'nextbutton',show_next_button,'backbutton',show_back_button,...
        'title','BEAPP Pre-Processing Settings','geomvert',pre_proc_ver_geometry,'skipline',skipline_panel,...
        'adv_uilist',adv_pre_proc_button_list, 'adv_geometry',adv_pre_proc_button_geometry,'adv_geomvert',adv_pre_proc_ver_geometry);
    
    if ~strcmp (strhalt_pre_proc,'')
        grp_proc_info = beapp_gui_pre_proc_subfunction_save_inputs (current_sub_panel,resstruct_pre_proc_settings,...
            resstruct_adv_pre_proc_settings,strhalt_adv,grp_proc_info);
    end
        
    % change available panels based on user data type selection
    if pre_proc_sub_panel_ctr ==1
           cont_mods_log =  ismember(grp_proc_info.beapp_toggle_mods.Module_Output_Type,'cont');
           on_cont_mods = all([cont_mods_log,grp_proc_info.beapp_toggle_mods.Module_On],2);
           pre_proc_sub_panel_list = ['pre_proc_general'; grp_proc_info.beapp_toggle_mods.Mod_Names(on_cont_mods)];
    end
    
    [strhalt_pre_proc_out, pre_proc_sub_panel_ctr, show_back_button, show_next_button] =...
        beapp_gui_navigate_subpanels(strhalt_pre_proc, pre_proc_sub_panel_ctr,length(pre_proc_sub_panel_list));

end

end