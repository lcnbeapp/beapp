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
% Levin AR, Méndez Leal AS, Gabard-Durnam LJ and O’Leary HM (2018) 
% BEAPP: The Batch Electroencephalography Automated Processing Platform.
%  Front. Neurosci. 12:513. doi: 10.3389/fnins.2018.00513
%
% Additional Credits:
% BEAPP utilizes functionality from the software listed below. Users who choose to run any of this
% software through BEAPP should cite the appropriate papers in any publications. 
% 
% EEGLAB Version 14.1.2b:
% Delorme A & Makeig S (2004) EEGLAB: an open source toolbox for analysis 
% of single-trial EEG dynamics. Journal of Neuroscience Methods 134:9-21
% 
% PREP pipeline Version 0.52: 
% Bigdely-Shamlo N, Mullen T, Kothe C, Su K-M and Robbins KA (2015) 
% The PREP pipeline: standardized preprocessing for large-scale EEG analysis
% Front. Neuroinform. 9:16. doi: 10.3389/fninf.2015.00016
% 
% CSD Toolbox: 
% Kayser, J., Tenke, C.E. (2006). Principal components analysis of 
% Laplacian waveforms as a generic method for identifying ERP generator 
% patterns: I. Evaluation with auditory oddball tasks. Clinical Neurophysiology, 
% 117(2), 348-368
% 
% Users using low-resolution (less than 64 channel) montages with the 
% CSD toolbox should also cite: Kayser, J., Tenke, C.E. (2006). Principal 
% components analysis of Laplacian waveforms as a generic method for identifying
% ERP generator patterns: II. Adequacy of low-density estimates. 
% Clinical Neurophysiology, 117(2), 369-380
% 
% HAPPE:
% Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., & Levin, A. R. 
% (2018). The Harvard Automated Processing Pipeline for Electroencephalography 
% (HAPPE): standardized processing software for developmental and high-artifact data.
% Frontiers in Neuroscience (2018).
% 
% The REST Toolbox:
% Li Dong*, Fali Li, Qiang Liu, Xin Wen, Yongxiu Lai, Peng Xu and Dezhong Yao*.
% MATLAB Toolboxes for Reference Electrode Standardization Technique (REST) 
% of Scalp EEG. Frontiers in Neuroscience, 2017:11(601).
% 
% MARA:
% Winkler et al., Automatic Classification of Artifactual ICA-Components
% for Artifact Removal in EEG Signals. Behavioral and Brain Functions 7:30 (2011).
% 
% CleanLine:
% Mullen, T. (2012). NITRC: CleanLine: Tool/Resource Info.
%
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C)  2015, 2016, 2017, 2018
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% GENERAL USER INPUTS for BEAPP: Set these for any data runs
grp_proc_info.src_dir={'C:\Sample_directory'}; %the directory containing your source filesopen 
grp_proc_info.beapp_curr_run_tag = 'NONE'; % The tag you would like to append to folder names for this run. def = '' or 'NONE'. 'NONE' mutes timestamping. If not given on a rerun, a timestamp will be used. 
grp_proc_info.beapp_prev_run_tag = ''; % def = ''.  run tag for previous run that you would like to use as source data for rerun. can be timestamp, but must be exact.
grp_proc_info.beapp_advinputs_on= 0; %flag that toggles advanced user options, default is 0 (user did not set advanced user values)

% MODULE SELECTION
% pipeline flags:0=off, 1=on
grp_proc_info.beapp_toggle_mods{'format',{'Module_On','Module_Export_On'}}=[1,1]; % Convert source files to BEAPP format
grp_proc_info.beapp_toggle_mods{'prepp',{'Module_On','Module_Export_On'}}=[0,0]; %Turn on PREP Pipeline
grp_proc_info.beapp_toggle_mods{'filt',{'Module_On','Module_Export_On'}}=[0,0]; %Turn on filtering
grp_proc_info.beapp_toggle_mods{'rsamp',{'Module_On','Module_Export_On'}}=[1,1]; %Turn on resampling
grp_proc_info.beapp_toggle_mods{'ica',{'Module_On','Module_Export_On'}}=[1,1]; %Turn on ICA module (ICA, ICA+MARA, HAPPE)
grp_proc_info.beapp_toggle_mods{'rereference',{'Module_On','Module_Export_On'}}=[0,0]; %Turn on rereferencing
grp_proc_info.beapp_toggle_mods{'detrend',{'Module_On','Module_Export_On'}}=[0,0]; % Turn on detrending 
grp_proc_info.beapp_toggle_mods{'segment',{'Module_On','Module_Export_On'}}=[1,1]; % Turn on segmentation
grp_proc_info.beapp_toggle_mods{'HAPPE_V3',{'Module_On','Module_Export_On'}}=[1,1]; %Turn on HAPPE+ER Pre-processing pipeline - will automatically not run any other preprocessing pipeline
grp_proc_info.beapp_toggle_mods{'psd',{'Module_On','Module_Export_On'}}=[0,0]; %flag that toggles the PSD calculations
grp_proc_info.beapp_toggle_mods{'itpc',{'Module_On','Module_Export_On'}}=[0,0]; %turns ITPC analysis on, use with event data only
grp_proc_info.beapp_toggle_mods{'topoplot',{'Module_On','Module_Export_On'}}=[0,0]; % Turn on topoplots
grp_proc_info.beapp_toggle_mods{'fooof',{'Module_On','Module_Export_On'}}=[0,0]; %On a power spectrum, fits oscillations and 1/f (Voytek lab)
grp_proc_info.beapp_toggle_mods{'pac',{'Module_On','Module_Export_On'}}=[0,0]; %IN DEVELOPMENT. Phase amplitude coupling using pactools 
grp_proc_info.beapp_toggle_mods{'bycycle',{'Module_On','Module_Export_On'}}=[0,0]; %IN DEVELOPMENT. Characterizing waveform shape using bycycle (Voytek lab)

% FORMATTING SPECIFICATIONS
%Formatting specifications: Required
grp_proc_info.src_format_typ = 1; %type of source file 1=.mat files, 2=mff, 3=PRE-PROCESSED + PRE-SEGMENTED MFF  4 = .set (EEGLAB) files
grp_proc_info.src_data_type = 1; % type of data being processed (for segmenting,see user guide): 1 = baseline, 2 = event related 3= conditioned baseline
grp_proc_info.src_presentation_software = 1; % presentation software used for paradigm (1 = EPrime, 2 = Presentation. def = 1)

%Formatting specifications: Optional
grp_proc_info.src_linenoise= 60; % def = 60. for the notch filter, HAPPE,cleanline and PREP. If linenoise is different across files, set to = 'input_table' and put information in appropriate input table
grp_proc_info.src_unique_nets= {''}; % def ={''} If not running HAPP-E with multiple nets, optional for speed. Required for more than one net if running HAPP-E
grp_proc_info.epoch_inds_to_process = []; % def = []. ex [1], [3,4]Index of desired epochs to analyze (for ex. if resting is always in the first epoch, for baseline analysis = [1]);
grp_proc_info.src_eeg_vname={'EEG_Segment1','Category_1_Segment1','Category_1','EEGSegment1','CA61_011419_L0A'}; %possible variable name of the EEG data EEG_Segment1

%Formatting specifications: Events
%Formatting specifications: Event Offsets
grp_proc_info.event_tag_offsets = 0; % def = 0 OR 'input_table'. Event offset in ms. If input is not uniform across dataset, set to input_table and input information as in beapp_file_info_table in user inputs 

% Formatting specifications: Behavioral Coding
grp_proc_info.behavioral_coding.events = {''}; % def = {''}. Ex {'TRSP'} Events containing behavioral coding information
grp_proc_info.behavioral_coding.keys = {''}; % def = {''} Keys in events containing behavioral coding information
grp_proc_info.behavioral_coding.bad_value = {''}; % def = {''}. Value that marks behavioral coding as bad. must be string - number values must be listed as string, ex '1'

%PREP SPECIFICATIONS
%Note that PREP removes line noise; be sure to set line noise correctly in formatting specifications
grp_proc_info.beapp_toggle_mods{'prepp','Module_Xls_Out_On'} = 1; % flag that toggles prepp xls report option on

% FILTER SPECIFICATIONS
grp_proc_info.beapp_filters{'Notch','Filt_On'} = 0; % Notch filter at line noise frequency specified above
grp_proc_info.beapp_filters{'Lowpass','Filt_On'} = 1;
grp_proc_info.beapp_filters{'Lowpass','Filt_Cutoff_Freq'} = 100; 
grp_proc_info.beapp_filters{'Highpass','Filt_On'} = 1; 
grp_proc_info.beapp_filters{'Highpass','Filt_Cutoff_Freq'} = 1; % def = 1
grp_proc_info.beapp_filters{'Cleanline','Filt_On'} = 0; % def = 0; 1 turns on cleanline for line noise frequency

%RESAMPLING SPECIFICATIONS
grp_proc_info.beapp_rsamp_srate = 250; %target sampling rate for resampling, if desired

% ICA SPECIFICATIONS
grp_proc_info.beapp_ica_type  = 2; % 1 = ICA with MARA, 2 = HAPPE, 3 = only ICA 
grp_proc_info.beapp_toggle_mods{'ica','Module_Xls_Out_On'} = 1; % flag that toggles ICA xls report option on

%choose whether to run all 10_20 electrodes (if running HAPPE or MARA,
%recommended to use all
%(HAPPE and ICA with MARA require all 10-20 electrodes)
grp_proc_info.beapp_ica_run_all_10_20 = 1;

%If not running all 10_20 electrodes, choose which 10-20 electrodes to run
grp_proc_info.beapp_ica_10_20_chans_lbls{1} = []; 
%grp_proc_info.beapp_ica_10_20_chans_lbls{2} = []; 

% additional channels labels being analyzed beyond 10-20 channels in ICA module
% MUST match number of nets and order of nets in .src_unique nets exactly
grp_proc_info.beapp_ica_additional_chans_lbls{1} = []; % def = []. ex. [4,8,19,20]
grp_proc_info.beapp_ica_additional_chans_lbls{2} = [];

% REREFENCING SPECIFICATIONS
 %type of reference method to use (1= average, 2= CSD Laplacian, 3 = specific electrodes, 4 = REST)
grp_proc_info.reref_typ = 1;

% Rows in eeg corresponding to desired reference channel for each net (only used if reref_typ = 3)
% MUST match number of nets and order of nets in .src_unique nets exactly ex {[57,100],[51,26]};
grp_proc_info.beapp_reref_chan_inds = {[]}; % def = {[]}; 

% DETRENDING SPECIFICATIONS
grp_proc_info.dtrend_typ=1; %type of detrending method to use (1=mean, 2=linear, 3=Kalman)

%SEGMENTING SPECIFICATIONS -- General (applies to baseline, conditioned
%baseline, and event related)
grp_proc_info.segment_linear_detrend = 0; %def = 0; detrend segments. 0 off, 1 = linear, 2 = mean detrend
grp_proc_info.art_thresh = 40; %def = 180. threshold in uV for artifact removal -- will need to be adjusted for scale if HAPPE or CSDLP is run beforehand
grp_proc_info.beapp_reject_segs_by_amplitude= 0; % def = 1; flag that toggles amplitude-based rejection of segments after segment creation
grp_proc_info.beapp_happe_segment_rejection = 0; % def = 0; joint probability and post-segmentation amplitude based rejection of segments

% SEGMENTING SPECIFICATIONS -- BASELINE/CONDITIONED BASELINE ONLY
%Set segment size (number of seconds for each window for segmentation and calculations (for continuous data; for event data, see below)
grp_proc_info.win_size_in_secs = 2; % def = 1; (second)

% def = 1; flag that toggles the removal of high-amplitude artifact before segmentation (only used for baseline)
% 0 = off; 1 = mark samples with any channels above threshold bad; 2 = mark
% samples with percentage channels above threshold bad
grp_proc_info.beapp_baseline_msk_artifact=0; 

% percent (0-100) of channels being analyzed above threshold required to mask sample for pre-segmentation rejection
% only used if grp_proc_info.beapp_baseline_msk_artifact=2 
grp_proc_info.beapp_baseline_rej_perc_above_threshold = .01; % def = .01; (.01%, should reject if any channels bad assuming channel # <1000)  

% SEGMENTING SPECIFICATIONS -- EVENT-RELATED/ CONDITIONED BASELINE ONLY
grp_proc_info.beapp_event_use_tags_only = 1; % def =0 (use event codes/tags/strings and condition/cel information). 1 = use event codes/tags/strings only for segmenting (usually for .set source files)
grp_proc_info.beapp_event_code_onset_strs={'Segment'}; %Ex {'stm+'} the event codes assigned during data collection to signifiy the onset of the stimulus. 

% Desired condition names: Order must match cell numbers if cell sets are being used, or event tags if only event tags are being used
grp_proc_info.beapp_event_eprime_values.condition_names = {'Segment'};
grp_proc_info.beapp_event_eprime_values.event_codes(:,1) = [1]; % these MUST line up across all possible cell sets
grp_proc_info.beapp_event_eprime_values.event_codes(:,2) = [2];
grp_proc_info.beapp_event_eprime_values.event_codes(:,3) = [3];

% only used for conditioned baseline, otherwise optional: 
grp_proc_info.beapp_event_code_offset_strs={''}; %def = {''} Ex {'TRSP'} the event codes assigned during data collection to signifiy the offset of the stimulus (should match onset strs)

%For event-related data only: Set where to create segments, relative to the event marker of interest
grp_proc_info.evt_seg_win_start = 0; % def = -0.100;  start time in seconds for segments, relative to the event marker of interest (ex -0.100, 0) 
grp_proc_info.evt_seg_win_end = 2;  % def = .800; end time in seconds for segments, relative to the event marker of interest (ex .800, 1) 

%Set which event data to analyze, relative to the event marker of interest (This can be the whole segment, or part of a segment) 
grp_proc_info.evt_analysis_win_start = -.100; % def = -0.100;  start time in seconds for analysis segments, relative to the event marker of interest (ex -0.100, 0) 
grp_proc_info.evt_analysis_win_end = .800;  % def = .800; end time in seconds for analysis segments, relative to the event marker of interest (ex .800, 1) 

%Set which event data is baseline 
grp_proc_info.evt_trial_baseline_removal = 0; % def = 0; flag on use of pop_rmbaseline in segmentation module. 
grp_proc_info.evt_trial_baseline_win_start = -.100; % def = -0.100;  start time in seconds for baseline, relative to the event marker of interest (ex -0.100, 0). Must be within range you've segmented on. 
grp_proc_info.evt_trial_baseline_win_end = -.100; % def = -0.100;  start time in seconds for baseline, relative to the event marker of interest (ex -0.100, 0) 
%__________________________________________________________________________
%__________________________________________________________________________
%                           HAPPE-V3 SPECIFICATIONS
grp_proc_info.HAPPE_v3_reprocessing = 0; %choose2('raw', 'reprocess') ;
% Channels to analyze
grp_proc_info.chans_to_analyze = 'all' ; %can be 'all','coi_include','coi_exclude' if 'coi_include or coi_exclude', it will analyze or exclude from analysis 10-20 (if turned on) and additional channels (from additional_channels_ica)
% Resampling - Resampling value set in resampling specifications above
grp_proc_info.happe_resamp_on = 0; %Toggle on/off happe resampling, if on, will resample to grp_proc_info.beapp_rsamp_srate in RESAMPLING specifications
% Linenoise - Linenoise reduction will occur at frequency set above in LINENOISE section
grp_proc_info.lineNoise_harms_on = 0 ; %turning on line noise reduction at other frequencies (not always but often at harmonics of electric linenoise frequency) default 0, if you turn to 1 set next variable 
grp_proc_info.lineNoise_harms_freqs = []; %vector of other frequencies for linenoise reduction, default [];
% Artifact Detection
grp_proc_info.badChans_rej=1; %turn on bad channel rejection? default one 
% Rereferencing - Rereferencing method set in REREFERENCING specifications 
grp_proc_info.reref_on = 1; %[0 off, 1 on] if on, will use rereferencing method set in reref specifications (NOTE: happe v3 only supports average, subset, and rest)
grp_proc_info.reref_flat = 0; %0: No rereference channel to include 1: Include rereference/flat channel  NOTE: If you want to exclude ref from processing, choose 'coi_exclude' above and include ref in your additional channels 
grp_proc_info.reref_chan= []; %default [], if there is rereference channel in your data, list name here, will only be used of reref_flat is turned on
% Segmentation - Segmentation boundaries, rejection method, and max threshold set in segmentation specifications above
grp_proc_info.happe_segment_on = 1; %toggle on/off happe segmentation
grp_proc_info.art_thresh_min = -150;  %Min amplitude for artifact rejection -200 for infant data, and -150 for child, adolescent, and adult data
grp_proc_info.art_thresh_max = 150; %Max amplitude for artifact rejection 200 for infant data, and 150 for child, adolescent, and adult data
grp_proc_info.segRej_ROI_on = 0; %default uses all channels (0) , 1 would use specific set of rois (regions of interest)
grp_proc_info.segRej_ROI_chans = {}; %default empty cell, otherwise enter channels to use for seg rejection with the format 'E[channelnum' ex 'E12' separated by commas
grp_proc_info.segment_interp = 0; %'Interpolate the specific channels data determined ' ...'to be artifact/bad within each segment? N=0, Y = 1
%Save format
grp_proc_info.save_format = [1];  %'Format to save processed data:\n  1 = .txt file (electrodes as columns, time as rows) - Choose this for ERP timeseries\n  2 = .mat file (MATLAB format)\n  3 = .set file (EEGLAB format)\n']) ;  
%__________________________________________________________________________
%               HAPPE-V3 Inputs for Non-ERP Analyses Only
% Artifact Detection
grp_proc_info.muscIL_on = 0; % 0 or 1, default off: On will use ICLabel to reduce remaining muscle artifact, NOTE: This will drastically increase processing time. Recommended for files with significant muscle artifact.
% Visualization
grp_proc_info.vis_psd_min = []; % If visualizatio("Minimum value for power spectrum figure:\n> ") ;
grp_proc_info.vis_psd_max = [] ;%("Maximum value for power spectrum figure:\n> ") ;
grp_proc_info.vis_topoplot_freqs = []; %
%__________________________________________________________________________
%       HAPPE-V3 Inputs for ERP (Event Related data + ERP analyses) Only
% Toggle on ERP Analysis
grp_proc_info.ERPAnalysis = 0; %0 off 1 on
% Filtering - High and low pass values set in filtering specifications above 
grp_proc_info.ERPfilter = []; % Type of filter which will apply bandpass filter at values set in filtering section 0: fir = Hamming windowed sinc FIR filter (EEGLAB''s standard filter) 1: 'butter = IIR butterworth filter (ERPLAB''s standard filter)\n']) ;
% Artifact Detection
grp_proc_info.wavelet_softThresh = 0; % Default 0 (hard threshold), 1  = soft threshold, Using a soft threshold slightly preserves ERP amplitude but may keep slightly more artifact in the data. Using a hard threshold removes more artifact but at the slight cost of ERP amplitude.
% Visualization
grp_proc_info.vis_erp_min = [] ; %  Start time, in MILLISECONDS, for the ERP timeseries figure
grp_proc_info.vis_erp_max = [] ; % End time, in MILLISECONDS, for the ERP timeseries figure
%__________________________________________________________________________
%OUTPUT MEASURE SPECIFICATIONS
% trial selection specifications
% select n of usable segments PER CONDITION to use for output measure
% [] = use all possible segments, n = use specific number, discard file if file has
% fewer than n
grp_proc_info.win_select_n_trials = [];

%OUTPUT MEASURE SPECIFICATIONS
% Bandwith information. Total includes in all output bands by default
%THESE ARE ABC FREQUENCIES;
grp_proc_info.bw(1,1:2)=[0.4,4]; %bandwidth 1 start and end frequencies (the first band), can have as many or as few bandwidths as the user would like
grp_proc_info.bw_name(1)={'Delta'}; %name of bandwidth 1
grp_proc_info.bw(2,1:2)=[4,8]; %bandwidth 2
grp_proc_info.bw_name(2)={'Theta'}; %name of bandwidth 2
grp_proc_info.bw(3,1:2)=[8,12]; %bandwidth 5
grp_proc_info.bw_name(3)={'Alpha'}; %name of bandwidth 3
grp_proc_info.bw(4,1:2)=[13,30]; %bandwidth 8
grp_proc_info.bw_name(4)={'Beta'}; %name of bandwidth 4
grp_proc_info.bw(5,1:2)=[30,55]; %bandwidth 8
grp_proc_info.bw_name(5)={'Gamma'}; %name of bandwidth 5

% frequencies to include in calculation of total power (for normalization). def = [1:100]. Separate ranges with commas. Ex: [2:58.3, 62.1:110];
% gaps between frequencies of less than 1 Hz will be ignored
grp_proc_info.bw_total_freqs = [1:55,65:100];

% PSD SPECIFICATIONS
grp_proc_info.psd_win_typ=2; %power spectra windowing type 0=rectangular window, 1=hanning window, 2=multitaper (recomended 2 seconds or longer)
grp_proc_info.psd_interp_typ=1; %type of interpolation of psd 1 none, 2 linear, 3 nearest neighbor, 4 piecewise cubic spline  
grp_proc_info.beapp_toggle_mods{'psd','Module_Xls_Out_On'}=0; %flags the export data to xls report option on

%for event-related data only
grp_proc_info.psd_baseline_normalize = 0; %0 to not normalize, 1 to normalize using decibel conversion; 2 to normalize with percent change 

% ITPC SPECIFICATIONS
% see newtimef in EEGLAB for more details on these inputs
grp_proc_info.beapp_itpc_params.win_size= 0.128; %CURRENTLY NOT USED; the win_size (in seconds) to calculate ERSP and ITPC from the ERPs of the composed dataset (e.g. should result in a number of samples an integer and divide trials equaly ex: 10)
grp_proc_info.beapp_itpc_params.baseline_norm = 1;
grp_proc_info.beapp_itpc_params.use_common_baseline = 1;
grp_proc_info.beapp_itpc_params.common_baseline_idx = 1;
grp_proc_info.beapp_itpc_params.min_freq = 2;  % def = 2; frequency limits
grp_proc_info.beapp_itpc_params.max_freq = 80;  % def = 80
grp_proc_info.beapp_itpc_params.min_cyc = 2; % def = 2; number of cycles in each Morlet wavelet
grp_proc_info.beapp_itpc_params.max_cyc = 2; % def = 0; 0 = use same window size across freqs, 1 = use same number of cycles, 0<max_cyc<1 = increase cycles  linearly, max_cyc>1 = incr cycles from min_cyc up to max cyc
grp_proc_info.beapp_toggle_mods{'itpc','Module_Xls_Out_On'}=0;%flags the export data to xls report option on

% FOOOF SPECIFICATIONS 
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

%PAC SPECIFICATIONS
grp_proc_info.pac_low_fq_min = 12; %Minimum frequency of the low frequency to calculate
grp_proc_info.pac_low_fq_max = 12; %Maximum frequency of the low frequency to calculate
grp_proc_info.pac_low_fq_res = 1; %The # of frequencies to calculate between the min and max;Ex: to calculate for frequencies 1-10, set min to 1, max to 10, and res to 10
grp_proc_info.pac_low_fq_width = 8; %Bandwidth of the bandpass filter for the lower frequency
grp_proc_info.pac_high_fq_min = 45; %Minimum frequency of the low frequency to calculate
grp_proc_info.pac_high_fq_max = 45; %Maximum frequency of the low frequency to calculate
grp_proc_info.pac_high_fq_res = 1; %The # of frequencies to calculate between the min and max;Ex: to calculate for frequencies 1-10, set min to 1, max to 10, and res to 10
grp_proc_info.pac_high_fq_width = 20; %Bandwidth of the bandpass filter for the higher frequency
grp_proc_info.pac_method = 'tort'; %Can be: 'ozkurt', 'canolty', 'tort', 'penny', 'vanwijk', 'duprelatour', 'colgin', 'sigl', 'bispectrum'
grp_proc_info.pac_save_all_reports = 0; %1 if all reports should be saved; 0 if not
grp_proc_info.pac_save_participants = {}; %Specify for which participants reports should be saved; {} to not specify participants. Ex: {'baselineEEG01.mat'}
grp_proc_info.pac_save_channels = []; %Specify to only save reports for some channel #'s. Ex: [1,2] save reports from channels 1 and 2; [] to not specify channels
grp_proc_info.pac_xlsout_on = 0; %1 if excel reports should be saved, 0 if not. 
grp_proc_info.pac_chans_to_analyze = []; %list channels to analyze if only some channels should be analyzed; else, leave as []

%BYCYCLE SPECIFICATIONS
grp_proc_info.bycycle_freq_bands = [6,8;8,10;12,14]; %Ex: 6,8;8,10. Enter minimum, maximum frequency for each range, and separate ranges using a semicolon.
grp_proc_info.bycycle_gen_reports = true;
grp_proc_info.bycycle_save_reports = true;
