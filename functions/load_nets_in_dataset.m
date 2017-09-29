%% load_nets_in_dataset
%
% load nets in the current dataset from the net library into grp_proc_info
%
% Inputs:
% src_unique_nets:list of names of nets being used (detected or user set)
% net_library_options_location: path for net_library options table
% net_library_location: net_library folder path 
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
function [net_vstructs,net_ref_rows,net_10_20_elecs,largest_nchan] = load_nets_in_dataset(src_unique_nets,net_library_options_location,net_library_location)

% get library variable names of coordinates of nets in data from catalog
load(net_library_options_location);
[~,~,nets_in_dataset] = intersect(src_unique_nets,net_library_options.Net_Full_Name,'stable');
net_variables_in_dataset = net_library_options.Net_Variable_Name(nets_in_dataset);
net_ref_rows = net_library_options.Ref_Elec_Row_Num(nets_in_dataset);
net_10_20_elecs = net_library_options.Net_10_20_Electrode_Equivalents(nets_in_dataset);
cd(net_library_location)

% load all nets in dataset into grp_proc_info for speed
for curr_net = 1:length(net_variables_in_dataset)
    load(net_variables_in_dataset{curr_net});
    net_vstructs{curr_net} = sensor_layout;
    clear sensor layout
end

largest_nchan = max(cellfun(@length,net_vstructs,'UniformOutput',true));



    