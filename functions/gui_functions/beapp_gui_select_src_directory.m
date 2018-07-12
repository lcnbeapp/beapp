function [src_dir] =  beapp_gui_select_src_directory (src_dir,show_field_tag)

if ~isempty(src_dir)
    open_dialog_at_dir = src_dir{1};
else
    [beapp_folder_path,~] = fileparts(which('beapp_gui.m'));
    open_dialog_at_dir = beapp_folder_path;
end

src_dir = {uigetdir(open_dialog_at_dir)};

if isequal({[0]},src_dir)
    warndlg('No source directory selected. Please choose the directory where source files are located');
    src_dir = {''};
end
set(findobj('Tag',show_field_tag),'string',...
    sprintf(['Currently selected directory: ' '\n' strrep(src_dir{1},'\','\\')]));

end