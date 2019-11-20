function pac_between_chans(grp_proc_info_in)

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
            curr_eeg = eeg_w{1,1}; %used to be: eeg_wfp_mean_all = mean(eeg_w{1,1},3);

             if grp_proc_info_in.pac_set_num_segs == 0 || size(curr_eeg,3) > (grp_proc_info_in.pac_num_segs-1)
                low_fq_range = linspace(grp_proc_info_in.pac_low_fq_min, grp_proc_info_in.pac_low_fq_max, grp_proc_info_in.pac_low_fq_res);
                high_fq_range = linspace(grp_proc_info_in.pac_high_fq_min, grp_proc_info_in.pac_high_fq_max, grp_proc_info_in.pac_high_fq_res);
                for lf = 1:size(low_fq_range,2)
                    for hf = 1:size(high_fq_range,2)
                        %%get the lf hf phase and amp dists for every chan
                        %%and segment
                        chan_idx = 0;
                        for chan = 1:max_n_channels 
                            if ismember(chan,file_proc_info.beapp_indx{1,1}) && ~(chan==file_proc_info.net_ref_elec_rnum) ...%%should work if beapp_indx{1,1} only contains channels that haven't been removed -- CHECK
                                    && (isempty(grp_proc_info_in.pac_chans_to_analyze) || ismember(chan,grp_proc_info_in.pac_chans_to_analyze)) %either chans to analyze is not specified or this channel is specified as one to analyze
                                %waitbar(chan / 129, bar, strcat('Running Channel # ', num2str(chan)))
                                chan_idx = chan_idx+1;
                                disp(strcat('Running Channel # ',num2str(chan)))
                                %randomly set segments to run, or run all of them
                                segments_torun = (linspace(1,size(curr_eeg,3),size(curr_eeg,3)));

                                for seg = 1:size(segments_torun,2) 
                                    curr_seg = segments_torun(1,seg); 
                                    signal = curr_eeg(chan,:,curr_seg);
                                    [amp_dists(chan_idx,curr_seg,:),phase_dists(chan_idx,curr_seg,:)] = get_amp_phase_dist(signal,low_fq_range(1,lf),high_fq_range(1,hf),file_proc_info.beapp_srate,grp_proc_info_in.pac_high_fq_width);
                                end

                                %all_chan_phase_amp(chan,:) = nanmean(curr_chan_phase_amp,1);
                                comodulogram_column_headers = low_fq_range;
                                comodulogram_row_headers = high_fq_range;
                                comodulogram_row_headers = comodulogram_row_headers';
                            end
                        end
                        
                        %%now compute the MI between relevant chans
                        calc_surrs = 0;
                        if calc_surrs == 1
                            for surr = 1:201
                                if surr == 1
                                    for lf_chan = 1:size(phase_dists,1)
                                        for hf_chan = 1:size(amp_dists,1)
                                            for seg_idx = 1:size(segments_torun,2)
                                                curr_seg = segments_torun(1,seg_idx);
                                                curr_phase_dist = squeeze(phase_dists(lf_chan,curr_seg,:));
                                                curr_amp_dist = squeeze(amp_dists(hf_chan,curr_seg,:));                                    
                                                 for b=1:18
                                                    selection = curr_amp_dist(curr_phase_dist==b);
                                                    curr_binned_amp_dist(b) = mean(selection);
                                                 end
                                                 binned_amp_dist(seg_idx,:) = curr_binned_amp_dist ./ sum(curr_binned_amp_dist);
                                            end
                                            % calc MI
                                            amp_dist_2 = nanmean(binned_amp_dist,1);
                                            divergence_kl = sum(amp_dist_2 .* log(amp_dist_2 * 18));
                                            MI_matrix(lf,hf,lf_chan,hf_chan) = divergence_kl / log(18);
                                        end
                                    end
                                else %offset segments
                                    offset = randi([1 59]);
                                    for lf_chan = 1:size(phase_dists,1)
                                        for hf_chan = 1:size(amp_dists,1)
                                            for seg_idx = 1:size(segments_torun,2)
                                                curr_seg = segments_torun(1,seg_idx);
                                                curr_phase_dist = squeeze(phase_dists(lf_chan,curr_seg,:));
                                                if curr_seg+offset>60
                                                    amp_seg = curr_seg+offset - 60;
                                                else
                                                    amp_seg = curr_seg+offset;
                                                end
                                                curr_amp_dist = squeeze(amp_dists(hf_chan,amp_seg,:));                                    
                                                 for b=1:18
                                                    selection = curr_amp_dist(curr_phase_dist==b);
                                                    curr_binned_amp_dist(b) = mean(selection);
                                                 end
                                                 binned_amp_dist(seg_idx,:) = curr_binned_amp_dist ./ sum(curr_binned_amp_dist);
                                            end
                                            % calc MI
                                            amp_dist_2 = nanmean(binned_amp_dist,1);
                                            divergence_kl = sum(amp_dist_2 .* log(amp_dist_2 * 18));
                                            MI_matrix(lf,hf,lf_chan,hf_chan,surr) = divergence_kl / log(18);
                                        end
                                    end
                                end
                            end
                        else %just compute mi
                              for lf_chan = 1:size(phase_dists,1)
                                    for hf_chan = 1:size(amp_dists,1)
                                        for seg_idx = 1:size(segments_torun,2)
                                            curr_seg = segments_torun(1,seg_idx);
                                            curr_phase_dist = squeeze(phase_dists(lf_chan,curr_seg,:));
                                            curr_amp_dist = squeeze(amp_dists(hf_chan,curr_seg,:));                                    
                                             for b=1:18
                                                selection = curr_amp_dist(curr_phase_dist==b);
                                                curr_binned_amp_dist(b) = mean(selection);
                                             end
                                             binned_amp_dist(seg_idx,:) = curr_binned_amp_dist ./ sum(curr_binned_amp_dist);
                                        end
                                        % calc MI
                                        amp_dist_2 = nanmean(binned_amp_dist,1);
                                        divergence_kl = sum(amp_dist_2 .* log(amp_dist_2 * 18));
                                        MI_matrix(lf,hf,lf_chan,hf_chan) = divergence_kl / log(18);
                                    end
                              end                      
                        end
                    end
                end

            %close(bar)
             end 
    %          if grp_proc_info_in.pac_calc_zscores
    %             new_zscore_comod = beapp_calc_mi_zscore(amp_dist);
    %          end
            %% save output .mat and excel files
            if grp_proc_info_in.pac_set_num_segs == 0 || size(curr_eeg,3) > (grp_proc_info_in.pac_num_segs-1)
                 cd(grp_proc_info_in.beapp_toggle_mods{'pac','Module_Dir'}{1});
                 filename = erase(file_proc_info.beapp_fname{1},'.mat');
                 save(strcat(filename,'_pac_results','.mat'),'MI_matrix');
            
            end
          end
          file_proc_info = beapp_prepare_to_save_file('pac',file_proc_info, grp_proc_info_in, src_dir{1});


    end
    clearvars -except grp_proc_info_in src_dir curr_file
end