%% happe_run_wICA_on_file
%
% run wICA as in HAPPE
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

function EEG_wavcleaned = happe_run_wICA_on_file(EEG_tmp, curr_srate, happe_plotting_on)

%run wavelet-ICA (ICA first for clustering the data, then wavelet thresholding on the ICs)
%uses a soft, global threshold for the wavelets, wavelet family is coiflet (level 5), threshold multiplier .75 to remove more high frequency noise
%for details, see wICA.m function
[wIC, A, W, IC] = wICA(EEG_tmp,'runica', 1, happe_plotting_on,curr_srate,5);

%reconstruct artifact signal as channels x samples format from the wavelet coefficients
artifacts = A*wIC;

%reshape EEG signal from EEGlab format to channelsxsamples format
EEG2D=reshape(EEG_tmp.data, size(EEG_tmp.data,1), []);

%subtract out wavelet artifact signal from EEG signal
wavcleanEEG=EEG2D-artifacts;
EEG_wavcleaned = EEG_tmp;
EEG_wavcleaned.data = wavcleanEEG;
