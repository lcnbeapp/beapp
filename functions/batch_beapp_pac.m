%% batch_beapp_pac (grp_proc_info)
%  NOTE: only works for 1 condition currently
%  a module to run phase-amplitude-coupling 
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

function batch_beapp_pac (grp_proc_info_in)

src_dir = find_input_dir('pac',grp_proc_info_in.beapp_toggle_mods);
%Preallocate arrays and matrices
max_n_channels = 256; %maximum number of channels in the EEG dataset -- currently hardcoded

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
  
    cd(src_dir{1});
     if grp_proc_info_in.pac_save_all_reports == 1 ||  ...
             ismember(grp_proc_info_in.beapp_fname_all{curr_file}, grp_proc_info_in.pac_save_participants) ||...%%If we're saving reports, make source directory
             ~isempty(grp_proc_info_in.pac_save_channels)
         cd(grp_proc_info_in.beapp_toggle_mods{'pac','Module_Dir'}{1});
        mkdir(strcat(erase(grp_proc_info_in.beapp_fname_all{curr_file},'.mat'),'_image_outputs'));
        cd(src_dir{1});
     end
   
      if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
         % load eeg if module takes continuous input
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg_w','file_proc_info');
        if size(file_proc_info.beapp_indx{1,1},2) == 1 %flip beapp_indx if needed
            file_proc_info.beapp_indx{1,1} = file_proc_info.beapp_indx{1,1}';
        end
        comodulogram_third_dim_headers = cell(1,size(file_proc_info.beapp_indx{1,1},2));
        curr_eeg = eeg_w{1,1}; %used to be: eeg_wfp_mean_all = mean(eeg_w{1,1},3);
        if grp_proc_info_in.slid_win_on == 1
            amount2slide = .1; %fraction of the window size to increment
            num_slides = floor((file_proc_info.beapp_win_size_in_samps - grp_proc_info_in.slid_win_sz*file_proc_info.beapp_srate)...
                             / (file_proc_info.beapp_srate * amount2slide));
            comodulogram =  NaN(grp_proc_info_in.pac_high_fq_res, grp_proc_info_in.pac_low_fq_res,max_n_channels,num_slides);
            comodulogram_4th_dim_headers = NaN(1,num_slides);
        else
            if ~isempty(grp_proc_info_in.win_select_n_trials)
                comodulogram = NaN(grp_proc_info_in.pac_high_fq_res, grp_proc_info_in.pac_low_fq_res,max_n_channels,grp_proc_info_in.win_select_n_trials); %num chans hard coded temporarily
            else
                comodulogram = NaN(grp_proc_info_in.pac_high_fq_res, grp_proc_info_in.pac_low_fq_res,max_n_channels,size(curr_eeg,3)); %num chans hard coded temporarily
            end
        end
        if grp_proc_info_in.pac_calc_zscores
            z_score_comod = NaN(grp_proc_info_in.pac_high_fq_res, grp_proc_info_in.pac_low_fq_res,max_n_channels,grp_proc_info_in.pac_num_segs);
            surr_max = NaN(max_n_channels,200,grp_proc_info_in.pac_num_segs); %200 = num surrogates
        end
        amp_dist = NaN(grp_proc_info_in.pac_high_fq_res, grp_proc_info_in.pac_low_fq_res,18,grp_proc_info_in.win_select_n_trials,18,201); %18 = N_bins ... don't init channels to minimize variable size
%         phase = -3.1;
%         idx = 1;
%         while phase < 3.1
%             phase_range(idx) = phase;
%             phase = phase + .1;
%             idx = idx + 1;
%         end
         if grp_proc_info_in.pac_set_num_segs == 0 || size(curr_eeg,3) > (grp_proc_info_in.pac_num_segs-1)
            low_fq_range = linspace(grp_proc_info_in.pac_low_fq_min, grp_proc_info_in.pac_low_fq_max, grp_proc_info_in.pac_low_fq_res);
            high_fq_range = linspace(grp_proc_info_in.pac_high_fq_min, grp_proc_info_in.pac_high_fq_max, grp_proc_info_in.pac_high_fq_res);
            %bar = waitbar(0, 'Initializing PAC');
            disp('Initializing PAC')
            %all_chan_phase_amp = NaN(max_n_channels,size(phase_range,2));
            chan_idx = 0;
            for chan = 1:max_n_channels 
                if ismember(chan,file_proc_info.beapp_indx{1,1}) && ~(chan==file_proc_info.net_ref_elec_rnum) ...%%should work if beapp_indx{1,1} only contains channels that haven't been removed -- CHECK
                        && (isempty(grp_proc_info_in.pac_chans_to_analyze) || ismember(chan,grp_proc_info_in.pac_chans_to_analyze)) %either chans to analyze is not specified or this channel is specified as one to analyze
                    %waitbar(chan / 129, bar, strcat('Running Channel # ', num2str(chan)))
                    chan_idx = chan_idx+1;
                    disp(strcat('Running Channel # ',num2str(chan)))
                    comodulogram_third_dim_headers{chan_idx} = strcat('Channel # ',num2str(chan));
                    curr_chan_comodulogram = NaN(size(comodulogram,1),size(comodulogram,2),size(comodulogram,4));
                    %curr_chan_phase_amp = NaN(size(curr_eeg,3),size(phase_range,2));
                    curr_chan_amp_dist = NaN(grp_proc_info_in.pac_high_fq_res, grp_proc_info_in.pac_low_fq_res,18,grp_proc_info_in.pac_num_segs,201);
                    %randomly set segments to run, or run all of them
                    if ~isempty(grp_proc_info_in.win_select_n_trials)
                        if isempty(file_proc_info.selected_segs{1,1}) && size(eeg_w{1,1},3)>= grp_proc_info_in.win_select_n_trials %if previous module hasn't already set this
                            segments_torun = randsample(size(curr_eeg,3),grp_proc_info_in.win_select_n_trials);
                            file_proc_info.selected_segs = segments_torun;
                        else
                            segments_torun = file_proc_info.selected_segs{1,1};
                        end
                    else
                        segments_torun = (linspace(1,size(curr_eeg,3),size(curr_eeg,3)));
                    end 
                    
                    for seg = 1:size(segments_torun,2) 
                        curr_seg = segments_torun(1,seg); 
                        signal = curr_eeg(chan,:,curr_seg); 
                        
                        if grp_proc_info_in.slid_win_on == 1
                            %if using a sliding window, need a time dimension 
                            curr_chan_comodulogram = NaN(grp_proc_info_in.pac_high_fq_res, grp_proc_info_in.pac_low_fq_res,size(curr_eeg,3),num_slides);
                             for time = 1:num_slides
                                sample_start = 1+(time-1)*(amount2slide*file_proc_info.beapp_srate);
                                sample_end = sample_start + file_proc_info.beapp_srate*grp_proc_info_in.slid_win_sz-1;
                                curr_time_sig = signal(1,sample_start:sample_end);
                                [curr_chan_comodulogram(:,:,seg,time), curr_z_score, curr_surr_max] = beapp_calc_comod(curr_time_sig,file_proc_info.beapp_srate,low_fq_range,high_fq_range,...
                                    grp_proc_info_in.pac_method,grp_proc_info_in.pac_low_fq_width,grp_proc_info_in.pac_high_fq_width,grp_proc_info_in.pac_low_fq_res,grp_proc_info_in.pac_high_fq_res,grp_proc_info_in.pac_calc_zscores);
                                comodulogram_4th_dim_headers(1,time) = ((sample_start+sample_end)/2) / file_proc_info.beapp_srate;
                             end
                        else
                            compute_shifts = 0;
                            if seg == 1 && chan_idx == 1
                                compute_shifts = 1;
                                shifts = 0;
                            end
                            [curr_chan_comodulogram(:,:,seg), curr_z_score, curr_surr_max, phase_bins, curr_amp_dist, shifts, curr_phase_dist] = beapp_calc_comod(signal,file_proc_info.beapp_srate,low_fq_range,high_fq_range,...
                                    grp_proc_info_in.pac_method,grp_proc_info_in.pac_low_fq_width,grp_proc_info_in.pac_high_fq_width,grp_proc_info_in.pac_low_fq_res,...
                                    grp_proc_info_in.pac_high_fq_res,grp_proc_info_in.pac_calc_zscores,compute_shifts,shifts);
                        end
                        z_score_comod(:,:,chan,seg) = curr_z_score;
                        surr_max(chan,:,seg) = curr_surr_max;
                        curr_chan_amp_dist(:,:,:,seg,:) = curr_amp_dist;
                     end
                    if grp_proc_info_in.slid_win_on == 1
                        comodulogram(:,:,chan,:)= nanmean(curr_chan_comodulogram,3);
                    else
                        comodulogram(:,:,chan,:) = curr_chan_comodulogram;
                    end
                    amp_dist(:,:,:,:,chan_idx,:) = curr_chan_amp_dist;
                    %all_chan_phase_amp(chan,:) = nanmean(curr_chan_phase_amp,1);
                    comodulogram_column_headers = low_fq_range;
                    comodulogram_row_headers = high_fq_range;
                    comodulogram_row_headers = comodulogram_row_headers';
                    if grp_proc_info_in.pac_save_all_reports == 1 || ((ismember(chan,grp_proc_info_in.pac_save_channels) && ...
                                   ismember(file_proc_info.beapp_fname{1}, grp_proc_info_in.pac_save_participants)) || (ismember(chan,grp_proc_info_in.pac_save_channels) && ...
                                   isempty(grp_proc_info_in.pac_save_participants)) || (isempty(grp_proc_info_in.pac_save_channels) && ismember(file_proc_info.beapp_fname{1},grp_proc_info_in.pac_save_participants)))
                        cd(grp_proc_info_in.beapp_toggle_mods{'pac','Module_Dir'}{1});
                        cd(strcat(erase(grp_proc_info_in.beapp_fname_all{curr_file},'.mat'),'_Image_outputs'));
                        flipped_com = flipud(comodulogram(:,:,chan));
                        figure;
                        h = heatmap(flipped_com,'Colormap',parula,'XData',comodulogram_column_headers,'YData',flipud(comodulogram_row_headers),'XLabel','Driver Frequency (Hz)','YLabel','Signal Frequency (Hz)');
    %                     colorbar;
    %                     caxis([.02 .065])
                        filename = erase(file_proc_info.beapp_fname{1},'.mat');
                        title(strcat(filename,'_channel_',num2str(chan)));
                        saveas(h,strcat(filename,'_channel_',num2str(chan),'.png'));
                        close;
                        cd(src_dir{1});
                    end
                end
            end
      
        %close(bar)
         end 
%          if grp_proc_info_in.pac_calc_zscores
%             new_zscore_comod = beapp_calc_mi_zscore(amp_dist);
%          end
        amp_dist = nanmean(amp_dist,4);
        %% save output .mat and excel files
        if grp_proc_info_in.pac_set_num_segs == 0 || size(curr_eeg,3) > (grp_proc_info_in.pac_num_segs-1)
             cd(grp_proc_info_in.beapp_toggle_mods{'pac','Module_Dir'}{1});
             filename = erase(file_proc_info.beapp_fname{1},'.mat');
             if grp_proc_info_in.slid_win_on == 1
                save(strcat(filename,'_pac_results','.mat'),'comodulogram','comodulogram_column_headers','comodulogram_row_headers','comodulogram_third_dim_headers','comodulogram_4th_dim_headers','amp_dist');
             else
                 save(strcat(filename,'_pac_results','.mat'),'comodulogram','comodulogram_column_headers','comodulogram_row_headers','comodulogram_third_dim_headers','phase_bins','amp_dist');
             end
             if grp_proc_info_in.pac_xlsout_on == 1
                 %write and save excel files, where each channel is a sheet
                 comodulogram_row_headers = num2cell(comodulogram_row_headers);
                 comodulogram_row_headers = ['row; col';comodulogram_row_headers];
                 comodulogram_column_headers = num2cell(comodulogram_column_headers);
                 for chan = 1:max_n_channels
                    if ismember(chan,file_proc_info.beapp_indx{1,1}) && ~(chan==file_proc_info.net_ref_elec_rnum) ...
                        && (isempty(grp_proc_info_in.pac_chans_to_analyze) || ismember(chan,grp_proc_info_in.pac_chans_to_analyze)) %either chans to analyze is not specified or this channel is specified as one to analyze
                         curr_results = comodulogram(:,:,chan);
                         curr_results = [comodulogram_column_headers;num2cell(curr_results)];
                         curr_results = [comodulogram_row_headers,curr_results];
                         xlswrite(strcat(filename,'_pac_report.xls'),curr_results,comodulogram_third_dim_headers{chan});
                    end
                 end
             end
        end
      end
      file_proc_info = beapp_prepare_to_save_file('pac',file_proc_info, grp_proc_info_in, src_dir{1});
      
       
end
clearvars -except grp_proc_info_in src_dir curr_file
