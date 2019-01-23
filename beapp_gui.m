function varargout = beapp_gui
% a preliminary gui for BEAPP:

%% make main window
% will need to add path checking, check for previous BEAPP figures 

addpath(genpath([fileparts(mfilename('fullpath')) filesep 'functions' filesep 'gui_functions']));
addpath(genpath([fileparts(mfilename('fullpath')) filesep 'functions' filesep 'reference_data']));
addpath(genpath([fileparts(mfilename('fullpath')) filesep 'functions' filesep 'run_templates']));

main_menu_option_list = {'Create New Run Template', 'Load Existing Run Template', 'Documentation','Graphics (To Come)','Extras (To Come)'};
main_menu_callback_list = {'grp_proc_info = beapp_gui_create_new_run_template;',...
    'grp_proc_info = beapp_gui_load_run_template;','beapp_get_docs;','beapp_graphics;','beapp_extras;'};

main_menu_handle = findobj('tag','beapp_main_menu_figure');
if ~isempty(main_menu_handle)
    warning('BEAPP GUI: only one instance of BEAPP can be edited at a time. Closing old BEAPP windows.');     
    close(main_menu_handle);
    
    run_template_handle = findobj('tag','beapp_main_menu_figure');
    if ~isempty(run_template_handle)
        close(run_template_handle);
    end
   
end;

%  Create and then hide the UI as it is being constructed.
beapp_main_menu = figure('Visible','off','Name','BEAPP','tag','beapp_main_menu_figure');

button_list = cellfun(@ (x,y) {'style','pushbutton','string', x, 'tag', regexprep(x, '\s+', ''),...
    'userdata','main_menu_buttons','CallBack',y},...
    main_menu_option_list, main_menu_callback_list,'UniformOutput',0);

button_geometry = cellfun(@ (x) {1}, main_menu_option_list,'UniformOutput',1);

[handlers, outheight, allhandlers] = supergui_mod_for_beapp('fig',beapp_main_menu,...
    'geomhoriz', button_geometry,'geomvert',ones(1,length(button_geometry)),'uilist', button_list,'adjustbuttonwidth','on',...
   'horizontalalignment','left');

end
