%% beapp_dir_prep
% create beapp directories according to module settings and run tags
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

function [grp_proc_info_in,modnames,first_mod_ind] = beapp_dir_prep(grp_proc_info_in)

% find modules flagged on, get directories not set by user
modnames = grp_proc_info_in.beapp_toggle_mods.Properties.RowNames;
first_mod_ind = find(grp_proc_info_in.beapp_toggle_mods.Module_On, 1, 'first');
inds_dir_not_set = find(cellfun(@isempty,grp_proc_info_in.beapp_toggle_mods.Module_Dir));

% add tags for initial run
if grp_proc_info_in.beapp_toggle_mods{'format','Module_On'}
    if isempty(grp_proc_info_in.beapp_curr_run_tag) || strcmp(grp_proc_info_in.beapp_curr_run_tag,'NONE')
        grp_proc_info_in.beapp_toggle_mods.Module_Dir(inds_dir_not_set) = strcat([grp_proc_info_in.src_dir{1} filesep], modnames(inds_dir_not_set));
        grp_proc_info_in.beapp_curr_run_tag = '';
    else
        grp_proc_info_in.beapp_toggle_mods.Module_Dir(inds_dir_not_set) = strcat([grp_proc_info_in.src_dir{1} filesep], modnames(inds_dir_not_set),['_',grp_proc_info_in.beapp_curr_run_tag]);
    end

% add user tag or datestamp to directories created in rerun
else
    
    % add previous run tag for earlier modules if needed
    if ~isempty(grp_proc_info_in.beapp_prev_run_tag)
        grp_proc_info_in.beapp_toggle_mods.Module_Dir(inds_dir_not_set) = strcat([grp_proc_info_in.src_dir{1} filesep], modnames(inds_dir_not_set),['_',grp_proc_info_in.beapp_prev_run_tag]);
    else
        grp_proc_info_in.beapp_toggle_mods.Module_Dir(inds_dir_not_set) = strcat([grp_proc_info_in.src_dir{1} filesep], modnames(inds_dir_not_set));
    end
    
    % add timestamp or user tag to directories from this rerun if not muted
    dir_ind = intersect(inds_dir_not_set,first_mod_ind:length(grp_proc_info_in.beapp_toggle_mods.Module_On));
    
    if strcmp(grp_proc_info_in.beapp_curr_run_tag,'NONE')
        grp_proc_info_in.beapp_toggle_mods.Module_Dir(dir_ind)= strcat([grp_proc_info_in.src_dir{1} filesep],modnames(dir_ind));
        grp_proc_info_in.beapp_curr_run_tag = '';
    else
        if isempty(grp_proc_info_in.beapp_curr_run_tag)
            grp_proc_info_in.beapp_curr_run_tag = datestr(grp_proc_info_in.hist_run_tag,'run_dd_mm_yy_at_HH_MM_SS');
        end
        grp_proc_info_in.beapp_toggle_mods.Module_Dir(dir_ind)= strcat([grp_proc_info_in.src_dir{1} filesep],modnames(dir_ind), ['_' grp_proc_info_in.beapp_curr_run_tag]);
    end
end

try
dir_prev_exist = rowfun(@beapp_create_outdirs,grp_proc_info_in.beapp_toggle_mods,'NumOutputs',1);
catch err
    if strcmp(err.identifier,'MATLAB:table:rowfun:FunFailed')
        errordlg('Please confirm source directory selected exists');
    else
        rethrow(err);
    end
end
if any(dir_prev_exist.Var1)
    if grp_proc_info_in.beapp_dir_warn_off ~= 1
               
    usr_cont = questdlg(['The following directories already exist:';
        [grp_proc_info_in.beapp_toggle_mods.Module_Dir(logical(dir_prev_exist.Var1))];
        'Continuing with the pipeline could result in deleting copies of data currently in these directories';...
        'Would you like to continue?'],'BEAPP Directory Warning','Yes','No','Yes');
        if strcmp('Yes',usr_cont)
            disp(sprintf(' \n Continuing with pipeline. \n Could not create directories:'));
            disp([grp_proc_info_in.beapp_toggle_mods.Module_Dir(logical(dir_prev_exist.Var1))])
        elseif  strcmp('No',usr_cont)
            error('User did not proceed with run, exiting BEAPP'); 
        end
    else
        disp(['The following directories already exist and were not recreated, data may be overwritten'; '';...
        [grp_proc_info_in.beapp_toggle_mods.Module_Dir(logical(dir_prev_exist.Var1))];...
       'Continuing with pipeline';]);
    end
end
% Check if HAPPE_V3 turned on and if there are any modules with same tag
% besides formatting
HAPPE_mod_ind = find(strcmpi(modnames,'HAPPE_V3'));
if grp_proc_info_in.beapp_toggle_mods.Module_On(HAPPE_mod_ind) && any(dir_prev_exist.Var1(2:(HAPPE_mod_ind-1)))
    same_dirs = [grp_proc_info_in.beapp_toggle_mods.Module_Dir(logical(dir_prev_exist.Var1))];
    usr_cont = questdlg(['The following directories already exist with the same tag as your current run:';
       [same_dirs(1:end-1,:)]; 'Continuing with the pipeline will result in HAPPE V3 pulling data from:'; [same_dirs(end-1,:)];...
       'rather than the formatting module';...
        'Would you like to continue?'],'HAPPE V3 Directory Warning','Yes','No','Yes');
        if strcmp('Yes',usr_cont)
            disp(sprintf(' \n Continuing with pipeline. \n Could not create directories:'));
            disp([grp_proc_info_in.beapp_toggle_mods.Module_Dir(logical(dir_prev_exist.Var1))])
        elseif  strcmp('No',usr_cont)
            error('User did not proceed with run, exiting BEAPP'); 
        end
end

if isempty(grp_proc_info_in.beapp_genout_dir{1})
    if strcmp(grp_proc_info_in.beapp_curr_run_tag,'') || strcmp(grp_proc_info_in.beapp_curr_run_tag,'NONE')
        grp_proc_info_in.beapp_genout_dir={[grp_proc_info_in.src_dir{1},filesep,'out']};
    else
        grp_proc_info_in.beapp_genout_dir={[grp_proc_info_in.src_dir{1},filesep,'out_',grp_proc_info_in.beapp_curr_run_tag]};
    end
    if ~isdir(grp_proc_info_in.beapp_genout_dir{1})
        mkdir(grp_proc_info_in.beapp_genout_dir{1});
    end
end
