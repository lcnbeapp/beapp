function beapp_happe_V3_module_warning(toggle_mods)
repeating_mods = {'filt','rsamp','ica','rereference','segment'};
warning_dialogs = {'filtering','rsampling','artifact detection','rereferencing','segmenting'};
warning_message = [];
repeated_mods = [];
for mod = 1:length(repeating_mods)
    if toggle_mods{repeating_mods{mod},'Module_On'} && toggle_mods{'HAPPE_V3','Module_On'}
        if isempty(warning_message)
            warning_message = [warning_message, warning_dialogs{mod}];
        repeated_mods = [repeated_mods, repeating_mods{mod}];
        else
        warning_message = [warning_message, ',', warning_dialogs{mod}];
        repeated_mods = [repeated_mods, ',', repeating_mods{mod}];
        end
    end
end
if ~isempty(warning_message)
    usr_cont = questdlg(['WARNING: You have turned on the following modules:';[{repeated_mods}];'but HAPPE V3 may also use';[{warning_message}];' methods on the data';
        'Do you want to continue processing and repeat these steps or stop and adjust inputs?';...
      ],'HAPPE V3 Directory Warning','Yes Continue','No Go back and adjust inputs','Yes Continue');
        if strcmp('Yes Continue',usr_cont)
            disp(sprintf(' \n Continuing with pipeline. '));
        elseif  strcmp('No Go back and adjust inputs',usr_cont)
            error('User did not proceed with run, exiting BEAPP'); 
        end
end
% if~isempty(warning_message)
%     warning('WARNING: You have turned on the following modules: %s \n but HAPPE V3 may also use %s methods on the data',repeated_mods,warning_message)
%     fprintf('Do you want to continue processing and repeat these steps or stop and adjust inputs? \n Y/N \n');
%     while true
%         keep_going = input('> ', 's') ;
%         if strcmpi(keep_going, 'N'); error('Exiting BEAPP: Please Update User Inputs and Turn off relevant modules') ;
%         elseif strcmpi(keep_going, 'Y'); break ;
%         else; fprintf("Invalid input: please enter %s or %s\n", 'Y', 'N') ;
%         end
%     end
    
end
