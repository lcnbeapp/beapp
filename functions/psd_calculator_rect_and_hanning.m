%% psd_calculator_rect_and_hanning 
%
% calculate psd using rectangular or Hann/ Hanning window
% Inputs:
% eeg_w- segmented eeg (one condition)
% w - window
% srate-sampling rate
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
function [eeg_wf, eeg_wfp,f]= psd_calculator_rect_and_hanning (eeg_w,w,srate)
            %apply window to EEG segments
            eeg_w=eeg_w.*w;
            
            %Calculate the FFT
            nfft=2^nextpow2(size(eeg_w,2));
            eeg_wf=fft(eeg_w,nfft,2);
            
            %save the complex fft values unscaled
            eeg_wf=eeg_wf(:,1:(nfft/2+1),:);
            
            %calculate power spectra
            eeg_wfp=2*((1/(srate*size(eeg_w,2))).*abs(eeg_wf).^2);
            
            %frequency axis
            f=srate/2*linspace(0,1,(nfft/2)+1);