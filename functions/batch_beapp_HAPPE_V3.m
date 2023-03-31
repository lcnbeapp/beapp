%% batch_beapp_HAPPE_V3 (grp_proc_info)
%run HAPPE Version 3 pipeline through BEAPP
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

function grp_proc_info_in = batch_beapp_HAPPE_V3(grp_proc_info_in)
src_dir_orig = find_input_dir('HAPPE_V3',grp_proc_info_in.beapp_toggle_mods,grp_proc_info_in.HAPPE_v3_reprocessing);
disp('|====================================|');
% If rerunning happe, copy necessary files to dest_src_dir and move there
src_dir = happe_v3_rerun_file_check(grp_proc_info_in.HAPPE_v3_reprocessing,src_dir_orig,grp_proc_info_in.beapp_toggle_mods.Module_Dir(find(strcmpi(grp_proc_info_in.beapp_toggle_mods.Properties.RowNames, 'HAPPE_V3'))),grp_proc_info_in.beapp_fname_all);

% Translate beapp's user inputs to happe params (if necessary) and load / initialize data/pipeline assesment structs
[qual_control,params] = set_happe_v3_params_qcs(grp_proc_info_in);
[dirNames] = set_happe_v3_path(grp_proc_info_in,params);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    cd(src_dir{1});
    if grp_proc_info_in.HAPPE_v3_reprocessing || exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        
        if ~grp_proc_info_in.HAPPE_v3_reprocessing
            load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        else
            load(['0 - rerun_file_proc_infos' filesep strcat(grp_proc_info_in.beapp_fname_all{curr_file}(1:end-4),'file_info.mat')],'file_proc_info');
            EEGraw = NaN(5,1);
        end
        
        for curr_rec_period = 1:size(eeg,2)

        tic;
        if ~grp_proc_info_in.HAPPE_v3_reprocessing
            curr_eeg = eeg{:,curr_rec_period};
          %  load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
            [EEGraw] = beapp2eeglab(file_proc_info,curr_eeg,curr_rec_period,1);
            [EEGraw] = add_happe_v3_events_eeglab_struct(file_proc_info,EEGraw,curr_rec_period);       % add events specific to happe-er/based on file type
        else
            load(['0 - rerun_file_proc_infos' filesep strcat(grp_proc_info_in.beapp_fname_all{curr_file}(1:end-4),'file_info.mat')],'file_proc_info');
            EEGraw = NaN(5,1);
        end
        %% Run HAPPE-ER Processing steps
        [eeg_out, dataQC,chan_info,lnMeans,wavMeans,errorLog] = HAPPE_v2_3_for_beapp(params,EEGraw, grp_proc_info_in.HAPPE_v3_reprocessing,{grp_proc_info_in.beapp_fname_all{curr_file}},fullfile(grp_proc_info_in.src_dir{1,1},strcat('HAPPE_V3_',grp_proc_info_in.beapp_curr_run_tag)),dirNames); % Call HAPPE V3
        %% Update file_output_struct
        if ~iscell(eeg_out)
            eeg_out = {eeg_out};
        end
        qual_control(1).lnMean = [qual_control(1).lnMean; lnMeans];
        qual_control(1).wavMean = [qual_control(1).wavMean; wavMeans];
        qual_control(1).dataQC = [qual_control(1).dataQC; dataQC];
        %% Update File Proc Info
        if ~isempty(eeg_out)
            file_proc_info = update_file_proc_info_posthappe_v3(grp_proc_info_in,file_proc_info,qual_control,params,eeg_out,chan_info,curr_file,curr_rec_period);
        end
        %% Convert Data back to BEAPP for segmented files
        eeg_final = cell(length(eeg_out),1);
        for condition = 1:length(eeg_out)
                if ~isempty(eeg_out{1,condition})
                    eeg_final{condition,1} = nan(129,size(eeg_out{1,condition}.data,2),size(eeg_out{1,condition}.data,3));
                eeg_final{condition,1}(file_proc_info.beapp_indx{1,1},:,:) = eeg_out{1,condition}.data;
                else
                    eeg_final{condition,1} = [];
                end
        end
        if params.segment.on
            eeg_w{1,curr_rec_period} = eeg_final;
        else
            eeg{1,curr_rec_period} = eeg_final;
        end
        end
        %% save and update file history
        cd(grp_proc_info_in.beapp_toggle_mods{'HAPPE_V3','Module_Dir'}{1});
        %
        if ~all(cellfun(@isempty,eeg_final))
            file_proc_info = beapp_prepare_to_save_file('HAPPE_V3',file_proc_info, grp_proc_info_in, src_dir{1});
            if params.segment.on
                                save(strcat(file_proc_info.beapp_fname{1,1}),'eeg_w','file_proc_info','-v7.3','-nocompression');
            else
            save(strcat(file_proc_info.beapp_fname{1,1}),'eeg','file_proc_info');
            end  
        end
        clearvars -except grp_proc_info_in src_dir curr_file qual_control params errorLog dirNames
    end
end
%save output table and dataQC table
beapp_save_happe_v3_qual_control(grp_proc_info_in,qual_control,params,errorLog)
rmpath(genpath(grp_proc_info_in.ref_HAPPE_V2_3_loc_dir));
end

 
