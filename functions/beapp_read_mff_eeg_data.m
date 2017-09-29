%% beapp_read_mff_eeg_data
% reads eeg data from MFF file using EGI API, separates recording periods
% (epochs) and/or segments from each other 
%
% this function is adapted from the EGI
% API written by Colin Davey for FieldTrip in 2006-2014. 
% https://github.com/fieldtrip/fieldtrip/tree/master/external/egi_mff
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
function eeg = beapp_read_mff_eeg_data(firstsample,total_samples_in_file,read_window_length,tmp_signal_info,file_proc_info)
    
    data = zeros(file_proc_info.beapp_nchan,total_samples_in_file);
    
    read_window_start = 1;
    while firstsample+read_window_start <= total_samples_in_file
        
        % either read to end of read window or end of file
        read_window_end = min(read_window_start+read_window_length-1,total_samples_in_file);
        
        try
            data(:,read_window_start:read_window_end) = beapp_read_mff_signal(file_proc_info.beapp_fname,'sample',1+read_window_start-1,...
                firstsample+read_window_end-1,1:file_proc_info.src_nchan,tmp_signal_info,file_proc_info.src_epoch_nsamps);
        catch exc
            jv_hp_err_chk(exc)
        end
        
        read_window_start = read_window_end+1;
    end
    
    % store eeg in cell array
    eeg=cell(1,file_proc_info.src_num_epochs);
    
    for curr_epoch = 1:file_proc_info.src_num_epochs
        eeg{curr_epoch}=data(:,file_proc_info.src_epoch_start_samps(curr_epoch)+1:file_proc_info.src_epoch_start_samps(curr_epoch)+file_proc_info.src_epoch_nsamps(curr_epoch));
    end

    clear channels_desired firstsample read_window_end read_window_length
    clear read_window_start total_samples_in_file tmp_signal_info