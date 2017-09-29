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
% GENERAL USER INPUTS for BEAPP: Set these for any data runs
grp_proc_info.src_dir={'C:\beapp_dev\Baseline_Mat'}; %the directory containing the source files, the files exported from Netstation(raw_eeg_src_dir)
grp_proc_info.beapp_curr_run_tag = 'Raw'; %def = '' or 'NONE'.  if you would like to append a tag to folder names for this run.'NONE' mutes timestamping. If not given on a rerun, a timestamp will be used. 
grp_proc_info.beapp_prev_run_tag = ''; % def = ''.  run tag for previous run that you would like to use as source data for rerun. can be timestamp, but must be exact.
grp_proc_info.beapp_advinputs_on=0; %flag that toggles advanced user options, default is 0 (user did not set advanced user values)

% MODULE SELECTION
% pipeline flags:0=off, 1=on
% modules commented out are not currently available but will be in the future
grp_proc_info.beapp_toggle_mods{'format',{'Module_On','Module_Export_On'}}=[1,1]; %flag that toggles the conversion of raw EEG to a general format that PREPP and BEAPP can use
grp_proc_info.beapp_toggle_mods{'prepp',{'Module_On','Module_Export_On'}}=[0,0];%flag that toggles the PREP pipeline, assume that PREP pipeline will be used
grp_proc_info.beapp_toggle_mods{'filt',{'Module_On','Module_Export_On'}}=[0,0]; %flag that toggles the filtering option on, this should be left on if some data needs to be down sampled
grp_proc_info.beapp_toggle_mods{'rsamp',{'Module_On','Module_Export_On'}}=[0,0];  %flag that toggles the BEAPP resampling code
grp_proc_info.beapp_toggle_mods{'ica',{'Module_On','Module_Export_On'}}=[0,0];
grp_proc_info.beapp_toggle_mods{'rereference',{'Module_On','Module_Export_On'}}=[0,0];%flags the rereferencing module on
grp_proc_info.beapp_toggle_mods{'detrend',{'Module_On','Module_Export_On'}}=[0,0]; % flag that toggles detrending 
grp_proc_info.beapp_toggle_mods{'segment',{'Module_On','Module_Export_On'}}=[1,1]; %flag that toggles the BEAPP code that creats fixed segments for psd calculations
grp_proc_info.beapp_toggle_mods{'psd',{'Module_On','Module_Export_On'}}=[1,1]; %flag that toggles the PSD calculations
grp_proc_info.beapp_toggle_mods{'itpc',{'Module_On','Module_Export_On'}}=[0,0]; %turns ITPC analysis on, use with event data only

% FORMATTING SPECIFICATIONS
%Formatting specifications: Required
grp_proc_info.src_format_typ = 1; %type of source file 1=.mat files, 2=mff, 3=PRE-PROCESSED + PRE-SEGMENTED MFF 
grp_proc_info.src_data_type = 1; % type of data being processed (for segmenting,see user guide): 1 = baseline, 2 = event related

%Formatting specifications: Optional
grp_proc_info.src_linenoise= 60; % def = 60. for the notch filter, HAPPE,cleanline and PREP. If linenoise is different across files, set to = 'input_table' and put information in appropriate input table
grp_proc_info.src_unique_nets={'HydroCel GSN 128 1.0','Geodesic Sensor Net 64 2.0'};   % def ={''} If not running HAPP-E with multiple nets, optional for speed. Required for more than one net if running HAPP-E
grp_proc_info.src_unique_srates = [500,250]; % only needs to be filled in during reruns,optional for rerun speed
grp_proc_info.epoch_inds_to_process = []; % def = []. ex [1], [3,4]Index of desired epochs to analyze (for ex. if resting is always in the first epoch, for baseline analysis = [1]);
grp_proc_info.src_eeg_vname={'Category_1_Segment1','Category_1','Category1'}; %possible variable name of the EEG data EEG_Segment1

%Formatting specifications: Events
%Formatting specifications: Event Offsets
grp_proc_info.event_tag_offsets = 0; % def = 0 OR 'offset_table'. Event offset in ms. If offset is not uniform across dataset, set to offset_table and input information as in mff_file_info_table in user inputs 

% Formatting specifications: Event Coding
grp_proc_info.beapp_event_code_onset_strs={'stm+'}; %Ex {'stm+'} the event codes assigned during data collection to signifiy the onset of the stimulus
grp_proc_info.beapp_event_eprime_values.condition_names = {'Standard','Native','Non-Native'};% desired condition names for cell numbers below
grp_proc_info.beapp_event_eprime_values.event_codes(:,1) = [1,2,3]; % these MUST line up across all possible cell sets
grp_proc_info.beapp_event_eprime_values.event_codes(:,2) = [10,12,13]; % these MUST line up across all possible cell sets
grp_proc_info.beapp_event_eprime_values.event_codes(:,3) = [11,12,13]; % these MUST line up across all possible cell sets

% Formatting specifications: Behavioral Coding
grp_proc_info.behavioral_coding.events = {''}; % def = {''}. Ex {'TRSP'} Events containing behavioral coding information
grp_proc_info.behavioral_coding.keys = {''}; % def = {''} Keys in events containing behavioral coding information
grp_proc_info.behavioral_coding.bad_value = {''}; % def = {''}. Value that marks behavioral coding as bad. must be string - number values must be listed as string, ex '1'

%PREP SPECIFICATIONS
grp_proc_info.beapp_toggle_mods{'prepp','Module_Xls_Out_On'} = 1; % flag that toggles prepp xls report option on
%Note that PREP removes line noise; be sure to set line noise correctly in formatting specifications

% FILTER SPECIFICATIONS
grp_proc_info.beapp_filters{'Notch','Filt_On'} = 0; %Turning on the notch filter will remove line noise frequency
grp_proc_info.beapp_filters{'Lowpass','Filt_On'} = 1;
grp_proc_info.beapp_filters{'Lowpass','Filt_Cutoff_Freq'} = 100; 
grp_proc_info.beapp_filters{'Highpass','Filt_On'} = 1;
grp_proc_info.beapp_filters{'Highpass','Filt_Cutoff_Freq'} = 1; % def = 1
grp_proc_info.beapp_filters{'Cleanline','Filt_On'} = 0;
%Note that cleanline removes line noise; be sure to set line noise correctly in formatting specifications

%RESAMPLING SPECIFICATIONS
grp_proc_info.beapp_rsamp_srate = 250; %target sampling rate for resampling, if desired

% ICA SPECIFICATIONS
grp_proc_info.beapp_ica_type  = 2; % 1 = ICA with MARA, 2 = HAPPE, 3 = only ICA 
grp_proc_info.beapp_toggle_mods{'ica','Module_Xls_Out_On'} = 1; % flag that toggles ICA xls report option on

% additional channels labels being analyzed beyond 10-20 channels in ICA module
% MUST match number of nets and order of nets in .src_unique nets exactly
grp_proc_info.beapp_ica_additional_chans_lbls{1} = {'E27','E23','E19','E4','E3','E123','E20','E118','E28','E41','E13','E117',...
    'E112','E103','E40','E46','E47','E109','E102','E98','E75'}; % def = {''}.
grp_proc_info.beapp_ica_additional_chans_lbls{2} = {'E12','E2','E8','E3','E16','E9','E58','E57','E21','E53','E25','E50'};% def = {''}.

% REREFENCING SPECIFICATIONS
grp_proc_info.reref_typ = 2; %type of reference method to use (1= average, 2= CSD Laplacian, 3 = specific electrodes)

% Rows in eeg corresponding to desired reference channel for each net (only used if reref_typ = 3)
% MUST match number of nets and order of nets in .src_unique nets exactly ex {[57,100],[51,26]};
grp_proc_info.beapp_reref_chan_inds = {[]}; % def = {[]}; 

% DETRENDING SPECIFICATIONS
grp_proc_info.dtrend_typ=1; %type of detrending method to use (1=mean, 2=linear, 3=Kalman)

%SEGMENTING SPECIFICATIONS
%Set artifact rejection criteria
% def = 1; flag that toggles the removal of high-amplitude artifact before segmentation (only used for baseline)
% 0 = off; 1 = mark samples with any channels above threshold bad; 2 = mark
% samples with percentage channels above threshold bad
grp_proc_info.beapp_baseline_msk_artifact=1; 

% percent (0-100) of channels being analyzed above threshold required to mask sample for pre-segmentation rejection
% only used if grp_proc_info.beapp_baseline_msk_artifact=2 
grp_proc_info.beapp_baseline_rej_perc_above_threshold = 1; % def = .01; (.01%, should reject if any channels bad assuming channel # <1000)  

grp_proc_info.art_thresh = 100; %threshold in uV for artifact removal -- will need to be adjusted for scale if CSDLP is run beforehand

grp_proc_info.beapp_reject_segs_by_amplitude= 0; % def = 1; flag that toggles amplitude-based rejection of segments after segment creation
grp_proc_info.beapp_happe_segment_rejection = 0; %

%For continous (non-event-related data only): Set segment size
grp_proc_info.win_size_in_secs = 1; % def = 1, number of seconds for each window for segmentation and calculations (for continuous data; for event data, see above)

%For event-related data only: Set where to create segments, relative to the event marker of interest
grp_proc_info.evt_seg_win_start = -0.100; % def = -0.100;  start time in seconds for segments, relative to the event marker of interest (ex -0.100, 0) 
grp_proc_info.evt_seg_win_end = 0.800;  % def = .800; end time in seconds for segments, relative to the event marker of interest (ex .800, 1) 
%Set which event data to analyze, relative to the event marker of interest (This can be the whole segment, or part of a segment) 
grp_proc_info.evt_analysis_win_start = 0.100; % def = -0.100;  start time in seconds for analysis segments, relative to the event marker of interest (ex -0.100, 0) 
grp_proc_info.evt_analysis_win_end = 0.300;  % def = .800; end time in seconds for analysis segments, relative to the event marker of interest (ex .800, 1) 
%Set which event data is baseline 
grp_proc_info.evt_trial_baseline_removal = 0; % def = 0; flag on use of pop_rmbaseline in segmentation module. 
grp_proc_info.evt_trial_baseline_win_start = -.100; % def = -0.100;  start time in seconds for baseline, relative to the event marker of interest (ex -0.100, 0). Must be within range you've segmented on. 
grp_proc_info.evt_trial_baseline_win_end = -.001; % def = -0.100;  start time in seconds for baseline, relative to the event marker of interest (ex -0.100, 0) 

%OUTPUT MEASURE SPECIFICATIONS
% Bandwith information. Total includes in all output bands by default
grp_proc_info.bw(1,1:2)=[2,3.99]; %bandwidth 1 start and end frequencies (the first band), can have as many or as few bandwidths as the user would like
grp_proc_info.bw_name(1)={'Delta'}; %name of bandwidth 1
grp_proc_info.bw(2,1:2)=[4,5.99]; %bandwidth 2
grp_proc_info.bw_name(2)={'Theta'}; %name of bandwidth 2
grp_proc_info.bw(3,1:2)=[6,8.99]; %bandwidth 3
grp_proc_info.bw_name(3)={'LowAlpha'}; %name of bandwidth 3
grp_proc_info.bw(4,1:2)=[9,12.99]; %bandwidth 4
grp_proc_info.bw_name(4)={'HighAlpha'}; %name of bandwidth 4
grp_proc_info.bw(5,1:2)=[13,29.99]; %bandwidth 5
grp_proc_info.bw_name(5)={'Beta'}; %name of bandwidth 5
grp_proc_info.bw(6,1:2)=[30,44.99]; %bandwidth 6
grp_proc_info.bw_name(6)={'Gamma'}; %name of bandwidth 6

% frequencies to include in calculation of total power (for normalization). def = [1:100]. Separate ranges with commas. Ex: [2:58.3, 62.1:110];
% gaps between frequencies of less than 1 Hz will be ignored
grp_proc_info.bw_total_freqs = [1:100];

% PSD SPECIFICATIONS
grp_proc_info.psd_win_typ=1; %power spectra windowing type 0=rectangular window, 1=hanning window, 2=multitaper (recomended 2 seconds or longer)
grp_proc_info.psd_interp_typ=1; %type of interpolation of psd 1 none, 2 linear, 3 nearest neighbor, 4 piecewise cubic spline  
grp_proc_info.beapp_toggle_mods{'psd','Module_Xls_Out_On'}=1; %flags the export data to xls report option on

% ITPC SPECIFICATIONS
grp_proc_info.beapp_itpc_params.win_size= 0.128; %the win_size (in seconds) to calculate ERSP and ITPC from the ERPs of the composed dataset (e.g. should result in a number of samples an integer and divide trials equaly ex: 10)
grp_proc_info.beapp_toggle_mods{'itpc','Module_Xls_Out_On'}=1;%flags the export data to xls report option on
