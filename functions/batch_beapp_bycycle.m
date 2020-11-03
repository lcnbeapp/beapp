function batch_beapp_bycycle (grp_proc_info_in)
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
% 
% This function adapted some code from https://github.com/StefanoBuccelli/bycycle_matlab/tree/master/Matlab_scripts
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

src_dir = find_input_dir('bycycle',grp_proc_info_in.beapp_toggle_mods);
max_n_chans = 256;
var_names={'sample_peak','sample_zerox_decay','sample_zerox_rise'...
    'sample_last_trough','sample_next_trough','period','time_peak',...
    'time_trough','volt_peak','volt_trough','time_rise','volt_decay',...
    'volt_rise','volt_amp','time_rdsym','time_ptsym','band_amp',...
    'amp_fraction','amp_consistency','period_consistency',...
    'monotonicity','is_burst'};
for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
  
    cd(src_dir{1});
    
      if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
         % load eeg if module takes continuous input
         savefigs = 1;
         load(grp_proc_info_in.beapp_fname_all{curr_file});
         if grp_proc_info_in.bycycle_save_reports && grp_proc_info_in.bycycle_gen_reports
            mkdir(strcat(erase(grp_proc_info_in.beapp_fname_all{curr_file},'.mat'),'_Image_outputs'));
         end
        for curr_condition = 1:size(eeg_w,1)
            if ~isempty(eeg_w{curr_condition,1})
                curr_eeg = eeg_w{curr_condition,1};
                if size(curr_eeg,3) > (grp_proc_info_in.bycyc_num_segs-1)
                    %TODO: make segments the same as for pac 
                    if ~isempty(grp_proc_info_in.win_select_n_trials)
                        segments_torun = file_proc_info.selected_segs{curr_condition,1};
                    else
                        if grp_proc_info_in.bycyc_set_num_segs==1
                            segments_torun = randsample(size(curr_eeg,3),grp_proc_info_in.bycyc_num_segs);
                        else
                            segments_torun = [1:size(curr_eeg,3)];
                        end
                    end
                    frequency_bands = grp_proc_info_in.bycycle_freq_bands; 
                    for chan = 1:max_n_chans
                        if ismember(chan,file_proc_info.beapp_indx{1,1})
                            disp('Chan')
                            disp(chan)
                            for freq_idx = 1:size(frequency_bands,1)
                                f_range = frequency_bands(freq_idx,:);
                                disp('Freq')
                                disp(f_range)
                                f_range = py.list(f_range); %bandpass filter 2Hz around freq of interest, 20Hz if > 20Hz
                                total_cyc_num = 0;
                                for seg = 1:size(segments_torun,2) 
                                    curr_chan_results = NaN(1,22);
                                    curr_seg = segments_torun(1,seg); 
                                    signal = curr_eeg(chan,:,curr_seg); 
                                    signal = py.numpy.array(signal);
                                    fs = file_proc_info.beapp_srate;
                                    fs = py.float(fs);
                                    %signal = py.bycycle.filt.lowpass_filter(signal, fs, py.float(35));
                                    burst_kwargs = py.dict(pyargs('amplitude_fraction_threshold',grp_proc_info_in.bycycle_burstparams.amplitude_fraction_threshold,...
                                        'amplitude_consistency_threshold',grp_proc_info_in.bycycle_burstparams.amplitude_consistency_threshold,...
                                        'period_consistency_threshold',grp_proc_info_in.bycycle_burstparams.period_consistency_threshold,...
                                        'monotonicity_threshold',grp_proc_info_in.bycycle_burstparams.monotonicity_threshold,...
                                        'N_cycles_min',grp_proc_info_in.bycycle_burstparams.N_cycles_min));
                                    bycyc = py.bycycle.features.compute_features(signal, fs, f_range, py.str('P'), py.str('cycles'),burst_kwargs);
                                    %py.bycycle.burst.plot_burst_detect_params(signal, fs, bycyc, burst_kwargs)
                                    df = bycyc.to_dict;
                                    %results_table = NaN(double(py.len(df{'sample_peak'})),double(py.len(keys(df))));
                                    if ~isnan(double(py.array.array('d',py.numpy.nditer(df{'sample_peak'}{0}))))
                                        for row = 1:(double(py.len(df{'sample_peak'}))) %length sems to be 1 more than it actually is ...  maybe it counts the title?                           
                                            total_cyc_num = total_cyc_num+1;
                                            curr_chan_results(row,1) = df{'sample_peak'}{row-1};
                                            curr_chan_results(row,2) = df{'sample_zerox_decay'}{row-1};
                                            curr_chan_results(row,3)= df{'sample_zerox_rise'}{row-1};
                                            curr_chan_results(row,4)= df{'sample_last_trough'}{row-1};
                                            curr_chan_results(row,5) = df{'sample_next_trough'}{row-1};
                                            curr_chan_results(row,6) = df{'period'}{row-1};
                                            curr_chan_results(row,7) = df{'time_peak'}{row-1};
                                            curr_chan_results(row,8) = df{'time_trough'}{row-1};
                                            curr_chan_results(row,9) = df{'volt_peak'}{row-1};
                                            curr_chan_results(row,10) = df{'volt_trough'}{row-1};
                                            curr_chan_results(row,11) = df{'time_rise'}{row-1};
                                            curr_chan_results(row,12) = df{'volt_decay'}{row-1};
                                            curr_chan_results(row,13) = df{'volt_rise'}{row-1};
                                            curr_chan_results(row,14) = df{'volt_amp'}{row-1};
                                            curr_chan_results(row,15) = df{'time_rdsym'}{row-1};
                                            curr_chan_results(row,16) = df{'time_ptsym'}{row-1};
                                            curr_chan_results(row,17) = df{'band_amp'}{row-1};
                                            curr_chan_results(row,18) = df{'amp_fraction'}{row-1};
                                            curr_chan_results(row,19) = df{'amp_consistency'}{row-1};
                                            curr_chan_results(row,20) = df{'period_consistency'}{row-1};
                                            curr_chan_results(row,21) = df{'monotonicity'}{row-1};
                                            curr_chan_results(row,22) = df{'is_burst'}{row-1};
                                        end
                                        num_cycs = double(py.len(df{'sample_peak'}));
                                        %% putting  results in a matlab table
                                        var_names={'sample_peak','sample_zerox_decay','sample_zerox_rise'...
                                            'sample_last_trough','sample_next_trough','period','time_peak',...
                                            'time_trough','volt_peak','volt_trough','time_rise','volt_decay',...
                                            'volt_rise','volt_amp','time_rdsym','time_ptsym','band_amp',...
                                            'amp_fraction','amp_consistency','period_consistency',...
                                            'monotonicity','is_burst'};
                                        result_table=array2table(curr_chan_results,'VariableNames',var_names);

                                        %% deleting NaN rows, converting ndarrays to matlab arrays
                                        if grp_proc_info_in.bycycle_gen_reports
                                            result_table(isnan(result_table.sample_peak),:)=[];
                                            result_table((result_table.sample_peak)==0,:)=[];
                                            signal = double(signal);
                                            signal_low_mat=signal;
                                            time_s=(1:1:length(signal))/file_proc_info.beapp_srate;
                                            byc_plot_table(signal,signal_low_mat,result_table,time_s,grp_proc_info_in.beapp_toggle_mods{'bycycle','Module_Dir'}{1},...
                                                erase(file_proc_info.beapp_fname{1},'.mat'),num2str(chan),num2str(seg),grp_proc_info_in.bycycle_save_reports);
                                           % byc_plot_table(signal,signal_low_mat,result_table,time_s,file_proc_info,grp_proc_info_in.beapp_toggle_mods{'bycycle','Module_Dir'}{1});
                                            close all
                                        end
                                    end
                                   % avg_cyc_chan_results = squeeze(nanmean(curr_chan_results,1)); %avg over cycles
                                   %append segments

                                   if exist('total_results_table','var') == 0
                                       total_results_table = curr_chan_results;
                                       total_results_table(:,end+1) = seg;
                                   else
                                       total_results_table(total_cyc_num-num_cycs+1:total_cyc_num,1:end-1) = curr_chan_results;
                                       total_results_table(total_cyc_num-num_cycs+1:total_cyc_num,end) = seg;
                                   end

                                end
                                total_results_table(total_results_table(:,1)==0,:) = [];
                                results{1,freq_idx} = total_results_table;
                                frequencies{1,freq_idx} = frequency_bands(freq_idx,:);
                            end
                            %total_results_table(total_results_table(:,1,freq_idx)==0,:) = [];
                            for i = 1:size(total_results_table,3)
                                total_results_table(total_results_table(:,1,i)==0,:,i) = NaN;
                            end
%                             curr_chan_results_burst = NaN(size(curr_chan_results));
%                             curr_chan_results_nburst = NaN(size(curr_chan_results));
%         %                     for seg = 1:size(curr_chan_results,3)
%         %                         for i=1:size(curr_chan_results,1)
%         %                             if curr_chan_results(i,22,seg) == 1
%         %                                 curr_chan_results_burst(i,:,seg) = curr_chan_results(i,:,seg);
%         %                             else
%         %                                 curr_chan_results_nburst(i,:,seg) = curr_chan_results(i,:,seg);
%         %                             end
%         %                         end  
%         %                     end
% 
%                             results_table(:,:,chan,:) = squeeze(nanmean(curr_chan_results,1)); %avg over cycles, then avg over segments
%                             %results_table_burst(:,chan) = squeeze(nanmean(nanmean(curr_chan_results_burst,1),3));
%                             %results_table_nburst(:,chan) = squeeze(nanmean(nanmean(curr_chan_results_nburst,1),3));
                        end
                    end
                else
                    results{curr_condition,1}=[];
                    frequencies{curr_condition,1} = [];
                end
           else
                results{curr_condition,1}=[];
                frequencies{curr_condition,1} = [];
           end               


        end
            %% save and update file history
            cd(grp_proc_info_in.beapp_toggle_mods{'bycycle','Module_Dir'}{1});
            filename = erase(file_proc_info.beapp_fname{1},'.mat');
            var_names{end+1} = 'Segment';
            save(strcat(filename,'_bycycle_results','.mat'),'results','frequencies','var_names');

      end
      clearvars -except grp_proc_info_in src_dir curr_file max_n_chans
      
end
