function beapp_gui_save_current_template(grp_proc_info)

[file_name,file_path] = uiputfile([grp_proc_info.ref_def_template_folder filesep '*.mat'],'Save Current BEAPP Run Template');


% if invalid file name or file not selected
if file_name == 0
    warndlg (['File not selected, BEAPP Template was not saved'],'BEAPP Template Save Error');
else
    save([file_path, file_name],'grp_proc_info');
end