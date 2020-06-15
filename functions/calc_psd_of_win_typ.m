% calculate PSD of appropriate window type
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
function [eeg_wfp_curr_cond, eeg_wf_curr_cond,f] = calc_psd_of_win_typ(win_typ,eeg_w_curr_cond,srate,pmtm_alpha,psd_nfft)

% calculate complex FFT and power spectra for selected window type
switch win_typ
    
    case 0 % rectangular window
        w=ones(size(eeg_w_curr_cond));
        [eeg_wf_curr_cond, eeg_wfp_curr_cond,f] = psd_calculator_rect_and_hanning (eeg_w_curr_cond,w,srate);
        
    case 1 % hanning window
        h_win=(hanning(size(eeg_w_curr_cond,2),'periodic'))'; 
        w=repmat(h_win,size(eeg_w_curr_cond,1),1,size(eeg_w_curr_cond,3));
        [eeg_wf_curr_cond, eeg_wfp_curr_cond,f] = psd_calculator_rect_and_hanning (eeg_w_curr_cond,w,srate);
        
    case 2  %multitaper, using the pmtm function (only takes 1D channel x time inputs)
        
        firstrun = 1;
        for curr_segment=1:size(eeg_w_curr_cond,3)
            
            % save psd outputs for each channel into eeg_wfp
            for curr_channel=1:size(eeg_w_curr_cond,1)
                run = 1;
                try 
                    validateattributes(squeeze(eeg_w_curr_cond(curr_channel,:,curr_segment))',{'single','double'}, {'finite','nonnan'},'pmtm','x');
                catch
                    run = 0;
                end
                if run
                    [tmp_psd,fxx]=pmtm(squeeze(eeg_w_curr_cond(curr_channel,:,curr_segment))',pmtm_alpha,psd_nfft,srate);
                    eeg_wfp_curr_cond(curr_channel,:,curr_segment)=tmp_psd';
                end
                
                % save frequency axis during first iteration
                if firstrun && run
                    f=fxx;
                    firstrun = 0;
                end 
            end
        end
        
        %To make sure nchannels is the same
        if size(eeg_wfp_curr_cond,1) < size(eeg_w_curr_cond,1)
            eeg_wfp_curr_cond(curr_channel,:,:) = NaN;
        end
        eeg_wfp_curr_cond(eeg_wfp_curr_cond==0) = NaN;
        eeg_wf_curr_cond=NaN(size(eeg_wfp_curr_cond));%eeg_wf is not an output option for pmtm function
end