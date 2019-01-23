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
for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
  
    cd(src_dir{1});
    
      if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
         % load eeg if module takes continuous input
        load(grp_proc_info_in.beapp_fname_all{curr_file});
        curr_eeg = eeg_w{1,1};
        if size(curr_eeg,3) > (grp_proc_info_in.bycyc_num_segs-1)
            segments_torun = randsample(size(curr_eeg,3),grp_proc_info_in.bycyc_num_segs);
            results_table = NaN(22,max_n_chans);
            results_table_burst = NaN(22,max_n_chans);
            results_table_nburst = NaN(22,max_n_chans);
            for chan = 1:max_n_chans
                curr_chan_results = NaN(500,22,size(segments_torun,1));
                if ismember(chan,file_proc_info.beapp_indx{1,1})
                    for seg = 1:size(segments_torun,1) 
                        curr_seg = segments_torun(seg,1); 
                        signal = curr_eeg(chan,:,curr_seg); 
                        signal = py.numpy.array(signal);
                        f_range = py.list([12,20]);
                        fs = size(curr_eeg,2) / 10; %where 2.5 = segment length
                        fs = py.float(fs);
                        %signal = py.bycycle.filt.lowpass_filter(signal, fs, py.float(35));
                        burst_kwargs = py.dict(pyargs('amplitude_fraction_threshold',.3,'amplitude_consistency_threshold',.4,'period_consistency_threshold',.5, 'monotonicity_threshold',.8,'N_cycles_min',3));
                        bycyc = py.bycycle.features.compute_features(signal, fs, f_range, py.str('P'), py.str('cycles'),burst_kwargs);
                        %py.bycycle.burst.plot_burst_detect_params(signal, fs, bycyc, burst_kwargs)
                        df = bycyc.to_dict;
                        %results_table = NaN(double(py.len(df{'sample_peak'})),double(py.len(keys(df))));
                        for row = 1:(double(py.len(df{'sample_peak'}))) %length sems to be 1 more than it actually is ...  maybe it counts the title?
                            curr_chan_results(row,1,seg) = df{'sample_peak'}{row-1};
                            curr_chan_results(row,2,seg) = df{'sample_zerox_decay'}{row-1};
                            curr_chan_results(row,3,seg)= df{'sample_zerox_rise'}{row-1};
                            curr_chan_results(row,4,seg)= df{'sample_last_trough'}{row-1};
                            curr_chan_results(row,5,seg) = df{'sample_next_trough'}{row-1};
                            curr_chan_results(row,6,seg) = df{'period'}{row-1};
                            curr_chan_results(row,7,seg) = df{'time_peak'}{row-1};
                            curr_chan_results(row,8,seg) = df{'time_trough'}{row-1};
                            curr_chan_results(row,9,seg) = df{'volt_peak'}{row-1};
                            curr_chan_results(row,10,seg) = df{'volt_trough'}{row-1};
                            curr_chan_results(row,11,seg) = df{'time_rise'}{row-1};
                            curr_chan_results(row,12,seg) = df{'volt_decay'}{row-1};
                            curr_chan_results(row,13,seg) = df{'volt_rise'}{row-1};
                            curr_chan_results(row,14,seg) = df{'volt_amp'}{row-1};
                            curr_chan_results(row,15,seg) = df{'time_rdsym'}{row-1};
                            curr_chan_results(row,16,seg) = df{'time_ptsym'}{row-1};
                            curr_chan_results(row,17,seg) = df{'band_amp'}{row-1};
                            curr_chan_results(row,18,seg) = df{'amp_fraction'}{row-1};
                            curr_chan_results(row,19,seg) = df{'amp_consistency'}{row-1};
                            curr_chan_results(row,20,seg) = df{'period_consistency'}{row-1};
                            curr_chan_results(row,21,seg) = df{'monotonicity'}{row-1};
                            curr_chan_results(row,22,seg) = df{'is_burst'}{row-1};
                        end
                       % avg_cyc_chan_results = squeeze(nanmean(curr_chan_results,1)); %avg over cycles
                    end
                    curr_chan_results_burst = NaN(size(curr_chan_results));
                    curr_chan_results_nburst = NaN(size(curr_chan_results));
                    for seg = 1:size(curr_chan_results,3)
                        for i=1:size(curr_chan_results,1)
                            if curr_chan_results(i,22,seg) == 1
                                curr_chan_results_burst(i,:,seg) = curr_chan_results(i,:,seg);
                            else
                                curr_chan_results_nburst(i,:,seg) = curr_chan_results(i,:,seg);
                            end
                        end  
                    end

                    results_table(:,chan) = squeeze(nanmean(nanmean(curr_chan_results,1),3)); %avg over cycles, then avg over segments
                    results_table_burst(:,chan) = squeeze(nanmean(nanmean(curr_chan_results_burst,1),3));
                    results_table_nburst(:,chan) = squeeze(nanmean(nanmean(curr_chan_results_nburst,1),3));
                end
            end
        
            %% save and update file history
            cd(grp_proc_info_in.beapp_toggle_mods{'bycycle','Module_Dir'}{1});
            filename = erase(file_proc_info.beapp_fname{1},'.mat');
            save(strcat(filename,'_bycycle_results','.mat'),'results_table','results_table_burst','results_table_nburst');
        end
      end
      clearvars -except grp_proc_info_in src_dir curr_file max_n_chans
      
end
