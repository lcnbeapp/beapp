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

src_dir = find_input_dir('new_module',grp_proc_info_in.beapp_toggle_mods);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
  
    cd(src_dir{1});
    
      if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
         
         % load eeg if module takes continuous input
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg_w','file_proc_info');

        
        %% // YOUR CODE HERE//
        
   
        
        
        
        
        
        %% save and update file history
        cd(grp_proc_info_in.beapp_toggle_mods{'new_module','Module_Dir'}{1});
        
        if ~all(cellfun(@isempty,eeg_w))
            file_proc_info = beapp_prepare_to_save_file('new_module',file_proc_info, grp_proc_info_in, src_dir{1});
            save(file_proc_info.beapp_fname{1},'eeg_w','file_proc_info');
        end
        
        clearvars -except grp_proc_info_in src_dir curr_file
      end
end
