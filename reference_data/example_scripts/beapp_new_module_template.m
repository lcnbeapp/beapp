%% beapp_new_module_template (grp_proc_info)
%
%  a template for new modules in BEAPP
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

function batch_beapp_new_module (grp_proc_info_in)

% get the source directory for module using the new module string
src_dir = find_input_dir('new_module',grp_proc_info_in.beapp_toggle_mods);

% loop through files 
for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
  
    % go to the source directory
    cd(src_dir{1});
    
    % load the file adn start the file timer if the file exists
      if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
         
         % load eeg if module takes continuous input
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg_w','file_proc_info');
        

        %% // YOUR CODE HERE//
        
        % apply your module process
        %
        % Note: you may also choose to use beapp_init_generic_analysis_report
        % and beapp_add_row_generic_analysis_report to generate BEAPP
        % format report values in the module (see batch_beapp_psd for an
        % example)
        
        % eeg_out = your_function_applied(eeg_w);
        
        
        %% save and update file history
        
        % if any of the cells in eeg_out have data
        if ~all(cellfun(@isempty,eeg_out))
            
            % stop the time tracking, cd to the out directory, and save file
            % history
            file_proc_info = beapp_prepare_to_save_file('new_module',file_proc_info, grp_proc_info_in, src_dir{1});
            
            % save the variables you want to keep
            save(file_proc_info.beapp_fname{1},'eeg_out','file_proc_info');
        end
        
        clearvars -except grp_proc_info_in src_dir curr_file
      end
end

% Note: you may choose to use mk_generic_analysis report (or a wrapper function, as with mk_psd_report)
% to generate BEAPP format report tables and outputs
