%% beapp_extract_segments
%
% pull out good segments after pre-segmentation baseline artifact masking
% Inputs:
% eeg_msk:  binary mask generate based on user amplitude and percent bad
% channel thresholds
%
% Outputs:
% tmp_eeg_w = segments for current epoch/recording period
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
function tmp_eeg_w = beapp_extract_segments(eeg_msk_curr_cond_curr_epoch,file_proc_info,grp_proc_info_in,eeg_curr_epoch)

            % find indices where data hasn't been flagged bad
            good_data_inds=find(eeg_msk_curr_cond_curr_epoch==0);
            grouped_good_data=group(good_data_inds); 
            clear tmpf1;
            
            %check if there is a long enough period of good data to use for
            %analysis
            segment_num=1;
            tmp_eeg_w = [];
            for curr_contig_good_per=1:length(grouped_good_data)
                local_good_data_inds=grouped_good_data{curr_contig_good_per};
                
                 %confirm that there are at least nsecs of data available
                if length(local_good_data_inds)>=file_proc_info.beapp_win_size_in_samps
                    
                   
                    pot_good_windows=floor(length(local_good_data_inds)/(file_proc_info.beapp_win_size_in_samps));
                    
                    if pot_good_windows>0
                        
                        %loop through each of the possible analysis windows and add
                        %them to eeg_w a three dimensional EEG
                        for curr_window=1:pot_good_windows
                            window_idxs=(1:floor(file_proc_info.beapp_srate*grp_proc_info_in.win_size_in_secs))+floor(file_proc_info.beapp_srate*grp_proc_info_in.win_size_in_secs)*(curr_window-1);
%                             
%                             tmp_wind_out=eeg_curr_epoch(:,local_good_data_inds(window_idxs))';
%                             wind_out=detrend(tmp_wind_out,'constant');
%                             tmp_eeg_w(:,:,segment_num)=wind_out';
                            
                             tmp_eeg_w(:,:,segment_num)=eeg_curr_epoch(:,local_good_data_inds(window_idxs));
                          
                            segment_num=segment_num+1;
                            
                            clear tmp_wind_out window_idxs wind_out
                        end
                        clear curr_window;
                    else
                        tmp_eeg_w =[];
                    end
                end
                
            end