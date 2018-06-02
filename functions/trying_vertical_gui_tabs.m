function grp_proc_info_in = trying_vertical_gui_tabs(grp_proc_info_in)

front_panel_color =  [0.8590, 1.0000, 1.0000]; % teal
tab_color =  [0.6000    0.8000    1.0000]; % light blue
tab_labels = {'General'; 'Pre-Process'; 'Segment'; 'Output'; 'Graphics'};
ntabs = length(tab_labels);

scrsz = get(groot,'ScreenSize');
screen_width = scrsz(3);
screen_height = scrsz(4);
clear scrsz