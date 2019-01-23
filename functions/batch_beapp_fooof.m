%% batch_beapp_fooof (grp_proc_info)
%
%  a module that runs fooof software to find the background and peaks of
%  the power spectrum
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

function batch_beapp_fooof (grp_proc_info_in)

src_dir = find_input_dir('fooof',grp_proc_info_in.beapp_toggle_mods);

max_n_channels = 256; %maximum number of channels in the EEG dataset -- currently hardcoded

if grp_proc_info_in.fooof_average_chans == 1 && isempty(grp_proc_info_in.fooof_channel_groups) %make a table
        fooof_results = NaN(size(grp_proc_info_in.beapp_fname_all,2),grp_proc_info_in.fooof_max_n_peaks*6+5);
        row_labels = cell(1,size(grp_proc_info_in.beapp_fname_all,2));
else %make a 3d matrix
    if grp_proc_info_in.fooof_average_chans == 1 && ~isempty(grp_proc_info_in.fooof_channel_groups)
        fooof_results = NaN(size(grp_proc_info_in.fooof_channel_groups,2),grp_proc_info_in.fooof_max_n_peaks*6+5,size(grp_proc_info_in.beapp_fname_all,2));
    else
        fooof_results = NaN(max_n_channels,grp_proc_info_in.fooof_max_n_peaks*6+5,size(grp_proc_info_in.beapp_fname_all,2));
    end
    third_dimension_labels = cell(1,size(grp_proc_info_in.beapp_fname_all,2));
end
    
for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1});
    
      if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
        load(grp_proc_info_in.beapp_fname_all{curr_file})
        
        if ~(grp_proc_info_in.fooof_average_chans && isempty(grp_proc_info_in.fooof_channel_groups)) %you have a 2d table if you're averaging everything together
            third_dimension_labels{curr_file} = file_proc_info.beapp_fname{1};
        end
        %% Run FOOOF
        % FOOOF settings
        settings = struct();  % Use defaults
        settings.peak_width_limits = grp_proc_info_in.fooof_peak_width_limits;
        settings.max_n_peaks = grp_proc_info_in.fooof_max_n_peaks;
        settings.min_peak_amplitude = grp_proc_info_in.fooof_min_peak_amplitude;
        if grp_proc_info_in.fooof_min_peak_threshold ~= 0
            settings.peak_threshold = grp_proc_info_in.fooof_min_peak_threshold;
        end
        
        if grp_proc_info_in.fooof_background_mode == 1
            settings.background_mode = 'fixed';
        end 
        if grp_proc_info_in.fooof_background_mode == 2
            settings.background_mode = 'knee';
        end

        min_freq = grp_proc_info_in.fooof_min_freq;
        max_freq = grp_proc_info_in.fooof_max_freq;
        f_range = [min_freq,max_freq];
        % Make freqs
        f = f{1,1};
        freq_inc = find(f>=min_freq & f<=max_freq);
        freqs = f(freq_inc);
        if size(freqs,1) > size(freqs,2) %frequencies need to be transposed
            freqs = freqs';
        end
        %Make psd, with averaged chans
        if grp_proc_info_in.fooof_average_chans == 1            
            eeg_wfp_mean_all = mean(eeg_wfp{1,1},3); %take average across trials
            thisEEG = eeg_wfp_mean_all(:,freq_inc);
            if isempty(grp_proc_info_in.fooof_channel_groups) %%channels should be averaged all together
                 %if any of the channels are not NaN or all channels are
                 %being analyzed and not all of them are NaN
                 if any(ismember(grp_proc_info_in.fooof_chans_to_analyze,file_proc_info.beapp_indx{1,1})) || (isempty(grp_proc_info_in.fooof_chans_to_analyze) && any(any(~isnan(thisEEG))>0))
                    if ~isempty(grp_proc_info_in.fooof_chans_to_analyze)
                        psd = nanmean(thisEEG(grp_proc_info_in.fooof_chans_to_analyze,:),1);
                    else
                        psd = nanmean(thisEEG,1); 
                    end
                    %Run FOOOF
                    pdf_name = erase(file_proc_info.beapp_fname{1},'.mat');
                    save_report = 0;
                    if grp_proc_info_in.fooof_save_all_reports == 1 || ismember(file_proc_info.beapp_fname{1}, grp_proc_info_in.fooof_save_participants)
                        save_report = 1;
                    end
                    curr_results = fooof(freqs, psd, f_range, settings, pdf_name, grp_proc_info_in, save_report)
                    %Add results to output table 
                    row_labels{curr_file} = file_proc_info.beapp_fname{1};
                    fooof_results(curr_file,1) = curr_results.background_params(1,1);
                    if grp_proc_info_in.fooof_background_mode == 2 %%knee has 3rd parameter needed to be saved 
                        fooof_results(curr_file,2) = curr_results.background_params(1,3); %%slope gets bumped to 3rd param
                        fooof_results(curr_file,3) = curr_results.background_params(1,2); %%knee is saved as second
                    else
                        fooof_results(curr_file,2) = curr_results.background_params(1,2);
                    end
                    fooof_results(curr_file,4) = curr_results.r_squared;
                    fooof_results(curr_file,5) = curr_results.error;
                    for j = 1:size(curr_results.peak_params,1)
                        fooof_results(curr_file,6+(6*(j-1))) = curr_results.peak_params(j,1);
                        fooof_results(curr_file,7+(6*(j-1))) = curr_results.peak_params(j,2);
                        fooof_results(curr_file,8+(6*(j-1))) = curr_results.peak_params(j,3);
                        fooof_results(curr_file,9+(6*(j-1))) = curr_results.gaussian_params(j,1);
                        fooof_results(curr_file,10+(6*(j-1))) = curr_results.gaussian_params(j,2);
                        fooof_results(curr_file,11+(6*(j-1))) = curr_results.gaussian_params(j,3);
                    end
                end

            else %%average in groups
                for i=1:size(grp_proc_info_in.fooof_channel_groups,2)
                    row_labels{i} = strcat('Channel Group #',num2str(i));
                    chans_to_avg = grp_proc_info_in.fooof_channel_groups{1,i};
                    psd = nanmean(thisEEG(chans_to_avg,:),1);
                    if any(ismember(chans_to_avg,file_proc_info.beapp_indx{1,1})) %if any of the channels are not NaN
                        %% ~~Run FOOOF (TODO--make this a function)
                        pdf_name = erase(file_proc_info.beapp_fname{1},'.mat');
                        save_report = 0;
                        if grp_proc_info_in.fooof_save_all_reports == 1 || ((ismember(i,grp_proc_info_in.fooof_save_groups) && ...
                               ismember(file_proc_info.beapp_fname{1}, grp_proc_info_in.fooof_save_participants)) || (ismember(i,grp_proc_info_in.fooof_save_groups) && ...
                               isempty(grp_proc_info_in.fooof_save_participants)) || (isempty(grp_proc_info_in.fooof_save_groups) && ismember(file_proc_info.beapp_fname{1},grp_proc_info_in.fooof_save_participants)))
                            save_report = 1;
                        end
                        curr_results = fooof(freqs, psd, f_range, settings, strcat(pdf_name,'_',num2str(i)), grp_proc_info_in, save_report)
                        %Add results to output table 
                        fooof_results(i,1,curr_file) = curr_results.background_params(1,1);
                        if grp_proc_info_in.fooof_background_mode == 2 %%knee has 3rd parameter needed to be saved 
                            fooof_results(i,2,curr_file) = curr_results.background_params(1,3); %%slope gets bumped to 3rd param
                            fooof_results(i,3,curr_file) = curr_results.background_params(1,2); %%knee is saved as second
                        else
                            fooof_results(i,2,curr_file) = curr_results.background_params(1,2);
                        end
                        fooof_results(i,4,curr_file) = curr_results.r_squared;
                        fooof_results(i,5,curr_file) = curr_results.error;
                        for j = 1:size(curr_results.peak_params,1)
                            fooof_results(i,6+(6*(j-1)),curr_file) = curr_results.peak_params(j,1);
                            fooof_results(i,7+(6*(j-1)),curr_file) = curr_results.peak_params(j,2);
                            fooof_results(i,8+(6*(j-1)),curr_file) = curr_results.peak_params(j,3);
                            fooof_results(i,9+(6*(j-1)),curr_file) = curr_results.gaussian_params(j,1);
                            fooof_results(i,10+(6*(j-1)),curr_file) = curr_results.gaussian_params(j,2);
                            fooof_results(i,11+(6*(j-1)),curr_file) = curr_results.gaussian_params(j,3);
                        end
                    end
                end
            end
                 
        elseif grp_proc_info_in.fooof_average_chans == 0 %if channels should be run seperately
            %%run fooof for every channel
            eeg_wfp_mean_all = mean(eeg_wfp{1,1},3); %take average across trials
            thisEEG = eeg_wfp_mean_all(:,freq_inc);
            channels_to_analyze = file_proc_info.beapp_indx{1,1};
            if size(channels_to_analyze,1) == 1 %if the beapp info is input as a row vector (sometimes is)
                channels_to_analyze = channels_to_analyze';
            end
            next_channel_to_analyze_indx = 1;
            next_channel_to_analyze = channels_to_analyze(next_channel_to_analyze_indx,1);
            for i=1:size(eeg_wfp_mean_all,1)
                %if the channel hasn't been removed 
                row_labels{i} = strcat('Channel # ',num2str(i));
                 if i == next_channel_to_analyze && (ismember(i,grp_proc_info_in.fooof_chans_to_analyze) || isempty(grp_proc_info_in.fooof_chans_to_analyze))
                     pdf_name = erase(file_proc_info.beapp_fname{1},'.mat'); 
                     pdf_name = strcat(pdf_name,'_',num2str(i));
                     save_report = 0;
                     if grp_proc_info_in.fooof_save_all_reports == 1 || ((ismember(i,grp_proc_info_in.fooof_save_channels) && ...
                               ismember(file_proc_info.beapp_fname{1}, grp_proc_info_in.fooof_save_participants)) || (ismember(i,grp_proc_info_in.fooof_save_channels) && ...
                               isempty(grp_proc_info_in.fooof_save_participants)) || (isempty(grp_proc_info_in.fooof_save_channels) && ismember(file_proc_info.beapp_fname{1},grp_proc_info_in.fooof_save_participants)))
                            save_report = 1;
                     end
                     curr_results = fooof(freqs, thisEEG(i,:), f_range, settings, pdf_name, grp_proc_info_in, save_report);
                     fooof_results(i,1,curr_file) = curr_results.background_params(1,1);
                     if grp_proc_info_in.fooof_background_mode == 2 %%knee has 3rd parameter needed to be saved 
                        fooof_results(i,2,curr_file) = curr_results.background_params(1,3); %%slope gets bumped to 3rd param
                        fooof_results(i,3,curr_file) = curr_results.background_params(1,2); %%knee is second
                     else
                        fooof_results(i,2,curr_file) = curr_results.background_params(1,2);
                     end
                     fooof_results(i,4,curr_file) = curr_results.r_squared;
                     fooof_results(i,5,curr_file) = curr_results.error;
                     for j = 1:size(curr_results.peak_params,1)
                         fooof_results(i,6+(6*(j-1)),curr_file) = curr_results.peak_params(j,1);
                         fooof_results(i,7+(6*(j-1)),curr_file) = curr_results.peak_params(j,2);
                         fooof_results(i,8+(6*(j-1)),curr_file) = curr_results.peak_params(j,3);
                         fooof_results(i,9+(6*(j-1)),curr_file) = curr_results.gaussian_params(j,1);
                         fooof_results(i,10+(6*(j-1)),curr_file) = curr_results.gaussian_params(j,2);
                         fooof_results(i,11+(6*(j-1)),curr_file) = curr_results.gaussian_params(j,3);
                     end
                     next_channel_to_analyze_indx = next_channel_to_analyze_indx + 1;
                     if next_channel_to_analyze_indx > size(channels_to_analyze,1) %%if there are no more channels to analyze
                         break;
                     end
                     next_channel_to_analyze = channels_to_analyze(next_channel_to_analyze_indx,1);
                 end
            end
        else %throw error, input wasn't 1 or 0         
            error('fooof_average_chans needs to be either a 1 or 0; No other options are available')
        end
      end
end

%%make dimension labels  
column_labels = {'background_offset','background_slope','knee','r_squared','error'};

for i = 1:grp_proc_info_in.fooof_max_n_peaks  
    column_labels{1,6+(6*(i-1))} = strcat('CF_peak_',num2str(i));
    column_labels{1,7+(6*(i-1))} = strcat('AMP_peak_',num2str(i));
    column_labels{1,8+(6*(i-1))} = strcat('BW_peak_',num2str(i));
    column_labels{1,9+(6*(i-1))} = strcat('Gauss_CF_peak_',num2str(i));
    column_labels{1,10+(6*(i-1))} = strcat('Gauss_AMP_peak_',num2str(i));
    column_labels{1,11+(6*(i-1))} = strcat('Gauss_BW_peak_',num2str(i));
end
    
%%save fooof_data
file_proc_info = beapp_prepare_to_save_file('fooof',file_proc_info, grp_proc_info_in, src_dir{1});
row_labels = row_labels';
if grp_proc_info_in.fooof_average_chans && isempty(grp_proc_info_in.fooof_channel_groups) %you have a 2d table if you're averaging everything together
    save(strcat(grp_proc_info_in.beapp_curr_run_tag,'_fooof_results'),'fooof_results','column_labels','row_labels');
else
    save(strcat(grp_proc_info_in.beapp_curr_run_tag,'_fooof_results'),'fooof_results','column_labels','row_labels','third_dimension_labels');
end

%If needed, write excel outputs. Has to be done differently depending on if
%channels are run seperately, averaged together or in groups

%If channels are averaged all together
if grp_proc_info_in.fooof_xlsout_on == 1 && grp_proc_info_in.fooof_average_chans == 1 && isempty(grp_proc_info_in.fooof_channel_groups) %%TEMP: only allow excel outputs if fooof_results is a 2-d table
    %add in row and column labels to actual fooof matrix, then save as
    %excel file
    fooof_results = [column_labels;num2cell(fooof_results)];
    row_labels = ['row';row_labels];
    fooof_results = [row_labels,fooof_results];
    xlswrite(strcat(grp_proc_info_in.beapp_curr_run_tag,'_fooof_report.xls'),fooof_results);
%If chans are run seperately
elseif grp_proc_info_in.fooof_xlsout_on == 1 && grp_proc_info_in.fooof_average_chans == 0
    for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
        curr_results = fooof_results(:,:,curr_file);
        %fill in labels for all possible channels
        row_labels = cell(max_n_channels,1);
        for i = 1:max_n_channels
            row_labels{i} = strcat('Channel # ',num2str(i));
        end
        curr_results = [column_labels;num2cell(curr_results)];
        row_labels = ['row';row_labels];
        curr_results = [row_labels,curr_results];
        xlswrite(strcat(grp_proc_info_in.beapp_curr_run_tag,'_fooof_report.xls'),curr_results,grp_proc_info_in.beapp_fname_all{curr_file});
    end
%If chans are averaged in groups
elseif grp_proc_info_in.fooof_xlsout_on == 1
    row_labels = ['row';row_labels];
    for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
         curr_results = fooof_results(:,:,curr_file);
         curr_results = [column_labels;num2cell(curr_results)];
         curr_results = [row_labels,curr_results];
         xlswrite(strcat(grp_proc_info_in.beapp_curr_run_tag,'_fooof_report.xls'),curr_results,grp_proc_info_in.beapp_fname_all{curr_file});
    end
end


clearvars -except grp_proc_info_in src_dir curr_file
