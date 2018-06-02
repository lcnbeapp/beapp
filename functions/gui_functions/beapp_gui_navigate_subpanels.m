function [strhalt_mod_out, sub_panel_ctr, show_back_button, show_next_button] = ...
    beapp_gui_navigate_subpanels(strhalt_mod_in, sub_panel_ctr,max_sub_panels)

% navigate within panels
switch strhalt_mod_in
    case 'retuninginputui'
        strhalt_mod_out = 'returninginputui_done';
    case 'retuninginputui_back'
        sub_panel_ctr = sub_panel_ctr-1;
        
        strhalt_mod_out = strhalt_mod_in;
    case 'retuninginputui_next'
        sub_panel_ctr = sub_panel_ctr+1;       
        strhalt_mod_out = strhalt_mod_in;
    case 'refreshinputui'
        % keep ctr the same
        strhalt_mod_out = strhalt_mod_in;
    case ''
        % save and close
        strhalt_mod_out = 'returninginputui_done';
end

if sub_panel_ctr ==1
    show_back_button = 'off';
else
    show_back_button = 'on';
end
if sub_panel_ctr == max_sub_panels
    show_next_button = 'off';
else
    show_next_button = 'on';
end
end