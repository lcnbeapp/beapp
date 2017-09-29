%% beapp_init_file_hist_table
%
% takes module names and initialized file history table 
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
function [file_history_table] = beapp_init_file_hist_table (Mod_Names)

Mod_Run = false(length(Mod_Names),1);
Time_Run_Start = cell(length(Mod_Names),1);
Time_Run_Start(:) = {''};
Mod_Run_Time_for_File = NaN(length(Mod_Names),1);
Mod_Input_Dir = Time_Run_Start;
Mod_Output_Dir = Time_Run_Start;
Curr_Run_Tag = Time_Run_Start;

file_history_table = table(Mod_Names, Mod_Run, Time_Run_Start, ...
Mod_Run_Time_for_File,Curr_Run_Tag,Mod_Input_Dir,Mod_Output_Dir);
file_history_table.Properties.RowNames = Mod_Names;