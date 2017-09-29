%% beapp_ica_select_channels_for_file
%
% select channels to use in ICA module. By default, uses 10-20 for net+
% user set additional channels (because of MARA).In the future, users not running MARA
% will be able to choose any channels they'd like
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
function [chan_IDs, file_proc_info] = beapp_ica_select_channels_for_file (file_proc_info,src_unique_nets, happe_additional_chans_lbls,name_10_20_elecs)

% get 10-20 labels and additional user set channels for this net
uniq_net_ind = find(strcmp(src_unique_nets, file_proc_info.net_typ{1}));
file_proc_info.net_happe_additional_chans_lbls = happe_additional_chans_lbls{uniq_net_ind};
[file_proc_info.net_vstruct(file_proc_info.net_10_20_elecs).labels] = name_10_20_elecs{:};

% check if user added optional channels,and only use electrodes that have labels in the dataset
if (length(file_proc_info.net_happe_additional_chans_lbls) == 1) && isempty(file_proc_info.net_happe_additional_chans_lbls{1})
    chan_IDs = unique(name_10_20_elecs);
else
    chan_IDs_all = unique([name_10_20_elecs  file_proc_info.net_happe_additional_chans_lbls]);
    chan_IDs = intersect(chan_IDs_all,{file_proc_info.net_vstruct.labels});
    if length(chan_IDs) < length(chan_IDs_all)
        extra_elecs = setdiff(chan_IDs_all,chan_IDs);
        warning (['Electrode(s) ' sprintf('%s ,',extra_elecs{1:end-1}) extra_elecs{end} ' are not found in file chanlocs']);
    end
end
