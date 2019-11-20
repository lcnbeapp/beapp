%% beapp_get_inds_total_freqs 
%
% Inputs:
% bw_total_freqs = user input frequencies to use for total/normalization
% frequencies_in_array = frequencies in output measure frequency axis

% Assumes gaps in bw_total_freqs are 1 Hz or larger, looks for gaps and
% pulls indices of frequency values that user has selected
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
function inds_freqs_in_total_range = beapp_get_inds_total_freqs (bw_total_freqs, frequencies_in_array)

% get indices for frequencies user would like for total power
% assumes that user has not used gaps of less than 1 Hz
inds_gaps_in_user_total_freqs = find(diff(bw_total_freqs)>1);
inds_freqs_in_total_range = [];

% if more than 1 Hz gap, cycle through and pick up all frequencies without
% gaps
if ~isempty(inds_gaps_in_user_total_freqs)
    for curr_diff_ind = 1:length(inds_gaps_in_user_total_freqs)+1
        if curr_diff_ind ==1
            freq_set_start_val = bw_total_freqs(1);
        else
            freq_set_start_val = bw_total_freqs(inds_gaps_in_user_total_freqs(curr_diff_ind-1)+1);
        end
        if curr_diff_ind == (length(inds_gaps_in_user_total_freqs)+1)
           freq_set_end_val = bw_total_freqs(end);
        else 
           freq_set_end_val = bw_total_freqs(inds_gaps_in_user_total_freqs(curr_diff_ind));
        end 
        inds_freqs_in_total_range_to_add=find(frequencies_in_array>=freq_set_start_val & frequencies_in_array<=freq_set_end_val);
        if size(inds_freqs_in_total_range,2) == 1 %12/4: sometimes the two inds arrays are along different dimensions
           inds_freqs_in_total_range = inds_freqs_in_total_range';
        end
        if size(inds_freqs_in_total_range_to_add,2) == 1
           inds_freqs_in_total_range_to_add = inds_freqs_in_total_range_to_add';
        end
        inds_freqs_in_total_range = sort(unique(([inds_freqs_in_total_range,inds_freqs_in_total_range_to_add])));
    end
    
else
    inds_freqs_in_total_range=find(frequencies_in_array>= bw_total_freqs(1) & frequencies_in_array<=bw_total_freqs(end));
end
