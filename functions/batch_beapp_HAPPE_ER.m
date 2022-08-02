%% batch_beapp_HAPP_ER (grp_proc_info)
%run HAPPE_ER pipeline through BEAPP
%  a template for new modules in BEAPP
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

function grp_proc_info_in = batch_beapp_HAPPE_ER(grp_proc_info_in)
src_dir = find_input_dir('HAPPE+ER',grp_proc_info_in.beapp_toggle_mods);
disp('|====================================|');
%% Check if reprocessing
fprintf(['Select an option:\n  raw = Run on raw data from the start\n' ...
    '  reprocess = Run on HAPPE-processed data starting post-artifact ' ...
    'reduction\n']) 
grp_proc_info_in.HAPPE_ER_reprocessing = 0; %choose2('raw', 'reprocess') ;
%% Translate beapp's user inputs to happe params (if necessary)
if ~isempty(grp_proc_info_in.HAPPE_ER_parameters_file_location{1,1}) && ~exist(grp_proc_info_in.HAPPE_ER_parameters_file_location{1,1})
    error('Cannot find HAPPE+ER Parameter file at given path, please check path in beapp_set_input_file_locations')
elseif isempty(grp_proc_info_in.HAPPE_ER_parameters_file_location{1,1})
    if grp_proc_info_in.HAPPE_ER_reprocessing == 0
        grp_proc_info_in =beapp_translate_to_happe_inputs_clean(grp_proc_info_in);% beapp_create_happe_params(grp_proc_info_in);
    elseif grp_proc_info_in.HAPPE_ER_reprocessing == 1
        error('No path to HAPPE+ER Parameter file provided, please set the path in beapp_set_input_file_locations')
    end
end
%% loop through files
addpath(genpath(grp_proc_info_in.ref_HAPPE_V2_3_loc_dir))
qual_control=struct();
for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    cd(src_dir{1});
    %
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        tic;
        %load eeg
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        % convert to eeg lab format
        [EEGraw] = beapp2eeglab(file_proc_info,eeg{1,1},1,1);
        % add events specific to happe-er/based on file type
        [EEGraw] = add_happe_er_events_eeglab_struct(file_proc_info,EEGraw);
  %% Run HAPPE-ER Processing steps 
       
  [eegByTags,params, dataQC, dataQCTab,lnMeans,wavMeans] = HAPPE_v2_3_yb(EEGraw, grp_proc_info_in,{grp_proc_info_in.beapp_fname_all{curr_file}},curr_file); % Call HAPPE 
       
           
       
        %% Update file_output_struct
      %  qual_control(curr_file).lnMean = lnMeans;
      %  qual_control(curr_file).wavMean = wavMeans;
      %  qual_control(curr_file).dataQC = dataQC; 
        %% Update File Proc Info
        if ~isempty(eegByTags)
        file_proc_info = update_file_proc_info_posthappe_er(grp_proc_info_in,file_proc_info,dataQCTab,params,eegByTags);
        end
        %% Convert Data back to BEAPP for segmented files
        eeg_w = cell(length(eegByTags),1);
        for condition = 1:length(eegByTags)
            try
            eeg_w{condition,1} = eegByTags{1,condition}.data;
            catch
                eeg_w{condition,1} = [];
            end
        end
        %% save and update file history
        cd(grp_proc_info_in.beapp_toggle_mods{'HAPPE+ER','Module_Dir'}{1});
        %
        if ~all(cellfun(@isempty,eeg_w))
            file_proc_info = beapp_prepare_to_save_file('HAPPE+ER',file_proc_info, grp_proc_info_in, src_dir{1});
            save(strcat(file_proc_info.src_subject_id,'.mat'),'eeg_w','file_proc_info');
        end
        clearvars -except grp_proc_info_in src_dir curr_file qual_control params dataQCTab
    end
    
end
%save output table and dataQC table
  %  beapp_save_happe_er_qual_control(grp_proc_info_in,qual_control,params,dataQCTab.Properties.VariableNames)
    rmpath(genpath(grp_proc_info_in.ref_HAPPE_V2_3_loc_dir));

end

 
