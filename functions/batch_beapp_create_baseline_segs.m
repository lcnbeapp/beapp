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
function batch_beapp_create_baseline_segs(grp_proc_info_in)

src_dir = find_input_dir('segment',grp_proc_info_in.beapp_toggle_mods);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
  
    cd(src_dir{1});
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        
        file_proc_info.beapp_win_size_in_samps=grp_proc_info_in.win_size_in_secs*file_proc_info.beapp_srate;
        
        if grp_proc_info_in.src_data_type ==1
            % baseline should only have one condition, for now -- will
            % eventually have option for eyes open eyes closed etc
            file_proc_info.evt_conditions_being_analyzed = table(NaN,{'baseline'},{''},'VariableNames',{'Evt_Codes','Condition_Name','Native_File_Condition_Name'});
            file_proc_info.grp_wide_possible_cond_names_at_segmentation = {'baseline'};
        else
            error('BEAPP Developer: beta does not have the ability to run conditioned baseline');
        end
        
        % initialize mask and output for current recording period
        eeg_msk = cell(1,size(eeg,2));
        eeg_w=[];
        
        for curr_epoch = 1:size(eeg,2)
            
            % if user has selected pre-segmentation artifact rejection,
            % generate mask
            if grp_proc_info_in.beapp_baseline_msk_artifact ~= 0
                [eeg_msk{curr_epoch},file_proc_info] = beapp_msk_art(eeg{curr_epoch}, grp_proc_info_in,file_proc_info,curr_epoch);
            else
                eeg_msk{curr_epoch}=zeros(1,size(eeg{curr_epoch},2));
            end
            
            %find the periods where there is continuous good data for at least as
            %many samples as there are in the user defined window size
            tmp_eeg_w = beapp_extract_segments(eeg_msk,file_proc_info,grp_proc_info_in,eeg,curr_epoch);
            
            % stacks usable segments across epochs
            eeg_w=cat(3, eeg_w, tmp_eeg_w);
            
            clear tmp_eeg_w grouped_good_data pot_good_windows segment_num good_data
        end
        
        % short term, until we add eyes open and eyes closed etc conditions
        eeg_w={eeg_w};
        
        if ~isempty(eeg_w{1})
            
            % if desired, remove segments with artifact above user threshold
            if grp_proc_info_in.beapp_reject_segs_by_amplitude || grp_proc_info_in.beapp_happe_segment_rejection
                
                EEG_tmp= curr_epoch_beapp2eeglab(file_proc_info,eeg_w{1},1);
                
                % detrend segment according to user preference
                EEG_tmp.data = detrend_segment(EEG_tmp.data,grp_proc_info_in.segment_linear_detrend);
                
                % post segmentation amplitude artifact rejection, with stopgap fix during beta testing 
                if size(file_proc_info.beapp_indx{1},1) > size(file_proc_info.beapp_indx{1},2)
                    % add ROI option
                    EEG_tmp = pop_eegthresh(EEG_tmp,1,file_proc_info.beapp_indx{1}',-1* grp_proc_info_in.art_thresh,grp_proc_info_in.art_thresh,[EEG_tmp.xmin],[EEG_tmp.xmax],2,0);
                else
                    EEG_tmp = pop_eegthresh(EEG_tmp,1,file_proc_info.beapp_indx{1},-1* grp_proc_info_in.art_thresh,grp_proc_info_in.art_thresh,[EEG_tmp.xmin],[EEG_tmp.xmax],2,0);
                end
                
                if grp_proc_info_in.beapp_happe_segment_rejection
                    tmp_chk = EEG_tmp.data;
                    tmp_chk(isnan(tmp_chk)) = 1000;
                    
                    % run pop_jointprob if no all zero channels, take out
                    % any NaNs
                    if all(any(any(tmp_chk,3),2))
                        chan_labels = {EEG_tmp.chanlocs(file_proc_info.beapp_indx{curr_epoch}).labels};
                        EEG_tmp = pop_select(EEG_tmp,'channel', chan_labels);
                        EEG_tmp = pop_jointprob(EEG_tmp,1,[1:length(chan_labels)],3,3,grp_proc_info_in.beapp_happe_seg_rej_plotting_on,0,...
                            grp_proc_info_in.beapp_happe_seg_rej_plotting_on,[],0);
                    else
                        warning([file_proc_info.beapp_fname{1} ': cannot run pop_jointprob because at least one channel contains all zeros']);
                    end
                end
                
                EEG_tmp = eeg_rejsuperpose(EEG_tmp, 1, 0, 1, 1, 1, 1, 1, 1);
                EEG_tmp = pop_rejepoch(EEG_tmp, [EEG_tmp.reject.rejglobal] ,0);
                
                % put NaNs back in if needed
                if length(EEG_tmp.chanlocs) == size(eeg{curr_epoch},1)
                    eeg_w{1} = EEG_tmp.data; clear EEG_tmp;
                else
                    tmp_eeg_arr = NaN(size(eeg{curr_epoch},1),size(EEG_tmp.data,2),size(EEG_tmp.data,3));
                    tmp_eeg_arr(file_proc_info.beapp_indx{curr_epoch},:,:) = EEG_tmp.data;
                    eeg_w{1} = tmp_eeg_arr;
                end
            end
        end
                
        if ~all(cellfun(@isempty,eeg_w))
            file_proc_info = beapp_prepare_to_save_file('segment',file_proc_info, grp_proc_info_in, src_dir{1});
            save(file_proc_info.beapp_fname{1},'eeg_w','file_proc_info','eeg_msk');
        end
        clearvars -except grp_proc_info_in curr_file src_dir
    end
end
