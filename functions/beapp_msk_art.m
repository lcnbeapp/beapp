%% beapp_msk_art
%
% create binary mask for current recording period/epoch based on percent of
% channels for a given sample that are marked bad (above user amplitude threshold)
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
function [eeg_msk_curr_epoch_out,file_proc_info_in] = beapp_msk_art (eeg_curr_epoch, grp_proc_info_in,file_proc_info_in,curr_epoch)

% %create a mask that tags the artifact
% eeg_msk_curr_epoch_aug = beapp_detect_eeg_art(eeg_curr_epoch,file_proc_info_in.beapp_srate,grp_proc_info_in.art_thresh, file_proc_info_in.beapp_win_size_in_samps);
% 
% % tag buffer sections of data for removal
% if grp_proc_info_in.src_buff_start_nsec>0
%     eeg_msk_curr_epoch_aug(:,1:ceil(grp_proc_info_in.src_buff_start_nsec*file_proc_info_in.beapp_srate))=1;
% end
% 
% if grp_proc_info_in.src_buff_end_nsec>0
%     length_data_aug=size(eeg_msk_curr_epoch_aug,2);
%     end_buffer_start_samp_aug=(length_data_aug-ceil(file_proc_info_in.beapp_srate*grp_proc_info_in.src_buff_end_nsec)+1);
%     eeg_msk_curr_epoch_aug(:,end_buffer_start_samp_aug:length_data_aug)=1;
% end
% 
% % find periods with artifact in any channel
% eeg_msk_curr_epoch_aug=sum(eeg_msk_curr_epoch_aug);
% tmpf1=find(eeg_msk_curr_epoch_aug>0);
% eeg_msk_curr_epoch_aug(tmpf1)=1; clear tmpf1;

%create a mask that tags the artifact
eeg_msk_curr_epoch = beapp_detect_eeg_art(eeg_curr_epoch,file_proc_info_in.beapp_srate,...
    grp_proc_info_in.art_thresh, file_proc_info_in.beapp_win_size_in_samps);

% find periods with artifact in any channel
eeg_msk_curr_epoch=sum(eeg_msk_curr_epoch);

% if percentage thresholding
if grp_proc_info_in.beapp_baseline_msk_artifact ==2
    % percent of channels being analyzed that are bad
    eeg_msk_percent_bad_curr_epoch = (eeg_msk_curr_epoch/length(file_proc_info_in.beapp_indx{curr_epoch}))*100;
    
    % mark samples with more than percent threshold of channels above amplitude threshold
    idxs_above_thr=find(eeg_msk_percent_bad_curr_epoch >grp_proc_info_in.beapp_baseline_rej_perc_above_threshold);
    
% if one bad channel threshold    
elseif grp_proc_info_in.beapp_baseline_msk_artifact ==1    
    idxs_above_thr=find(eeg_msk_curr_epoch>0);
end

eeg_msk_curr_epoch_out = zeros(1,size(eeg_msk_curr_epoch,2));
eeg_msk_curr_epoch_out(1,idxs_above_thr)=1; clear tmpf1;

% tag buffer sections of data for removal
if grp_proc_info_in.src_buff_start_nsec>0
    eeg_msk_curr_epoch_out(:,1:ceil(grp_proc_info_in.src_buff_start_nsec*file_proc_info_in.beapp_srate))=1;
end

if grp_proc_info_in.src_buff_end_nsec>0
    length_data=size(eeg_msk_curr_epoch_out,2);
    end_buffer_start_samp=(length_data-ceil(file_proc_info_in.beapp_srate*grp_proc_info_in.src_buff_end_nsec)+1);
    eeg_msk_curr_epoch_out(:,end_buffer_start_samp:length_data)=1;
end

% isequal(eeg_msk_curr_epoch_out,eeg_msk_curr_epoch_aug)
% hi = 0;