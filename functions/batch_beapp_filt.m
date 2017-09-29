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

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1})
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        tic;
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        
        for curr_epoch = 1:size(eeg,2)
            diary off;
            % filtering types in a table in case we want to add more
            % options
            
            % lowpass filtering
            if grp_proc_info_in.beapp_filters{'Lowpass','Filt_On'}
                disp(['Applying a low pass filter of type: ' grp_proc_info_in.beapp_filters{'Lowpass','Filt_Name'}{1}])
                
                % eegfilt checks for nyquist
                if strcmp(grp_proc_info_in.beapp_filters{'Lowpass','Filt_Name'}{1},'eegfilt')
                    eeg{curr_epoch}=eegfilt(eeg{curr_epoch},file_proc_info.beapp_srate,0,grp_proc_info_in.beapp_filters{'Lowpass','Filt_Cutoff_Freq'});
                end
            end
            
            % highpass filtering
            if grp_proc_info_in.beapp_filters{'Highpass','Filt_On'}
                disp(['Applying a highpass filter of type: ' grp_proc_info_in.beapp_filters{'Highpass','Filt_Name'}{1}]);
                eeg{curr_epoch}=eegfilt(eeg{curr_epoch},file_proc_info.beapp_srate,grp_proc_info_in.beapp_filters{'Highpass','Filt_Cutoff_Freq'},0);
            end
            
            % notch filter
            if grp_proc_info_in.beapp_filters{'Notch','Filt_On'}
                disp(['Applying a notch filter for ' int2str(file_proc_info.src_linenoise) ' Hz line noise']);
                eeg{curr_epoch}=beapp_notch_filt(eeg{curr_epoch},file_proc_info.src_linenoise,file_proc_info.beapp_srate/2); %use proc_info because later each file may have a new linenoise value when there is a mix of US and international data files
            end
            
            if grp_proc_info_in.beapp_filters{'Cleanline','Filt_On'}
                
                EEG_tmp =curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_epoch},curr_epoch);
                EEG_tmp = pop_cleanline(EEG_tmp, 'Bandwidth',2,'chanlist',[file_proc_info.beapp_indx{curr_epoch}],...
                    'computepower',1,'linefreqs',[file_proc_info.src_linenoise file_proc_info.src_linenoise*2] ,...
                    'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype',...
                    'Channels','tau',100,'verb',0,'winsize',4,'winstep',1, 'ComputeSpectralPower','False');
                close all;
                eeg{curr_epoch} = EEG_tmp.data;
            end
        end
        
        diary on;
        %save filtered eeg to output
        if ~all(cellfun(@isempty,eeg))
            file_proc_info = beapp_prepare_to_save_file('filt',file_proc_info, grp_proc_info_in, src_dir{1});
            save(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        end
        clearvars -except grp_proc_info_in curr_file src_dir lowp_filt srate_high
    end
end
