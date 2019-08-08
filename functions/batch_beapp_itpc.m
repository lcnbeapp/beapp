%% batch_beapp_itpc(grp_proc_info)
%
% calculate ITPC for segment window using newtimef, report desired ITPC
% values for analysis window into table if selected
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
function grp_proc_info_in = batch_beapp_itpc(grp_proc_info_in)

src_dir = find_input_dir('itpc',grp_proc_info_in.beapp_toggle_mods);
report_initialized = 0;
ntabs=grp_proc_info_in.beapp_itpc_xlsout_mx_on+grp_proc_info_in.beapp_itpc_xlsout_av_on;

%TEMP VARS (if used move to inputs)


for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    cd(src_dir{1});
    
    if exist(grp_proc_info_in.beapp_fname_all{curr_file},'file')
        
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg_w','file_proc_info');
        tic;
        if exist('eeg_w','var')
            
            % collect file information for output report if user selected
            if grp_proc_info_in.beapp_toggle_mods{'itpc','Module_Xls_Out_On'}
                if ~report_initialized
                    [report_info,all_condition_labels,all_obsv_sizes,itpc_report_values] = beapp_init_generic_analysis_report (grp_proc_info_in.beapp_fname_all,...
                        file_proc_info.grp_wide_possible_cond_names_at_segmentation,grp_proc_info_in.largest_nchan,(length(grp_proc_info_in.bw_name)+1),ntabs);
                    report_initialized = 1;
                end
                
                [report_info,all_condition_labels,all_obsv_sizes] = beapp_add_row_generic_analysis_report(report_info,...
                    all_condition_labels,all_obsv_sizes,curr_file,file_proc_info,eeg_w);
            end
            disp([strcat('File',num2str(curr_file))])            
            for curr_condition = 1:size(eeg_w,1)
  
                if ~isempty(grp_proc_info_in.win_select_n_trials)
                    if size(eeg_w{curr_condition,1},3)>= grp_proc_info_in.win_select_n_trials
                        
                        % only keep n trials
                        inds_to_select = sort(randperm(size(eeg_w{curr_condition,1},3),grp_proc_info_in.win_select_n_trials));
                        eeg_w{curr_condition,1} = eeg_w{curr_condition,1}(:,:,inds_to_select);
                    else
                        % if not enough trials in this condition
                        disp(['BEAPP file: ' file_proc_info.beapp_fname{1} ' condition ' file_proc_info.grp_wide_possible_cond_names_at_segmentation{curr_condition} ' does not have the user selected number of segments. Skipping...']);
                        eeg_itc{curr_condition,1} = [];
                        % go to next condition in the for loop
                        continue;
                    end
                end
            
                
                diary off;

                analysis_win_start = file_proc_info.evt_seg_win_evt_ind + floor((grp_proc_info_in.evt_analysis_win_start .* file_proc_info.beapp_srate));
                analysis_win_end = file_proc_info.evt_seg_win_evt_ind + floor((grp_proc_info_in.evt_analysis_win_end .* file_proc_info.beapp_srate))-1;
            
                if size(eeg_w{curr_condition},1)>0
                    for curr_chan=1:size(eeg_w{curr_condition},1)
                        if ismember(curr_chan,file_proc_info.beapp_indx{1,1})
                            %run newtimef to compute the psd baseline for
                            %the first stim
                            %'winsize',floor(grp_proc_info_in.beapp_itpc_params.win_size*file_proc_info.beapp_srate)
                            %if curr_chan==1 %TEMP (for speed)
                            if grp_proc_info_in.beapp_itpc_params.baseline_norm == 1
                                if grp_proc_info_in.beapp_itpc_params.use_common_baseline
                                    if curr_condition == grp_proc_info_in.beapp_itpc_params.common_baseline_idx
                                        if grp_proc_info_in.beapp_itpc_params.set_freq_range
                                            [~,~,powbase{curr_condition,1}(curr_chan,:),t_powbase,f_powbase]...
                                                =newtimef(eeg_w{1,1}(curr_chan,analysis_win_start:analysis_win_end,:),size(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),2),...
                                                [grp_proc_info_in.evt_analysis_win_start*1000 grp_proc_info_in.evt_analysis_win_end*1000],...
                                                file_proc_info.beapp_srate,[grp_proc_info_in.beapp_itpc_params.min_cyc grp_proc_info_in.beapp_itpc_params.max_cyc],...
                                                'freqs',[grp_proc_info_in.beapp_itpc_params.min_freq grp_proc_info_in.beapp_itpc_params.max_freq],...
                                                'itctype','phasecoher','wletmethod','dftfilt3',...
                                                'plotmean','off','plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off','verbose','off','baseline',...
                                                [grp_proc_info_in.evt_trial_baseline_win_start*1000 grp_proc_info_in.evt_trial_baseline_win_end*1000]);
                                        else
                                              [~,~,powbase{curr_condition,1}(curr_chan,:),t_powbase,f_powbase]...
                                                =newtimef(eeg_w{1,1}(curr_chan,analysis_win_start:analysis_win_end,:),size(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),2),...
                                                [grp_proc_info_in.evt_analysis_win_start*1000 grp_proc_info_in.evt_analysis_win_end*1000],...
                                                file_proc_info.beapp_srate,[grp_proc_info_in.beapp_itpc_params.min_cyc grp_proc_info_in.beapp_itpc_params.max_cyc],...
                                                'itctype','phasecoher','wletmethod','dftfilt3',...
                                                'plotmean','off','plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off','verbose','off','baseline',...
                                                [grp_proc_info_in.evt_trial_baseline_win_start*1000 grp_proc_info_in.evt_trial_baseline_win_end*1000]);
                                        end

                                    else
                                        powbase{curr_condition,1}(curr_chan,:) = powbase{grp_proc_info_in.beapp_itpc_params.common_baseline_idx,1}(curr_chan,:);
                                    end
                                else
                                    powbase{curr_condition,1}(curr_chan,:) = NaN; %NaN input will lead eeglab to make powbase per stim
                                    f_powbase(curr_chan,:) = NaN; %NaN input will lead eeglab to make powbase per stim
                                end
                                %use first baseline for each condition
                                if grp_proc_info_in.beapp_itpc_params.set_freq_range
                                    [ERSP{curr_condition,1}(curr_chan,:,:),eeg_itc{curr_condition,1}(curr_chan,:,:),powbase_2{curr_condition,1}(curr_chan,:),t{curr_condition,1},f{curr_condition,1},~,~]...
                                        =newtimef(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),size(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),2),...
                                        [grp_proc_info_in.evt_analysis_win_start*1000 grp_proc_info_in.evt_analysis_win_end*1000],...
                                        file_proc_info.beapp_srate,[grp_proc_info_in.beapp_itpc_params.min_cyc grp_proc_info_in.beapp_itpc_params.max_cyc],...  
                                        'freqs',[grp_proc_info_in.beapp_itpc_params.min_freq grp_proc_info_in.beapp_itpc_params.max_freq],'powbase',powbase{curr_condition,1}(curr_chan,:),'itctype','phasecoher',...
                                        'plotmean','off','plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off','verbose',...
                                        'off','wletmethod','dftfilt3');
                                else
                                    [ERSP{curr_condition,1}(curr_chan,:,:),eeg_itc{curr_condition,1}(curr_chan,:,:),powbase_2{curr_condition,1}(curr_chan,:),t{curr_condition,1},f{curr_condition,1},~,~]...
                                        =newtimef(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),size(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),2),...
                                        [grp_proc_info_in.evt_analysis_win_start*1000 grp_proc_info_in.evt_analysis_win_end*1000],...
                                        file_proc_info.beapp_srate,[grp_proc_info_in.beapp_itpc_params.min_cyc grp_proc_info_in.beapp_itpc_params.max_cyc],...  
                                        'powbase',powbase{curr_condition,1}(curr_chan,:),'itctype','phasecoher',...
                                        'plotmean','off','plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off','verbose',...
                                        'off','wletmethod','dftfilt3');
                                end

                            else
                                if grp_proc_info_in.beapp_itpc_params.set_freq_range
                                    [ERSP{curr_condition,1}(curr_chan,:,:),eeg_itc{curr_condition,1}(curr_chan,:,:),powbase_2{curr_condition,1}(curr_chan,:),t{curr_condition,1},f{curr_condition,1},~,~]...
                                        =newtimef(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),size(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),2),...
                                        [grp_proc_info_in.evt_analysis_win_start*1000 grp_proc_info_in.evt_analysis_win_end*1000],...
                                        file_proc_info.beapp_srate,[grp_proc_info_in.beapp_itpc_params.min_cyc grp_proc_info_in.beapp_itpc_params.max_cyc],... 
                                        'baseline',NaN,'itctype','phasecoher','freqs',... 
                                        [grp_proc_info_in.beapp_itpc_params.min_freq grp_proc_info_in.beapp_itpc_params.max_freq],...
                                        'plotmean','off','plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off','verbose',...
                                        'off');
                                        powbase{curr_condition,1}(curr_chan,:) = NaN;
                                        f_powbase(curr_chan,:) = NaN; 
                                else
                                    [ERSP{curr_condition,1}(curr_chan,:,:),eeg_itc{curr_condition,1}(curr_chan,:,:),powbase_2{curr_condition,1}(curr_chan,:),t{curr_condition,1},f{curr_condition,1},~,~]...
                                        =newtimef(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),size(eeg_w{curr_condition,1}(curr_chan,analysis_win_start:analysis_win_end,:),2),...
                                        [grp_proc_info_in.evt_analysis_win_start*1000 grp_proc_info_in.evt_analysis_win_end*1000],...
                                        file_proc_info.beapp_srate,[grp_proc_info_in.beapp_itpc_params.min_cyc grp_proc_info_in.beapp_itpc_params.max_cyc],... 
                                        'baseline',NaN,'itctype','phasecoher',... 
                                        'plotmean','off','plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off','verbose',...
                                        'off');
                                        powbase{curr_condition,1}(curr_chan,:) = NaN;
                                        f_powbase(curr_chan,:) = NaN; 
                                end
                            end
                        end
                     end
                else
                    eeg_itc{curr_condition,1} =[];
                end

                % analyze desired part of segment for event related data
                if grp_proc_info_in.src_data_type ==2
                    try
                        analysis_win_start_t_ind = find(t{curr_condition,1} >= grp_proc_info_in.evt_analysis_win_start*1000,1,'first');
                  
                        analysis_win_end_t_ind = find(t{curr_condition,1} <= grp_proc_info_in.evt_analysis_win_end*1000,1,'last');
                        
                    catch err
                        if strcmp(err.identifier,'MATLAB:badsubscript')
                            error('BEAPP: ITPC analysis segment boundary selected falls outside boundaries used to segment data. Change inputs or re-segment');
                        else
                            error(err);
                        end
                    end
                else
                    error('BEAPP: ITPC cannot be run on baseline data');
                end

                diary on;
                % calculate output statistics selected by user on analysis
                % window
                
                if ~isempty(eeg_itc{curr_condition,1}) && grp_proc_info_in.beapp_toggle_mods{'itpc','Module_Xls_Out_On'}
                    itpc_report_values{curr_condition,1}(curr_file,:,:) = beapp_calc_itpc_output(grp_proc_info_in,file_proc_info,eeg_itc{curr_condition,1}(:,:,analysis_win_start_t_ind: analysis_win_end_t_ind),...
                        f{curr_condition,1},t{curr_condition,1});
                end
            end
            
            if ~all(cellfun(@isempty,eeg_itc))
                file_proc_info = beapp_prepare_to_save_file('itpc',file_proc_info, grp_proc_info_in, src_dir{1});
                save(file_proc_info.beapp_fname{1},'file_proc_info','eeg_itc','ERSP','t','f','powbase','f_powbase');
            end
        else
            disp(['no usable segments were found in ' file_proc_info.beapp_fname ',itpc not calculated']);
        end
        clearvars -except grp_proc_info_in curr_file src_dir report_info itpc_report_values  all_condition_labels all_obsv_sizes report_initialized ntabs
    end
end

if grp_proc_info_in.beapp_toggle_mods{'itpc','Module_Xls_Out_On'}
    cd(grp_proc_info_in.beapp_toggle_mods{'itpc','Module_Dir'}{1});
    mk_itpc_report(grp_proc_info_in,report_info,itpc_report_values, all_condition_labels, all_obsv_sizes);
end
