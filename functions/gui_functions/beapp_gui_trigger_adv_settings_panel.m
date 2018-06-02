function beapp_gui_trigger_adv_settings_panel
%set(findobj('tag', 'ok'), 'userdata','refreshinputui');
%waitfor(findobj('tag', 'ok'), 'userdata');

set(findobj('tag', 'ok'), 'userdata','adv_settings_panel');
end