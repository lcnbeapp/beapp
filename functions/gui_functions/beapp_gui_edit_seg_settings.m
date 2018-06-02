function grp_proc_info = beapp_gui_edit_seg_settings (grp_proc_info)

% globals -- will find a way to pass them automatically later
scrsz = get(groot,'ScreenSize');
win_width = scrsz(3)/4;

seg_sub_panel_ctr = 1;
show_back_button = 'off';
strhalt_seg_out = '';
skipline_panel = 'on';

% initialize available panels based on user data type selection (baseline,
% evt, conditioned baseline)
[seg_sub_panel_list, show_next_button] = adjust_seg_panel_list (grp_proc_info.src_data_type);

while ~strcmp(strhalt_seg_out,'returninginputui_done')
    
    current_sub_panel = seg_sub_panel_list{seg_sub_panel_ctr};
    
    [seg_button_list,seg_button_geometry,seg_ver_geometry,skipline_panel] = beapp_gui_seg_subfunction_prep (current_sub_panel,grp_proc_info);
    
    [~, ~, strhalt_seg, resstruct_seg_settings, ~] = inputgui_mod_for_beapp('geometry',seg_button_geometry ,...
        'uilist',seg_button_list,'minwidth',win_width,'nextbutton',show_next_button,'backbutton',show_back_button,...
        'title','BEAPP Segmentation Settings','geomvert',seg_ver_geometry,'skipline',skipline_panel);
    
    if ~strcmp (strhalt_seg,'')
        grp_proc_info = beapp_gui_seg_subfunction_save_inputs (current_sub_panel,resstruct_seg_settings,grp_proc_info);
    end
        
    % change available panels based on user data type selection
    if seg_sub_panel_ctr ==1
        [seg_sub_panel_list, show_next_button] = adjust_seg_panel_list (grp_proc_info.src_data_type);
    end
    
    [strhalt_seg_out, seg_sub_panel_ctr, show_back_button, show_next_button] =...
        beapp_gui_navigate_subpanels(strhalt_seg, seg_sub_panel_ctr,length(seg_sub_panel_list));
end
end

function [seg_sub_panel_list, show_next_button] = adjust_seg_panel_list (src_data_type)
    % change available panels based on user data type selection
        switch src_data_type
            case 1 % baseline
                seg_sub_panel_list = {'seg_general','seg_baseline'};
            case 2 % event-related
                seg_sub_panel_list = {'seg_general', 'seg_evt_stm_on_off_info','seg_evt_condition_codes'};
            case 3 % conditioned baseline
                seg_sub_panel_list = {'seg_general', 'seg_evt_stm_on_off_info', 'seg_evt_condition_codes'};
        end
        
        if length(seg_sub_panel_list) ==1
            show_next_button = 'off';
        else
            show_next_button = 'on';
        end
end