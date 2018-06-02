% delete temporary directories using grp_proc_info.beapp_toggle_mods table
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
function delete_temp_dirs (mod_names,mod_on,mod_export_on,mod_xls_on,mod_dir,mod_input_type,mod_output_type)

if (mod_on)
    if (~mod_export_on) && isdir(mod_dir{1})
        try
            if ~mod_xls_on
                warning('off', 'MATLAB:RMDIR:RemovedFromPath')
                rmdir(mod_dir{1},'s')
                disp(['Removed temporary directory for module: ' mod_names{1}])
            else
                cd(mod_dir{1})
                delete *.mat
                disp(['Removed .mat outputs for module: ' mod_names{1} ', left .xls outputs'])
            end
            warning('on', 'MATLAB:RMDIR:RemovedFromPath')
        catch
            warning('Could not delete one or more BEAPP output directories');
        end
    end
end
    