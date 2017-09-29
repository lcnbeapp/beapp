%% batch_beapp_rereference (grp_proc_info_in)
% 
% rereference the data using an average, Laplacian, or single electrode
% reference. Takes the BEAPP grp_proc_info structure. 
% Uses the eeglab function pop_reref and the CSD Laplacian Toolbox
% developed by Kayser and Tenke (2006) 
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

function batch_beapp_rereference(grp_proc_info_in)

src_dir = find_input_dir('rereference',grp_proc_info_in.beapp_toggle_mods);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1});
    
    if exist(grp_proc_info_in.beapp_fname_all{curr_file},'file')
        
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        tic;
        for curr_epoch = 1:size(eeg,2)
            
            % average rereferencing
            switch  grp_proc_info_in.reref_typ
                
                % average reference
                case 1
                    diary off;
                    
                    % temporary fix -- ignore channels not in beapp_indx
                    EEG_tmp =curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_epoch},curr_epoch);
                    chans_exclude = setdiff([1:file_proc_info.src_nchan],file_proc_info.beapp_indx{curr_epoch});
                    
                    EEG_tmp = pop_reref(EEG_tmp, [],'exclude',chans_exclude);
                    diary on;
                    eeg{curr_epoch} = EEG_tmp.data;
                    
                    clear EEG_tmp chans_exclude
                
                % CSD Laplacian    
                case 2
                    % switch coords into "EGI" space to be compatible with CSD toolbox
                    % done repeatedly to allow channel selection to vary by epoch
                    csdlp_formatted_montage = calc_CSDLP_toolbox_coordinates (file_proc_info,curr_epoch);
                    
                    % get G and H matrices, apply CSDLP
                    [G,H]=GetGH(csdlp_formatted_montage,grp_proc_info_in.beapp_csdlp_interp_flex);
                    eeg{curr_epoch}(file_proc_info.beapp_indx{curr_epoch},:)= CSD(eeg{curr_epoch}(file_proc_info.beapp_indx{curr_epoch},:),G,H,grp_proc_info_in.beapp_csdlp_lambda);
                
                case 3
                    % temporary fix -- ignore channels not in beapp_indx
                    diary off;
                    uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
                    file_proc_info.net_reref_chan_inds = grp_proc_info_in.beapp_reref_chan_inds{uniq_net_ind};
                    
                    EEG_tmp =curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_epoch},curr_epoch);
                    chans_exclude = setdiff([1:file_proc_info.src_nchan],file_proc_info.beapp_indx{curr_epoch});
                    EEG_tmp = pop_reref (EEG_tmp, [file_proc_info.net_reref_chan_inds], 'keepref', 'on'); 
                    diary on;
                    eeg{curr_epoch} = EEG_tmp.data;
                    clear EEG_tmp chans_exclude
                
            end
        end
        
        file_proc_info = beapp_prepare_to_save_file('rereference',file_proc_info, grp_proc_info_in, src_dir{1});
            
        if  grp_proc_info_in.reref_typ == 2
            save(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info','G','H');
        else 
            save(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        end
        clearvars -except grp_proc_info_in src_dir curr_file
    end
end
