function beapp_happe_er_module_warning(toggle_mods)
repeating_mods = {'filt','rsamp','ica','rereference','segment'};
warning_dialogs = {'filtering','rsampling','artifact detection','rereferencing','segmenting'};
warning_message = [];
repeated_mods = [];
for mod = 1:length(repeating_mods)
    if toggle_mods{repeating_mods{mod},'Module_On'} && toggle_mods{'HAPPE+ER','Module_On'}
        if isempty(warning_message)
            warning_message = [warning_message, warning_dialogs{mod}];
        repeated_mods = [repeated_mods, repeating_mods{mod}];
        else
        warning_message = [warning_message, ',', warning_dialogs{mod}];
        repeated_mods = [repeated_mods, ',', repeating_mods{mod}];
        end
    end
end

if~isempty(warning_message)
    warning('WARNING: You have turned on the following modules: %s \n but HAPPE+ER may also use %s methods on the data',repeated_mods,warning_message)
    fprintf('Do you want to continue processing and repeat these steps or stop and adjust inputs? \n Y/N \n');
    while true
        keep_going = input('> ', 's') ;
        if strcmpi(keep_going, 'N'); error('Exiting BEAPP: Please Update User Inputs and Turn off relevant modules') ;
        elseif strcmpi(keep_going, 'Y'); break ;
        else; fprintf("Invalid input: please enter %s or %s\n", 'Y', 'N') ;
        end
    end
    
end
end