% set_beapp_pmtm_vars
%
% script to set the multitaper parameters
% checks that the multitaper option is set by the user
% if false assume that the user intened to use a different window type and
% skip this script
%
% uses grp_proc_info struct
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
if grp_proc_info_in.psd_win_typ==3
    
    %confirm that the user set the number of tapers to an integer that is 3 or greater    
    if grp_proc_info_in.psd_pmtm_l~=floor(grp_proc_info_in.psd_pmtm_l) || grp_proc_info_in.psd_pmtm_l<3
        
        disp(['The number of tapers that you selected ',grp_proc_info_in.psd_pmtm_l,' is incorrect.']);
        grp_proc_info_in.psd_pmtm_l=input('Please enter a positive integer that is equal to or greater than 3:');
        
        if grp_proc_info_in.psd_pmtm_l==floor(grp_proc_info_in.psd_pmtm_l) || grp_proc_info_in.psd_pmtm_l<3
            disp('The number of tapers must be a positive integer that is greater than or equal to 3.');
            disp('Please check your user inputs and retry.');
            disp('Exiting Code.');
            return;
        end
    end
    
    %calculate alpha
    grp_proc_info_in.psd_pmtm_alpha=(grp_proc_info_in.psd_pmtm_l+1)/2;

    %calculate spectral resolution
    grp_proc_info_in.psd_pmtm_r=(2*grp_proc_info_in.psd_pmtm_alpha)/grp_proc_info_in.win_size_in_secs;
    
    for inum=1:length(grp_proc_info_in.bw)
        tmp1(inum)=diff(grp_proc_info_in.bw(inum,:));
    end
    
    if grp_proc_info_in.psd_pmtm_r>min(tmp1)
        disp('Your spectral resolution is larger than the width of your smallest bandwidth.');
        if grp_proc_info_in.psd_pmtm_l>3
            
            disp('You can resolve this by increasing your segment length or decreasing the number of tapers.');            
            disp('Please check your user inputs and retry.');
            disp('Exiting Code.');
            return;
        else 
            disp('You can resolve this by increasing your segment length.');
            disp('Please check your user inputs and retry.');
            disp('Exiting Code.');
            return;
        end
    end
    
    clear tmp1;
end