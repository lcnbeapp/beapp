%% add_net_to_library (net_list_to_check, net_library_options_location,net_library_location,eeglab_loc_dir,name_10_20_elecs)
% 
% check if nets included in dataset are new, add them to net library if
% necessary. 
%
% Inputs:
% net_list_to_check = cell array of strings with net names in dataset
%
% net_library_options_location = path to net_library_options table (usually
% in reference_data folder). set in set_beapp_def as grp_proc_info.ref_net_library_options
%
% net_library_location = path to net_library folder with net structs
% (usually in reference_data folder). set in set_beapp_def as grp_proc_info.ref_net_library_dir
%
% eeglab_loc_dir = EEGLAB sample_locs directory path (usually in Packages
% folder). set in set_beapp_def as grp_proc_info.ref_eeglab_loc_dir
%
% name_10_20_elecs = list of 10-20 electrode names in order used in library (set in set_beapp_def as
% grp_proc_info.name_10_20_elecs)
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
function net_out_list = add_nets_to_library (net_list_to_check, net_library_options_location,net_library_location,eeglab_loc_dir,name_10_20_elecs)

% load table that contains current catalog of nets in the library on this computer
load(net_library_options_location);

% find nets present in this dataset that are not in the net library
nets_not_in_library = setdiff(net_list_to_check, net_library_options.Net_Full_Name,'stable');

% add unrecgonized nets to library
for curr_new_net = 1:length(nets_not_in_library)
    curr_net_string= char(nets_not_in_library(curr_new_net));
    
    % prompt user for location of coordinates for new net
    cd(eeglab_loc_dir); addpath(eeglab_loc_dir);
    net_dialog_string=['Select the file with coordinates for: ' curr_net_string ' including reference'];
    disp(['Select the file with coordinates for: ' curr_net_string ' including reference']);
    [new_net_filename,new_net_pathname,~] = uigetfile('*.*',net_dialog_string);
    
    if ~(new_net_filename ==0)
        % if file isn't in EEGLAB's loc directory, add it
        if ~strcmp(new_net_pathname,eeglab_loc_dir) && ~strcmp(new_net_pathname(1:end-1),eeglab_loc_dir)
            copyfile(strcat(new_net_pathname,new_net_filename),eeglab_loc_dir)
        end
    else
        warndlg(['No file selected, sensor layout "' curr_net_string '" not added to library']); 
        continue;
    end
    
    % use EEGLAB function to read coordinates for different filetypes
    sensor_layout = readlocs(new_net_filename);
    
    cd(net_library_location);
    
    % predict net name from string because of net company differences
    [~,new_net_abb,ext] = fileparts(new_net_filename);
    predicted_elec_num = regexp(new_net_abb,'\d\d\d*','Match');
    
    % confirm net name,abbreviation,and electrode number with user
    new_net_prompt = {'Enter number of electrodes in net (including reference, e.g. 65/129/257):','Enter reference electrode number (e.g. 65, 129, 257)', ...
        ['Enter desired net abbreviation in format GSN_65Ch_v2_0' sprintf('\n') '(Repeats ok if same net, with different full name):'], ...
        'Enter full net name (change from default not recommended)'};
    new_net_defaultans = {predicted_elec_num{1},predicted_elec_num{1},new_net_abb,curr_net_string};
    new_net_answer = inputdlg(new_net_prompt,'New Net Specifications',1,new_net_defaultans);
    
    elec_10_20_list=[{{'style','text','string', ...
        'Enter channel number for corresponding 10-20 electrodes'}},...
        {{'style','uitable','data',[name_10_20_elecs',num2cell(NaN(length(name_10_20_elecs),1))],'tag','add_10_20_equiv_table', ...
        'ColumnFormat',{'char','char'},'ColumnEditable',[false,true],'ColumnName',{'10-20 Electrode Name','Electrode Number in Net'}}}];
    
    button_10_20_geometry = {1 1};
    button_10_20_ver_geometry = [1 6];
    
    % make figure for module advanced settings
    [~, ~, strhalt_10_20s, resstruct_1020s, ~] = inputgui_mod_for_beapp('geometry',button_10_20_geometry ,...
        'uilist', elec_10_20_list,'title','Add New Sensor Layouts','geomvert',button_10_20_ver_geometry,...
        'tag','elec_10_20_add_fig');
    
    if ~strcmp (strhalt_10_20s,'')
        
        if ~all(cellfun(@isempty, resstruct_1020s.add_10_20_equiv_table.data(:,2),'UniformOutput',1))
            new_net_10_20s = cell2mat(resstruct_1020s.add_10_20_equiv_table.data(:,2)');
        else
            warndlg('No sensor layout names entered, no sensor layouts added to library');
        end
    end
    
    % if present, remove the EGI FID fields to prevent PREP issues
    Fid_indexes = strfind({sensor_layout.labels}, 'Fid');
    sensor_layout(find(not(cellfun('isempty', Fid_indexes))))=[];
    
    % create REST lead matrix if needed
    beapp_create_REST_lead_matrix(net_library_location, sensor_layout, new_net_answer{3},new_net_answer{4});

    % save new net in library and update library catalog
    save(new_net_answer{3},'sensor_layout')
    new_row_net_table=cell2table({new_net_answer{4},new_net_answer{3},str2num(new_net_answer{1}),str2num(new_net_answer{2}),{new_net_10_20s}});
    new_row_net_table.Properties.VariableNames=net_library_options.Properties.VariableNames;
    net_library_options = [net_library_options;new_row_net_table];
end

% remove empty lines from net library catalog
empty_rows  =  all(ismissing(net_library_options,{'' '.' 'NA' NaN 0})');
if sum(empty_rows) == size(net_library_options,1)
    net_library_options(empty_rows(2:end),:) =[];
else
    net_library_options(empty_rows,:) = [];
end

save(net_library_options_location,'net_library_options');
net_out_list = net_library_options.Net_Full_Name;
end
