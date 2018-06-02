function grp_proc_info = beapp_gui_edit_output_mod_settings(grp_proc_info)

% globals -- will find a way to pass them automatically later
scrsz = get(groot,'ScreenSize');
win_width = scrsz(3)/4;

out_mod_sub_panel_ctr = 1;
show_back_button = 'off';
strhalt_out_mod_out = '';
skipline_panel = 'on';

% pull a list of pre-processing modules
out_mod_sub_panel_list = ['out_mod_general'; grp_proc_info.beapp_toggle_mods.Mod_Names(ismember(grp_proc_info.beapp_toggle_mods.Module_Output_Type,'out'))];

if length(out_mod_sub_panel_list) ==1
    show_next_button = 'off';
else
    show_next_button = 'on';
end

while ~strcmp(strhalt_out_mod_out,'returninginputui_done')
    
    current_sub_panel = out_mod_sub_panel_list{out_mod_sub_panel_ctr};
    
    [out_mod_button_list,out_mod_button_geometry,out_mod_ver_geometry,skipline_panel,...
        adv_out_mod_button_list,adv_out_mod_button_geometry,adv_out_mod_ver_geometry] =...
        beapp_gui_out_mod_subfunction_prep (current_sub_panel,grp_proc_info);
    
    [~, ~, strhalt_out_mod, resstruct_out_mod_settings, ~,strhalt_adv,resstruct_adv_out_mod_settings] = inputgui_mod_for_beapp('geometry',out_mod_button_geometry ,...
        'uilist',out_mod_button_list,'minwidth',win_width,'nextbutton',show_next_button,'backbutton',show_back_button,...
        'title','BEAPP Pre-Processing Settings','geomvert',out_mod_ver_geometry,'skipline',skipline_panel,...
        'adv_uilist',adv_out_mod_button_list, 'adv_geometry',adv_out_mod_button_geometry,'adv_geomvert',adv_out_mod_ver_geometry,'grp_proc_info_in',grp_proc_info);
    
    if ~strcmp (strhalt_out_mod,'')
        grp_proc_info = beapp_gui_out_mod_subfunction_save_inputs (current_sub_panel,resstruct_out_mod_settings,...
            resstruct_adv_out_mod_settings,strhalt_adv,grp_proc_info);
    end
    
    % change available panels based on user data type selection
    if out_mod_sub_panel_ctr ==1
        cont_mods_log =  ismember(grp_proc_info.beapp_toggle_mods.Module_Output_Type,'out');
        on_cont_mods = all([cont_mods_log,grp_proc_info.beapp_toggle_mods.Module_On],2);
        out_mod_sub_panel_list = ['out_mod_general'; grp_proc_info.beapp_toggle_mods.Mod_Names(on_cont_mods)];
    end
    
    [strhalt_out_mod_out, out_mod_sub_panel_ctr, show_back_button, show_next_button] =...
        beapp_gui_navigate_subpanels(strhalt_out_mod, out_mod_sub_panel_ctr,length(out_mod_sub_panel_list));
    
end
end