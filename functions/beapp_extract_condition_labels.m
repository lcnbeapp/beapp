%% beapp_extract_condition_labels
%
% Inputs:
% beapp_fname: file_proc_info.beapp_fname{1}
% src_data_type: baseline, event-related, etc - grp_proc_info.src_data_type
% header_tag_info : information pulled from file header tag (MFF), can be
% empty set
% evt_info: file_proc_info.evt_info structure (all recording periods)
% beapp_event_eprime_values :user set event information (tags, codes)
% beapp_event_code_onset_strs: user set event tags, grp_proc_info.beapp_event_code_onset_strs

% Outputs:
% evt_info with .type field added for segmentation
% conditions_being_analyzed: condition found in both user settings and file
% skip_file: 1 if file does not contain any user set events of interest
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
function [evt_info, conditions_being_analyzed,skip_file] = beapp_extract_condition_labels(beapp_fname,src_data_type,...
    header_tag_info,evt_info,beapp_event_eprime_values,beapp_event_code_onset_strs)

% remove extra rows in header
header_no_cond = 0;
skip_file = 0;

% extract condition info from eprime file header if present
if (~isempty(header_tag_info))
    condition_labels_detected = header_tag_info;
    condition_labels_detected(~header_tag_info.Tag_Is_Condition_Label,:)= [];
    cels = header_tag_info.Evt_Codes(header_tag_info.Tag_Is_Condition_Label);
    non_native_condition_set = 0;
    clear empty_indexes_cnd grab_ind_of_tag
    
    if isempty(cels)
        disp([beapp_fname ': header present in file does not contain relevant condition info, using info provided in user inputs']);
        
        for curr_epoch = 1: length(evt_info)
            cels_epoch = unique([evt_info{curr_epoch}.evt_cel_type]);
            cels = unique([cels_epoch cels]);
        end
        
        cels(isnan(cels))=[];
        header_no_cond = 1;
    end
    
else % otherwise just get events present in cel
    disp([beapp_fname ': condition info not stored in event track, using condition info provided in user inputs']);
    cels = [];
    non_native_condition_set = 1;
    for curr_epoch = 1: length(evt_info)
        cels_epoch = unique([evt_info{curr_epoch}.evt_cel_type]);
        cels = unique([cels_epoch cels]);
    end
    cels(isnan(cels))=[];
    condition_labels_detected = [];
end

%% clumsy for now--  some version of this is necessary given unreliable ISP naming
% find largest overlap in event codes user gives and those found in file
% our longest condition set (ABCCT) takes <1 second
length_largest_overlap = 0;
largest_overlap_values = [];
for condition_column = 1:size(beapp_event_eprime_values.event_codes,2)
    
    % find event codes present in dataset
    [~,~,eprime_val_inds]=intersect(cels,beapp_event_eprime_values.event_codes(:,condition_column));
    
    % figure out which user condition set option is the best match
    if length(eprime_val_inds) > length_largest_overlap
        length_largest_overlap = length(eprime_val_inds); clear column_w_curr_largest_overlap
        column_w_curr_largest_overlap = condition_column; clear largest_overlap_values
        largest_overlap_values(:,1) = beapp_event_eprime_values.event_codes(eprime_val_inds);
        indexes_for_curr_best_match = eprime_val_inds;
    elseif (length(eprime_val_inds) ==length_largest_overlap) && (length_largest_overlap~=0)
        column_w_curr_largest_overlap(length(column_w_curr_largest_overlap)+1) = condition_column;
        if ~isempty(setdiff(beapp_event_eprime_values.event_codes(eprime_val_inds), largest_overlap_values))
            largest_overlap_values(:,size(largest_overlap_values,2)+1) = beapp_event_eprime_values.event_codes(eprime_val_inds);
        end
    end
end

if size(largest_overlap_values,2) >1
    warning(['multiple candidate condition sets for file' beapp_fname '. Please check user inputs'])
end

if (isempty(condition_labels_detected) || header_no_cond) && (length_largest_overlap>0)
    condition_labels_detected = table(cell(length_largest_overlap,1),...
        beapp_event_eprime_values.condition_names(indexes_for_curr_best_match)',...
        beapp_event_eprime_values.event_codes(indexes_for_curr_best_match,column_w_curr_largest_overlap(1)),...
        'VariableNames',{'Eprime_Cell_Name','Condition_Name','Evt_Codes'});
end

conditions_being_analyzed = table();
if src_data_type == 1 % baseline, no tag data
    conditions_being_analyzed = table(NaN,{'baseline'},{''},'VariableNames',{'Evt_Codes','Condition_Name','Native_File_Condition_Name'});
else % standard event related data
    if isempty(condition_labels_detected) || ~exist('indexes_for_curr_best_match','var')
        warning([beapp_fname ' : condition info not stored in event track, matching info not found in user inputs, moving on to next file']);
        skip_file = 1;
    else
        
        % clumsy way of finding appropriate indices -- change when time
        [conditions_being_analyzed.Evt_Codes,~,ind2]=intersect(beapp_event_eprime_values.event_codes(indexes_for_curr_best_match,column_w_curr_largest_overlap(1)),condition_labels_detected.Evt_Codes);
        conditions_being_analyzed.Condition_Name = beapp_event_eprime_values.condition_names(indexes_for_curr_best_match)';
        if ~non_native_condition_set
            conditions_being_analyzed.Native_File_Condition_Name = condition_labels_detected.Condition_Name(ind2);
        else
            conditions_being_analyzed.Native_File_Condition_Name = cell(length(ind2),1);
            conditions_being_analyzed.Native_File_Condition_Name(:) = {''};
        end
    end
end

% if condition information is empty, skip file
if isempty(conditions_being_analyzed) && (src_data_type == 2)
    skip_file = 1;
    return;
end

% more efficient ways to do this but ok in the short term
% loop through epochs (rec periods) and update .type field for segmenting
for curr_epoch = 1: length(evt_info)
    % set condition strings for event tag of interest
    [evt_info{curr_epoch}(:).type]=deal('Non_Target');
    
    for curr_condition = 1:length(conditions_being_analyzed.Condition_Name)
        cond_ind=conditions_being_analyzed.Evt_Codes(curr_condition)==[evt_info{curr_epoch}.evt_cel_type];
        [evt_info{curr_epoch}(cond_ind).type] = deal(conditions_being_analyzed.Condition_Name{curr_condition});
    end
    
    for curr_tag = 1:length(beapp_event_code_onset_strs)
        tag_ind{curr_epoch}(:,curr_tag)=strcmp(beapp_event_code_onset_strs{curr_tag},{evt_info{curr_epoch}.evt_codes});
    end
    tag_ind{curr_epoch} = sum(tag_ind{curr_epoch},2);
    [evt_info{curr_epoch}(~tag_ind{curr_epoch}).type]=deal('Non_Target');
    
end
clear empty_indexes_evt eventInd e_start_time_samp e_start_time_samp_actual condition_labels
clear event_time_epoch_samps event_time_ms event_time_samps epoch_lengths curr_track eprime_vals
clear non_tag_ind cond_ind curr_condition