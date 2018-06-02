%% beapp_calc_itpc_output(grp_proc_info_in,file_proc_info,eeg_itc_curr_cond,f,t)
% 
% calculate report values for desired ITPC metrics for a given condition
% Inputs:
% eeg_itc_curr_cond - itc output from newtimef for current condition for
% time points specified in sub-analysis window in user inputs
% f - frequency bins from newtime f
% t - time axis from newtimef
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
function itpc_report_values=beapp_calc_itpc_output(grp_proc_info_in,file_proc_info,eeg_itc_curr_cond,f,t)

% initialize variables + report array for file
col_ctr = 0;
itpc_bw_name = [grp_proc_info_in.bw_name {'Total'}];
ncols=(length(itpc_bw_name)*grp_proc_info_in.largest_nchan);
ntabs=grp_proc_info_in.beapp_itpc_xlsout_mx_on+grp_proc_info_in.beapp_itpc_xlsout_av_on;
itpc_report_values = NaN(1,ncols,ntabs);
time_window_indexes = find(t>= (grp_proc_info_in.evt_analysis_win_start*1000) & t <= (grp_proc_info_in.evt_analysis_win_end*1000));

for curr_band=1:(length(grp_proc_info_in.bw)+1)
    
    curr_tab=1;
    if curr_band<=size(grp_proc_info_in.bw,1)
        % get indices for frequencies in current band of interest
        freqs_in_band=find(f>=grp_proc_info_in.bw(curr_band,1)& f<=grp_proc_info_in.bw(curr_band,2));
    else
        % get indices for frequencies in total range
        freqs_in_band = beapp_get_inds_total_freqs (grp_proc_info_in.bw_total_freqs, f);
    end
        
    if grp_proc_info_in.beapp_itpc_xlsout_mx_on
        try 
        itpc_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= ...
            squeeze(max(max(abs(eeg_itc_curr_cond(:,freqs_in_band,time_window_indexes)),[],2),[],3))';
        catch err
            if strcmp(err.identifier,'MATLAB:subsassigndimmismatch')
                warning(['BEAPP ' file_proc_info.beapp_fname{1} ': user selected ' itpc_bw_name{curr_band} ' frequencies not included in newtimef outputs']);
            end
            itpc_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= NaN(1,file_proc_info.src_nchan);
        end
        curr_tab = curr_tab+1;
    end
    
    if grp_proc_info_in.beapp_itpc_xlsout_av_on
        try
            itpc_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)=...
                squeeze(nanmean(max(abs(eeg_itc_curr_cond(:,freqs_in_band,time_window_indexes)),[],2),3))';
        catch err
            if strcmp(err.identifier,'MATLAB:subsassigndimmismatch')
                warning(['BEAPP ' file_proc_info.beapp_fname{1} ': user selected ' itpc_bw_name{curr_band} ' frequencies not included in newtimef outputs']);
            end
            itpc_report_values(1,col_ctr+1:col_ctr+file_proc_info.src_nchan,curr_tab)= NaN(1,file_proc_info.src_nchan);
        end
        curr_tab = curr_tab+1;
    end
    
    col_ctr = col_ctr +grp_proc_info_in.largest_nchan;
end
