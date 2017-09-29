%% beapp_read_mff_events
% read event info from mff event tracks
% Inputs:
% full_filepath = file location path
% time_units_exp = exponent on MFF file version timestamps. 
% 6 = microseconds, 9 = nanoseconds
% record time = file start time
% curr_file_obj = current file java object (see EGI API)
%
% Outputs: evt_info (BEAPP event structure):
% 
% Many of the functions used to read in MFFs are adapted from the EGI
% API written by Colin Davey for FieldTrip in 2006-2014. 
% https://github.com/fieldtrip/fieldtrip/tree/master/external/egi_mff
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
function [evt_info_out,header_tag_info]= beapp_read_mff_events(curr_file_obj,full_filepath,record_time,time_units_exp,file_proc_info_in,grp_proc_info_in)

% extract event tracks from xml,usually Events_ECI_TCPIP_5513.xml
event_tracks = curr_file_obj.getEventTrackList(false);
clear curr_file_obj
header_tag_info = {};

% likely will have memory leak problems-- need to address eventually
if event_tracks.size() > 0
    MFFUtil = javaObject('com.egi.services.mff.utility.MFFUtil');
    
    % count events across tracks
    eventInd = 0;
    
    for curr_track = 1:(event_tracks.size)
        event_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_EventTrack, event_tracks.get(curr_track-1), full_filepath);
        all_events = event_obj.getEvents;
        
        for curr_event = 1:all_events.size;
            
            event = all_events.get(curr_event-1); % Java arrays are 0 based
            event_time = event.getBeginTime;
            
            % may change by version number, so far consistent in data
            event_time_ms = MFFUtil.getTimeDifferenceInMicroseconds(event_time, record_time);
            
            epoch_start_times_in_ms = file_proc_info_in.src_epoch_start_times/(10^(time_units_exp-6));
            epoch_end_times_in_ms = file_proc_info_in.src_epoch_end_times/(10^(time_units_exp-6));
            event_rec_period = intersect(find((epoch_end_times_in_ms>event_time_ms)),find((epoch_start_times_in_ms <event_time_ms))); % get netstation epoch for event
            event_time_rec_period_samps = time2samples(event_time_ms-epoch_start_times_in_ms(event_rec_period), file_proc_info_in.src_srate,6,'round');
            event_time_epoch_rel_in_micros = event_time_ms-epoch_start_times_in_ms(event_rec_period);
            event_time_samp_abs = event_time_rec_period_samps + sum(file_proc_info_in.src_epoch_nsamps (1:event_rec_period-1));
            
            if event_time_rec_period_samps < 1
                % this does happen depending on export settings
                warning(['sample number calculations for event ' char(event.getCode) ' in ' file_proc_info_in.beapp_fname{1} ' suggest the event occurred before file start. Please check']);
            else
                eventInd = eventInd + 1;
                
                % pull event information
                evt_info(eventInd).evt_codes=char(event.getCode);
                evt_info(eventInd).evt_times=char(event_time);
                evt_info(eventInd).evt_times_micros_rel = double(event_time_epoch_rel_in_micros);
                evt_info(eventInd).evt_times_epoch_rel=double(event_rec_period);
                evt_info(eventInd).evt_times_samp_rel=double(event_time_rec_period_samps)+file_proc_info_in.src_file_offset_in_ms *(file_proc_info_in.src_srate/1000)+1;
                evt_info(eventInd).evt_times_samp_abs = double(event_time_samp_abs)+file_proc_info_in.src_file_offset_in_ms *(file_proc_info_in.src_srate/1000)+1;
                evt_info(eventInd).evt_ind=double(eventInd);
                evt_info(eventInd).evt_duration_samps=time2samples(event.getDuration,file_proc_info_in.src_srate,6,'fix');
                evt_info(eventInd).duration_time=event.getDuration;
                
                % check if event code matches your behavioral coding event
                if ~isempty(grp_proc_info_in.behavioral_coding.events{1})
                    [~,evt_behav_index] = find(strcmp(grp_proc_info_in.behavioral_coding.events,char(event.getCode)));
                end
                
                all_keys = event.getKeys;
                for curr_key = 1:all_keys.size
                    
                    key = all_keys.get(curr_key-1);
                    
                    % pull out event type (marked by cel #)
                    if (strcmp((char(key.getCode)),'cel#'))
                        evt_info(eventInd).evt_cel_type=str2double(char(key.getData));
                    end
                    
                    % extract behavioral coding information
                    if ~isempty(grp_proc_info_in.behavioral_coding.events{1})
                        if ~isempty(evt_behav_index)
                            if any(strcmp((char(key.getCode)),grp_proc_info_in.behavioral_coding.keys))
                                tmp_behav_code = char(key.getData);
                                evt_info(eventInd).behav_code = ismember(tmp_behav_code,grp_proc_info_in.behavioral_coding.bad_value);
                            end
                        end
                    end
                end
                
                if ~isfield(evt_info,'evt_cel_type')
                    evt_info(eventInd).evt_cel_type = nan;
                elseif isempty(evt_info(eventInd).evt_cel_type)
                    evt_info(eventInd).evt_cel_type = nan;
                end
                
                if ~isfield(evt_info,'behav_code')
                    evt_info(eventInd).behav_code = nan;
                elseif isempty(evt_info(eventInd).behav_code)
                    evt_info(eventInd).behav_code = nan;
                end
                
                % compare event index and sample for temporal sorting
                if isempty(evt_info(eventInd).evt_times_samp_abs)
                    event_samps_inds(eventInd,1) = nan;
                else
                    event_samps_inds(eventInd,1) = evt_info(eventInd).evt_times_samp_abs;
                end
                event_samps_inds(eventInd,2) = eventInd;
                
                % track header info from EPrime, controls for inconsistent
                % track formats
                if strcmp(evt_info(eventInd).evt_codes,'SESS') || strcmp( evt_info(eventInd).evt_codes,'CELL')
                    header_tag_info{eventInd,1} = evt_info(eventInd).evt_codes;
                    header_tag_info{eventInd,2}=char(event.getLabel);
                    header_tag_info{eventInd,3} = evt_info(eventInd).evt_cel_type;
                    header_tag_info{eventInd,4}=eventInd;
                end

            end
        end
    end
    
    % sort events by sample time -- can be made more efficient
    event_samps_inds = sortrows(event_samps_inds);
    sortedEvents = evt_info;
    for p = 1:eventInd
        nextEventInd = event_samps_inds(p,2);
        sortedEvents(p) = evt_info(nextEventInd);
    end
    evt_info = sortedEvents;
    
    clear record_time all_events event event_obj all_keys curr_key key
    clear event_epoch curr_event MFFUtil event_tracks event_time
    clear p event_samps_inds sortedEvents nextEventInd tmp_behav_code
    
    %% pull out tags in file header if present
    header_tag_info(all(cellfun(@isempty,header_tag_info),2),:)= [];
    
    if ~isempty(header_tag_info)
        hdr_non_condition_tags = union(find(cellfun(@isnan, header_tag_info(:,3))==1),find(cellfun('isempty', header_tag_info(:,3))==1));
        header_tag_info = cell2table(header_tag_info,'VariableNames',{'Eprime_Cell_Name' 'Condition_Name' 'Evt_Codes' 'Eprime_Cell_Ind'});
        header_tag_info.Tag_Is_Condition_Label = true(size(header_tag_info,1),1);
        header_tag_info.Tag_Is_Condition_Label(hdr_non_condition_tags)=0;
    end
    
    %% extract conditions present and conditions being analyzed
    % if file is segmented, keep evt info in one block
    if grp_proc_info_in.src_format_typ ==3
        evt_info_out = evt_info;
    else
        % otherwise separate events into epochs in which they happen
        epochs_with_events = unique([evt_info.evt_times_epoch_rel]);
        evt_info_out=cell(1,length(epoch_start_times_in_ms));
        
        for curr_epoch = 1:length(epochs_with_events)
            curr_indices=([evt_info.evt_times_epoch_rel]==epochs_with_events(curr_epoch));
            evt_info_out{epochs_with_events(curr_epoch)}=evt_info(curr_indices);
        end
    end
end