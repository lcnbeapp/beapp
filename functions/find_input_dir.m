%% find_input_dir
% find input directory for current module using current module string name
% and grp_proc_info.beapp_toggle_mods
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
function src_dir = find_input_dir(current_module_name,beapp_toggle_mods,varargin)

disp('|====================================|');
disp(['Running data through the ' current_module_name ' module']);
beapp_toggle_mods_temp = beapp_toggle_mods;
row= find(strcmp(beapp_toggle_mods_temp.Mod_Names,current_module_name));
src_dir={''};
if length(varargin) > 0 && beapp_toggle_mods_temp('HAPPE_V3',:).Module_On
    happe_reprocess = varargin{1};
else
    happe_reprocess = 0;
end

if happe_reprocess
    curr_row = row;
    [prev_path] = strsplit(beapp_toggle_mods_temp.Module_Dir{1},filesep);
    beapp_toggle_mods_temp.Module_Dir{curr_row} = [fileparts(beapp_toggle_mods.Module_Dir{curr_row}) filesep strcat('HAPPE_V3',prev_path{end}(7:end))];
else
curr_row = row-1;
end

if isempty(row)
    error('BEAPP: please check that at least one module has been turned on for this run');
end

while (isempty(src_dir{1}) && curr_row >0)
    if isdir(beapp_toggle_mods_temp.Module_Dir{curr_row}) && ~isempty(dir([beapp_toggle_mods_temp.Module_Dir{curr_row},filesep,'*.mat']))
        if contains(beapp_toggle_mods_temp.Module_Output_Type(curr_row),beapp_toggle_mods_temp.Module_Input_Type(row)) || happe_reprocess
            src_dir = beapp_toggle_mods_temp.Module_Dir(curr_row);
            disp([current_module_name ' module : Using data from source directory ' src_dir{1}]);
        end
    end
    curr_row = curr_row-1;
end

if isempty(src_dir{1})
    error([current_module_name ': Adequate source data was not found.Please check the user inputs and retry.']);
    return;
elseif isempty(dir([src_dir{1},filesep,'*.mat']))
    error([current_module_name ': Adequate source data was not found. Files in desired source directory, ', src_dir{1},' do not exist or are incorrectly formatted.Please check the user inputs and retry.']);
    return;
end