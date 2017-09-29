%% beapp_read_mff_rec_period_info
% loads information about NetStation recording periods (called epochs in
% NS) from source file, needed to load events and EEG signal
% Inputs:
% full_filepath = full filepath to .mff file
% time_units_exp = exponent on MFF file version timestamps. 
% 6 = microseconds, 9 = nanoseconds
%
%
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [file_proc_info,epoch_first_blocks,epoch_last_blocks]= beapp_read_mff_rec_period_info(full_filepath,file_proc_info,time_units_exp)

% load and store number of recording periods
rec_period_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Epochs, 'epochs.xml', full_filepath);
all_rec_periods = rec_period_obj.getEpochs;
file_proc_info.src_num_epochs = all_rec_periods.size;
file_proc_info.beapp_num_epochs = file_proc_info.src_num_epochs;
clear epochs_obj

for curr_epoch = 1:all_rec_periods.size
    
    epoch = all_rec_periods.get(curr_epoch-1); % Java indexes start @ 0
    
    % get epoch time information
    e_start_times(curr_epoch)=epoch.getBeginTime();
    e_end_times(curr_epoch)= epoch.getEndTime();
    epoch_first_blocks(curr_epoch) = epoch.getFirstBlock;
    epoch_last_blocks(curr_epoch) = epoch.getLastBlock;
    
    % modified EGI API function micros2samples for nano seconds + rounding
    e_start_time_samp(curr_epoch) = time2samples(e_start_times(curr_epoch),file_proc_info.beapp_srate,time_units_exp,'fix');
    
    % adjusted to ignore time breaks
    if (curr_epoch==1)
        e_start_time_samp_actual(curr_epoch)=e_start_time_samp(curr_epoch);
    else
        e_start_time_samp_actual(curr_epoch)=sum(epoch_lengths(1:curr_epoch-1));
    end
    
    % epochs go up to end samp (not inclusive)
    epoch_lengths(curr_epoch) = time2samples(e_end_times(curr_epoch),file_proc_info.beapp_srate,time_units_exp,'fix')-e_start_time_samp(curr_epoch);
    
    % overall rather than epoch length in samples
    e_end_time_samp(curr_epoch) = time2samples(e_end_times(curr_epoch),file_proc_info.beapp_srate,time_units_exp,'fix');
    
end

% store local information
file_proc_info.src_epoch_start_times = e_start_times;
file_proc_info.src_epoch_end_times = e_end_times;
file_proc_info.src_epoch_start_samps = e_start_time_samp_actual;
file_proc_info.src_epoch_nsamps=epoch_lengths;

clear estart_time_samp epoch_lengths e_end_time_samp e_start_times
clear all_epochs curr_epoch epoch e_end_times