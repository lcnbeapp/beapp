%% add_events_eeglab_struct(EEG,evt_info_curr_rec_period)
% sets up an EEGLab structure to pull out events
%
% Inputs:
% EEG : eeglab struct created from BEAPP
% evt_info_curr_rec_period : BEAPP evt_info struct for file at current rec period
% eg. file_proc_info.evt_info{curr_rec_period}
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
function [EEG]=add_events_eeglab_struct(EEG,evt_info_curr_rec_period)

for curr_event=1:length(evt_info_curr_rec_period)
   
    %MM added 8/28/19 (see what it does)
%     EEG.event(curr_event).evt_codes=evt_info_curr_rec_period(curr_event).evt_codes;
%     EEG.event(curr_event).evt_times_micros_rel=evt_info_curr_rec_period(curr_event).evt_times_micros_rel; %see if this fixes timing info
%     EEG.event(curr_event).evt_times_samp_rel=evt_info_curr_rec_period(curr_event).evt_times_samp_rel;
%     EEG.event(curr_event).evt_times_samp_abs=evt_info_curr_rec_period(curr_event).evt_times_samp_abs;
%     EEG.event(curr_event).duration_time=evt_info_curr_rec_period(curr_event).duration_time;
%     EEG.event(curr_event).evt_cel_type=evt_info_curr_rec_period(curr_event).evt_cel_type;
%     EEG.event(curr_event).behav_code=evt_info_curr_rec_period(curr_event).behav_code;
    
    % add event label, time latency, and sample number to EEGLAB structure
    if isfield(evt_info_curr_rec_period,'type')
        EEG.event(curr_event).type=char(evt_info_curr_rec_period(curr_event).type);
    end
    
    EEG.event(curr_event).latency=double(evt_info_curr_rec_period(curr_event).evt_times_samp_rel); 
    EEG.event(curr_event).init_index=double(evt_info_curr_rec_period(curr_event).evt_ind); 
    EEG.event(curr_event).urevent=EEG.event(curr_event).init_index;

end
