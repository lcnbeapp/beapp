function [grp_proc_info] = beapp_translate_to_happe_inputs(grp_proc_info)
%Creates params struct based on beapp_user_inputs
params.lowDensity = 0 ; % currenlty not supported for .mff and .raw so toggled off for now choose2('N', 'Y') %low density is 1-32 channels - way to fig this out from net type?
params.paradigm = struct() ;
%% Task Onset Tags In progress
% if size(params.paradigm.onsetTags,2) > 1
% fprintf(['Do multiple onset tags belong to a single condition?' ...
%  ' [Y/N]\nExample: "happy_face" and "sad_face" belong to ' ...
% '"faces".\n']) ;
params.paradigm.conds.on = 0; %CHANGE LATER< FOR TESTING PURP NOW choose2('N', 'Y') ;
if params.paradigm.conds.on
    %                 params.paradigm.conds.groups = [] ;
    %                 fprintf(['Enter the conditions and included onset tags:\n' ...
    %                 'Enter each condition as a list, each element seperated by ' ...
    %                 'a blank space,\nwith the condition name as the first item ' ...
    %                 'in the list. Press enter/return between entries.\nWhen you ' ...
    %                 'have entered all conditions, input "done" (without quotations).\n' ...
    %                 'Example: faces happy_face sad_face angry_face\n']) ;
    %dealing w diff sizing, making one string matrix at end
    %             while true
    %                     temp = split(input('> ', 's'))' ;
    %                     if size(temp,2) == 1 && strcmpi(temp, 'done'); break ;
    %                     elseif size(temp,2) > 2
    %                         diff = size(temp,2) - size(params.paradigm.conds.groups,2) ;
    %                         if diff > 0 && size(params.paradigm.conds.groups, 2) ~= 0
    %                             params.paradigm.conds.groups = [params.paradigm.conds.groups ...
    %                                 strings(size(params.paradigm.conds.groups, ...
    %                                 1), diff)] ;
    %                         elseif diff < 0 && size(params.paradigm.conds.groups, 2) ~= 0
    %                             temp = [temp strings(1, abs(diff))] ;                %#ok<*AGROW>
    %                         end
    %                          params.paradigm.conds.groups = ...
    %                                 [params.paradigm.conds.groups; temp] ;
    %                     else
    %                         fprintf(['Invalid input: enter a condition name ' ...
    %                             'and at least two entries or "done" ' ...
    %                             '(without quotations).\n']) ;
    %                         continue ;
    %                     end
    %                 end
else; params.paradigm.conds.on = 0 ;
end
%% Data type: Resting-state/baseline or Task-related EEG
if grp_proc_info.src_data_type == 1 %baseline
    params.paradigm.task = 0; %0 maps to 'rest'
    params.paradigm.ERP.on = 0;
    params.paradigm.onsetTags = {};
else %condition baseline or event related
    params.paradigm.task =1; %1 maps to 'task';
    params.paradigm.ERP.on = grp_proc_info.ERPAnalysis;
    params.paradigm.onsetTags = grp_proc_info.beapp_event_code_onset_strs; % used to be this UI_cellArray(1,{}) ;
end
% Line below copied from setParams SET QC FREQS BASED ON THE PARADIGM: Use the paradigm to determine which set of frequencies to use in evaluating pipeline metrics.
if params.paradigm.ERP.on; params.QCfreqs = [.5, 1, 2, 5, 8, 12, ...
        20, 30, 45, 70] ;
else; params.QCfreqs = [2, 5, 8, 12, 20, 30, 45, 70] ;
end
%% ERP FILTER CUT-OFFS - SECTION MAPPED
params.paradigm.ERP.lowpass = grp_proc_info.beapp_filters{'Lowpass','Filt_Cutoff_Freq'} ; %Common low-pass filter is 30 - 45 Hz.
params.paradigm.ERP.highpass = grp_proc_info.beapp_filters{'Highpass','Filt_Cutoff_Freq'}; %Common high-pass filter is 0.1 - 0.3 Hz.
%% IMPORTING FILE INFORMATION 
params.loadInfo = struct() ;
params.loadInfo.chanlocs.inc = 1; %Copied from happe' loadingInfo code - Assume that the channel locations are included. Because this is true for most layouts/nets, it is easier to change in in the no-location layouts.
params.loadInfo.inputFormat = 1; %always 1 (.mat) bc went through format beforehand 
params.loadInfo.correctEGI = 0; %HARD CODING TO BE 0 bc will be corrected by beapp - check by file type
%% CHANNELS OF INTEREST SECTION MAPPED
if ~params.loadInfo.chanlocs.inc
    params.chans.IDs = {} ; params.chans.subset = 'all' ;
else
    params.chans.subset = grp_proc_info.chans_to_analyze;
    if ~isempty(grp_proc_info.beapp_ica_additional_chans_lbls{1,1})
    addit_chans = cell(1,length(grp_proc_info.beapp_ica_additional_chans_lbls{1,1}));
        for num_to_conv = 1:length(grp_proc_info.beapp_ica_additional_chans_lbls{1,1})
            addit_chans{num_to_conv} = char(grp_proc_info.beapp_ica_additional_chans_lbls{1,1}(num_to_conv)) ; %char(strcat('E',num2str(grp_proc_info.beapp_ica_additional_chans_lbls{1,1}(num_to_conv))));
        end
    else
        addit_chans = [];
    end
    if grp_proc_info.beapp_ica_run_all_10_20  
        % load net library options and find net 10-20 equivalents
        load(grp_proc_info.ref_net_library_options)

        uniq_net_ind = find(strcmp(grp_proc_info.src_unique_nets, net_library_options.Net_Full_Name));
        net_10_20_chan_equivalents = net_library_options.Net_10_20_Electrode_Equivalents{uniq_net_ind};
        net_10_20_eeglab_format = arrayfun(@(x) strcat('E',num2str(x)), net_10_20_chan_equivalents, 'UniformOutput', 0);
        %params.chans.IDs = unique([grp_proc_info.name_10_20_elecs, addit_chans]);
        params.chans.IDs = unique([net_10_20_eeglab_format,addit_chans]);
    else
    params.chans.IDs = unique(addit_chans);
    end
end
%% LINE NOISE FREQUENCY AND METHOD SECTIN MAPPED
params.lineNoise.freq = grp_proc_info.src_linenoise; % 'Frequency of electrical (line) noise in Hz: USA data probably = 60; Otherwise, probably =50 ;
params.lineNoise.neighbors = [params.lineNoise.freq-10, params.lineNoise.freq-5, ...
    params.lineNoise.freq-2, params.lineNoise.freq-1, params.lineNoise.freq, ...
    params.lineNoise.freq+1, params.lineNoise.freq+2, params.lineNoise.freq+5, ...
    params.lineNoise.freq+10] ;
params.lineNoise.harms.on = grp_proc_info.lineNoise_harms_on; 
if params.lineNoise.harms.on
    params.lineNoise.harms.freqs = unique(grp_proc_info.lineNoise_harms_freqs, 'stable'); %
    if isempty(params.lineNoise.harms.freqs)
        error('Line noise reduction: You have turned on option to reduce additional frequencies, but the additional frequency vector is empty, please check user inputs');
    end
else
    params.lineNoise.harms.freqs = [] ;
end
params.lineNoise.cl = 1; % hardcoded to cleanline for now , could add notch in future but not avail now
if params.lineNoise.cl
    params.lineNoise.legacy = 0; %maps to default linenoise reduction method ; choose2('default', 'legacy') ;
else; error('Notch filter not currently available') ;
end   
%% RESAMPLE SECTION MAPPED
if  grp_proc_info.happe_resamp_on %turn on or off happe resampling
    params.downsample = grp_proc_info.beapp_rsamp_srate;
    HAPPE_downsample_opt = [250 500 1000];
    if (params.downsample ~= 250) + (params.downsample ~= 500) + (params.downsample ~= 1000) == 3
        [~,index] = min(abs(params.downsample - HAPPE_downsample_opt));
        params.downsample = HAPPE_downsample_opt(index);
        sprintf('Your downsample choice %d was not on of the preset happe options so has been reset to the closest value %d',grp_proc_info.beapp_rsamp_srate,params.downsample)
    end
else
    params.downsample = 0;
end
%% FILTER SECTION MAPPED
if ~params.loadInfo.chanlocs.inc; params.filt.butter = 0;
elseif params.paradigm.ERP.on
    params.filt.butter = grp_proc_info.ERPfilter ; 
else; params.filt.butter = 0 ;
end
%% BAD CHANNEL DETECTION SECTION MAPPED
if ~params.loadInfo.chanlocs.inc; params.badChans.rej = 0;
else
    params.badChans.rej = grp_proc_info.badChans_rej; %choose whether to reject chans ('n','y') ;
    if params.badChans.rej && ~params.lowDensity
        params.badChans.legacy = 0; %making default bad chan detec method instead of legacy choose2('default', 'legacy') ;
    else; params.badChans.legacy = 0 ;
    end
end
%% WAVELET METHODOLOGY SECTION MAPPED
params.wavelet.legacy = 0 ; %making default and not legacy
if ~params.wavelet.legacy && params.paradigm.ERP.on
    params.wavelet.softThresh = grp_proc_info.wavelet_softThresh; 
end
%% MUSCIL SECTION MAPPED
if ~params.paradigm.ERP.on
    params.muscIL = grp_proc_info.muscIL_on ; 
else; params.muscIL = 0;
end
%% SEGMENTATION SECTION MAPPED
params.segment.on = grp_proc_info.happe_segment_on;  % on by default
params.baseCorr.on = 0;
if params.segment.on
if params.paradigm.task
    params.segment.start = grp_proc_info.evt_seg_win_start ;
    params.segment.end = grp_proc_info.evt_seg_win_end; 
    if params.paradigm.ERP.on
        params.segment.offset = NaN; % hardcoded because offset is dealt with already during formatting and don't want to double introduce offset
        params.baseCorr.on = grp_proc_info.evt_trial_baseline_removal; 
        if params.baseCorr.on
            params.baseCorr.start = grp_proc_info.evt_trial_baseline_win_start*1000 ; %  MILLISECONDS, where the baseline segment begins:\nExample: -100
            params.baseCorr.end = grp_proc_info.evt_trial_baseline_win_end*1000; %  MILLISECONDS, where the baseline segment ends
        end
    end
elseif ~params.paradigm.task; params.segment.length = grp_proc_info.win_size_in_secs ; %Segment length, in SECONDS
end
end
%% INTERPOLATION SECTION Interpolate the specific channels data determined 'to be artifact/bad within each segment? [Y/N]
if ~params.loadInfo.chanlocs.inc  % || ~params.badChans.rej
    params.segment.interp = 0 ;
else
    params.segment.interp =grp_proc_info.segment_interp ;
end
%% SEGMENT REJECTION SECTION MAPPED
if  params.segment.on && (grp_proc_info.beapp_reject_segs_by_amplitude || grp_proc_info.beapp_happe_segment_rejection)
    params.segRej.on = 1;
else
    params.segRej.on = 0;
end
%  method of segment rejection: Amplitude criteria only, similarity only, Both amplitude criteria and segment similarity
if  grp_proc_info.beapp_reject_segs_by_amplitude &&grp_proc_info.beapp_happe_segment_rejection
    params.segRej.method = 'both';
elseif grp_proc_info.beapp_happe_segment_rejection
    params.segRej.method = 'similarity';
else
    params.segRej.method = 'amplitude';
end
if strcmpi(params.segRej.method, 'amplitude') || ...
        strcmpi(params.segRej.method, 'both')
    params.segRej.minAmp = grp_proc_info.art_thresh_min ;%Minimum signal amplitude to use as the artifact threshold
    params.segRej.maxAmp = grp_proc_info.art_thresh; %Maximum signal amplitude to use as the artifact threshold
end
params.segRej.ROI.on = grp_proc_info.segRej_ROI_on ; 
if params.segRej.ROI.on
    params.segRej.ROI.chans = unique(grp_proc_info.segRej_ROI_chans); %Use all channels or a region of interest for segment rejection? 
end
if params.paradigm.task && params.loadInfo.inputFormat == 1
    % fprintf(['Use pre-selected "usable" trials to restrict analysis? [Y/N]\n']) ;
    params.segRej.selTrials = 0 ; %guide says this currenlty doesn't function, so setting to 0 choose2('n', 'y') ;
end
%% RE-REFERENCING SECTION MAPPED FOR NOW (no rest)
if ~params.loadInfo.chanlocs.inc; params.reref.on = 0;
else
    params.reref.on = grp_proc_info.reref_on; 
    if params.reref.on
        params.reref.flat = grp_proc_info.reref_flat; 
        if params.reref.flat
        params.reref.chan = grp_proc_info.reref_chan; 
        end
    end  
    reref_map = {1,'average';2,'NaN';3,'subset';4,'rest'};     %type of reference method to use (1= average, 2= CSD Laplacian, 3 = specific electrodes, 4 = REST)
    params.reref.method = reref_map{grp_proc_info.reref_typ,2};
    if strcmpi(params.reref.method, 'subset')
        params.reref.subset = grp_proc_info.beapp_reref_chan_inds{1,1}; 
    elseif strcmpi(params.reref.method, 'rest')
        fprintf(['REST from beapp to happe not currently supported']) ; %TO DO
    end
end
%% SAVE FORMAT SECTION MAPPED
params.outputFormat = grp_proc_info.save_format;
%% VISUALIZATIONS SECTION MAPPED
params.vis.enabled = grp_proc_info.happe_plotting_on; 
if params.vis.enabled
    % POWER SPECTRUM: Min and Max
    params.vis.min = grp_proc_info.vis_psd_min ; %Minimum value for power spectrum figure
    params.vis.max =grp_proc_info.vis_psd_max; % Maximum value for power spectrum figure
    params.vis.toPlot = unique(grp_proc_info.vis_topoplot_freqs,'stable'); % Frequencies for spatial topoplots
    if params.paradigm.ERP.on
        params.vis.min = grp_proc_info.vis_erp_min; % Start time, in MILLISECONDS, for the ERP timeseries figure
        params.vis.max =grp_proc_info.vis_erp_max; % End time, in MILLISECONDS, for the ERP timeseries figure
    end
end
%%  SAVE INPUT PARAMETERS
% CREATE "input_parameters" FOLDER AND ADD IT TO PATH, unless it already exists.
if ~isfolder([grp_proc_info.src_dir{1,1} filesep 'input_parameters'])
    mkdir([grp_proc_info.src_dir{1,1} filesep 'input_parameters']) ;
end
addpath([grp_proc_info.src_dir{1,1}, filesep, 'input_parameters']) ;
cd ([grp_proc_info.src_dir{1,1}, filesep, 'input_parameters']) ;
paramFile = [datestr(now, 'dd-mm-yyyy') '_', grp_proc_info.beapp_curr_run_tag, '.mat'];
grp_proc_info.HAPPE_v3_parameters_file_location = {[grp_proc_info.src_dir{1,1} filesep, 'input_parameters', filesep, paramFile]};
% SAVE PARAMETERS: Save the params variable to a .mat file using the name created above.
params.HAPPEver = '2_3_0' ;
fprintf('Saving parameters...') ;
save(paramFile, 'params') ;
fprintf('Parameters saved.') ;
end
