function pac_get_phase(grp_proc_info_in)

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
            
            %%CROSSF
            segments_torun = file_proc_info.selected_segs{1,1};
            if size(file_proc_info.net_vstruct,2) > 80
                x_signal = squeeze(eeg_w{1,1}(22,:,segments_torun));
                y_signal = squeeze(eeg_w{1,1}(70,:,segments_torun));
            else %64
                x_signal = squeeze(eeg_w{1,1}(11,:,segments_torun));
                y_signal = squeeze(eeg_w{1,1}(37,:,segments_torun));
            end
            if ~(isempty(x_signal) || isempty(y_signal))
                xdata = x_signal(:,1)';
                ydata = y_signal(:,1)';
                for seg = 2:size(x_signal,2)
                    xdata = [xdata squeeze(x_signal(:,seg))'];
                    ydata = [ydata squeeze(y_signal(:,seg))'];
                end
                if ~(isnan(x_signal(1,1)) || isnan(y_signal(1,1)))
                    try
                        [coh,mcoh,timesout,freqsout,cohboot,cohangle] = newcrossf(xdata,ydata,500,[0 2000],250,[3 .5],'maxfreq',100,'savecoher',1);
                    catch 
                        disp(['whoops']);
                    end
                end
            end
            michaelsaysso = 0;
            if michaelsaysso == 1
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

                                    chan_headers(chan_idx) = file_proc_info.beapp_indx{1,1}(1,chan_idx);
                                    for seg = 1:size(segments_torun,2) 
                                        curr_seg = segments_torun(1,seg); 
                                        signal = curr_eeg(chan,:,curr_seg);
                                        %TODO: add something to label chans

                                        [amp_dists(chan_idx,seg,:),phase_dists(chan_idx,seg,:)] = get_amp_phase_dist(signal,low_fq_range(1,lf),high_fq_range(1,hf),file_proc_info.beapp_srate,grp_proc_info_in.pac_high_fq_width);
                                    end

                                    %all_chan_phase_amp(chan,:) = nanmean(curr_chan_phase_amp,1);
                                    comodulogram_column_headers = low_fq_range;
                                    comodulogram_row_headers = high_fq_range;
                                    comodulogram_row_headers = comodulogram_row_headers';
                                end
                            end
                        end
                    end

                %close(bar)
                 end 
            end
        %          if grp_proc_info_in.pac_calc_zscores
    %             new_zscore_comod = beapp_calc_mi_zscore(amp_dist);
    %          end
            %%CROSSF
           % xdata = phase_dists(1,:,:);
            %ydata = phase_dists(12,:,:);
            %make data into one row vector (concat)

    
            %% save output .mat and excel files
            if grp_proc_info_in.pac_set_num_segs == 0 || size(curr_eeg,3) > (grp_proc_info_in.pac_num_segs-1)
                 cd(grp_proc_info_in.beapp_toggle_mods{'pac','Module_Dir'}{1});
                 filename = erase(file_proc_info.beapp_fname{1},'.mat');
                 if michaelsaysso
                    save(strcat(filename,'_pac_results','.mat'),'phase_dists','chan_headers','comodulogram_column_headers','comodulogram_row_headers');
                 else
                    save(strcat(filename,'_pac_results','.mat'),'coh','mcoh','timesout','freqsout','cohboot','cohangle');
                    savefig(strcat(filename,'.fig'));
                    close all
                 end
            
            end
          end
          file_proc_info = beapp_prepare_to_save_file('pac',file_proc_info, grp_proc_info_in, src_dir{1});


    end
    clearvars -except grp_proc_info_in src_dir curr_file
end