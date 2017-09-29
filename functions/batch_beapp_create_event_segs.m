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

function batch_beapp_create_event_segs(grp_proc_info_in)

src_dir = find_input_dir('segment',grp_proc_info_in.beapp_toggle_mods);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
   
    cd(src_dir{1});
    
    if exist(grp_proc_info_in.beapp_fname_all{curr_file},'file')
        
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
         tic;
        % determine what condition sets in user inputs are present in this
        % file (greatest overlap)
        [file_proc_info.evt_info,file_proc_info.evt_conditions_being_analyzed,skip_file] = beapp_extract_condition_labels...
            (file_proc_info.beapp_fname{1},grp_proc_info_in.src_data_type,file_proc_info.evt_header_tag_information,file_proc_info.evt_info,grp_proc_info_in.beapp_event_eprime_values,grp_proc_info_in.beapp_event_code_onset_strs);
        
        % if no conditions in inputs are in the file, skip file
        if skip_file, continue; end
        
        % incorporate behavioral information
        file_proc_info.evt_info =  beapp_exclude_trials_using_behavioral_codes (file_proc_info.evt_info);
        
        % make sure eeg outputs line up across all files being processed in
        % this run
        file_proc_info.grp_wide_possible_cond_names_at_segmentation = grp_proc_info_in.beapp_event_eprime_values.condition_names;
        
        eeg_w=cell(length( file_proc_info.grp_wide_possible_cond_names_at_segmentation),1);
        EEG_epoch_structs=cell(length(file_proc_info.evt_conditions_being_analyzed.Condition_Name),size(eeg,2));
        
        diary off;
        
        for curr_epoch = 1:size(eeg,2)
            
            %make an EEGLab structure
            EEG_orig =curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_epoch},curr_epoch);
            
            if (length(file_proc_info.evt_info)>= curr_epoch)
                if ~isempty(eeg{curr_epoch})&& ~isempty(file_proc_info.evt_info{curr_epoch})
                    
                    % check that there are target events to segment
                    if ~all(ismember({file_proc_info.evt_info{curr_epoch}.type},'Non_Target'))
                        
                        %add the events to the EEG structure
                        EEG_epoch_structs{curr_epoch}=add_events_eeglab_struct(EEG_orig,file_proc_info.evt_info{curr_epoch});
                        EEG_epoch_structs{curr_epoch}.data=eeg{curr_epoch};
                        
                        % segment all desired conditions by time before/after event type
                        EEG_epoch_structs{curr_epoch}= pop_epoch(EEG_epoch_structs{curr_epoch},...
                            file_proc_info.evt_conditions_being_analyzed.Condition_Name',...
                            [grp_proc_info_in.evt_seg_win_start grp_proc_info_in.evt_seg_win_end],'verbose','off');
                        
                        % check that this is correct
                        file_proc_info.evt_seg_win_evt_ind = find(EEG_epoch_structs{curr_epoch}.times == 0);
                        
                        % detrend segment according to user preference
                        EEG_epoch_structs{curr_epoch}.data = detrend_segment(EEG_epoch_structs{curr_epoch}.data,grp_proc_info_in.segment_linear_detrend);
                        
                        %Make the 3-d event EEG array
                        EEG_epoch_structs{curr_epoch}=eeg_checkset(EEG_epoch_structs{curr_epoch});
                        
                        % if desired, remove segments with artifact above user threshold
                        if grp_proc_info_in.beapp_reject_segs_by_amplitude || grp_proc_info_in.beapp_happe_segment_rejection
                            
                            % stopgap fix during beta testing
                            if size(file_proc_info.beapp_indx{curr_epoch},1) > size(file_proc_info.beapp_indx{curr_epoch},2)
                                % add ROI option
                                EEG_epoch_structs{curr_epoch} = pop_eegthresh(EEG_epoch_structs{curr_epoch},1,file_proc_info.beapp_indx{curr_epoch}',-1* grp_proc_info_in.art_thresh,grp_proc_info_in.art_thresh,[EEG_epoch_structs{curr_epoch}.xmin],[EEG_epoch_structs{curr_epoch}.xmax],2,0);
                            else
                                EEG_epoch_structs{curr_epoch} = pop_eegthresh(EEG_epoch_structs{curr_epoch},1,file_proc_info.beapp_indx{curr_epoch},-1* grp_proc_info_in.art_thresh,grp_proc_info_in.art_thresh,[EEG_epoch_structs{curr_epoch}.xmin],[EEG_epoch_structs{curr_epoch}.xmax],2,0);
                            end
                            
                            if grp_proc_info_in.beapp_happe_segment_rejection
                                tmp_chk = EEG_epoch_structs{curr_epoch}.data;
                                tmp_chk(isnan(tmp_chk)) = 1000;
                                
                                % run pop_jointprob if no all zero channels
                                if all(any(any(tmp_chk,3),2))
                                    chan_labels = {EEG_epoch_structs{curr_epoch}.chanlocs(file_proc_info.beapp_indx{curr_epoch}).labels};
                                    EEG_epoch_structs{curr_epoch} = pop_select(EEG_epoch_structs{curr_epoch},'channel', chan_labels);
                                    EEG_epoch_structs{curr_epoch} = pop_jointprob(EEG_epoch_structs{curr_epoch},1,[1:length(chan_labels)],3,3,grp_proc_info_in.beapp_happe_seg_rej_plotting_on,...
                                        0,grp_proc_info_in.beapp_happe_seg_rej_plotting_on,[],0);
                                else
                                    warning([file_proc_info.beapp_fname{1} ': cannot run pop_jointprob because at least one channel contains all zeros']);
                                end
                            end
                            
                            EEG_epoch_structs{curr_epoch} = eeg_rejsuperpose(EEG_epoch_structs{curr_epoch}, 1, 0, 1, 1, 1, 1, 1, 1);
                        end
                        
                        %Remove the baseline using the prestimulus average
                        % selected by user
                        if grp_proc_info_in.evt_trial_baseline_removal
                            EEG_epoch_structs{curr_epoch}=pop_rmbase(EEG_epoch_structs{curr_epoch},[grp_proc_info_in.evt_trial_baseline_win_start*1000 grp_proc_info_in.evt_trial_baseline_win_end*1000]);
                        end
                        
                        % moving average filter if selected
                        if grp_proc_info_in.beapp_erp_maf_on
                            EEG_epoch_structs{curr_epoch}=pop_firma(EEG_epoch_structs{curr_epoch},'forder',grp_proc_info_in.beapp_erp_maf_order);
                        end
                        
                        % use beapp event list, since EEGLAB list will count
                        % multiple valid tags in one segment
                        all_tag_list = {file_proc_info.evt_info{curr_epoch}(:).type};
                        non_targ_idx = find(ismember(all_tag_list, 'Non_Target'));
                        all_tag_list(non_targ_idx) = [];
                        
                        % allocate segments according to dataset wide
                        % conditions analyzed, not what is in file
                        for curr_condition = 1:length(file_proc_info.grp_wide_possible_cond_names_at_segmentation)
                            
                            targ_cond_logical = ismember(all_tag_list, file_proc_info.grp_wide_possible_cond_names_at_segmentation{curr_condition});
                            
                            if isempty(EEG_epoch_structs{curr_epoch}.reject.rejglobal)
                                % if no segment rejection was run, keep all
                                % segments
                                tmp_EEG_struct_rejglobal = ones(1,size(EEG_epoch_structs{curr_epoch}.data,3));
                            else
                                % get segments to keep, not segments to
                                % reject
                                tmp_EEG_struct_rejglobal = not([EEG_epoch_structs{curr_epoch}.reject.rejglobal]);
                            end
                            
                            segs_to_keep = all([targ_cond_logical; tmp_EEG_struct_rejglobal]);
                            
                            %convert back to BEAPP format
                            if ~isempty(segs_to_keep)
                                if length(EEG_epoch_structs{curr_epoch}.chanlocs) == size(eeg{curr_epoch},1)
                                    eeg_w{curr_condition,1}= cat(3,eeg_w{curr_condition,1},EEG_epoch_structs{curr_epoch}.data(:,:,segs_to_keep));
                                else
                                    tmp_eeg_arr = NaN(size(eeg{curr_epoch},1),size(EEG_epoch_structs{curr_epoch}.data,2),sum(segs_to_keep));
                                    tmp_eeg_arr(file_proc_info.beapp_indx{curr_epoch},:,:) = EEG_epoch_structs{curr_epoch}.data(:,:,segs_to_keep);
                                    eeg_w{curr_condition,1}= cat(3,eeg_w{curr_condition,1},tmp_eeg_arr);
                                end
                            elseif isempty(eeg_w{curr_condition,1})
                                eeg_w{curr_condition,1} = [];
                            end
                            
                            clear  targ_cond_logical segs_to_keep tmp_EEG_struct_rejglobal
                        end
                    else
                        diary on;
                        warning ([file_proc_info.beapp_fname{1} ' epoch ' int2str(curr_epoch) ': no target events found in epoch, no segments created']);
                        diary off;
                    end
                    
                    clear all_tag_list non_targ_idx
                end
            end
        end
        
        diary on;
        
        if ~all(cellfun(@isempty,eeg_w))
            file_proc_info = beapp_prepare_to_save_file('segment',file_proc_info, grp_proc_info_in, src_dir{1});
            save(file_proc_info.beapp_fname{1},'file_proc_info','eeg_w');
        end
        clearvars -except grp_proc_info_in curr_file src_dir
    end
end