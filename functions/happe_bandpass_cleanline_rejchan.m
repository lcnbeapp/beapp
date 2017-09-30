%% happe_bandpass_cleanline_rejchan
%
% 1-249 bandpass, cleanline, and reject channels as in HAPPE
%
% HAPPE Version 1.0
% Gabard-Durnam LJ, Méndez Leal AS, and Levin AR (2017) The Harvard Automated Pre-processing Pipeline for EEG (HAPP-E)
% Manuscript in preparation
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
function [EEG_tmp, full_selected_channels] = happe_bandpass_cleanline_rejchan (EEG_orig,chan_IDs, curr_srate, src_linenoise)

%1 Hz highpass, if srate> 250, bandpass 1-249 Hz (ICA doesn't reliably work well here with frequencies above 250hz)
if curr_srate <500
    EEG_tmp = pop_eegfiltnew(EEG_orig, [],1,[],1,[],0);
else
    EEG_tmp = pop_eegfiltnew(EEG_orig, 1,249,[],0,[],0);
end

EEG_tmp = pop_select(EEG_tmp,'channel', chan_IDs);

%select EEG channels of interest for analyses and 10-20 channels
full_selected_channels = EEG_tmp.chanlocs;
diary off;

%reduce line noise in the data (note: may not completely eliminate, re-referencing helps at the end as well)
EEG_tmp = pop_cleanline(EEG_tmp, 'Bandwidth',2,'chanlist',[1:length(chan_IDs)],...
    'computepower',1,'linefreqs',[src_linenoise src_linenoise*2] ,...
    'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype',...
    'Channels','tau',100,'verb',0,'winsize',4,'winstep',1, 'ComputeSpectralPower','False');
close all;

%crude bad channel detection using spectrum criteria and 3SDeviations as channel outlier threshold, done twice
EEG_tmp = pop_rejchan(EEG_tmp, 'elec',[1:length(chan_IDs)],'threshold',[-3 3],'norm','on','measure','spec','freqrange',[1 125]);
EEG_tmp = pop_rejchan(EEG_tmp, 'elec',[1:EEG_tmp.nbchan],'threshold',[-3 3],'norm','on','measure','spec','freqrange',[1 125] );