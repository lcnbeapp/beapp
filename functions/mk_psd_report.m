%% mk_psd_report
%
% make report table (.mat and .csv) for PSD
%
% Inputs:
% report_values- 3D file x channel+band x analysis array
% tname_out - tab/analysis name
% report_info - metadata for all files
% bw_names - set by user
% largest_nchan - largest number of channels for any net in dataset
% all_condition_labels - all conditions being used across files
% all_obsv_sizes - number of segments per file for all files
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
function mk_psd_report(grp_proc_info_in,report_info,report_values,report_values_condition_labels, all_obsv_sizes)

curr_tabname = 1;

if grp_proc_info_in.beapp_xlsout_av_on
    if grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='mean_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end

    if grp_proc_info_in.beapp_xlsout_norm_on
        tabnames{curr_tabname}='mean_NormAbsPwr';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='mean_Log_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_norm_on
      tabnames{curr_tabname}='mean_Log_NormAbsPwr';
      curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='mean_Log10_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_norm_on
      tabnames{curr_tabname}='mean_Log10_NormAbsPwr';
      curr_tabname = curr_tabname +1;
    end
end


if grp_proc_info_in.beapp_xlsout_sd_on
    if grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='sd_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_norm_on
        tabnames{curr_tabname}='sd_NormAbsPwr';
        curr_tabname = curr_tabname +1;
    end

    if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='sd_Log_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_norm_on
        tabnames{curr_tabname}='sd_Log_NormAbsPwr';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='sd_Log10_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_norm_on
        tabnames{curr_tabname}='sd_Log10_NormAbsPwr';
        curr_tabname = curr_tabname +1;
    end
end

if grp_proc_info_in.beapp_xlsout_med_on
    if grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='med_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end

    if grp_proc_info_in.beapp_xlsout_norm_on
        tabnames{curr_tabname}='med_NormAbsPwr';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='med_Log_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log_on && grp_proc_info_in.beapp_xlsout_norm_on
      tabnames{curr_tabname}='med_Log_NormAbsPwr';
      curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_raw_on
        tabnames{curr_tabname}='med_Log10_Pwr_Per_Hz';
        curr_tabname = curr_tabname +1;
    end
    
    if grp_proc_info_in.beapp_xlsout_log10_on && grp_proc_info_in.beapp_xlsout_norm_on
      tabnames{curr_tabname}='med_Log10_NormAbsPwr';
      curr_tabname = curr_tabname +1;
    end
end

tabnames = tabnames(~cellfun('isempty',tabnames));
report_values_header = mk_generic_analysis_report(report_values,tabnames,report_info, [grp_proc_info_in.bw_name {'Total'}],...
    grp_proc_info_in.largest_nchan, report_values_condition_labels, all_obsv_sizes,grp_proc_info_in.beapp_genout_dir{1});

cd(grp_proc_info_in.beapp_genout_dir{1})

if ~isempty(grp_proc_info_in.beapp_curr_run_tag)
    save(['PSD_report_values_' grp_proc_info_in.beapp_curr_run_tag '.mat'],'report_values','report_values_header','tabnames','report_values_condition_labels');
else
    save(['PSD_report_values' grp_proc_info_in.beapp_curr_run_tag '.mat'],'report_values','report_values_header','tabnames','report_values_condition_labels');
end
