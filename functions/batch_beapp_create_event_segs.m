%% batch_beapp_create_event_segs(grp_proc_info)
%
% extract event-tagged segments using user set window start and end and group by condition
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
function grp_proc_info_in = batch_beapp_create_event_segs(grp_proc_info_in)

src_dir = find_input_dir('segment',grp_proc_info_in.beapp_toggle_mods);

for curr_file = 1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1});
    
    if exist(grp_proc_info_in.beapp_fname_all{curr_file},'file')
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        if strcmp(lastwarn,'Variable ''eeg'' not found.')
            error('eeg variable not found for this file, check that you have continous data (and not already segmented data in your source directory')
        end
        tic;
        
        % version control for beta testers (new fields, offset fix)
        file_proc_info = beapp_pre_segmentation_version_control (file_proc_info);
        
        % pull out event tags of interest + incorporate behavioral coding
        [file_proc_info, skip_file] = beapp_extract_relevant_event_tags_and_behav_info ...
            (file_proc_info,grp_proc_info_in.src_data_type, ...
            grp_proc_info_in.beapp_event_eprime_values,grp_proc_info_in.beapp_event_code_onset_strs,...
             grp_proc_info_in.src_format_typ,grp_proc_info_in.beapp_event_use_tags_only,...
             grp_proc_info_in.select_nth_trial,grp_proc_info_in.segment_nth_stim_str);
         
        % skip file if it doesn't contain user-chosen event tags (unless pure baseline)
        if skip_file, continue; end
        
        % initialize ouput and intermediate structs
        eeg_w=cell(length(file_proc_info.grp_wide_possible_cond_names_at_segmentation),1);
        EEG_epoch_structs=cell(length(file_proc_info.evt_conditions_being_analyzed.Condition_Name),size(eeg,2));
        
        diary off;
        
        for curr_epoch = 1:size(eeg,2)
            
            %make an EEGLab structure
            EEG_orig =curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_epoch},curr_epoch);
            
            if ~isempty(eeg{curr_epoch})&& ~isempty(file_proc_info.evt_info{curr_epoch})
                
                % check that there are target events to segment
                if ~all(ismember({file_proc_info.evt_info{curr_epoch}.type},'Non_Target'))
                    
                    %8/2/19: select nth stim type A after a stim type B
                    if ~isempty(grp_proc_info_in.select_nth_trial)
                        [file_proc_info.evt_info{curr_epoch}] = beapp_extract_nth_trial(file_proc_info.evt_info{curr_epoch},...
                            grp_proc_info_in.select_nth_trial,grp_proc_info_in.beapp_event_code_onset_strs,...
                            grp_proc_info_in.segment_stim_relative_to,grp_proc_info_in.segment_nth_stim_str);
                    end
                    %add the events to the EEG structure
                    EEG_epoch_structs{1,curr_epoch}=add_events_eeglab_struct(EEG_orig,file_proc_info.evt_info{curr_epoch}); %RL changed from EEG_epoch_structs{curr_epoch}
                    EEG_epoch_structs{1,curr_epoch}.data=eeg{curr_epoch}; %RL changed from EEG_epoch_structs{curr_epoch}
                    
                    [unique_vals,~,type_of_val] = unique({file_proc_info.evt_info{curr_epoch}(:).type});
                    bincounts_conds = histc(type_of_val,unique(type_of_val));
                    
                    if ~isequal(unique_vals,{'Non_Target'})
                        [conds,cond_inds_table,cond_inds_values]=intersect(file_proc_info.evt_conditions_being_analyzed.Condition_Name,unique_vals);
                        file_proc_info.evt_conditions_being_analyzed.Good_Behav_Trials_Pre_Rej(cond_inds_table) = bincounts_conds(cond_inds_values) +  file_proc_info.evt_conditions_being_analyzed.Good_Behav_Trials_Pre_Rej(cond_inds_table);
                    end
                    
                    if isempty(grp_proc_info_in.select_nth_trial)
                    % segment all desired conditions by time before/after event type
                        [EEG_epoch_structs{1,curr_epoch}, inds_of_events_in_boundaries]= pop_epoch(EEG_epoch_structs{1,curr_epoch},... %RL changed from EEG_epoch_structs{curr_epoch}
                            file_proc_info.evt_conditions_being_analyzed.Condition_Name',...
                            [grp_proc_info_in.evt_seg_win_start grp_proc_info_in.evt_seg_win_end],'verbose','off');
                    else
                        %%MM: 9/9/19
                         [EEG_epoch_structs{1,curr_epoch}, inds_of_events_in_boundaries]= pop_epoch(EEG_epoch_structs{1,curr_epoch},... %RL changed from EEG_epoch_structs{curr_epoch}
                            file_proc_info.grp_wide_possible_cond_names_at_segmentation',...
                            [grp_proc_info_in.evt_analysis_win_start grp_proc_info_in.evt_analysis_win_end],'verbose','off');
                    end 
                    
                    if ~isempty(EEG_epoch_structs{1,curr_epoch}) %RL changed from EEG_epoch_structs{curr_epoch}
                        % get sample index for event in segment (used to make subwindows in analysis modules)
                        file_proc_info.evt_seg_win_evt_ind = find(EEG_epoch_structs{1,curr_epoch}.times == 0); %RL changed from EEG_epoch_structs{curr_epoch}
                    end
                    
                    % detrend segment according to user preference
                    EEG_epoch_structs{1,curr_epoch}.data = detrend_segment(EEG_epoch_structs{1,curr_epoch}.data,grp_proc_info_in.segment_linear_detrend); %RL changed from EEG_epoch_structs{curr_epoch}
                    
                    EEG_epoch_structs{1,curr_epoch}=eeg_checkset(EEG_epoch_structs{1,curr_epoch}); %RL changed from EEG_epoch_structs{curr_epoch}
                    
                    % if desired, remove segments using pop_eegthresh and/or pop_jointprob
                    if grp_proc_info_in.beapp_reject_segs_by_amplitude || grp_proc_info_in.beapp_happe_segment_rejection
                        diary on;
                        
                        EEG_epoch_structs{1,curr_epoch} = post_seg_artifact_rejection(EEG_epoch_structs{1,curr_epoch}, grp_proc_info_in, ... %RL changed from EEG_epoch_structs{curr_epoch}
                            file_proc_info.beapp_indx,file_proc_info.beapp_fname,curr_epoch);
                        diary off;
                    end
                    
                    % Remove the baseline using window selected by user
                    if grp_proc_info_in.evt_trial_baseline_removal
                        EEG_epoch_structs{1,curr_epoch}=pop_rmbase(EEG_epoch_structs{1,curr_epoch},[grp_proc_info_in.evt_trial_baseline_win_start*1000 grp_proc_info_in.evt_trial_baseline_win_end*1000]); %RL changed from EEG_epoch_struct{curr_epoch}
                    end
                    
                    % moving average filter if selected
                    if grp_proc_info_in.beapp_erp_maf_on
                        EEG_epoch_structs{1,curr_epoch}=pop_firma(EEG_epoch_structs{1,curr_epoch},'forder',grp_proc_info_in.beapp_erp_maf_order); %RL changed from EEG_epoch_structs{curr_epoch}
                    end
                    
                    % use beapp event list, since EEGLAB list will count
                    % multiple valid tags in one segment
                    
                    all_tag_list = {file_proc_info.evt_info{curr_epoch}(:).type};
                    non_targ_idx = find(ismember(all_tag_list, 'Non_Target'));
                    all_tag_list(non_targ_idx) = [];
                   [file_proc_info.evt_info{curr_epoch}(:).trial_selection] = deal(NaN);
                    
                    curr_epoch_curr_cond_eeg_w = cell(length(file_proc_info.grp_wide_possible_cond_names_at_segmentation),1);
                    
                    if length(all_tag_list) ~=  length(EEG_epoch_structs{1,curr_epoch}.reject.rejglobal) %RL changed from EEG_epoch_structs{curr_epoch
                        throw_out_events = setdiff(1:length(all_tag_list),inds_of_events_in_boundaries);
                        all_tag_list(throw_out_events) = [];
                    end
                    
                    
                    if isempty(EEG_epoch_structs{1,curr_epoch}.reject.rejglobal) %RL changed from EEG_epoch_structs{curr_epoch}
                        % if no segment rejection was run, keep all
                        % segments
                        tmp_EEG_struct_rejglobal = ones(1,size(EEG_epoch_structs{1,curr_epoch}.data,3)); %RL changed from EEG_epoch_structs{curr_epoch}
                    else
                        % get segments to keep, not segments to
                        % reject
                        tmp_EEG_struct_rejglobal = not([EEG_epoch_structs{1,curr_epoch}.reject.rejglobal]); %RL changed from EEG_epoch_structs{curr_epoch}
                    end                    
                    %%MM 9/9/19:
                    if grp_proc_info_in.beapp_event_group_stim == 1
                        tmp_EEG_struct_rejglobal = remove_evt_seqs_in_groups(length(file_proc_info.grp_wide_possible_cond_names_at_segmentation),...
                             length(EEG_epoch_structs{1,curr_epoch}.epoch),tmp_EEG_struct_rejglobal,EEG_epoch_structs{1,curr_epoch}.epoch,... %RL changed from EEG_epoch_struct{1,1}
                             file_proc_info.grp_wide_possible_cond_names_at_segmentation);
                    end
% %                      if strcmp(grp_proc_info_in.beapp_curr_run_tag,'no_bsl_same_45_chosen_at_seg_042418')
% %                          
% %                          for curr_tag = 1 :length(all_tag_list)
% %                              [file_proc_info.beapp_tmp_seg_info(curr_tag).seg_name] = all_tag_list(curr_tag);
% %                              [file_proc_info.beapp_tmp_seg_info(curr_tag).trial_selection] = false;
% %                              [file_proc_info.beapp_tmp_seg_info(curr_tag).good_trial] = tmp_EEG_struct_rejglobal(curr_tag);
% %                          end
% %                      end
%                  
%                     % allocate segments according to dataset wide
%                     % conditions analyzed, not what is in file
                    for curr_condition = 1:length(file_proc_info.grp_wide_possible_cond_names_at_segmentation)
                        
                        targ_cond_logical = ismember(all_tag_list, file_proc_info.grp_wide_possible_cond_names_at_segmentation{curr_condition});
                        
                        if ~ismember(1,targ_cond_logical) %RL edit start
                            continue
                        end %RL edit end

                        % keep good segments of this condition type
                        segs_to_keep = all([targ_cond_logical; tmp_EEG_struct_rejglobal]);
                        file_proc_info.evt_conditions_being_analyzed.Num_Segs_Pre_Rej(curr_condition) = sum(targ_cond_logical);
                        file_proc_info.evt_conditions_being_analyzed.Num_Segs_Post_Rej(curr_condition) = sum(segs_to_keep);
                        
%                         if strcmp(grp_proc_info_in.beapp_curr_run_tag,'no_bsl_same_45_chosen_at_seg_042418')
%      
%                             if ~isempty(grp_proc_info_in.win_select_n_trials)
%                                 if sum(segs_to_keep) >= grp_proc_info_in.win_select_n_trials
%                                     good_indexes = find(segs_to_keep);
%                                     inds_to_select = sort(randperm(sum(segs_to_keep),grp_proc_info_in.win_select_n_trials));
%                                     good_inds_to_select = good_indexes(inds_to_select);
%                                     segs_to_keep_subset = false(1,length(segs_to_keep));
%                                     segs_to_keep_subset(good_inds_to_select) = deal(true);
%                                     
%                                     for curr_tester = 1:length(segs_to_keep)
%                                         if segs_to_keep_subset(curr_tester) && not(segs_to_keep(curr_tester))
%                                             error('uh oh')
%                                         end
%                                     end
%                                     
%                                     segs_to_keep = segs_to_keep_subset;
%                                 else
%                                     segs_to_keep = false(length(segs_to_keep));
%                                 end
%                             end
%                             for curr_tag = 1 :length(file_proc_info.beapp_tmp_seg_info)
%                                 if not(file_proc_info.beapp_tmp_seg_info(curr_tag).trial_selection)
%                                     [file_proc_info.beapp_tmp_seg_info(curr_tag).trial_selection] = segs_to_keep(curr_tag);
%                                 end
%                             end
%                              
%                         end
%              
                        %convert back to BEAPP format
                        if ~isempty(segs_to_keep)
                            if length(EEG_epoch_structs{1,curr_epoch}.chanlocs) == size(eeg{1,curr_epoch},1) %RL changed from EEG_epoch_structs{curr_epoch}
                                curr_epoch_curr_cond_eeg_w{curr_condition,1} = EEG_epoch_structs{1,curr_epoch}.data(:,:,segs_to_keep); %RL changed from EEG_epoch_structs{curr_epoch}
                            else
                                tmp_eeg_arr = NaN(size(eeg{curr_epoch},1),size(EEG_epoch_structs{1,curr_epoch}.data,2),sum(segs_to_keep)); %RL changed from EEG_epoch_structs{curr_epoch}
                                tmp_eeg_arr(file_proc_info.beapp_indx{curr_epoch},:,:) = EEG_epoch_structs{1,curr_epoch}.data(:,:,segs_to_keep); %RL changed from EEG_epoch_structs{curr_epoch}
                                curr_epoch_curr_cond_eeg_w{curr_condition,1} = tmp_eeg_arr;
                            end
                        else
                            curr_epoch_curr_cond_eeg_w{curr_condition,1} = [];
                        end
                        
%                         
%                         [curr_epoch_curr_cond_eeg_w{curr_condition,1},~] = extract_condition_segments_from_eeglab_struct...
%                             (EEG_epoch_structs{curr_epoch}, all_tag_list,file_proc_info.grp_wide_possible_cond_names_at_segmentation{curr_condition}, size(eeg{curr_epoch},1),file_proc_info.beapp_indx{curr_epoch});
%                         
                        eeg_w{curr_condition,1}=cat(3,eeg_w{curr_condition,1}, curr_epoch_curr_cond_eeg_w{curr_condition,1});
                        %8/29/19: add the info about each kept epoch to file_proc_info
                        if isfield(EEG_epoch_structs{1,curr_epoch},'epoch') %RL changed from EEG_epoch_structs{1,1}
                            if ~isempty(EEG_epoch_structs{1,curr_epoch}.epoch) %RL changed from EEG_epoch_structs{1,1}
                                file_proc_info.epoch{curr_condition,curr_epoch} = EEG_epoch_structs{1,curr_epoch}.epoch(segs_to_keep); %RL changed from file_proc_info.epoch{curr_condition,1} and EEG_epoch_structs{1,1}
                            end
                        end
                        clear curr_cond_event_list_idxs
                    end
                    beapp_update_ica_report(file_proc_info.evt_conditions_being_analyzed,grp_proc_info_in.beapp_root_dir{1,1},...
                            grp_proc_info_in.beapp_genout_dir,grp_proc_info_in.beapp_prev_run_tag,...
                            grp_proc_info_in.beapp_curr_run_tag,grp_proc_info_in.beapp_fname_all{curr_file});
                end
                clear all_tag_list non_targ_idx
            end
        end
        
        diary on;
        
        [conds_all,cond_inds_table_all,cond_inds_values_all]=intersect(file_proc_info.evt_conditions_being_analyzed.Condition_Name,...
            file_proc_info.grp_wide_possible_cond_names_at_segmentation,'stable');
        file_proc_info.evt_conditions_being_analyzed.Num_Segs_Post_Rej(cond_inds_table_all)= cellfun(@ (x) size(x,3),eeg_w(cond_inds_values_all));
        
        %% (added 2/19)
        if ~isempty(grp_proc_info_in.win_select_n_trials)
            for curr_condition = 1:length(file_proc_info.grp_wide_possible_cond_names_at_segmentation) %RL edit
                if size(eeg_w{curr_condition,1},3)>= grp_proc_info_in.win_select_n_trials
%                     for curr_condition = 1:size(eeg_w,1) %RL edit
                    inds_to_select = sort(randperm(size(eeg_w{curr_condition,1},3),grp_proc_info_in.win_select_n_trials));
                    file_proc_info.selected_segs{curr_condition,1} = inds_to_select;
%                     end %RL edit
                else 
                    file_proc_info.selected_segs{curr_condition,1} = [];
                end
            end %RL edit
        end
        %%
        
        if ~all(cellfun(@isempty,eeg_w))
            file_proc_info = beapp_prepare_to_save_file('segment',file_proc_info, grp_proc_info_in, src_dir{1});
            save(file_proc_info.beapp_fname{1},'file_proc_info','eeg_w');
        end
        clearvars -except grp_proc_info_in curr_file src_dir
    end
end