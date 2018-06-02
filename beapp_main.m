function beapp_main(grp_proc_info_main)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C) 2015, 2016, 2017
% 
% 
% Developed at Boston Children's Hospital Department of Neurology and the
% Laboratories of Cognitive Neuroscience
% 
% All rights reserved.
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
% 
% Description:
% The Batch Electroencephalography Automated Processing Platform (BEAPP) is a modular,
% MATLAB-based software designed to facilitate flexible batch processing 
% of baseline and event related EEG files for artifact removal and analysis. 
% BEAPP is designed for users who are comfortable using the MATLAB
% environment to run software but does not require advanced programing
% knowledge.
% 
% Contributors to BEAPP:
% April R. Levin, MD (april.levin@childrens.harvard.edu)
% Adriana Méndez Leal (asmendezleal@gmail.com)
% Laurel Gabard-Durnam, PhD (laurel.gabarddurnam@gmail.com)
% Heather M. O'Leary (Heather.oleary1@gmail.com)
% 
% Correspondence: 
% April R. Levin, MD
% april.levin@childrens.harvard.edu
%
% In publications, please reference:
% Levin AR., Méndez Leal A., Gabard-Durnam L., O'Leary, HM (2017) BEAPP: The Batch Electroencephalography Automated Processing Platform
% Manuscript in preparation
% 
% Additional Credits:
% BEAPP utilizes functionality from the software listed below. Users who choose to run any of this
% software through BEAPP should cite the appropriate papers in any publications. 
% 
% EEGLAB Version 14.0.0b
% http://sccn.ucsd.edu/wiki/EEGLAB_revision_history_version_14
% 
% Delorme A & Makeig S (2004) EEGLAB: an open source toolbox for analysis
% of single-trial EEG dynamics. Journal of Neuroscience Methods 134:9-21
% 
% PREP pipeline Version 0.52
% https://github.com/VisLab/EEG-Clean-Tools
% 
% Bigdely-Shamlo N, Mullen T, Kothe C, Su K-M and Robbins KA (2015)
% The PREP pipeline: standardized preprocessing for large-scale EEG analysis
% Front. Neuroinform. 9:16. doi: 10.3389/fninf.2015.00016
% 
% CSD Toolbox
% http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/
% 
% Kayser, J., Tenke, C.E. (2006). Principal components analysis of Laplacian
% waveforms as a generic method for identifying ERP generator patterns: I. 
% Evaluation with auditory oddball tasks. Clinical Neurophysiology, 117(2), 348-368
% 
% Users using low-resolution (less than 64 channel) montages with the CSD toolbox should also cite: 
% Kayser, J., Tenke, C.E. (2006). Principal components analysis of Laplacian
% waveforms as a generic method for identifying ERP generator patterns: II. 
% Adequacy of low-density estimates. Clinical Neurophysiology, 117(2), 369-380
% 
% HAPP-E Version 1.0
% Gabard-Durnam LJ, Méndez Leal AS, and Levin AR (2017) The Harvard Automated Pre-processing Pipeline for EEG (HAPP-E)
% Manuscript in preparation

% Requirements:
% BEAPP was written in Matlab 2016a. Older versions of Matlab may not
% support certain functions used in BEAPP. 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tic;

% set defaults and path, get user inputs if using scripts
if isequal(grp_proc_info_main, 'use_script')
    grp_proc_info_main = beapp_configure_settings;
end

% check inputs, set output directories
grp_proc_info_main = prepare_to_run_main (grp_proc_info_main);

% run pipeline modules
if grp_proc_info_main.beapp_toggle_mods{'format','Module_On'}
    grp_proc_info_main = batch_beapp_format(grp_proc_info_main);
end

if grp_proc_info_main.beapp_toggle_mods{'prepp','Module_On'}
    grp_proc_info_main = batch_beapp_prepp(grp_proc_info_main);
end

if grp_proc_info_main.beapp_toggle_mods{'filt','Module_On'}
    grp_proc_info_main = batch_beapp_filt(grp_proc_info_main);
end

if grp_proc_info_main.beapp_toggle_mods{'rsamp','Module_On'}
    grp_proc_info_main = batch_beapp_rsamp(grp_proc_info_main);
end

if grp_proc_info_main.beapp_toggle_mods{'ica','Module_On'}
    grp_proc_info_main = batch_beapp_ica(grp_proc_info_main);
end

if grp_proc_info_main.beapp_toggle_mods{'rereference','Module_On'}
    grp_proc_info_main = batch_beapp_rereference(grp_proc_info_main);
end


if grp_proc_info_main.beapp_toggle_mods{'detrend','Module_On'}
    grp_proc_info_main = batch_beapp_detrend(grp_proc_info_main);
end

%create segments/analysis windows from the data according to data type
if grp_proc_info_main.beapp_toggle_mods{'segment','Module_On'}
    grp_proc_info_main = batch_beapp_segment(grp_proc_info_main);
end

%%  output modules
if grp_proc_info_main.beapp_toggle_mods{'psd','Module_On'}
    grp_proc_info_main =batch_beapp_psd(grp_proc_info_main);
end

if grp_proc_info_main.beapp_toggle_mods{'itpc','Module_On'}
    grp_proc_info_main = batch_beapp_itpc(grp_proc_info_main);
end

diary off;
cd(grp_proc_info_main.src_dir{1});

% deletes temporary directories
rowfun(@delete_temp_dirs,grp_proc_info_main.beapp_toggle_mods,'NumOutputs',0);

%end the timer
grp_proc_info_main.proc_etime=toc;

%runtime report is written into out directory
mk_runtime_report(grp_proc_info_main);

%return to the source code directory
if isdir(grp_proc_info_main.beapp_root_dir{1})
    disp('Processing completed returning to the BEAPP source code directory');
    cd(grp_proc_info_main.beapp_root_dir{1});
else
    disp('Processing completed');
end

clearvars;
end
