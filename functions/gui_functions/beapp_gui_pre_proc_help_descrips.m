function beapp_gui_pre_proc_help_descrips(current_sub_panel)
switch current_sub_panel
    otherwise
    panel_title = 'Help Panel to Come';
    help_button_list = [{{'style','text','string','Instructions for this panel still to come, consult user guide for help'}}];
    help_button_geometry = {1};
    help_button_vert_geometry = [1];
    
    [~, ~, strhalt_help, ~, ~] = inputgui_mod_for_beapp('geometry', help_button_geometry,...
    'uilist',help_button_list,'title',panel_title,'geomvert',help_button_vert_geometry,'minwidth',win_width,...
    'tag','pre_proc_help');
    
end
end