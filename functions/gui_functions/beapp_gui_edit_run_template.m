function grp_proc_info = beapp_gui_edit_run_template (new_or_existing_run)

% check if main menu is open elsewhere, close old instances
template_handle = findobj('tag','beapp_edit_template_figure');
if ~isempty(template_handle)
    warning('BEAPP GUI: only one template window can be edited at a time. Closing existing template window.');
    close(template_handle);
end

% if new run, fill in template with defaults, otherwise load previous
% template
if strcmp(new_or_existing_run,'new')
    % set defaults and default path
    grp_proc_info = set_beapp_def;
    grp_proc_info = set_beapp_path(grp_proc_info);
elseif strcmp(new_or_existing_run,'existing')
    
    [load_template_file,load_template_path] = uigetfile(['~'   [fileparts(which('set_beapp_def.m')) filesep, 'run_templates']  filesep '*.mat'],'Select Existing BEAPP Template to Use');
    
    if ~(load_template_path==0)
    load([load_template_path,filesep,load_template_file],'grp_proc_info');
    grp_proc_info = reset_beapp_path_defaults(grp_proc_info); % update paths for current computer
    grp_proc_info = set_beapp_path(grp_proc_info);
    grp_proc_info = sync_beapp_toggle_mods(grp_proc_info); % backwards compatibility for old gui runs, 
    else 
        warndlg('No template was selected, please select a template to load or create a new template');
    end
end

% create and name figure
beapp_et_menu = figure('Visible','off','Name','BEAPP Run Template','tag','beapp_edit_template_figure');

% spacer for formatting in supergui
extra_space_line = {{'style','text','string',''}};

% menu header
beapp_et_menu_header = {{'style','text','string', 'General BEAPP User Settings:','tag','Header_et_template',...
    'userdata','','FontSize',45,'horizontalalignment','center'}};

% src directory selection list
src_dir_select_list = ...
    [{{'style','text','string', 'BEAPP Source Directory: '}},...
    {{'style','pushbutton','string', 'Select Directory ','tag','select_src_button','userdata','','horizontalalignment','left','CallBack',...
    'grp_proc_info.src_dir = beapp_gui_select_src_directory(grp_proc_info.src_dir,''src_dir_show_field''); '}},...
    {{'style','text','string', sprintf(['Currently selected directory: ' '\n' strrep(grp_proc_info.src_dir{1},'\','\\')]),'tag','src_dir_show_field'}}];

% run tag prompt and response list
gen_set_el_list = [{{'style','text','string','Current BEAPP Run Tag (ex. proj_expname_date):'}},...
    {{'style','edit','string',grp_proc_info.beapp_curr_run_tag,'tag','curr_run_tag_resp','Callback',['grp_proc_info.beapp_curr_run_tag',...
    '= get(findobj(''tag'',''curr_run_tag_resp''),''String'');']}},...
    {{'style','text','string','Previous BEAPP Run Tag (for Re-Runs, see guide):'}},...
    {{'style','edit','string',grp_proc_info.beapp_prev_run_tag,'tag','prev_run_tag_resp',...
    'Callback','grp_proc_info.beapp_prev_run_tag = get(findobj(''tag'',''prev_run_tag_resp''),''String'');'}}];

% options for additional parameters
et_menu_add_option_list = {'Format and Pre-Processing', 'Segmentation','Output Modules'};
et_menu_add_callback_list = {'beapp_gui_edit_pre_proc_settings',...
    'beapp_gui_edit_seg_settings','beapp_gui_edit_output_mod_settings'};

et_add_on_button_list = cellfun(@ (x,y) {'style','pushbutton','string', x, 'tag', regexprep(x, '\s+', ''),...
    'userdata','edit_run_temp_buttons','CallBack',['grp_proc_info = ' y '(grp_proc_info);' ]},...
    et_menu_add_option_list, et_menu_add_callback_list,'UniformOutput',0);

% run, save and cancel options
general_option_list = [{{'style','pushbutton','string','Cancel',...
    'CallBack', 'close(findobj(''tag'',''beapp_edit_template_figure'')); clear grp_proc_info;'}},...
    {{'style','pushbutton','string','Save Current Run Template',...
    'CallBack', 'beapp_gui_save_current_template(grp_proc_info);'}},...
    extra_space_line,{{'style','pushbutton','string','Run BEAPP','CallBack','beapp_main(grp_proc_info);'}}];

% put all buttons together with extra spacing
et_button_list = horzcat(beapp_et_menu_header,extra_space_line,...
    src_dir_select_list,gen_set_el_list,extra_space_line,...
    {{'style','pushbutton','string','Adv. General Settings','CallBack',...
    'grp_proc_info = beapp_gui_set_adv_gen_settings(grp_proc_info);'}},...
    extra_space_line,et_add_on_button_list,extra_space_line,...
    general_option_list);

% set number of elements in each row and row
et_button_geometry = {1 1 [.6 .4] 1   1 1 1 1 [.3 .3] 1 1 1 1 1 [.3 .7] 1 1} ;
          geomvert = [1 1 1       2   1 1 1 1 1       1 1 1 1       1 1 1 2]; % set row heights
          
% make main figure
[handlers_et, outheight_et, allhandlers_et] = supergui_mod_for_beapp('fig',beapp_et_menu,...
    'geomhoriz', et_button_geometry,'geomvert',geomvert,'uilist',...
    et_button_list,'adjustbuttonwidth','off');

end
