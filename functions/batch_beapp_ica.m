%% batch_beapp_ica (grp_proc_info)
%
% Apply  ICA + MARA, HAPPE, or ICA to the data according to
% grp_proc_info.ica_type, generate output report if user selected
%
% ICA+ MARA and HAPPE outputs will have backprojected components
% output for ICA alone will be raw data + ICA weights and sphere matrices
%
% HAPP-E Version 1.0
% Gabard-Durnam LJ, Méndez Leal AS, and Levin AR (2017) The Harvard Automated Pre-processing Pipeline for EEG (HAPP-E)
% Manuscript in preparation
%
% MARA
% Irene Winkler, Stefan Haufe and Michael Tangermann. Automatic Classification of Artifactual
% ICA-Components for Artifact Removal in EEG Signals. Behavioral and Brain Functions, 7:30, 2011.
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
function grp_proc_info_in = batch_beapp_ica(grp_proc_info_in)

src_dir = find_input_dir('ica',grp_proc_info_in.beapp_toggle_mods);

% initialize report. depending on setting some values will not be generated
if grp_proc_info_in.beapp_toggle_mods{'ica','Module_Xls_Out_On'}
    if grp_proc_info_in.beapp_toggle_mods{'ica','Module_Xls_Out_On'}
    ica_report_categories = {'BEAPP_Fname','Time_Elapsed_For_File','Num_Rec_Periods', 'Number_Channels_UserSelected',...
        'File_Rec_Period_Lengths_In_Secs','Number_Good_Channels_Selected_Per_Rec_Period', ...
        'Interpolated_Channel_IDs_Per_Rec_Period', 'Percent_ICs_Rejected_Per_Rec_Period', ...
        'Percent_Variance_Kept_of_Data_Input_to_MARA_Per_Rec_Period', ...
        'Mean_Artifact_Probability_of_Kept_ICs_Per_Rec_Period','Median_Artifact_Probability_of_Kept_ICs_Per_Rec_Period'};
    ICA_report_table= cell2table(cell(length(grp_proc_info_in.beapp_fname_all),length(ica_report_categories)));
    ICA_report_table.Properties.VariableNames=ica_report_categories;
    ICA_report_table.BEAPP_Fname = grp_proc_info_in.beapp_fname_all';
    end
end

% add path to cleanline
if exist('cleanline', 'file')
    cleanline_path = which('eegplugin_cleanline.m');
    cleanline_path = cleanline_path(1:findstr(cleanline_path,'eegplugin_cleanline.m')-1);
    addpath(genpath(cleanline_path));
end

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    tic
    cd(src_dir{1})
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        
        try
            load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        catch 
            disp('Problem Loading')
            pause(5)
            load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        end

        tic;
%        epoch_length = file_proc_info.src_epoch_nsamps / file_proc_info.src_srate;
%         if epoch_length < 15 && ~grp_proc_info_in.beapp_ica_type==3
%            warning(strcat('Current file length=',num2str(epoch_length),...
%                '_seconds. MARA requires at least 15 seconds of data to work correctly'))
%         end
        %FOR TESTING
        uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
        ica_chan_labels_in_eeglab_format = {file_proc_info.net_vstruct(grp_proc_info_in.beapp_ica_additional_chans_lbls{uniq_net_ind}).labels};
%         use_all_10_20s = 1;
%         if grp_proc_info_in.beapp_ica_type == 3 && grp_proc_info_in.beapp_ica_run_all_10_20 == 0
%             use_all_10_20s = 0;
%         end
        %%REMOVES REPETITIVE CHANS (WILL BREAK HAPPE IF PRESENT)
        chans2remove = [];
        rmv_idx = 1;
         for chan1 = 1:size(eeg{1,1},1)
            for chan2 = 1:size(eeg{1,1},1)
                if ~(chan1 == chan2)
                  %  if ~(any(eeg{1,1}(chan1,:) == eeg{1,1}(chan2,:)==0))
                    if (sum(eeg{1,1}(chan1,:) == eeg{1,1}(chan2,:))) > size(eeg{1,1})/2
                        chans2remove(1,rmv_idx) = chan1;
                        rmv_idx = rmv_idx+1;
                    end
                end 
            end
        end
        chans2remove = unique(chans2remove);
        grp_proc_info_in.beapp_indx_chans_to_exclude{1,1} = chans2remove;
        if ~isempty(chans2remove)
           warning(['Channels ' num2str(chans2remove) ' demonstrated identical or no data; those channels were removed from further analysis']);
        end
        % select channels depending on user settings
        [chan_IDs, file_proc_info] = beapp_ica_select_channels_for_file (file_proc_info,grp_proc_info_in.src_unique_nets,...
            ica_chan_labels_in_eeglab_format,grp_proc_info_in.name_10_20_elecs,grp_proc_info_in.beapp_indx_chans_to_exclude,...
            grp_proc_info_in.beapp_ica_run_all_10_20,grp_proc_info_in.beapp_ica_10_20_chans_lbls,grp_proc_info_in.name_selected_10_20_chans_lbls);
        
        for curr_rec_period = 1:size(eeg,2)
            
            % make EEGLAB struct, change 10-20 electrode labels for MARA
            EEG_orig = curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_rec_period},curr_rec_period);
            
            % if HAPPE, run 1-250 bandpass filter, cleanline, and reject channels
            % either way, select EEG channels of interest for analyses
            if grp_proc_info_in.beapp_ica_type == 2
                [EEG_tmp, full_selected_channels,file_proc_info.beapp_filt_max_freq] = happe_bandpass_cleanline_rejchan (EEG_orig,chan_IDs,...
                    file_proc_info.beapp_srate, file_proc_info.src_linenoise,file_proc_info.beapp_filt_max_freq);
            else
                EEG_tmp = pop_select(EEG_orig,'channel', chan_IDs);
                full_selected_channels = EEG_tmp.chanlocs;
                diary off;
            end
            
            if grp_proc_info_in.beapp_rmv_bad_chan_on
                [chan_name_indx_dict(:,1), file_proc_info.beapp_indx{curr_rec_period}] = intersect({file_proc_info.net_vstruct.labels},{EEG_tmp.chanlocs.labels},'stable');
            else
                [chan_name_indx_dict(:,1), file_proc_info.beapp_indx{curr_rec_period}] = intersect({file_proc_info.net_vstruct.labels},{full_selected_channels.labels},'stable');
            end
            
            % save reporting information
            ica_report_struct.good_chans_per_rec_period(curr_rec_period) = length({EEG_tmp.chanlocs.labels});
            ica_report_struct.rec_period_lengths_in_secs(curr_rec_period) = (length(eeg{curr_rec_period})/file_proc_info.beapp_srate);
            ica_report_struct.num_interp_per_rec_period(curr_rec_period) = length(chan_IDs) - length({EEG_tmp.chanlocs.labels});
            
            % save channels used in file_proc_info
            file_proc_info.beapp_nchans_used(curr_rec_period) = length(file_proc_info.beapp_indx{curr_rec_period});
            chan_name_indx_dict(:,2) = num2cell(file_proc_info.beapp_indx{curr_rec_period});
            [~,ind_marked_bad_chans]= intersect({file_proc_info.net_vstruct.labels},setdiff({full_selected_channels.labels},{EEG_tmp.chanlocs.labels}),'stable');
            %ERROR REPORTED HERE: horzcat error; ind_marked_bad_chans was a
            %column, can't be concatenated with a row
            file_proc_info.beapp_bad_chans{curr_rec_period} = unique([file_proc_info.beapp_bad_chans{curr_rec_period} ind_marked_bad_chans]);
            
            % if HAPPE is selected, run wICA on file
            if grp_proc_info_in.beapp_ica_type == 2
                EEG_tmp = happe_run_wICA_on_file(EEG_tmp, file_proc_info.beapp_srate, grp_proc_info_in.happe_plotting_on);
            end
            
            % run ICA to evaluate components this time
            EEG_after_ICA = pop_runica(EEG_tmp, 'extended',1,'interupt','on','verbose', 'off');
            
            if (grp_proc_info_in.beapp_ica_type == 1) || (grp_proc_info_in.beapp_ica_type == 2)
                %use MARA to flag artifactual IComponents automatically if artifact probability > .5
                [EEG_out,ica_report_struct,skip_file]  = beapp_ica_run_mara (EEG_after_ICA,file_proc_info.beapp_fname{1},grp_proc_info_in.happe_plotting_on,ica_report_struct,curr_rec_period);
                
                % skip recording period if all components rejected
                if skip_file, continue; end;
            else
                EEG_out = EEG_after_ICA;
                icaweights = EEG_out.icaweights;
                icasphere = EEG_out.icasphere;
            end
            
            diary on;
            
            if grp_proc_info_in.beapp_ica_type == 2
                if ~grp_proc_info_in.beapp_rmv_bad_chan_on
                    %interpolate channels marked bad above, reference data
                    EEG_out = pop_interp(EEG_out, full_selected_channels, 'spherical');
                end
                EEG_out = pop_reref(EEG_out, [], 'exclude', ind_marked_bad_chans);
            end
            
            eeg{curr_rec_period} = NaN(size(eeg{curr_rec_period}));
            [~,~,inds_in_dict]=intersect({EEG_out.chanlocs.labels},chan_name_indx_dict(:,1),'stable');
            eeg{curr_rec_period}(cell2mat(chan_name_indx_dict(inds_in_dict,2)),:) = EEG_out.data;
            clear chan_name_indx_dict
        end
        
        file_ica_toc = toc;
        file_proc_info.ica_stats.Time_Elapsed_For_File = {num2str(file_ica_toc/60)};
        
        if grp_proc_info_in.beapp_toggle_mods{'ica','Module_Xls_Out_On'}
            ICA_report_table.Num_Rec_Periods(curr_file) = num2cell(curr_rec_period);
            ICA_report_table.File_Rec_Period_Lengths_In_Secs(curr_file) = {ica_report_struct.rec_period_lengths_in_secs};
            ICA_report_table.Number_Channels_UserSelected(curr_file) = {length(chan_IDs)};
            ICA_report_table.Number_Good_Channels_Selected_Per_Rec_Period(curr_file) = {ica_report_struct.good_chans_per_rec_period};
            if ~all(cellfun(@isempty,file_proc_info.beapp_bad_chans))
                tmp = cellfun(@mat2str,file_proc_info.beapp_bad_chans, 'UniformOutput',0);
                ICA_report_table.Interpolated_Channel_IDs_Per_Rec_Period(curr_file) =tmp;
            else
                ICA_report_table.Interpolated_Channel_IDs_Per_Rec_Period(curr_file) ={''};
            end
            if ~(grp_proc_info_in.beapp_ica_type ==3)
                ICA_report_table.Percent_ICs_Rejected_Per_Rec_Period(curr_file) = {ica_report_struct.percent_ICs_rej_per_rec_period};
                ICA_report_table.Percent_Variance_Kept_of_Data_Input_to_MARA_Per_Rec_Period(curr_file) = {ica_report_struct.perc_var_post_wave_per_rec_period};
                ICA_report_table.Mean_Artifact_Probability_of_Kept_ICs_Per_Rec_Period(curr_file) = {ica_report_struct.mn_art_prob_per_rec_period};
                ICA_report_table.Median_Artifact_Probability_of_Kept_ICs_Per_Rec_Period(curr_file) = {ica_report_struct.median_art_prob_per_rec_period};
            end
            ICA_report_table.Time_Elapsed_For_File(curr_file) = {num2str(file_ica_toc/60)};
        end
        
        file_proc_info.ica_stats.Number_Good_Channels_Selected_Per_Rec_Period = {ica_report_struct.good_chans_per_rec_period};
        
        if ~(grp_proc_info_in.beapp_ica_type ==3)
            file_proc_info.ica_stats.Percent_ICs_Rejected_Per_Rec_Period = {ica_report_struct.percent_ICs_rej_per_rec_period};
            file_proc_info.ica_stats.Percent_Variance_Kept_of_Data_Input_to_MARA_Per_Rec_Period = {ica_report_struct.perc_var_post_wave_per_rec_period};
            file_proc_info.ica_stats.Mean_Artifact_Probability_of_Kept_ICs_Per_Rec_Period = {ica_report_struct.mn_art_prob_per_rec_period};
            file_proc_info.ica_stats.Median_Artifact_Probability_of_Kept_ICs_Per_Rec_Period = {ica_report_struct.median_art_prob_per_rec_period};
        end
        
        if ~all(cellfun(@isempty,eeg))            
            file_proc_info = beapp_prepare_to_save_file('ica',file_proc_info, grp_proc_info_in, src_dir{1});
            if grp_proc_info_in.beapp_ica_type ==3
                save(file_proc_info.beapp_fname{1},'eeg','file_proc_info','icaweights','icasphere');
            else 
                save(file_proc_info.beapp_fname{1},'eeg','file_proc_info');
            end 
            %pop_saveset(EEG_out,[strrep(file_proc_info.beapp_fname{1},'mat','') '_post_ICA']);
        end
        
        clearvars -except grp_proc_info_in curr_file src_dir ICA_report_table cleanline_path ica_report_struct
    end
end

% save report if user selected option
cd (grp_proc_info_in.beapp_genout_dir{1})
if grp_proc_info_in.beapp_toggle_mods{'ica','Module_Xls_Out_On'}
    writetable(ICA_report_table, ['ICA_Report_Table ',grp_proc_info_in.beapp_curr_run_tag,'.csv']);
end

% remove cleanline path
rmpath(genpath(cleanline_path));
