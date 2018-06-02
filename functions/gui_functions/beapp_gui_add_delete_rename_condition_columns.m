function beapp_gui_add_delete_rename_condition_columns (seg_evt_table,add_del_ren)
scrsz = get(groot,'ScreenSize');
win_width = scrsz(3)/4;

switch add_del_ren
    case 'add'
        
        empty_10_cel = cell(10,1);
        empty_10_cel(:) = deal({''});
        seg_opt_button_list = [{{'style','text','string','Enter Names of Conditions to Add Below'}},...
            {{'style','uitable','data',  empty_10_cel,'tag','seg_evt_tag_table_cond_add', ...
            'ColumnFormat',{'char'},'ColumnEditable',[true],'ColumnName','New Conditions'}}];
        seg_opt_button_geometry = {1 1};
        seg_opt_ver_geometry=  [1 5];
        
    case 'delete'
        seg_opt_button_list = [{{'style','text','string','Delete Segment Conditions'}},...
            {{'style','listbox', 'string', seg_evt_table.ColumnName,'max',100,'min',1,'tag','seg_evt_tag_table_cond_del_select'}}];
        seg_opt_button_geometry = {1 1};
        seg_opt_ver_geometry=  [1 5];
        
    case 'rename'
        
        all_condition_names = horzcat(seg_evt_table.ColumnName,seg_evt_table.ColumnName);
        
        seg_opt_button_list = [{{'style','text','string','Rename Segment Conditions'}},...
            {{'style','uitable','data', all_condition_names,'tag','seg_evt_tag_table_cond_rename',...
            'ColumnFormat',{'char','char'},'ColumnEditable',[false true],...
            'ColumnName',{'Current_Condition_Names', 'Desired_Condition_Names'}}}];
        seg_opt_button_geometry = {1 1};
        seg_opt_ver_geometry=  [1 5];
        
end


[~, ~, strhalt_seg_opt_evt, resstruct_seg_opt_evt, ~] = inputgui_mod_for_beapp('geometry',seg_opt_button_geometry ,...
    'uilist',seg_opt_button_list,'popoutpanel',1,...
    'title','Rename Conditions for Segmentation','minwidth',win_width,...
    'geomvert',seg_opt_ver_geometry,'skipline','on','tag','seg_evt_cond_del_rename_add');

if ~isempty(strhalt_seg_opt_evt)
    
    seg_table_handle = findobj('tag','seg_evt_tag_table');
    
    switch add_del_ren
        case 'add'
            add_cond_names = resstruct_seg_opt_evt.seg_evt_tag_table_cond_add.data;
            add_cond_names(cellfun('isempty',add_cond_names)) = [];
            add_cond_formats = cell(1,length(add_cond_names));
            add_cond_formats(:) = deal({'numeric'});

            starter_data_to_add = cell(size(seg_table_handle.Data,1),length(add_cond_names));
            seg_table_handle.Data = [seg_table_handle.Data,starter_data_to_add];
            seg_table_handle.ColumnName = [seg_table_handle.ColumnName; add_cond_names];
            seg_table_handle.ColumnFormat =[seg_table_handle.ColumnFormat,add_cond_formats];
            seg_table_handle.ColumnEditable= [seg_table_handle.ColumnEditable, true(length(add_cond_names))];
            
        case 'delete'
            seg_table_handle.ColumnName(resstruct_seg_opt_evt.seg_evt_tag_table_cond_del_select)=[];
            seg_table_handle.Data(:,resstruct_seg_opt_evt.seg_evt_tag_table_cond_del_select)=[];
            seg_table_handle.ColumnFormat(resstruct_seg_opt_evt.seg_evt_tag_table_cond_del_select)=[];
            seg_table_handle.ColumnEditable(resstruct_seg_opt_evt.seg_evt_tag_table_cond_del_select)=[];
            
        case 'rename'
            
            seg_table_handle.ColumnName = resstruct_seg_opt_evt.seg_evt_tag_table_cond_rename.data(:,2);
    end
end
