%% format_segmented_mff_data 
%
% extract condition and data quality information from pre-segmented MFFs
% save eeg_w and relevant event information
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
function [eeg_w, file_proc_info] =  format_segmented_mff_data (eeg,file_proc_info,user_set_condition_names,throw_out_bad_segments)

if ~isequal(file_proc_info.src_epoch_start_times,[file_proc_info.seg_info.s_start_time])
    warning([file_proc_info.beapp_fname{1} ':segment quality and condition information timestamps do not match data, please check'])
end

% sometimes is different from conditions in dataset (as in GAMES). For now
% need to be separate
conditions_in_segments  =  unique({file_proc_info.seg_info.condition_name});

file_proc_info.grp_wide_possible_cond_names_at_segmentation = user_set_condition_names;

file_proc_info.evt_seg_win_evt_ind = time2samples(nanmean([file_proc_info.seg_info.s_evt_start_time]-...
    [file_proc_info.seg_info.s_start_time]), file_proc_info.beapp_srate,6,'round');

for curr_condition = 1:length(user_set_condition_names)
    
    if ismember(conditions_in_segments, user_set_condition_names{curr_condition})
        % if throw out bad segments, grab good segs for each condition
        if throw_out_bad_segments
            cond_seg_idxs = intersect(find(~strcmp('bad', {file_proc_info.seg_info.s_status})), find(strcmp(conditions_in_segments{curr_condition}, {file_proc_info.seg_info.condition_name})));
            
            % otherwise, just get segments for each condition
        else
            cond_seg_idxs = find(strcmp(conditions_in_segments{curr_condition}, {file_proc_info.seg_info.condition_name}));
        end
        
        if ~isempty (cond_seg_idxs)
            cond_segments = eeg(cond_seg_idxs);
            eeg_w{curr_condition,1} = cat(3,cond_segments{:});
        else
            %warning([file_proc_info.beapp_fname{1} ':no usable segments matching conditions were found']);
            eeg_w{curr_condition,1}  = [];
        end
    else 
        eeg_w{curr_condition,1}  = [];
    end
end 

if all(cellfun(@isempty,eeg_w))
    warning (['BEAPP ' file_proc_info.beapp_fname{1} ': no usable segments matching user-entered conditions were found']);
end
