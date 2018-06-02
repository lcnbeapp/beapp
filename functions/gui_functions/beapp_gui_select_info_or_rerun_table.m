function [curr_table_loc] =  beapp_gui_select_info_or_rerun_table(curr_table_loc,show_field_tag)
[curr_table_name, pathname] = uigetfile(curr_table_loc);
curr_table_loc = fullfile(pathname, curr_table_name);
set(findobj('Tag',show_field_tag),'string',...
    sprintf([strrep(curr_table_loc,'\','\\')]));
end