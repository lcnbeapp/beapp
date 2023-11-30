%% beapp_load_nonmat_flist_and_evt_table
% 
% loads file specific offsets and linenoise information from input table for 
% files that may have events (non-mat inputs)if user has selected that option,
% otherwise generates file list and stores group offset and linenoise 
% values input by user for all files
%
% Inputs: 
% file_extension = string with file extension, ex '.mff','.bdf'
% src_dir = grp_proc_info.src_dir
% event_tag_offsets = grp_proc_info.event_tag_offsets
% src_linenoise = grp_proc_info.src_linenoise
% event_file_info_table_loc = grp_proc_info.beapp_file_info_table
% net_type_in_file = 1 if net type is embedded in file, 0 if net type needs to be read from table
% srate_in_file = 1 if srate is embedded in file, 0 if srate needs to be read from the table
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [src_fname_all,src_linenoise_all,src_offsets_in_ms_all,beapp_fname_all,src_net_typ_all]  = beapp_load_nonmat_flist_and_evt_table ...
(src_dir,file_extension,event_tag_offsets,src_linenoise,event_file_info_table_loc, src_format_typ,run_per_file,file_idx)

% get list of files of source type in source directory
cd(src_dir{1});
src_file_list = dir(['*' file_extension]);
src_file_list = {src_file_list.name};

if isempty(src_file_list)
    error (['BEAPP: No ' file_extension ' files were found in source directory' src_dir{1}]);
end

% pull in event offsets or individual linenoise freqs from table if needed 
if ~isnumeric(event_tag_offsets) || ~isnumeric(src_linenoise) || src_format_typ == 4 || src_format_typ == 5
   load(event_file_info_table_loc);
    if run_per_file 
        beapp_file_info_table =  beapp_file_info_table(file_idx,:);
    end
    % find files listed both in source directory and offset info table
    [src_fname_all,ind_table] =  intersect(beapp_file_info_table.FileName,src_file_list,'stable');
    src_fname_all = src_fname_all';
   
    if isempty(src_fname_all)
        error (['BEAPP: User chose to use an offset or linenoise table, but no files listed in table were found in source directory' src_dir{1}]);
    end 
   
    % load offset info if file specific,otherwise use group value for all
    if strcmp(event_tag_offsets,'input_table')
        src_offsets_in_ms_all = beapp_file_info_table.FileOffset(ind_table);
    else
        src_offsets_in_ms_all = event_tag_offsets* ones(1,length(src_fname_all));
    end
    
    % load linenoise freq if file specific,otherwise use group value for all
    if strcmp(src_linenoise,'input_table')
       src_linenoise_all = beapp_file_info_table.Line_Noise_Freq(ind_table);  
    else
       src_linenoise_all = src_linenoise *ones(1,length(src_fname_all));
    end 
   
    % EEGLAB, often will need to pull net name
    if src_format_typ == 4 || src_format_typ == 5
        % store group net types and sampling rates (from table)
        src_net_typ_all = beapp_file_info_table.NetType(ind_table);
    else
         src_net_typ_all = 'pulled directly from files';
    end
        
    
else
    % if no event/linenoise information table needed, use group value for
    % all files
    src_fname_all = src_file_list;
    src_offsets_in_ms_all = event_tag_offsets * ones(1,length(src_fname_all));
    src_linenoise_all = src_linenoise * ones(1,length(src_fname_all));
    src_net_typ_all = 'pulled directly from files';
end

beapp_fname_all=strrep(src_fname_all, file_extension, '.mat');