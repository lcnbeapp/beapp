%% set_beapp_def
%
% initialize BEAPP grp_proc_info struct, which contains processing
% information for the whole dataset
%
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
% Adriana Méndez Leal (asmendezleal@gmail.com)
% Laurel Gabard-Durnam, PhD (laurel.gabarddurnam@gmail.com)
% Heather M. O'Leary (Heather.oleary1@gmail.com)
% 
% Correspondence: 
% April R. Levin, MD
% april.levin@childrens.harvard.edu
%
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
% Gabard-Durnam L., Méndez Leal A., and Levin AR (2017) The Harvard Automated Pre-processing Pipeline for EEG (HAPP-E)
% Manuscript in preparation

% Requirements:
% BEAPP was written in Matlab 2016a. Older versions of Matlab may not
% support certain functions used in BEAPP. 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function grp_proc_info = set_beapp_def 
%% version numbers for BEAPP and packages
grp_proc_info.beapp_ver={'BEAPP_v4_1'};
grp_proc_info.eeglab_ver = {'eeglab14_1_2b'};
grp_proc_info.fieldtrip_ver = {'fieldtrip-20160917'};
grp_proc_info.beapp_root_dir = {fileparts(mfilename('fullpath'))}; %sets the directory to the BEAPP code assuming that it is in same directory as set_beapp_def
grp_proc_info.HAPPE_ver_3 = {'HAPPE_v2_3_0_for_beapp'};
%% directory defaults and paths
grp_proc_info.beapp_pname={''}; %the Matlab paths where the BEAPP code is located 
grp_proc_info.src_dir={''}; %source directory containing the EEG data exported from Netstation, left empty in defaults because it must be set by the user 
grp_proc_info.beapp_genout_dir={''}; %general output directory that is used to store output when the directory that the output would normally be stored in is temporary

%% initialize module flags (which modules are on and off)
ModuleNames = {'format','prepp','filt','rsamp','ica','rereference','detrend','HAPPE_V3','segment','psd','itpc','topoplot','fooof','pac','bycycle'};
Module_Input_Type = {'cont','cont','cont','cont','cont','cont','cont','cont','cont','seg','seg','psd','psd','seg','seg'}'; %TODO: make output from psd 'psd'
Module_Output_Type ={'cont','cont','cont','cont','cont','cont','cont','cont or seg','seg','psd','out','out','out','out','out'}'; % note happe_v3 can output seg or cont

Mod_Names=ModuleNames(:);
Module_On = true(length(ModuleNames),1); % flag all modules on as default
Module_Export_On=false(length(ModuleNames),1); % set export to false as default
Module_Dir = cell(length(ModuleNames),1);
Module_Dir(:) = {''};
Module_Xls_Out_On= false(length(ModuleNames),1);
grp_proc_info.beapp_toggle_mods=table(Mod_Names,Module_On,Module_Export_On,Module_Xls_Out_On,Module_Dir,Module_Input_Type,Module_Output_Type);
grp_proc_info.beapp_toggle_mods.Properties.RowNames=ModuleNames;
clear ModuleNames Module_On Module_Export_On Module_Dir
clear Module_Xls_Out_On Mod_Names Module_Input_Type Module_Output_Type

%% initialize module and export toggles that are different from standard module on, export off
grp_proc_info.beapp_toggle_mods{'ica','Module_Xls_Out_On'}=1; % flag that toggles segment xls report option on
grp_proc_info.beapp_toggle_mods{'segment','Module_Xls_Out_On'}=1; % flag that toggles segment xls report option on
grp_proc_info.beapp_toggle_mods{'psd','Module_Export_On'}=1; %flag that toggles the data export option for the psd code 
grp_proc_info.beapp_toggle_mods{'psd','Module_Xls_Out_On'}=1; % export psd to tables
grp_proc_info.beapp_toggle_mods{'itpc','Module_On'}=0; %turns ITPC analysis on, use with event data only
grp_proc_info.beapp_toggle_mods{'itpc','Module_Xls_Out_On'}=1; %flags the export data to xls option on
grp_proc_info.beapp_toggle_mods{'prepp','Module_Xls_Out_On'}=1; %flags the export data to xls option on

% coherence is not yet an option
%grp_proc_info.beapp_toggle_mods{'coh','Module_Xls_Out_On'}=0; %export coherence to tables
%grp_proc_info.beapp_toggle_mods{'coh',{'Module_On','Module_Export_On'}}=[0,0];% turns coherence off

%% paths for packages and tables
grp_proc_info.beapp_ft_pname={[grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,grp_proc_info.eeglab_ver{1},filesep,grp_proc_info.fieldtrip_ver{1}]}; 
grp_proc_info.beapp_format_mff_jar_lib = [grp_proc_info.beapp_root_dir{1} filesep 'reference_data' filesep 'MFF-1.2.jar']; %the java class file needed when reading mff source files
grp_proc_info.beapp_format_mff_matlab_package = [grp_proc_info.beapp_root_dir{1} filesep 'Packages' filesep 'MFFMatlabIO4.0'];
grp_proc_info.ref_net_library_dir=[grp_proc_info.beapp_root_dir{1},filesep,'reference_data',filesep,'net_library'];
grp_proc_info.ref_net_library_options = ([grp_proc_info.beapp_root_dir{1},filesep,'reference_data',filesep,'net_library_options.mat']);
grp_proc_info.ref_eeglab_loc_dir = [grp_proc_info.beapp_root_dir{1},filesep, 'Packages',filesep,grp_proc_info.eeglab_ver{1},filesep, 'sample_locs'];
grp_proc_info.ref_def_template_folder = [fileparts(mfilename('fullpath')) filesep, 'run_templates'];
grp_proc_info.ref_HAPPE_V2_3_loc_dir = [grp_proc_info.beapp_root_dir{1},filesep, 'Packages',filesep,grp_proc_info.HAPPE_ver_3{1}];
% initialize input tables: only necessary if inputs are .mats, non-uniform offset information is
% needed for mff files, or if you'd like to rerun a subselection of files
grp_proc_info.beapp_file_info_table =[grp_proc_info.beapp_root_dir{1} filesep 'user_inputs',filesep,'beapp_file_info_table.mat'];
grp_proc_info.rerun_file_info_table =[grp_proc_info.beapp_root_dir{1} filesep 'user_inputs',filesep,'rerun_fselect_table.mat'];
grp_proc_info.beapp_alt_beapp_file_info_table_location = {''};
grp_proc_info.beapp_alt_rerun_file_info_table_location = {''};
grp_proc_info.HAPPE_v3_parameters_file_location = {''};
%% general defaults
grp_proc_info.beapp_advinputs_on=0; %flag that toggles advanced user options, default is 0 (user did not set advanced user values)
grp_proc_info.hist_run_tag = datetime('now'); % run_tag records when beapp was started
grp_proc_info.beapp_dir_warn_off = 0;
grp_proc_info.beapp_curr_run_tag = ''; % if you would like to append a tag to folder names for this run. If not given on a rerun, a timestamp will be used
grp_proc_info.beapp_prev_run_tag = ''; % run tag for previous run that you would like to use as source data for rerun. can be timestamp, but must be exact.
grp_proc_info.beapp_use_rerun_table = 0; % use rerun table to select subset of files previously run 
grp_proc_info.seg_info_mff_src_dir = {''}; % for almost all users should be empty, functionality not supported
grp_proc_info.beapp_fname_all={''}; %list of beapp file names, set during get_beapp_srcflist
grp_proc_info.beapp_run_per_file = 0;
grp_proc_info.beapp_file_idx = 1;

%% general user setting defaults
grp_proc_info.beapp_rmv_bad_chan_on=0; %flag that removes channels that prepp/HAPPE identifies as bad, replace with NaNs

%% formatting/source file defaults
grp_proc_info.src_format_typ=1; %type of source file 1=.mat files, 2=mff, 3=PRE-PROCESSED + PRE-SEGMENTED MFF 
grp_proc_info.src_data_type = 1; % type of data being processed (for segmenting,see user guide): 1 = baseline, 2 = event related
grp_proc_info.epoch_inds_to_process = []; % def = []. ex [1], [3,4]Index of desired epochs to analyze (for ex. if resting is always in the first epoch, for baseline analysis = [1]);
grp_proc_info.src_unique_nets={''}; % unique net names in dataset 
grp_proc_info.src_fname_all={''}; %list of source file names, set during get_beapp_srcflist or as a user input
grp_proc_info.src_eeg_vname={'Category_1_Segment1','Category_1','EEG_Segment1','EEGSegment1'}; %variable name of the EEG data EEG_Segment1
grp_proc_info.src_format_typ=1; %type of source file 1=netstation, 2=mff, 3=mff in *.mat format, previously proc_info.beapp_format_typ
grp_proc_info.src_net_typ_all=[]; %list of net types from source files set in get_beapp_srcnettyp
grp_proc_info.src_srate_all=[]; %list of net types from source files set in get_beapp_srcsrate
grp_proc_info.src_linenoise=60; %line noise frequency in the source data, later replace with fft to test for 60 or 70
grp_proc_info.src_buff_start_nsec=2; %number of seconds buffer at the start of the EEG recording that can be excluded after filtering and artifact removal (buff1_nsec)- GROUP OR FILE?
grp_proc_info.src_buff_end_nsec=2; %number of seconds buffer at the end of the EEG recording that can be excluded after filtering and artifact removal (buff2_nsec) -GROUP OR FILE?
grp_proc_info.mff_seg_throw_out_bad_segments =1; % determines whether to throw out bad segments 
grp_proc_info.src_presentation_software =1; % presentation software used for paradigm (0 = none, 1 = EPrime, 2 = Presentation, 3 = EEGLAB formatted (see user guide).  def = 1)
grp_proc_info.beapp_indx_chans_to_exclude = {}; % index of channels to exclude in each net. def  = {};
grp_proc_info.src_eeglab_cond_info_field = 'condition'; % name of field with condition information (ex .cel_type or .condition)
grp_proc_info.src_eeglab_latency_units =1; % units on EEGLAB .set file latency field. def=1; 1 = samples, 2 = seconds, 3 = milliseconds, 4 = microseconds

%% event formatting defaults
grp_proc_info.beapp_event_code_onset_strs={''}; %the event codes assigned during data collection to signifiy the onset of the stimulus
grp_proc_info.beapp_event_code_offset_strs={''};  %Ex {'TRSP'} the event codes assigned during data collection to signifiy the offset of the stimulus (should match onset strs)
grp_proc_info.beapp_event_eprime_values.condition_names = {''};
grp_proc_info.beapp_event_eprime_values.event_codes = []; % 2d array -- groups x condition codes
grp_proc_info.event_tag_offsets = 0; % def = 0 OR 'input_table'. Event offset in ms. If offset is not uniform across dataset, set to input_table and input information as in evt_file_info_table example 
grp_proc_info.beapp_event_use_tags_only  = 0; % def =0 (use event codes/tags/strings and condition/cel information). 1 = use event codes/tags/strings only for segmenting

%% Formatting specifications: Behavioral Coding
grp_proc_info.behavioral_coding.events = {''}; % def = {''}. Ex {'TRSP'} Events containing behavioral coding information
grp_proc_info.behavioral_coding.keys = {''}; % def = {''} Keys in events containing behavioral coding information
grp_proc_info.behavioral_coding.bad_value = {''}; % def = {''}. Value that marks behavioral coding as bad. must be string - number values must be listed as string, ex '1'

%% defaults for BEAPP filtering 
Filt_Type = {'Lowpass','Highpass','Notch','Cleanline'}';
Filt_On = [1,1,1,0]';
Filt_Name = {'eegfilt','eegfilt','notch','cleanline'}';%equiripple FIR filter, eeglab filter, or notch filter
Filt_Attenpband = [1,nan,nan,nan]'; %attenuation in the passband in dB, not needed for EEGLab filter
Filt_Attensband = [60,nan,nan,nan]'; %attenuation in the stop band in dB, not needed for EEGLab filter
Filt_Cutoff_Freq =[100,1,nan,nan]'; % highest good frequency or lowest good frequency depending on highpass or lowpass
Filt_Lp_Filt=[nan,nan,nan,nan]';  %gets set inside batch_beapp_filt if lowpass is on

grp_proc_info.beapp_filters=table(Filt_On,Filt_Name,Filt_Cutoff_Freq,Filt_Lp_Filt);
grp_proc_info.beapp_filters.Properties.RowNames=Filt_Type;
clear Filt_Type Filt_On Filt_Name Filt_Attenpband Filt_Attensband Filt_Cutoff_Freq Filt_Lp_Filt Filt_Src_Linenoise

%% defaults for batch resampling 
grp_proc_info.beapp_rsamp_typ='interpolation'; % set default, 'interpolation' or 'downsampling'
grp_proc_info.beapp_rsamp_srate=250; %sampling rate that all resampled files should have (1000 for U19, switch later)
grp_proc_info.beapp_rsamp_nsamp=[]; %number of samples after resampling

%% ICA variables
grp_proc_info.name_10_20_elecs = {'FP1','FP2','F7','F3','F4','F8','C3','C4','T5','PZ','T6','O1','O2','T3','T4','P3','P4','Fz'}; % does not include CZ
grp_proc_info.beapp_ica_type  = 1; % 1 = ICA with MARA, 2 = HAPPE, 3 = only ICA 
grp_proc_info.beapp_ica_run_all_10_20 = 1;
grp_proc_info.beapp_ica_10_20_chans_lbls{1} = []; 
grp_proc_info.beapp_ica_additional_chans_lbls{1}= []; %additional channels to use in ICA module besides 10-20
grp_proc_info.happe_plotting_on = 0 ; % if 1, plot visualizations from MARA, require user input

%% rereference module defaults
grp_proc_info.reref_typ = 1; %average reference as default

% CSD laplacian defaults
grp_proc_info.beapp_csdlp_interp_flex=4; %m=2...10, 4 spline
grp_proc_info.beapp_csdlp_lambda=1e-5; %learning rate def = 1e-5;

% Rows in eeg corresponding to desired reference channel for each net (only used if reref_typ = 3)
% MUST match number of nets and order of nets in .src_unique nets exactly ex {[57,100],[51,26]};
grp_proc_info.beapp_reref_chan_inds = {[]}; % def = {[]}; 

%% defaults for detrending
grp_proc_info.dtrend_typ=1; %type of detrending method to use (0=no detrend, 1=mean, 2=linear, 3=Kalman)
grp_proc_info.kalman_b=0.9999; %used to determine smoothing in the Kalman filter, use 0.995 as alternative
grp_proc_info.kalman_q_init=1; %used to determine smoothing in Kalman filter 

%% segmentation defaults
grp_proc_info.beapp_reject_segs_by_amplitude= 0; % def = 1; flag that toggles amplitude-based rejection of segments after segment creation
grp_proc_info.art_thresh=150; %threshold in uV for artifact (scale will need to change if using CSDLP)
grp_proc_info.segment_linear_detrend = 0;  % apply linear detrend to segments in segmentation module 0 off, 1 = linear, 2 = mean detrend
grp_proc_info.beapp_happe_segment_rejection = 0; %def = 0; eeg_thresh and jointprob rejection after segmentation
grp_proc_info.beapp_happe_seg_rej_plotting_on = 0; % def = 0; visualizations during joint prob

%% defaults for baseline segmentation module
% flag that toggles the removal of high-amplitude artifact before segmentation (only used for baseline)
grp_proc_info.beapp_baseline_msk_artifact=1; % def = 1; 0= off, 1 = on, 2 = by percent

% percent (0-100) of channels being analyzed above threshold required to mask sample for pre-segmentation rejection
grp_proc_info.beapp_baseline_rej_perc_above_threshold = .01; % def = .01; (.01%, should reject if any channels bad assuming channel # <1000) 
grp_proc_info.win_size_in_secs=1; % length of windows for segmenting (baseline length of good data needed)
%% defaults for event segmentation module
grp_proc_info.beapp_erp_maf_on=0; %flags on the moving average filter when the ERP events are generated
grp_proc_info.beapp_erp_maf_order=30; %Order of the moving average filter

grp_proc_info.evt_seg_win_start = -0.100; % def = -0.100;  start time in seconds for segments, relative to the event marker of interest (ex -0.100, 0) 
grp_proc_info.evt_seg_win_end = 0.800;  % def = .800; end time in seconds for segments, relative to the event marker of interest (ex .800, 1) 
%Set which event data to analyze, relative to the event marker of interest (This can be the whole segment, or part of a segment) 
grp_proc_info.evt_analysis_win_start = -0.100; % def = -0.100;  start time in seconds for analysis segments, relative to the event marker of interest (ex -0.100, 0) 
grp_proc_info.evt_analysis_win_end = 0.800;  % def = .800; end time in seconds for analysis segments, relative to the event marker of interest (ex .800, 1) 
%Set which event data is baseline 
grp_proc_info.evt_trial_baseline_removal = 0; % def = 0; flag on use of pop_rmbaseline in segmentation module. 
grp_proc_info.evt_trial_baseline_win_start = -.100; % def = -0.100;  start time in seconds for baseline, relative to the event marker of interest (ex -0.100, 0). Must be within range you've segmented on. 
grp_proc_info.evt_trial_baseline_win_end = 0; % def = 0;  start time in seconds for baseline, relative to the event marker of interest (ex -0.100, 0) 
%Option to segment on nth trial
grp_proc_info.select_nth_trial = [];
grp_proc_info.segment_stim_relative_to = {''}; 
grp_proc_info.segment_nth_stim_str = {''};
grp_proc_info.beapp_event_group_stim=0;
%% defaults for HAPPE V3 additional inputs
%Format
grp_proc_info.chans_to_analyze = 'all';
grp_proc_info.typeFields = {'code'}; % Add any additional type fields besides "code", separating other entries with a comma ;        
grp_proc_info.happe_net_type = []; %NET Type %fprintf(['Acquisition layout type:\n  1 = EGI Geodesic Sensor ' ...% 'Net\n  2 = EGI HydroCel Geodesic Sensor Net\n  3 = Neuroscan Quik-Cap' ...%'\n  4 = Other'
grp_proc_info.happe_net_num_channels = []; %number of channels on net
grp_proc_info.happe_resamp_on = 0; %turn on or off happe resampling
grp_proc_info.lineNoise_harms_on = 0 ; %turning on line noise reduction at other frequencies (not always but often at harmonics of electric linenoise frequency) default 0, if you turn to 1 set next variable 
grp_proc_info.lineNoise_harms_freqs = []; %vector of other frequencies for linenoise reduction, default [];
grp_proc_info.badChans_rej= 0; %turn on bad channel rejection? defualt one
grp_proc_info.wavelet_softThresh = 0; %0 default set to hard to retain more data/assuming more artifact in data, could switch to soft if desired
grp_proc_info.reref_on = 0; %set to on but can turn off
grp_proc_info.reref_chan= []; %default [], if there is rereference channel in your data, list name here
grp_proc_info.art_thresh_min = -150;  % -200 to 200 for infant data, and -150 to 150 for child, adolescent, and adult data
grp_proc_info.art_thresh_max = 150;
grp_proc_info.segRej_ROI_on = 0; %default uses all channels (0) , 1 would use specific set of rois (regions of interest)
grp_proc_info.segRej_ROI_chans = {}; %default empty cell, otherwise enter channels to use for seg rejection with the format 'E[channelnum' ex 'E12' separated by commas
grp_proc_info.segment_interp = 0; %'Interpolate the specific channels data determined ' ...'to be artifact/bad within each segment? N=0, Y = 1
grp_proc_info.muscIL_on = 0;
grp_proc_info.happe_segment_on = 0;
grp_proc_info.ERPAnalysis = 0; 
grp_proc_info.reref_flat = 0;
%SAVE FORMAT
grp_proc_info.save_format = [1];  %'Format to save processed data:\n  1 = .txt file (electrodes as ' ...
  %  'columns, time as rows) - Choose this for ERP timeseries\n  2 = .mat' ...
  %  ' file (MATLAB format)\n  3 = .set file (EEGLAB format)\n']) ;  
%FILTER 
grp_proc_info.ERPfilter = []; %['Choose a filter:\n 0: fir = Hamming windowed sinc FIR filter (EEGLAB''s standard filter)\n  ' ...           %  or 1: 'butter = IIR butterworth filter (ERPLAB''s standard filter)\n']) ;%Visualizations            
grp_proc_info.vis_psd_min = []; % If visualizatio("Minimum value for power spectrum figure:\n> ") ;
grp_proc_info.vis_psd_max = [] ;%("Maximum value for power spectrum figure:\n> ") ;
grp_proc_info.vis_topoplot_freqs = []; %
grp_proc_info.vis_erp_min = []; % input('Start time, in MILLISECONDS, for the ERP timeseries figure:\n> ') ;
grp_proc_info.vis_erp_max = [] ; % input(['End time, in MILLISECONDS, for the ERP timeseries figure:\n' ...                   % '> ']) ;
%% variables for general output module processing 
%OUTPUT MEASURE SPECIFICATIONS
% trial selection specifications
% select n of usable segments PER CONDITION to use for output measure
% [] = use all possible segments, n = use specific number, discard file if file has
% fewer than n
grp_proc_info.win_select_n_trials = [];

% def = 0; select number of trials based on segments pre-rejection
% (automatically 0 for resting)
% 1 = select trials after segment rejection
grp_proc_info.win_select_trials_post_rej = 0; 

% select trials from trial range ex[25,50];. def = []; (select at random) 
% if .win_select_trials_post_rej = 1, trial ranges will apply to good
% trials after rejection
grp_proc_info.win_select_trials_in_range = []; 

%removed the option of reusing previously calculated frequency info
grp_proc_info.bw(1,1:2)=[2,4]; %bandwidth 1 start and end frequencies (the first band), can have as many or as few bandwidths as the user would like
grp_proc_info.bw_name(1)={'Delta'}; %name of bandwidth 1
grp_proc_info.bw_total_freqs = [1:100]; % frequencies to include in calculation of total power (for normalization). def = [1:100].
grp_proc_info.win_select_n_trials = []; % use all available trials
%% PSD default variables
grp_proc_info.psd_output_typ = 1; % psd = 1, power = 2, def = 1
grp_proc_info.psd_win_typ=1; %windowing type 0=rectangular window, 1=hanning window, 2=multitaper (recomended 2 seconds or longer)
grp_proc_info.psd_interp_typ=1; %type of interpolation of psd 1 none, 2 linear, 3 nearest neighbor, 4 piecewise cubic spline  
grp_proc_info.psd_interp_typ_name(1)={'None'}; %no interpolation
grp_proc_info.psd_interp_typ_name(2)={'linear'}; %linear interpolation, the default in current and previous versions of BEAPP
grp_proc_info.psd_interp_typ_name(3)={'nearest'}; %nearest neighbor
grp_proc_info.psd_interp_typ_name(4)={'spline'}; %piecewise cubic spline
grp_proc_info.psd_nfft=[]; %number of sample points used for the fft, wil be set in the batch_beapp_psd
grp_proc_info.psd_baseline_normalize = 0;
%variables needed for the PSD Multitaper option
grp_proc_info.psd_pmtm_l=3; %number of tapers to use in the multitaper, positive int 3 or greater
grp_proc_info.psd_pmtm_alpha=[]; %alpha used in multitaper, if alpha=2 and nsec=2 then L=3 tapers and spectral resolution is 2 
grp_proc_info.psd_pmtm_r=[]; %the spectral resolution of the power clculated from the PSD multitaper method 

%% variables for writing PSD data into xls sheets or csv
grp_proc_info.beapp_xlsout_ntab=1; %this is determined by the number of types of outputs to write into a single workbook, may remove this in the future
grp_proc_info.beapp_xlsout_hdr={'FileName','NetType','ArtifactThreshold','DetrendType','WindowSizeSeconds','WindowType','NumberOfObservations'};% header for values generated in reports
grp_proc_info.beapp_xlsout_av_on=1; %toggles on the mean power option
grp_proc_info.beapp_xlsout_sd_on=0; %toggles on the standard deviation option
grp_proc_info.beapp_xlsout_med_on=1; %toggles on the median option
grp_proc_info.beapp_xlsout_raw_on=1; %toggles on that the absolute power should be reported
grp_proc_info.beapp_xlsout_norm_on=1; %toggles on that the normalized power should be reported
grp_proc_info.beapp_xlsout_log_on=0; %toggles on that the natural log should be reported
grp_proc_info.beapp_xlsout_log10_on=1; %toggles on that the log10 should be reported
grp_proc_info.beapp_xlsout_elect_indx=1:129; %Channel numbers for the report. If the channel numbers are net dependent then report all possible net channel numbers for all nets, can't specify different channels for different nets
%% ITPC default variables
grp_proc_info.beapp_itpc_params.win_size=0.256;%64; %the win_size (in seconds) to calculate ERSP and ITPC from the ERPs of the composed dataset (e.g. should result in a number of samples an integer and divide trials equaly ex: 10)
grp_proc_info.beapp_itpc_xlsout_mx_on=1; % report max itpc
grp_proc_info.beapp_itpc_xlsout_av_on=1; % report mean itpc
grp_proc_info.beapp_itpc_params.baseline_norm=1;
grp_proc_info.beapp_itpc_params.use_common_baseline=0;
grp_proc_info.beapp_itpc_params.common_baseline_idx=1;
grp_proc_info.beapp_itpc_params.set_freq_range=0;
grp_proc_info.beapp_itpc_params.min_freq= 2;
grp_proc_info.beapp_itpc_params.max_freq=50;
grp_proc_info.beapp_itpc_params.min_cyc=1;
grp_proc_info.beapp_itpc_params.max_cyc=8;
%% FOOOF default variables 
grp_proc_info.fooof_min_freq = 1; %The frequency range of the psd fooof will run on
grp_proc_info.fooof_max_freq = 50;
grp_proc_info.fooof_peak_width_limits = [0,10]; %Set peak width limit to prevent overfitting. Needs to be > frequency resolution
grp_proc_info.fooof_max_n_peaks = 6; %Set a max number of peaks for fooof to find to prevent overfitting -- some maximum must be set
grp_proc_info.fooof_min_peak_amplitude = 0; %Set a min peal amplitude for fooof to find to prevent overfitting
grp_proc_info.fooof_min_peak_threshold = 0; %Set to a number > 0 to set a min peak threshold -- recommended to set if psd has no peaks. Otherwise keep 0
grp_proc_info.fooof_background_mode = 2; %1 = fixed, 2 = knee; If freq range is ~40Hz or below, recommended to use 'fixed'; otherwise, use 'knee'
grp_proc_info.fooof_save_all_reports = 1; %0 to not save reports; 1 if all reports should be saved
grp_proc_info.fooof_save_participants = {}; %Specify for which participants reports should be saved. Ex: {'baselineEEG01.mat'}
grp_proc_info.fooof_save_channels = []; %Specify to only save reports for some channel #'s. Ex: [1,2] save reports from channels 1 and 2; [] to not specify channels
grp_proc_info.fooof_save_groups = []; %Specify to only save reports for group #'s specified. Ex: [1,3]
grp_proc_info.fooof_xlsout_on = 0; %1 if excel reports should be saved, 0 if not
grp_proc_info.fooof_average_chans = 0; %1 if channels should be averaged; 0 if they should be run seperately
grp_proc_info.fooof_channel_groups = {}; %Ex: {[8,9,10],[15,16,17,18,19,20]}; if averaging is on, but channels should be averaged in seperate groups; leave as {} if channels should be averaged together
grp_proc_info.fooof_chans_to_analyze = []; %list channels to analyze if only some channels should be analyzed; else, leave as []
%% PAC default variables
grp_proc_info.pac_low_fq_min = 1; %Minimum frequency of the low frequency to calculate
grp_proc_info.pac_low_fq_max = 10; %Maximum frequency of the low frequency to calculate
grp_proc_info.pac_low_fq_res = 50; %The # of frequencies to calculate between the min and max;Ex: to calculate for frequencies 1-10, set min to 1, max to 10, and res to 10
grp_proc_info.pac_high_fq_min = 10; %Minimum frequency of the low frequency to calculate
grp_proc_info.pac_high_fq_max = 125; %Maximum frequency of the low frequency to calculate
grp_proc_info.pac_high_fq_res = 50; %The # of frequencies to calculate between the min and max;Ex: to calculate for frequencies 1-10, set min to 1, max to 10, and res to 10
grp_proc_info.pac_method = 'tort'; %Can be: 'ozkurt', 'canolty', 'tort', 'penny', 'vanwijk', 'duprelatour', 'colgin', 'sigl', 'bispectrum'
grp_proc_info.pac_low_fq_width = 2.0; %Bandwidth of the bandpass filter for the lower frequency
grp_proc_info.pac_high_fq_width = 20; %Bandwidth of the bandpass filter for the higher frequency
grp_proc_info.pac_save_all_reports = 1; 
grp_proc_info.pac_save_participants = {}; %Specify for which participants reports should be saved; {} to not specify participants. Ex: {'baselineEEG01.mat'}
grp_proc_info.pac_save_channels = []; %Specify to only save reports for some channel #'s. Ex: [1,2] save reports from channels 1 and 2; [] to not specify channels
grp_proc_info.pac_xlsout_on = 0; %1 if excel reports should be saved, 0 if not. 
grp_proc_info.pac_chans_to_analyze = []; %list channels to analyze if only some channels should be analyzed; else, leave as []
grp_proc_info.slid_win_sz = 1; 
grp_proc_info.slid_win_on = 0; %turn on to measure pac across time
grp_proc_info.pac_set_num_segs = 0; %choose whether a set the number of segments should be used for pac
grp_proc_info.pac_num_segs = 6; %if set_num_segs is on: set the number of segments to use for pac
grp_proc_info.pac_calc_zscores = 0;
grp_proc_info.pac_calc_btwn_chans = 0; %Compute PAC between 2 channels, instead of within each channel (BETA)
grp_proc_info.pac_variable_hf_filt = 0;
grp_proc_info.pac_save_amp_dist = 0; %save the binned high frequency amplitude distribution
%% Bycycle default methods 
grp_proc_info.bycyc_set_num_segs = 0;
grp_proc_info.bycyc_num_segs = 0;
grp_proc_info.bycycle_freq_bands = [12,14]; %Ex: 6,8;8,10. 
grp_proc_info.bycycle_gen_reports = true;
grp_proc_info.bycycle_save_reports = true;
grp_proc_info.bycycle_burstparams.amplitude_fraction_threshold = .3;
grp_proc_info.bycycle_burstparams.amplitude_consistency_threshold = .4;
grp_proc_info.bycycle_burstparams.period_consistency_threshold = .5;
grp_proc_info.bycycle_burstparams.monotonicity_threshold = .8;
grp_proc_info.bycycle_burstparams.N_cycles_min = 3;

end