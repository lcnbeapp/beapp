%% beapp_read_set_segment_info
% pull pre-created segment information from .set file
% Inputs:
% EEG_struct - loaded .set file from poploadset
%
% Function adapted from beapp_read_mff_segment_info, with some variables
% irrelevant variables excluded
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
function file_proc_info = beapp_read_set_segment_info(EEG_struct,file_proc_info,grp_proc_info_in)
if grp_proc_info_in.src_data_type ~=1
    all_categories = grp_proc_info_in.beapp_event_eprime_values.condition_names;
else
    all_categories = [];
end
file_proc_info.evt_seg_win_evt_ind = find(EEG_struct.times == 0);
condition_name = cell(size(EEG_struct.epoch,2),1);
if ~isempty(all_categories)
    cat_names = cell(length(all_categories),1);
    for curr_cat = 1:length(all_categories)

        evt_type_idx = cell2mat(cellfun(@(x) strcmpi(cell2mat(all_categories(curr_cat)), x), {EEG_struct.event.code},'UniformOutput',false));
        evt_lat_idx =  cell2mat(cellfun(@(x) (cell2mat(x) == 0), {EEG_struct.epoch.eventlatency},'UniformOutput',false) ) ;

        %checking that is has condition label and that that condition label happens
        %at time zero (so is label that is segmented around)
        cat_indices = (evt_type_idx&evt_lat_idx);
        cat_epochs = [EEG_struct.event(cat_indices).epoch];
        cat_names{curr_cat}= char(all_categories{curr_cat});

        condition_name(cat_epochs) = deal({cat_names{curr_cat}});
        clear cat cat_epoch
    end
    seg_info = struct('condition_name',condition_name);
    file_proc_info.seg_info = seg_info;
    file_proc_info.seg_tasks=cat_names;
    clearvars -except file_proc_info
end