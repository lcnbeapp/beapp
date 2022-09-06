% beapp_set_input_file_locations
% 
% use to set user inputs, advanced inputs, and input tables to non-default files
% To use default scripts and tables (beapp_userinputs.m, beapp_advinputs.m,
% beapp_file_info_table) set inputs blank. Otherwise, specify relevant
% filepaths to input scripts and tables
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
% In no event shall Boston Children's Hospital (BCH), the BCH Department of
% Neurology, the Laboratories of Cognitive Neuroscience (LCN), or software 
% contributors to BEAPP be liable to any party for direct, indirect, 
% special, incidental, or consequential damages, including lost profits, 
% arising out of the use of this software and its documentation, even if 
% Boston Children's Hospital,the Laboratories of Cognitive Neuroscience, 
% and software contributors have been advised of the possibility of such 
% damage. Software and documentation is provided "as is". Boston Children's 
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

% set location for beapp to load user inputs and advanced inputs
grp_proc_info.beapp_alt_user_input_location = ... ,%{'/Users/delphinus/beapp/user_inputs/beapp_userinputs_pac.m'};
{'/Volumes/neuro-levin/Groups/SPA/02_Data_Processing/01_BEAPP_Scripts_User_Inputs/01_Study_User_Inputs/04_Tactile_Spatial_Suppression/ui_4_segment_seg_happe_er_yb_test.m'};%seg_happe_er_yb_test.m'};
%{'/Volumes/neuro-levin/Groups/SPA/02_Data_Processing/01_BEAPP_Scripts_User_Inputs/01_Study_User_Inputs/07_Tactile_Spatial_Suppression_Arm/ui_happe_er_YBTESTING.m'};
%{'/Users/delphinus/beapp/user_inputs/ui_segment_seg.m'}; % def = {''}, which will use beapp_userinputs.m 
grp_proc_info.beapp_alt_adv_user_input_location = {''}; % def = {''}, which will use beapp_advinputs.m

% set location for beapp to load mat, mff, or rerun file info tables
grp_proc_info.beapp_alt_beapp_file_info_table_location = {'/Volumes/neuro-levin/Groups/SPA/02_Data_Processing/01_BEAPP_Scripts_User_Inputs/01_Study_User_Inputs/04_Tactile_Spatial_Suppression/beapp_file_info_table_all.mat'}; % def = {''}, which will use beapp_file_info_table.mat
grp_proc_info.beapp_alt_rerun_file_info_table_location ={'/Volumes/neuro-levin/Groups/SPA/02_Data_Processing/01_BEAPP_Scripts_User_Inputs/01_Study_User_Inputs/04_Tactile_Spatial_Suppression/rerun_fselect_table_all.mat'}; % def = {''},  which will use rerun_fselect_table.mat

% set location for beapp to load HAPPE+ER parameters file (only if using HAPPE+ER module
grp_proc_info.HAPPE_ER_parameters_file_location = {''};% {'/Volumes/neuro-levin/Groups/SPA/01_Data_Raw_Summary_Processed/EEG/Participant_Data/03_Processed_Data/03_Tactile_Temporal_Habituation/HAPPE+ER_YB_Testing/input_parameters/25-07-2022_yb_7.24.22.mat'}; %/Users/delphinus/happe-integration-testing/input_parameters/19-07-2022_test_happe_integration.mat'}; % def = {''}, which will use x .mat
