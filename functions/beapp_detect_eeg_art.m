%% beapp_detect_eeg_art (eeg_in,srate,thr,win_size_in_samps)
%  
% generate mask for eeg in currend recording period by finding larger than
% threshold amplitudes, and marking bad until nearest zero crossings
% Inputs:
% eeg_in - eeg for current recording period
% srate = file_proc_info.beapp_srate
% thr = user set threshold 
% win_size_in_samps  = window size in samples (seconds*srate)
%
% Outputs:
% eeg_msk : chan x samples mask indicating which samples are in a  bad (marked 1) or good
% (marked 0) period between zero crossings in each channel.
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

% removes artifact above threshold, assumes detrending or highpass
function eeg_msk = beapp_detect_eeg_art(eeg_in,srate,thr,win_size_in_samps)

%% new mask function
% mark any data above threshold
eeg_above_thr=abs(eeg_in)>=thr;

% grab the channels and sample numbers for all zero crossing in the data
[channel_zero_crossing,sample_num_zero_crossing]= find(diff(sign(eeg_in)')' ~=0);

% initialize artifact mask as all good data
eeg_msk = zeros(size(eeg_in));

% mark channels with no 0 crossings as bad if they have artifact > threshold
% Reference channels usually have no crossings but also no artifact > thr
% chans_w_o_zeros = setdiff(1:size(eeg_in,1),unique(channel_zero_crossing));
% 
% if ~isempty(chans_w_o_zeros)
%     for curr_no_zero_channel = 1:length(chans_w_o_zeros)
%         
%         % mark whole channel (and so whole segment) bad
%         if any(eeg_above_thr(chans_w_o_zeros(curr_no_zero_channel),:))
%             eeg_msk (chans_w_o_zeros(curr_no_zero_channel),:)=1;
%         end
%     end
% end

% cycle through channels with 0s, mark periods b/t 0s bad if any artifact > thr     
chans_w_zeros = sort(unique(channel_zero_crossing));       
for curr_channel = 1:length(chans_w_zeros)
    
    channel_zeros_sample_nums = sort(sample_num_zero_crossing(channel_zero_crossing == chans_w_zeros(curr_channel)));
    
        for curr_zero_crossing = 1:length(channel_zeros_sample_nums)
            
            % check for artifact before first 0 crossing in this channel
            if curr_zero_crossing == 1
                if any(eeg_above_thr(chans_w_zeros(curr_channel),1:channel_zeros_sample_nums(curr_zero_crossing)))
                    eeg_msk(chans_w_zeros(curr_channel),1:channel_zeros_sample_nums(curr_zero_crossing)) = 1;
                end
            end 
            
            % check for artifact after last 0 crossing in this channel
            if curr_zero_crossing == length(channel_zeros_sample_nums)
                 if any(eeg_above_thr(chans_w_zeros(curr_channel),channel_zeros_sample_nums(curr_zero_crossing):end))
                    eeg_msk(chans_w_zeros(curr_channel),channel_zeros_sample_nums(curr_zero_crossing):end)=1;
                 end
                 
            % check for artifact between this 0 crossing and the next
            elseif any(eeg_above_thr(chans_w_zeros(curr_channel),channel_zeros_sample_nums(curr_zero_crossing):channel_zeros_sample_nums(curr_zero_crossing+1)))
                eeg_msk(chans_w_zeros(curr_channel),channel_zeros_sample_nums(curr_zero_crossing):channel_zeros_sample_nums(curr_zero_crossing+1)) = 1;
            end
        end
end

clearvars -except eeg_in srate thr win_size_in_samps eeg_msk
