%% beapp_calc_psd_output(grp_proc_info_in,file_proc_info,eeg_wfp_curr_cond,f,largest_nchan)
% 
% calculate report values for desired PSD metrics for a given condition
% Inputs:
% eeg_wfp_curr_cond - output from psd for current condition
% f - frequency bins 
% largest_nchan - largest number of channels in any net in dataset 
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
function psd_report_values=beapp_calc_psd_output(grp_proc_info_in,file_proc_info,eeg_wfp_curr_cond,f,largest_nchan)

% initialize variables and initialize report value array for file
col_ctr = 0;
psd_bw_name = [grp_proc_info_in.bw_name {'Total'}];
nstats =  grp_proc_info_in.beapp_xlsout_av_on +grp_proc_info_in.beapp_xlsout_sd_on + grp_proc_info_in.beapp_xlsout_med_on;
ndtyps =  grp_proc_info_in.beapp_xlsout_raw_on + grp_proc_info_in.beapp_xlsout_norm_on;
ntransfs = grp_proc_info_in.beapp_xlsout_log_on+grp_proc_info_in.beapp_xlsout_log10_on+1;
ntabs=nstats*ndtyps*ntransfs;
psd_report_values = NaN(1,(length(psd_bw_name))*(largest_nchan),ntabs);

% find indices in array for total frequencies selected by user
inds_freqs_in_total_range = beapp_get_inds_total_freqs (grp_proc_info_in.bw_total_freqs, f);
abs_total_pwr = sum(eeg_wfp_curr_cond(:,inds_freqs_in_total_range,:),2);

for curr_band=1:length(psd_bw_name)
    
    if curr_band<=size(grp_proc_info_in.bw,1)
        freqs_in_band_inds = find(f>=grp_proc_info_in.bw(curr_band,1)& f<=grp_proc_info_in.bw(curr_band,2));
    else
        freqs_in_band_inds = inds_freqs_in_total_range;
    end
    
    curr_tab=1; 
    
    % gives a channel x 1 (all freq of interest) x segment array
    abs_pwr_in_band_within_segments = sum(eeg_wfp_curr_cond(:,freqs_in_band_inds,:),2);
    
   % psd: average power in band/ normalized average power in band
    
    mean_pwr_per_hz_in_band_within_segs = abs_pwr_in_band_within_segments/(length(freqs_in_band_inds));
    total_pwr = abs_total_pwr;
   
    % mean power calculations
    if grp_proc_info_in.beapp_xlsout_av_on
        
        % user flagged mean raw power
        if grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= nanmean(mean_pwr_per_hz_in_band_within_segs,3);
            curr_tab= curr_tab+1;
        end
        
        % user flagged mean normalized power
        if grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= nanmean(abs_pwr_in_band_within_segments./total_pwr,3);
            curr_tab= curr_tab+1;
        end
        
        % user flagged mean log raw power
        if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log(nanmean(mean_pwr_per_hz_in_band_within_segs,3));
            curr_tab= curr_tab+1;
        end
        
        % user flagged mean log normalized power
        if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log(nanmean(mean_pwr_per_hz_in_band_within_segs./total_pwr,3));
            curr_tab= curr_tab+1;
        end
        
        % user flagged mean log10 raw power
        if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log10(nanmean(mean_pwr_per_hz_in_band_within_segs,3));
            curr_tab= curr_tab+1;
        end
        
         % user flagged mean log10 normalized power
        if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log10(nanmean(mean_pwr_per_hz_in_band_within_segs./total_pwr,3));
            curr_tab= curr_tab+1;
        end
    end
    
    % user flagged sd power calculations 
    if grp_proc_info_in.beapp_xlsout_sd_on
        
        % user flagged sd raw power
        if grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= nanstd(mean_pwr_per_hz_in_band_within_segs,0,3);
            curr_tab= curr_tab+1;
        end
        
        % user flagged sd normalized power
        if grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= nanstd(mean_pwr_per_hz_in_band_within_segs./total_pwr,0,3);
            curr_tab= curr_tab+1;
        end
        
        % user flagged sd log raw power
        if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log(nanstd(mean_pwr_per_hz_in_band_within_segs,0,3));
            curr_tab= curr_tab+1;
        end
        
        % user flagged mean log normalized power
        if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log(nanstd(mean_pwr_per_hz_in_band_within_segs./total_pwr,0,3));
            curr_tab= curr_tab+1;
        end
        
        % user flagged sd log10 raw power
        if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log10(nanstd(mean_pwr_per_hz_in_band_within_segs,0,3));
            curr_tab= curr_tab+1;
        end
        
        % user flagged sd log10 normalized power
        if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log10(nanstd(mean_pwr_per_hz_in_band_within_segs./total_pwr,0,3));
            curr_tab= curr_tab+1;
        end
    end
    
    % median power calculations
    if grp_proc_info_in.beapp_xlsout_med_on
        
        % user flagged median raw power
        if grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= nanmedian(mean_pwr_per_hz_in_band_within_segs,3);
            curr_tab= curr_tab+1;
        end
        
        % user flagged median normalized power
        if grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= nanmedian(mean_pwr_per_hz_in_band_within_segs./total_pwr,3);
            curr_tab= curr_tab+1;
        end
        
        % user flagged median log raw power
        if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log(nanmedian(mean_pwr_per_hz_in_band_within_segs,3));
            curr_tab= curr_tab+1;
        end
        
        % user flagged median log normalized power
        if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log(nanmedian(mean_pwr_per_hz_in_band_within_segs./total_pwr,3));
            curr_tab= curr_tab+1;
        end
        
        % user flagged median log10 raw power
        if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_raw_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log10(nanmedian(mean_pwr_per_hz_in_band_within_segs,3));
            curr_tab= curr_tab+1;
        end
        
         % user flagged median log10 normalized power
        if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_norm_on
            psd_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= log10(nanmedian(mean_pwr_per_hz_in_band_within_segs./total_pwr,3));
            curr_tab= curr_tab+1;
        end
    end

    col_ctr = col_ctr +largest_nchan;
end