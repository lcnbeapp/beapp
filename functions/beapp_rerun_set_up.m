%% beapp_rerun_setup 
% 
% prepare to run re-run (format module off), collect list of file names to
% run, unique net information in dataset (net type etc), load nets
% Inputs and outputs all correspond to grp_proc_info structure:
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
function [beapp_fname_all,src_unique_net_vstructs,unique_net_types,src_unique_net_ref_rows,src_net_10_20_elecs,largest_nchan] =...
    beapp_rerun_set_up(beapp_toggle_mods, first_module_on,rerun_fselect_table_str,beapp_use_rerun_table,unique_net_types,...
    ref_net_library_options,ref_net_library_dir,run_per_file,file_idx,happe_er_reprocessing)

% find first module on in this run
first_src_dir = find_input_dir(first_module_on,beapp_toggle_mods,happe_er_reprocessing);

if isempty(first_src_dir{1})
    error(['No appropriate source files found for first module flagged on (' first_module_on '), please check source directories and data types']);
else
    cd(first_src_dir{1})
    src_dir_flist = dir('*.mat');
    src_dir_flist = {src_dir_flist.name};
    
    % use rerun file selection list if the user has one
    if beapp_use_rerun_table || run_per_file
        
        % get group information for files in both user input table and source directory
        load(rerun_fselect_table_str);
        if run_per_file
           rerun_fselect_table = rerun_fselect_table(file_idx,:);
        end
        [beapp_fname_all,indexes_in_table] = intersect(rerun_fselect_table.FileName,src_dir_flist);
        beapp_fname_all= beapp_fname_all';
        if isempty(unique_net_types{1})
            if  ismember('NetType', rerun_fselect_table.Properties.VariableNames);
                unique_net_types = unique(rerun_fselect_table.NetType(indexes_in_table));
            end
        end
    else
        beapp_fname_all=src_dir_flist;
    end
    
    % get net types if not in user inputs or rerun table
    if isempty(unique_net_types{1})
        for curr_file = 1:length(beapp_fname_all)
            load(beapp_fname_all{curr_file},'file_proc_info');
            src_net_type_all(curr_file)= file_proc_info.net_typ;
        end
        unique_net_types= unique(src_net_type_all);
    end
    
    % save nets in dataset into grp_proc_info for easy access
    [src_unique_net_vstructs,src_unique_net_ref_rows,src_net_10_20_elecs,largest_nchan] = load_nets_in_dataset(unique_net_types,ref_net_library_options,ref_net_library_dir);
end