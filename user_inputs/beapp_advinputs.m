%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C) 2015, 2016, 2017
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
% Adriana S. Méndez Leal (asmendezleal@gmail.com)
% Laurel J. Gabard-Durnam, PhD (laurel.gabarddurnam@gmail.com)
% Heather M. O'Leary (Heather.oleary1@gmail.com)
% 
% Correspondence: 
% April R. Levin, MD
% april.levin@childrens.harvard.edu
%
%
% In publications, please reference:
% Levin AR, Méndez Leal AS, Gabard-Durnam LJ, and O'Leary, HM (2017)
% BEAPP: The Batch Electroencephalography Automated Processing Platform 
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

% This script will only run if the user sets proc_info.advinputs_on=1; in
% beapp_userinputs, and will override default settings

% GENERAL ADVANCED USER INPUTS for BEAPP:
grp_proc_info.beapp_dir_warn_off = 0; % def = 0; if 1, mute directory warnings
grp_proc_info.beapp_use_rerun_table = 0; % def = 0; if 1, use rerun table to run a subset of files. not needed for normal reruns
grp_proc_info.beapp_rmv_bad_chan_on=0; % def = 0; 1 if you'd like to remove channels flagged as bad in PREP or HAPPE

% FORMATTING SPECIFICATIONS
grp_proc_info.mff_seg_throw_out_bad_segments = 1; % throw out segments marked bad when importing pre-segmented MFF files. def = 1; 

% FILTER SPECIFICATIONS
%Sets the buffer at the begining and end of the source files when making segments
%This should only be set to 0 if no filtering is applied to the data.
grp_proc_info.src_buff_start_nsec=2; %number of seconds buffer at the start of the EEG recording that can be excluded after filtering and artifact removal (buff1_nsec)
grp_proc_info.src_buff_end_nsec=2; %number of seconds buffer at the end of the EEG recording that can be excluded after filtering and artifact removal (buff2_nsec)

% ICA/HAPPE/MARA
% def = 0; turns on HAPPE/MARA visualisations - will then require user feedback for each file
grp_proc_info.happe_plotting_on = 0; 

% REREFENCING SPECIFICATIONS 
grp_proc_info.beapp_csdlp_interp_flex=4; % m=2...10, 4 spline. def = 4; Used in CSD toolbox only
%grp_proc_info.beapp_csdlp_lambda=1e-5; %learning rate def = 1e-5;

% DETRENDING SPECIFICATIONS 
grp_proc_info.kalman_b=0.9999; %used to determine smoothing in the Kalman filter
grp_proc_info.kalman_q_init=1; %used to determine smoothing in Kalman filter

% SEGMENTING SPECIFICATIONS
grp_proc_info.beapp_happe_seg_rej_plotting_on = 0; % def = 0; show jointprob visualizations if happe segment rejection is on 

%for moving average filter applied to ERP data
grp_proc_info.beapp_erp_maf_on=0; %flags on the moving average filter when the ERP events are generated
grp_proc_info.beapp_erp_maf_order=30; %Order of the moving average filter

%% output measure settings
% PSD XLS report settings
grp_proc_info.psd_output_typ = 1; % psd = 1, power = 2, def = 1
grp_proc_info.psd_pmtm_l=3; %number of tapers to use if using the multitaper window type, should be a positive integer 3 or greater
grp_proc_info.beapp_xlsout_av_on=1; %toggles on the mean power option
grp_proc_info.beapp_xlsout_sd_on=1; %toggles on the standard deviation option
grp_proc_info.beapp_xlsout_med_on=1; %toggles on the median option
grp_proc_info.beapp_xlsout_raw_on=1; %toggles on that the absolute power should be reported
grp_proc_info.beapp_xlsout_norm_on=1; %toggles on that the normalized power should be reported
grp_proc_info.beapp_xlsout_log_on=1; %toggles on that the natural log should be reported
grp_proc_info.beapp_xlsout_log10_on=1; %toggles on that the log10 should be reported

% ITPC 
grp_proc_info.beapp_itpc_xlsout_mx_on=1; % report max ITPC in xls report?
grp_proc_info.beapp_itpc_xlsout_av_on=1; % report mean ITPC in xls report?
