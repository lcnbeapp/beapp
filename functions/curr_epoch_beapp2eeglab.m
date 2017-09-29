%% curr_epoch_beapp2eeglab
%
% convert current recording period ("epoch" in old BEAPP) to EEGLAB struct
% will eventually be changed to curr_rec_period_beapp2eeglab
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
function EEG=curr_epoch_beapp2eeglab(file_proc_info,eeg_curr_epoch,curr_epoch)
% initialize EEGLab structure using EEGLab script
EEG=eeg_emptyset;
EEG.data = eeg_curr_epoch; 
EEG.srate=file_proc_info.beapp_srate;
EEG.setname = file_proc_info.beapp_fname{1}; 
EEG.nbchan=file_proc_info.beapp_nchans_used(curr_epoch);
EEG.chanlocs=file_proc_info.net_vstruct;
EEG.history=sprintf(['EEG = pop_importdata(''dataformat'',''matlab'',''nbchan'',0,''data'',',file_proc_info.beapp_fname{1},'''',',''setname'',''BEAPP_Dataset'',''srate'',0,''pnts'',0,''xmin'',0);\n','EEG = eeg_checkset( EEG );']);
EEG.noiseDetection.status = [];
EEG.noiseDetection.errors.status = '';
EEG=orderfields(EEG);
EEG=eeg_checkset(EEG);
