%% batch_beapp_create_baseline_segs(grp_proc_info)
%
% remove baseline artifact above threshold (before or after segmentation), extract baseline segments of
% user set window size and group by condition
% detrend segments if selected
% reject segments using eeg_thresh and eeg_jointprob if selected
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
function grp_proc_info_in = batch_beapp_create_baseline_segs(grp_proc_info_in)

src_dir = find_input_dir('segment',grp_proc_info_in.beapp_toggle_mods);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1});
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        tic;
                
        % version control for beta testers (new fields, offset fix)
        file_proc_info = beapp_pre_segmentation_version_control (file_proc_info);
        
        % pull out event tags of interest + incorporate behavioral coding
        [file_proc_info, skip_file] = beapp_extract_relevant_event_tags_and_behav_info ...
                    (file_proc_info,grp_proc_info_in.src_data_type, ...
                    grp_proc_info_in.beapp_event_eprime_values,grp_proc_info_in.beapp_event_code_onset_strs,...
                    grp_proc_info_in.src_format_typ,grp_proc_info_in.beapp_event_use_tags_only, ...
                    grp_proc_info_in.select_nth_trial, grp_proc_info_in.segment_nth_stim_str);

        % skip file if it doesn't contain user-chosen event tags (unless pure baseline)
        if skip_file, continue; end
        
        file_proc_info.beapp_win_size_in_samps = grp_proc_info_in.win_size_in_secs*file_proc_info.beapp_srate;
        
        % initialize mask and output for current recording period
        eeg_msk = cell(1,size(eeg,2));
        eeg_w = cell(length((file_proc_info.grp_wide_possible_cond_names_at_segmentation)),1);
        
        for curr_epoch = 1:size(eeg,2)
            
            cond_seg_counter = [];
            cond_seg_counter_curr_ind = 1;
            
            % generate mask for pre-segmentation artifact rejection if needed
            if grp_proc_info_in.beapp_baseline_msk_artifact ~= 0
                [eeg_msk{curr_epoch},file_proc_info] = beapp_msk_art(eeg{curr_epoch}, grp_proc_info_in,file_proc_info,curr_epoch);
            else
                eeg_msk{curr_epoch}=zeros(1,size(eeg{curr_epoch},2));
            end
            
             curr_epoch_curr_cond_eeg_w = cell(length(file_proc_info.grp_wide_possible_cond_names_at_segmentation),1);
            % allocate segments according to dataset wide
            % conditions analyzed, not what is in file
            for curr_condition = 1:length(file_proc_info.grp_wide_possible_cond_names_at_segmentation)
                
                % incorporate condition information into mask
                eeg_msk_w_cond_info = beapp_create_condition_mask(grp_proc_info_in,file_proc_info,eeg_msk{curr_epoch},curr_epoch,curr_condition);
                
                %find the periods where there is continuous good data for at least as
                %many samples as there are in the user defined window size
                curr_epoch_curr_cond_eeg_w{curr_condition,1} = beapp_extract_segments(eeg_msk_w_cond_info,file_proc_info,grp_proc_info_in,eeg{curr_epoch});
                
                file_proc_info.evt_conditions_being_analyzed.Num_Segs_Pre_Rej(curr_condition) = size(curr_epoch_curr_cond_eeg_w{curr_condition,1},3);
                % detrend segment according to user preference
                curr_epoch_curr_cond_eeg_w{curr_condition,1} = detrend_segment(curr_epoch_curr_cond_eeg_w{curr_condition,1},grp_proc_info_in.segment_linear_detrend);
                
                cond_seg_counter(cond_seg_counter_curr_ind:cond_seg_counter_curr_ind+size(curr_epoch_curr_cond_eeg_w{curr_condition,1},3)-1) = curr_condition;
                cond_seg_counter_curr_ind = cond_seg_counter_curr_ind +size(curr_epoch_curr_cond_eeg_w{curr_condition,1},3);
                
                clear eeg_msk_w_cond curr_cond_curr_epoch_msk
            end
            
            if ~all(cellfun(@isempty,curr_epoch_curr_cond_eeg_w))
                
                % if desired, remove segments with artifact above user threshold
                if grp_proc_info_in.beapp_reject_segs_by_amplitude || grp_proc_info_in.beapp_happe_segment_rejection
                    
                    diary on;
                    
                    % jointprob should use information from all segments in rec period
                    all_baseline_conds_eeg = cat(3,curr_epoch_curr_cond_eeg_w{:});
                    EEG_tmp= curr_epoch_beapp2eeglab(file_proc_info,all_baseline_conds_eeg,1);
                    
                    EEG_tmp = post_seg_artifact_rejection(EEG_tmp, grp_proc_info_in, ...
                        file_proc_info.beapp_indx,file_proc_info.beapp_fname,curr_epoch);
                    diary off; 
                end
                
                % allocate segments according to dataset wide
                % conditions analyzed, not what is in file
                for curr_condition = 1:length(file_proc_info.grp_wide_possible_cond_names_at_segmentation)
                    
                    if grp_proc_info_in.beapp_reject_segs_by_amplitude || grp_proc_info_in.beapp_happe_segment_rejection
                        
                        curr_epoch_curr_cond_eeg_w{curr_condition,1} = extract_condition_segments_from_eeglab_struct...
                            (EEG_tmp, cond_seg_counter,curr_condition, size(eeg{curr_epoch},1),file_proc_info.beapp_indx{curr_epoch});                       
                    end
                    % stacks usable segments across epochs
                    eeg_w{curr_condition,1}=cat(3, eeg_w{curr_condition,1}, curr_epoch_curr_cond_eeg_w{curr_condition,1});
                end
            end
            
            clear curr_epoch_eeg_w grouped_good_data pot_good_windows segment_num good_data cond_seg_counter EEG_tmp
        end
        
        [conds_all,cond_inds_table_all,cond_inds_values_all]=intersect(file_proc_info.evt_conditions_being_analyzed.Condition_Name,...
            file_proc_info.grp_wide_possible_cond_names_at_segmentation,'stable');
        
        file_proc_info.evt_conditions_being_analyzed.Num_Segs_Post_Rej(cond_inds_table_all)= cellfun(@ (x) size(x,3),eeg_w(cond_inds_values_all));        
        %update ICA excel report
        beapp_update_ica_report(file_proc_info.evt_conditions_being_analyzed,grp_proc_info_in.beapp_root_dir{1,1},...
            grp_proc_info_in.beapp_genout_dir,grp_proc_info_in.beapp_prev_run_tag,grp_proc_info_in.beapp_curr_run_tag,grp_proc_info_in.beapp_fname_all{curr_file});
        
        if ~isempty(grp_proc_info_in.win_select_n_trials)
            if size(eeg_w{curr_condition,1},3)>= grp_proc_info_in.win_select_n_trials
                for curr_condition = 1:size(eeg_w,1)
                    inds_to_select = sort(randperm(size(eeg_w{curr_condition,1},3),grp_proc_info_in.win_select_n_trials));
                    file_proc_info.selected_segs{curr_condition,1} = inds_to_select;
                end
            else 
                file_proc_info.selected_segs{curr_condition,1} = [];
            end
        end
        
        if ~all(cellfun(@isempty,eeg_w))
            file_proc_info = beapp_prepare_to_save_file('segment',file_proc_info, grp_proc_info_in, src_dir{1});
            save(file_proc_info.beapp_fname{1},'eeg_w','file_proc_info','eeg_msk');
        end
    end
    
    clearvars -except grp_proc_info_in curr_file src_dir
end
