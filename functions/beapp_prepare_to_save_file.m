%% beapp_prepare_to_save_file
%
% update file history table, order file_proc_info fields
% Inputs:
% curr_mod: module name string from beapp_toggle_mods
% hist_run_tag: run timestamp, grp_proc_info.hist_run_tag
% curr_run_tag: grp_proc_info.curr_run_tag
% mod_input_dir: directory from previous module
% mod_output_dir: module output directory
% Mod_Names: all the module names (from beapp_toggle_mods)
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
function file_proc_info = beapp_prepare_to_save_file(curr_mod,file_proc_info, grp_proc_info_in, mod_input_dir)

% cd to output directory
cd(grp_proc_info_in.beapp_toggle_mods{curr_mod,'Module_Dir'}{1});

% version control -- if file run history table doesn't exist, create
if ~isfield(file_proc_info,'hist_run_table')
    file_proc_info.hist_run_table = beapp_init_file_hist_table(grp_proc_info_in.beapp_toggle_mods.Mod_Names);
end

%% update file run history table
run_time_for_file = toc;
file_proc_info.hist_run_table{curr_mod,{'Mod_Run','Mod_Run_Time_for_File'}} = [1,run_time_for_file];
file_proc_info.hist_run_table{curr_mod,{'Time_Run_Start','Curr_Run_Tag','Mod_Input_Dir','Mod_Output_Dir'}}...
    = {char(grp_proc_info_in.hist_run_tag),grp_proc_info_in.beapp_curr_run_tag,mod_input_dir,grp_proc_info_in.beapp_toggle_mods{curr_mod,'Module_Dir'}};

%TH
if strcmp(curr_mod,'pac') || strcmp(curr_mod,'itpc')
    if grp_proc_info_in.include_diagnosis
        diagnosis_folder=grp_proc_info_in.diagnosis_map{([grp_proc_info_in.diagnosis_map{:,[1]}]==file_proc_info.diagnosis),2};
        if exist(fullfile(cd,diagnosis_folder),'file')==0
            mkdir(cd,diagnosis_folder);
        end
        cd(fullfile(cd, diagnosis_folder));
    end
end

% order fields
file_proc_info = orderfields(file_proc_info);
