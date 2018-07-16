%% batch_beapp_filter (grp_proc_info)
% filter files (lowpass, highpass, notch) and/or apply cleanline
%
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
function grp_proc_info_in = batch_beapp_filt(grp_proc_info_in)

% identify data source directory based on processing history
src_dir = find_input_dir('filt',grp_proc_info_in.beapp_toggle_mods);


% set cutoff for lowpass filter
if grp_proc_info_in.beapp_filters{'Lowpass','Filt_On'}
    disp(['Applying a low pass filter of type: ' grp_proc_info_in.beapp_filters{'Lowpass','Filt_Name'}{1}])
    
    high_freq_cutoff = grp_proc_info_in.beapp_filters{'Lowpass','Filt_Cutoff_Freq'};
    
else
    high_freq_cutoff = [];
end

if grp_proc_info_in.beapp_filters{'Highpass','Filt_On'}
    disp(['Applying a highpass filter of type: ' grp_proc_info_in.beapp_filters{'Highpass','Filt_Name'}{1}]);
    low_freq_cutoff = grp_proc_info_in.beapp_filters{'Highpass','Filt_Cutoff_Freq'};
else
    low_freq_cutoff = [];
end

% add path to cleanline
if exist('cleanline', 'file') && grp_proc_info_in.beapp_filters{'Cleanline','Filt_On'}
    cleanline_path = which('eegplugin_cleanline.m');
    cleanline_path = cleanline_path(1:findstr(cleanline_path,'eegplugin_cleanline.m')-1);
    addpath(genpath(cleanline_path));
end

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1})
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        tic;
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        
        for curr_epoch = 1:size(eeg,2)
            diary off;
            
            EEG_curr_rec_period = curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_epoch},curr_epoch);
            
            % highpass/lowpass/bandpass
            if grp_proc_info_in.beapp_filters{'Highpass','Filt_On'} || grp_proc_info_in.beapp_filters{'Lowpass','Filt_On'}
                if strcmp(grp_proc_info_in.beapp_filters{'Highpass','Filt_Name'}{1},'eegfilt') || strcmp(grp_proc_info_in.beapp_filters{'Lowpass','Filt_Name'}{1},'eegfilt')
                    EEG_curr_rec_period = pop_eegfiltnew(EEG_curr_rec_period,low_freq_cutoff, high_freq_cutoff, [],0,[],0);
                end
            end
                                   
            % notch filter
            if grp_proc_info_in.beapp_filters{'Notch','Filt_On'}
                disp(['Applying a notch filter for ' int2str(file_proc_info.src_linenoise) ' Hz line noise']);
                EEG_curr_rec_period.data = beapp_notch_filt(EEG_curr_rec_period.data,file_proc_info.src_linenoise,file_proc_info.beapp_srate/2); 
            end
            
            % cleanline
            if grp_proc_info_in.beapp_filters{'Cleanline','Filt_On'}
                
                EEG_curr_rec_period = pop_cleanline(EEG_curr_rec_period, 'Bandwidth',2,'chanlist',[file_proc_info.beapp_indx{curr_epoch}],...
                    'computepower',1,'linefreqs',[file_proc_info.src_linenoise file_proc_info.src_linenoise*2] ,...
                    'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype',...
                    'Channels','tau',100,'verb',0,'winsize',4,'winstep',1, 'ComputeSpectralPower','False');
                close all;
            end
            
            eeg{curr_epoch} = EEG_curr_rec_period.data;
        end
        
        diary on;
        %save filtered eeg to output
        if ~all(cellfun(@isempty,eeg))
            file_proc_info = beapp_prepare_to_save_file('filt',file_proc_info, grp_proc_info_in, src_dir{1});
            save(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        end
        clearvars -except grp_proc_info_in curr_file src_dir lowp_filt srate_high low_freq_cutoff high_freq_cutoff cleanline_path
    end
end

if grp_proc_info_in.beapp_filters{'Cleanline','Filt_On'} && exist (cleanline_path,'var')
    % remove cleanline path
    rmpath(genpath(cleanline_path));
end