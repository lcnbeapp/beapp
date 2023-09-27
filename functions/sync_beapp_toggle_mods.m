function [grp_proc_info] = sync_beapp_toggle_mods(grp_proc_info)
%Provide backwards compatibility for beapp gui users who created/are using run
%templates during older versions of beapp
%Checks which modules do not exist in current run template and updates
%them/turns them off
grp_proc_info_current = set_beapp_def;
%compare the beapp toggle mods for the latest version of beapp 
new_mods = setdiff(grp_proc_info_current.beapp_toggle_mods.Row,grp_proc_info.beapp_toggle_mods.Row);

for new_mod = 1:length(new_mods)
    mod = new_mods{new_mod};
    grp_proc_info.beapp_toggle_mods(mod,:) = grp_proc_info_current.beapp_toggle_mods(mod,:);
    grp_proc_info.beapp_toggle_mods{mod,'Module_On'} = 0;
end

end