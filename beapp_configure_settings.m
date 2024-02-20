%% beapp_configure_settings
%  
% load user settings from default inputs or user set files, load tables
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C) 2015, 2016, 2017
% Authors: AR Levin, AS Méndez Leal, LJ Gabard-Durnam, HM O'Leary
% 
% This software is being distributed with the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU General
% Public License for more details.
% 
% In no event shall Boston Children’s Hospital (BCH), the BCH Department of
% Neurology, the Laboratories of Cognitive Neuroscience (LCN), or software 
% contributors to BEAPP be liable to any party for direct, indirect, 
% special, incidental, or consequential damages, including lost profits, 
% arising out of the use of this software and its documentation, even if 
% Boston Children’s Hospital,the Laboratories of Cognitive Neuroscience, 
% and software contributors have been advised of the possibility of such 
% damage. Software and documentation is provided “as is.” Boston Children’s 
% Hospital, the Laboratories of Cognitive Neuroscience, and software 
% contributors are under no obligation to provide maintenance, support, 
% updates, enhancements, or modifications.
% 
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License (version 3) as
% published by the Free Software Foundation.
% 
% You should receive a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function grp_proc_info = beapp_configure_settings
grp_proc_info = set_beapp_def;
grp_proc_info = set_beapp_path (grp_proc_info);
beapp_set_input_file_locations;

% get basic user inputs from default or user specified location
if strcmp(grp_proc_info.beapp_alt_user_input_location{1},'')
    beapp_userinputs;
else
    [filepath,input_script_name] = fileparts(grp_proc_info.beapp_alt_user_input_location{1}); %RL edit
    eval(fullfile(filepath, input_script_name)); clear input_script_name; %RL edit added fullfile()
end

% get advanced user inputs from default or user specified location
if grp_proc_info.beapp_advinputs_on
    if strcmp(grp_proc_info.beapp_alt_adv_user_input_location{1},'')
        beapp_advinputs;
    else
        [~,adv_input_script_name] = fileparts(grp_proc_info.beapp_alt_adv_user_input_location{1});
        eval(adv_input_script_name);clear adv_input_script_name;
    end
end

% get mat file user inputs from default or user specified location
if ~strcmp(grp_proc_info.beapp_alt_beapp_file_info_table_location{1},'')
    grp_proc_info.beapp_file_info_table = grp_proc_info.beapp_alt_beapp_file_info_table_location{1};
end
     
% get rerun file sub-selection user from default or user specified location
if ~strcmp (grp_proc_info.beapp_alt_rerun_file_info_table_location{1},'')
    grp_proc_info.rerun_file_info_table = grp_proc_info.beapp_alt_rerun_file_info_table_location{1};
end 
