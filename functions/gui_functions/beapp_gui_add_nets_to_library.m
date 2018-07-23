% gui wrapper for adding nets to net library

function beapp_gui_add_nets_to_library(grp_proc_info_in,net_disp_table_tag)

empty_10_cell = cell(10,1);
empty_10_cell(:) = deal({''});

button_list=[{{'style','text','string', ...
    'Enter exact names of new nets/sensor layouts to add below'}},...
    {{'style','uitable','data',empty_10_cell,'tag','new_net_name_table', ...
    'ColumnFormat',{'char'},'ColumnEditable',true,'ColumnName',{'SensorLayoutNames'}}}];

button_geometry = {1 1};
button_ver_geometry = [1 6];

scrsz = get(groot,'ScreenSize');
win_width = scrsz(3)/4;

% make figure for module advanced settings
[~, ~, strhalt_nets, resstruct_nets, ~] = inputgui_mod_for_beapp('geometry',button_geometry ,...
    'uilist',button_list,'title','Add New Sensor Layouts','geomvert',button_ver_geometry,'minwidth',win_width,...
    'tag','new_net_add_fig');

% if user saves the inputs
if ~strcmp (strhalt_nets,'')
    
    % delete empty rows
    non_empty_inds = cellfun(@ (x) ~isempty(x),resstruct_nets.new_net_name_table.data(:,1),'UniformOutput',1);
    if any (non_empty_inds)
        net_list = resstruct_nets.new_net_name_table.data(non_empty_inds,1);
        
        % call net adding function
        netmenuoptions = add_nets_to_library(net_list,grp_proc_info_in.ref_net_library_options,...
            grp_proc_info_in.ref_net_library_dir, grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);
            set(findobj('tag',net_disp_table_tag),'ColumnFormat',{netmenuoptions'});
    else
        warndlg('No sensor layout names entered, no sensor layouts added to library');
    end
end


    