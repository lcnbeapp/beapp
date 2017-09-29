%% batch_beapp2eeglab

% convert files (specific recording periods) from beapp format to EEGLAB format
% only applied to data pre-segmentation or baseline segmented
% Inputs: 
% src_dir = path to source directory with BEAPP files e.g
% ='C:\beapp_beta\prepp\';
% 
% out_dir = path to output directory for files e.g
% ='C:\beapp_beta\prepp_eeglab_format\';
%
% curr_rec_period : rec_period to pull file information from (eeg, bad chans,
% etc). should be integer ex. 1 

% event_data : 1 if you'd like to add events, 0 if not

% save_as_set: 1 if you'd like to save file as .set, 0 if .mat
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

function batch_beapp2eeglab(src_dir, out_dir,curr_rec_period,event_data, save_as_set)

cd(src_dir);
fname_all = dir('*.mat');
fname_all={fname_all.name};

if ~isdir(out_dir)
    mkdir(out_dir);
end

for curr_file=1:length(fname_all)
    
    cd(src_dir)
    
    if exist(strcat(src_dir,filesep,fname_all{curr_file}),'file')
        
        load(fname_all{curr_file},'eeg','file_proc_info');
        
        EEG = beapp2eeglab(file_proc_info,eeg{curr_rec_period},curr_rec_period,event_data);
        
        cd(out_dir);
        
        if ~save_as_set
            save(file_proc_info.beapp_fname{1},'EEG');
        else
            pop_saveset(EEG,'filename',strrep(file_proc_info.beapp_fname{1},'.mat','.set'));
        end
        clear EEG file_proc_info eeg
    end
end