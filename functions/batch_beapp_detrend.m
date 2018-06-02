%% batch_beapp_detrend (grp_proc_info_in)
%
% detrend the data using an mean, linear, or Kalman filter detrend.
% Takes the BEAPP grp_proc_info structure.
% uses the KalEM1d_Estep function written by Demba Ba for the Kalman filter
%
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
function grp_proc_info_in = batch_beapp_detrend (grp_proc_info_in)

src_dir = find_input_dir('detrend',grp_proc_info_in.beapp_toggle_mods);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1});
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        tic;
        for curr_epoch = 1:size(eeg,2)
            
            % apply selected detrend to each epoch
            switch grp_proc_info_in.dtrend_typ
                
                % mean detrend
                case 1
                    for curr_chan=1:size(eeg{curr_epoch},1)
                        eeg{curr_epoch}(curr_chan,:)=detrend_biosig_nan(eeg{curr_epoch}(curr_chan,:),'constant');
                    end
                    
                    % linear detrend
                case 2
                    for curr_chan=1:size(eeg{curr_epoch},1)
                        eeg{curr_epoch}(curr_chan,:)=detrend_biosig_nan(eeg{curr_epoch}(curr_chan,:),'linear');
                    end
                    
                    % Kalman
                case 3
                    [eeg{curr_epoch},file_proc_info.ktrend{curr_epoch}]=dtrend_eeg(eeg{curr_epoch},grp_proc_info_in.dtrend_typ,grp_proc_info_in.kalman_q_init,grp_proc_info_in.kalman_b);
            end
        end
        
        if ~all(cellfun(@isempty,eeg))
            file_proc_info = beapp_prepare_to_save_file('detrend',file_proc_info, grp_proc_info_in, src_dir{1});
            save(file_proc_info.beapp_fname{1},'eeg','file_proc_info');
        end
        clearvars -except grp_proc_info_in curr_file src_dir
    end
end

