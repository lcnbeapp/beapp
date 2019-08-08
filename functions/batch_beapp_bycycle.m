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
        load(grp_proc_info_in.beapp_fname_all{curr_file});
        curr_eeg = eeg_w{1,1};
        if size(curr_eeg,3) > (grp_proc_info_in.bycyc_num_segs-1)
            %TODO: make segments the same as for pac 
            if ~isempty(grp_proc_info_in.win_select_n_trials)
                segments_torun = file_proc_info.selected_segs{1,1};
            else
                segments_torun = randsample(size(curr_eeg,3),grp_proc_info_in.bycyc_num_segs);
            end
            frequencies_torun = linspace(3,100,98);
            %frequencies_torun(1,length(frequencies_torun):length(frequencies_torun)+20) = linspace(20,100,21);
            results_table = NaN(22,length(frequencies_torun),max_n_chans,length(segments_torun));
            results_table_burst = NaN(22,length(frequencies_torun),max_n_chans);
            results_table_nburst = NaN(22,length(frequencies_torun),max_n_chans);
            for chan = 1:max_n_chans
                curr_chan_results = NaN(500,22,length(frequencies_torun),size(segments_torun,1));
                if ismember(chan,file_proc_info.beapp_indx{1,1})
                    disp('Chan')
                    disp(chan)
                    %TEMP FOR TESTING
                    if chan==52
                        disp('BREAK')
                    end
                    for freq_idx = 1:length(frequencies_torun)
                        curr_freq = frequencies_torun(1,freq_idx);
                        disp('Freq')
                        disp(curr_freq)
                        bw = 2;
                        if curr_freq >= 20
                            bw = 20;
                        end
                        if curr_freq < 4
                            bw = .8;
                        end
                        f_range = py.list([curr_freq-bw/2,curr_freq+bw/2]); %bandpass filter 2Hz around freq of interest, 20Hz if > 20Hz
                        for seg = 1:size(segments_torun,2) 
                            curr_seg = segments_torun(1,seg); 
                            signal = curr_eeg(chan,:,curr_seg); 
                            signal = py.numpy.array(signal);
                            fs = size(curr_eeg,2) / 2; %where 2 = segment length
                            fs = py.float(fs);
                            %signal = py.bycycle.filt.lowpass_filter(signal, fs, py.float(35));
                            burst_kwargs = py.dict(pyargs('amplitude_fraction_threshold',.3,'amplitude_consistency_threshold',.4,'period_consistency_threshold',.5, 'monotonicity_threshold',.8,'N_cycles_min',3));
                            bycyc = py.bycycle.features.compute_features(signal, fs, f_range, py.str('P'), py.str('cycles'),burst_kwargs);
                            %py.bycycle.burst.plot_burst_detect_params(signal, fs, bycyc, burst_kwargs)
                            df = bycyc.to_dict;
                            %results_table = NaN(double(py.len(df{'sample_peak'})),double(py.len(keys(df))));
                            if ~isnan(double(py.array.array('d',py.numpy.nditer(df{'sample_peak'}{0}))))
                                for row = 1:(double(py.len(df{'sample_peak'}))) %length sems to be 1 more than it actually is ...  maybe it counts the title?                           
                                    curr_chan_results(row,1,freq_idx,seg) = df{'sample_peak'}{row-1};
                                    curr_chan_results(row,2,freq_idx,seg) = df{'sample_zerox_decay'}{row-1};
                                    curr_chan_results(row,3,freq_idx,seg)= df{'sample_zerox_rise'}{row-1};
                                    curr_chan_results(row,4,freq_idx,seg)= df{'sample_last_trough'}{row-1};
                                    curr_chan_results(row,5,freq_idx,seg) = df{'sample_next_trough'}{row-1};
                                    curr_chan_results(row,6,freq_idx,seg) = df{'period'}{row-1};
                                    curr_chan_results(row,7,freq_idx,seg) = df{'time_peak'}{row-1};
                                    curr_chan_results(row,8,freq_idx,seg) = df{'time_trough'}{row-1};
                                    curr_chan_results(row,9,freq_idx,seg) = df{'volt_peak'}{row-1};
                                    curr_chan_results(row,10,freq_idx,seg) = df{'volt_trough'}{row-1};
                                    curr_chan_results(row,11,freq_idx,seg) = df{'time_rise'}{row-1};
                                    curr_chan_results(row,12,freq_idx,seg) = df{'volt_decay'}{row-1};
                                    curr_chan_results(row,13,freq_idx,seg) = df{'volt_rise'}{row-1};
                                    curr_chan_results(row,14,freq_idx,seg) = df{'volt_amp'}{row-1};
                                    curr_chan_results(row,15,freq_idx,seg) = df{'time_rdsym'}{row-1};
                                    curr_chan_results(row,16,freq_idx,seg) = df{'time_ptsym'}{row-1};
                                    curr_chan_results(row,17,freq_idx,seg) = df{'band_amp'}{row-1};
                                    curr_chan_results(row,18,freq_idx,seg) = df{'amp_fraction'}{row-1};
                                    curr_chan_results(row,19,freq_idx,seg) = df{'amp_consistency'}{row-1};
                                    curr_chan_results(row,20,freq_idx,seg) = df{'period_consistency'}{row-1};
                                    curr_chan_results(row,21,freq_idx,seg) = df{'monotonicity'}{row-1};
                                    curr_chan_results(row,22,freq_idx,seg) = df{'is_burst'}{row-1};
                                end
                            end
                           % avg_cyc_chan_results = squeeze(nanmean(curr_chan_results,1)); %avg over cycles
                        end
                    end
                    curr_chan_results_burst = NaN(size(curr_chan_results));
                    curr_chan_results_nburst = NaN(size(curr_chan_results));
%                     for seg = 1:size(curr_chan_results,3)
%                         for i=1:size(curr_chan_results,1)
%                             if curr_chan_results(i,22,seg) == 1
%                                 curr_chan_results_burst(i,:,seg) = curr_chan_results(i,:,seg);
%                             else
%                                 curr_chan_results_nburst(i,:,seg) = curr_chan_results(i,:,seg);
%                             end
%                         end  
%                     end

                    results_table(:,:,chan,:) = squeeze(nanmean(curr_chan_results,1)); %avg over cycles, then avg over segments
                    %results_table_burst(:,chan) = squeeze(nanmean(nanmean(curr_chan_results_burst,1),3));
                    %results_table_nburst(:,chan) = squeeze(nanmean(nanmean(curr_chan_results_nburst,1),3));
                end
            end
        
            %% save and update file history
            cd(grp_proc_info_in.beapp_toggle_mods{'bycycle','Module_Dir'}{1});
            filename = erase(file_proc_info.beapp_fname{1},'.mat');
            save(strcat(filename,'_bycycle_results','.mat'),'results_table','frequencies_torun');
        end
      end
      clearvars -except grp_proc_info_in src_dir curr_file max_n_chans
      
end
