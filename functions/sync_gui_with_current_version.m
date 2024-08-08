function [grp_proc_info] = sync_gui_with_current_version(grp_proc_info)
%Provide backwards compatibility for beapp gui users who created/are using run templates during older versions of beapp


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



% Back Compatability for field update beapp_itpc_params --> beapp_itpc_ersp_params change
if isfield(grp_proc_info,'beapp_itpc_params')
    if ~isfield(grp_proc_info,'beapp_itpc_ersp_params')
        warning(sprintf(['Old run template field "beapp_itpc_params" detected instead of new field "beapp_itpc_ersp_params", BEAPP will overwrite beapp_itpc_ersp_params and remove old fields']))
        grp_proc_info.beapp_itpc_ersp_params = grp_proc_info.beapp_itpc_params;
    else
        overlapped_fields = intersect(fields( grp_proc_info_in.beapp_itpc_ersp_params),fields( grp_proc_info.beapp_itpc_params));
        fields_to_update = overlapped_fields(cellfun(@(x) ~isequal(grp_proc_info.beapp_itpc_ersp_params.(x),grp_proc_info.beapp_itpc_params.(x)),overlapped_fields));
        warning(sprintf(['Old run template field "beapp_itpc_params" detected with conflicting values from new fields "beapp_itpc_ersp_params", BEAPP will overwrite beapp_itpc_ersp_params and remove old fields:\n', repmat('''%s''\n', 1, numel(fields_to_update))] ,fields_to_update{:}))
        for i_f = 1:length(fields_to_update)
            grp_proc_info.beapp_itpc_ersp_params.(fields_to_update{i_f}) = grp_proc_info.beapp_itpc_params.(fields_to_update{i_f});
        end
    end
    grp_proc_info = rmfield(grp_proc_info,'beapp_itpc_params');
end