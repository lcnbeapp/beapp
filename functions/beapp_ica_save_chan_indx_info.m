%% beapp_ica_save_chan_indx_info
%
% save channels to run ICA on after HAPPE channel rejection, depending on
% user settings to interpolate or remove bad channels in HAPPE
%
% Inputs:
% beapp_rmv_bad_chan_on: user setting from grp_proc_info, 0=interpolate bad
% chans after ICA, 1 : NaNs in bad channels after ICA
% ica_report_struct : structure containing report values
% curr_rec_period: current recording period/epoch
% full_selected_channels : EEGLAB chanlocs struct before HAPPE bad channel
% detection
% curr_eeg_tmp_labels : labels for channels being used after channel rejection, if chosen 
%
% Outputs:
% chan_name_dict : channel label and index dictionary for channels kept
% ica_report_struct : structure containing report values
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

function [ica_report_struct,file_proc_info,chan_name_indx_dict] = beapp_ica_save_chan_indx_info...
    (beapp_rmv_bad_chan_on, file_proc_info, full_selected_channels,curr_EEG_tmp_labels,ica_report_struct,curr_rec_period)

if beapp_rmv_bad_chan_on
    [chan_name_indx_dict(:,1), file_proc_info.beapp_indx{curr_rec_period}] = intersect({file_proc_info.net_vstruct.labels},curr_EEG_tmp_labels,'stable');
else
    [chan_name_indx_dict(:,1), file_proc_info.beapp_indx{curr_rec_period}] = intersect({file_proc_info.net_vstruct.labels},{full_selected_channels.labels},'stable');
end

% save reporting information
ica_report_struct.good_chans_per_rec_period(curr_rec_period) = length(curr_EEG_tmp_labels);
ica_report_struct.rec_period_lengths_in_secs(curr_rec_period) = (length(eeg{curr_rec_period})/file_proc_info.beapp_srate);
ica_report_struct.num_interp_per_rec_period(curr_rec_period) = length(chan_IDs) - length(curr_EEG_tmp_labels);

file_proc_info.beapp_nchans_used(curr_rec_period) = length(file_proc_info.beapp_indx{curr_rec_period});
chan_name_indx_dict(:,2) = num2cell(file_proc_info.beapp_indx{curr_rec_period});
[~,ind_marked_bad_chans]= intersect({file_proc_info.net_vstruct.labels},setdiff({full_selected_channels.labels},curr_EEG_tmp_labels),'stable');
file_proc_info.beapp_bad_chans{curr_rec_period} = unique([file_proc_info.beapp_bad_chans{curr_rec_period} ind_marked_bad_chans]);