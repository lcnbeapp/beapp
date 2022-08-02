function [grp_proc_info] = beapp_create_happe_params(grp_proc_info)

%% setting up parameters SECTIN MAPPED

params.lowDensity = 0 ; % currenlty not supported for .mff and .raw so toggled off for now choose2('N', 'Y') %low density is 1-32 channels - way to fig this out from net type?
params.paradigm = struct() ;

%% fprintf(['Data type:\n  rest = Resting-state/baseline EEG\n  task = ' ...'Task-related EEG\n']) ;
if grp_proc_info.src_data_type == 1 %baseline
    params.paradigm.task = 0; %0 maps to 'rest'
    params.paradigm.ERP.on = 0;
else %condition baseline or event related
    params.paradigm.task =1; %1 maps to 'task';
    params.paradigm.ERP.on = 1;
end

%COPIED FROM setParams SET QC FREQS BASED ON THE PARADIGM: Use the paradigm to determine
% which set of frequencies to use in evaluating pipeline metrics.
if params.paradigm.ERP.on; params.QCfreqs = [.5, 1, 2, 5, 8, 12, ...
        20, 30, 45, 70] ;
else; params.QCfreqs = [2, 5, 8, 12, 20, 30, 45, 70] ;
end

%% TASK ONSET TAGS SECTION In progress

% fprintf(['Enter the task onset tags, one at a time, pressing ' ...
%  'enter/return between each entry.\nWhen you have entered ' ...
%  'all tags, input "done" (without quotations).\n']) ;
params.paradigm.onsetTags = grp_proc_info.beapp_event_code_onset_strs; % used to be this UI_cellArray(1,{}) ;
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
%% NEED TOFINISH THIS SECTION ABOVE

%%
%% ERP FILTER CUT-OFFS - SECTION MAPPED
params.paradigm.ERP.lowpass = grp_proc_info.beapp_filters{'Lowpass','Filt_Cutoff_Freq'} ; %input(['Enter low-pass filter, in Hz:\nCommon low-pass filter is 30 - 45 Hz.\n> ']) ;
params.paradigm.ERP.highpass = grp_proc_info.beapp_filters{'Highpass','Filt_Cutoff_Freq'}; %input(['Enter high-pass filter, in Hz:\nCommon high-pass filter is 0.1 - 0.3 Hz.\n> ']) ;
%% IMPORTING FILE INFORMATION SECTION MAPPED
params.loadInfo = struct() ;
params.loadInfo.chanlocs.inc = 1; %Assume that the channel locations are included. Because this is true for
% most layouts/nets, it is easier to change in in the no-location layouts.
% params.loadInfo = loadingInfo(params, happeDir) ;
%  params.loadInfo = loadingInfo(params, happeDir) ;
format_map = [1,1;2,5;3,NaN;4,3;]; %maps the beapp format_typ to the equivalent option in happe
params.loadInfo.inputFormat = 1 ; %hardcoding to 1 format_map(grp_proc_info.src_format_typ,2);
if isnan(params.loadInfo.inputFormat) %check if it could support this?
    error('HAPPE does not support pre-processed/segmented .mff files, please check your source format again')
end
% need to figure out net mapping and ask about version
% fprintf(['Acquisition layout type:\n  1 = EGI Geodesic Sensor ' ...
%     'Net\n  2 = EGI HydroCel Geodesic Sensor Net\n  3 = Neuroscan Quik-Cap' ...
%     '\n  4 = Other'
params.loadInfo.layout(1) = grp_proc_info.happe_net_type;
params.loadInfo.layout(2) = grp_proc_info.happe_net_num_channels;

if ismember(params.loadInfo.layout(1), [1,2]); params.loadInfo.correctEGI = 0; %HARD CODING TO BE 0 bc will be corrected by beapp - check
else; params.loadInfo.correctEGI = 0;
end
if params.loadInfo.inputFormat == 2
    if params.lowDensity == 1
        error('HAPPE does not currently support .raw low density files.') ;
    elseif (params.loadInfo.layout(1) == 1 && params.loadInfo.layout(2) ~= 64) || ...
            (params.loadInfo.layout(1) == 2 && ~ismember(params.loadInfo.layout(2), ...
            [32, 64, 128, 256]))
        error(['The entered number of channels is not supported for this' ...
            ' net as a .raw file.']) ;
    end
    % .set
elseif params.loadInfo.inputFormat == 3
    
    % .cdt
elseif params.loadInfo.inputFormat == 4
    
    % .mff
elseif params.loadInfo.inputFormat == 5
    if params.lowDensity; error(['HAPPE does not currently support .mff ' ...
            'low density files.']) ;
    else
        params.loadInfo.typeFields = grp_proc_info.typeFields;
        fprintf('Do you have additional type fields besides "code"? [Y/N]\n') ;
        if ~ismember('code', params.loadInfo.typeFields)
            params.loadInfo.typeFields = {'code', params.loadInfo.typeFields{:}};
        end
    end
end

%% CHANNELS OF INTEREST SECTION MAPPED
if ~params.loadInfo.chanlocs.inc
    params.chans.IDs = {} ; params.chans.subset = 'all' ;
else
    params.chans.subset = grp_proc_info.chans_to_analyze;
    params.chans.subset = 'coi_include';
    if grp_proc_info.beapp_ica_run_all_10_20
            addit_chans = cell(1,length(grp_proc_info.beapp_ica_additional_chans_lbls{1,1}));
        for num_to_conv = 1:length(grp_proc_info.beapp_ica_additional_chans_lbls{1,1})
            addit_chans{num_to_conv} = strcat('E',num2str(grp_proc_info.beapp_ica_additional_chans_lbls{1,1}(num_to_conv)));
        end
        params.chans.IDs = unique([grp_proc_info.name_10_20_elecs, addit_chans]);
    end
    %% LINE NOISE FREQUENCY AND METHOD SECTIN MAPPED
    params.lineNoise.freq = grp_proc_info.src_linenoise; % input(['Frequency of electrical (line) ' ...
    % 'noise in Hz:\nUSA data probably = 60; Otherwise, probably = ' ...
    %'50\n> ']) ;
    params.lineNoise.neighbors = [params.lineNoise.freq-10, params.lineNoise.freq-5, ...
        params.lineNoise.freq-2, params.lineNoise.freq-1, params.lineNoise.freq, ...
        params.lineNoise.freq+1, params.lineNoise.freq+2, params.lineNoise.freq+5, ...
        params.lineNoise.freq+10] ;
    
    %         fprintf(['Are there any additional frequencies, (e.g., harmonics) to' ...
    %             ' reduce? [Y/N]\n']) ;
    params.lineNoise.harms.on = grp_proc_info.lineNoise_harms_on; %add advanced input here choose2('n', 'y') ;
    if params.lineNoise.harms.on
        params.lineNoise.harms.freqs = unique(grp_proc_info.lineNoise_harms_freqs, 'stable'); %
        if isempty(params.lineNoise.harms.freqs)
            error('Line noise reduction: You have turned on option to reduce additional frequencies, but the additional frequency vector is empty, please check user inputs');
        end
    else
        params.lineNoise.harms.freqs = [] ;
    end
    
    
    %  fprintf(['Line noise reduction method:\n  cleanline = Use Tim ' ...
    %     'Mullen''s CleanLine\n  notch = Use a notch filter (COMING SOON)\n']) ;
    params.lineNoise.cl = 1; % set to cleanline for now , could add notch in future choose2('notch', 'cleanline') ;
    if params.lineNoise.cl
        %             fprintf(['Use legacy or default line noise reduction?\n  default - Default method' ...
        %                 ' optimized in HAPPE v2\n  legacy - Method from HAPPE v1 (NOT' ...
        %                 ' RECOMMENDED\n']) ;
        params.lineNoise.legacy = 0; %maps to default ; choose2('default', 'legacy') ;
    else; error('Notch filter not currently available') ;
    end
    
    %% RESAMPLE SECTION MAPPED
    % params.downsample = determ_downsample() ;
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
        %   fprintf(['Choose a filter:\n  fir = Hamming windowed sinc FIR filter (EEGLAB''s standard filter)\n  ' ...
        %   'butter = IIR butterworth filter (ERPLAB''s standard filter)\n']) ;
        params.filt.butter = grp_proc_info.ERPfilter ; %choose2('fir', 'butter') ;
    else; params.filt.butter = 0 ;
    end
    %% BAD CHANNEL DETECTION SECTION MAPPED
    if ~params.loadInfo.chanlocs.inc; params.badChans.rej = 0;
    else
        %  fprintf('Perform bad channel detection? [Y/N]\n') ;
        params.badChans.rej = grp_proc_info.badChans_rej; %choose2('n','y') ;
        if params.badChans.rej && ~params.lowDensity
            % fprintf(['Bad channel detection method:\n  default = ' ...
            %  'Default method optimized in HAPPE v2.\n  legacy = ' ...
            % 'Method from HAPPE v1 (NOT RECOMMENDED).\n']) ;
            params.badChans.legacy = 0; %making default instead of legacy choose2('default', 'legacy') ;
        else; params.badChans.legacy = 0 ;
        end
    end
    %% WAVELET METHODOLOGY SECTION MAPPED
    %         fprintf(['Method of wavelet thresholding:\n  default = Default' ...
    %             'method optimized in HAPPE v2.\n  legacy = Method from HAPPE' ...
    %             ' v1 (NOT RECOMMENDED).\n']) ;
    params.wavelet.legacy = 0 ; %making default choose2('default', 'legacy') ;
    if ~params.wavelet.legacy && params.paradigm.ERP.on
        %             fprintf(['Threshold rule for wavelet thresholding:\n  soft - ' ...
        %                 'Use a soft threshold\n' ...
        %                 '  hard - Use a hard threshold\n']) ;
        params.wavelet.softThresh = grp_proc_info.wavelet_softThresh; % choose2('hard', 'soft') ;
    end
    %% MUSCIL SECTION MAPPED
    if ~params.paradigm.ERP.on
        fprintf(['Use ICLabel to reduce remaining muscle artifact ' ...
            'in your data? [Y/N]\nNOTE: This will drastically increase' ...
            ' processing time. Recommended for files with significant' ...
            ' muscle artifact.\n']) ;
        params.muscIL = 0 ; %set to no for now, but could ad as option in future? choose2('N', 'Y') ;
    else; params.muscIL = 0;
    end
    %% SEGMENTATION SECTION MAPPED
    % fprintf('Segment data? [Y/N]\n') ;
    params.segment.on = 1; % choose2('N', 'Y') ;
    if params.paradigm.task
        % SET SEGMENT START AND END
        params.segment.start = grp_proc_info.evt_seg_win_start ;% input(['Segment start, in MILLISECONDS, ' ...
        % 'relative to stimulus onset:\nExample: -100\n> '])/1000 ;
        params.segment.end = grp_proc_info.evt_seg_win_end; %input(['Segment end, in MILLISECONDS, ' ...
        % 'relative to stimulus onset:\n> '])/1000 ;
        if params.paradigm.ERP.on
            % DETERMINE TASK OFFSET
            % *** For this, maybe make it possible to upload a list
            % of offset delays?
            params.segment.offset = grp_proc_info.event_tag_offsets; % CHECK ON INPUT TABLE OPTION input(['Offset delay, in MILLISECONDS, ' ...
            %  'between stimulus initiation and presentation:\n' ...
            %  'NOTE: Please enter the total offset (combined system' ...
            %  ' and task-specific offsets).\n' ...
            % '> ']) ;
            % DETERMINE IF WANT BASELINE CORRECTION
            % fprintf('Perform baseline correction (by subtraction)? [Y/N]\n') ;
            params.baseCorr.on = grp_proc_info.evt_trial_baseline_removal; %choose2('n', 'y') ;
            if params.baseCorr.on
                % DETERMINE BASELINE START AND END
                params.baseCorr.start = grp_proc_info.evt_trial_baseline_win_start*1000 ; % input(['Enter, in MILLISECONDS,' ...
                %  ' where the baseline segment begins:\nExample: -100\n> ']) ;
                params.baseCorr.end = grp_proc_info.evt_trial_baseline_win_end*1000; % input(['Enter, in MILLISECONDS,' ...
                %' where the baseline segment ends:\n' ...
                % 'NOTE: 0 indicates stimulus onset.\n> ']) ;
            end
        end
        % DETERMINE SEGMENT LENGTH
    elseif ~params.paradigm.task; params.segment.length = grp_proc_info.win_size_in_secs ; %...
        % input("Segment length, in SECONDS:\n> ") ;
    end
end
%% INTERPOLATION SECTION MAPPED
if ~params.loadInfo.chanlocs.inc  % || ~params.badChans.rej
    params.segment.interp = 0 ;
else
    %  fprintf(['Interpolate the specific channels data determined ' ...
    %  'to be artifact/bad within each segment? [Y/N]\n']) ;
    params.segment.interp =grp_proc_info.segment_interp ; % choose2('n', 'y') ;
end

%% SEGMENT REJECTION SECTION MAPPED
if  grp_proc_info.beapp_reject_segs_by_amplitude || grp_proc_info.beapp_happe_segment_rejection
    params.segRej.on = 1;
end
%             fprintf(['Choose a method of segment rejection:\n  amplitude =' ...
%                 ' Amplitude criteria only\n  similarity = Segment ' ...
%                 'similarity only\n  both = Both amplitude criteria and ' ...
%                 'segment similarity\n']) ;
if  grp_proc_info.beapp_reject_segs_by_amplitude &&grp_proc_info.beapp_happe_segment_rejection
    params.segRej.method = 'both';
elseif grp_proc_info.beapp_happe_segment_rejection
    params.segRej.method = 'similarity';
else
    params.segRej.method = 'amplitude';
end% def = 1; flag that toggles amplitude-based rejection of segments after segment creation
if strcmpi(params.segRej.method, 'amplitude') || ...
        strcmpi(params.segRej.method, 'both')
    params.segRej.minAmp = grp_proc_info.art_thresh_min ;%input(['Minimum signal amplitude' ...
    % ' to use as the artifact threshold:\n> ']) ;
    params.segRej.maxAmp = grp_proc_info.art_thresh; %input(['Maximum signal amplitude' ...
    %'to use as the artifact threshold:\n> ']) ;
end
%            fprintf(['Use all channels or a region of interest for ' ...
%    'segment rejection?\n  all = All channels\n  roi = Region' ...
%   ' of interest\n']) ;
params.segRej.ROI.on = grp_proc_info.segRej_ROI_on ; %choose2('all', 'roi') ;
if params.segRej.ROI.on
    % fprintf(['Enter the channels in the ROI, one at a time.\n' ...
    %   'When you have finished entering all channels, enter ' ...
    % '"done" (without quotations).\n']) ;
    pa%rams.segRej.ROI.chans = unique(grp_proc_info.segRej_ROI_chans); % UI_cellArray(1,{}) ;
end
if params.paradigm.task && params.loadInfo.inputFormat == 1
    % fprintf(['Use pre-selected "usable" trials to restrict ' ...
    %  'analysis? [Y/N]\n']) ;
    params.segRej.selTrials = 0 ; %guide says this currenlty doesn't function, so setting to 0 choose2('n', 'y') ;
    %                 if params.segRej.selTrials
    %                     fprintf(['Enter the file, including the full path name ' ...
    %                         'and file extension, indicating which trials should' ...
    %                         ' be included in analyses.\n']) ;
    %                     params.segRej.trialFile = input('> ', 's') ;
    %                 end
end
%% RE-REFERENCING SECTION MAPPED FOR NOW (no rest)
if ~params.loadInfo.chanlocs.inc; params.reref.on = 0;
else
    % fprintf('Re-reference data? [Y/N]\n') ;
    params.reref.on = grp_proc_info.reref_on; % choose2('n', 'y') ;
    if params.reref.on
        %fprintf(['Does your data contain a flatline or all zero ' ...
        %   'reference channel? [Y/N]\n']) ;
        %params.reref.flat = choose2('n', 'y') ;
        params.reref.flat = 1; %HARDCODED, need to generalize or add input
        %if params.reref.flat
        % fprintf(['Enter reference channel ID:\nIf unknown, ' ...
        %    'press enter/return.\n']) ;
        params.reref.chan = grp_proc_info.reref_chan; % input('> ', 's') ;
    end
    
    %                 fprintf(['Re-referencing type:\n  average = Average ' ...
    %                     're-referencing\n  subset = Re-reference to a channel ' ...
    %                     'or subset of channels\n  rest = Re-reference using' ...
    %                     ' infinity with REST (Yao, 2001)\n']) ;
    %type of reference method to use (1= average, 2= CSD Laplacian, 3 = specific electrodes, 4 = REST)
    reref_map = {1,'average';2,'NaN';3,'subset';4,'rest'};
    params.reref.method = reref_map{grp_proc_info.reref_typ,2};
    %params.reref.method = input('> ', 's') ;
    if strcmpi(params.reref.method, 'subset')
        %                         fprintf(['Enter channel/subset of channels to ' ...
        %                         're-reference to, one at a time.\nWhen you have ' ...
        %                         'entered all channels, input "done" (without ' ...
        %                         'quotations).\n']) ;
        params.reref.subset = grp_proc_info.beapp_reref_chan_inds{1,1}; % UI_cellArray(1,{}) ;
    elseif strcmpi(params.reref.method, 'average')
    elseif strcmpi(params.reref.method, 'rest')
        fprintf(['REST from beapp to happe not currently supported']) ;
    end
end

%% SAVE FORMAT SECTION MAPPED
params.outputFormat = grp_proc_info.save_format;
%% VISUALIZATIONS SECTION MAPPED
params.vis.enabled = grp_proc_info.happe_plotting_on; %choose2('N', 'Y') ;
if params.vis.enabled
    % POWER SPECTRUM:
    % Min and Max
    params.vis.min = grp_proc_info.vis_psd_min ; %input("Minimum value for power spectrum figure:\n> ") ;
    params.vis.max =grp_proc_info.vis_psd_max; % input("Maximum value for power spectrum figure:\n> ") ;
    params.vis.toPlot = unique(grp_proc_info.vis_topoplot_freqs,'stable'); % Frequencies for spatial topoplots
    if params.paradigm.ERP.on
        % DETERMINE TIME RANGE FOR THE TIMESERIES FIGURE
        params.vis.min = grp_proc_info.vis_erp_min; % input('Start time, in MILLISECONDS, for the ERP timeseries figure:\n> ') ;
        params.vis.max =grp_proc_info.vis_erp_max; % input(['End time, in MILLISECONDS, for the ERP timeseries figure:\n' ...
        % 'NOTE: This should end 1+ millisecond(s) before your segmentation parameter ends (e.g. 299 for 300).\n' ...
        % '> ']) ;
    end
end
%% DONE SECTION MAPPED dont need code for this part
%    if ~preExist || strcmpi(paramChoice, 'done')
%        fprintf(['Please check your parameters before continuing.\n']) ;
%        listParams(params) ;
%        fprintf(['Are the above parameters correct? [Y/N]\n']) ;
%        if choose2('n','y'); break ;
%        elseif ~preExist
%            changedParams = 1 ;
%            preExist = 1 ;
%        end
%    end

%%  SAVE INPUT PARAMETERS

% If created new or changed parameter set, save as a new .mat file to a new
% folder (input_parameters) added to the source folder.
% CREATE "input_parameters" FOLDER AND ADD IT TO PATH, unless it
% already exists.
if ~isfolder([grp_proc_info.src_dir{1,1} filesep 'input_parameters'])
    mkdir([grp_proc_info.src_dir{1,1} filesep 'input_parameters']) ;
end
addpath([grp_proc_info.src_dir{1,1}, filesep, 'input_parameters']) ;
cd ([grp_proc_info.src_dir{1,1}, filesep, 'input_parameters']) ;

% DETERMINE PARAMETER FILE NAME: Prompt to use a default or custom name
% for parameter file. If file exists, ask to create new file with a
% different name or overwrite existing file.
% fprintf(['Parameter file save name:\n  default = Default name (input' ...
%  'Parameters_dd-mm-yyyy.mat).\n  custom = Create a custom file name' ...
%  '\n']) ;
%if choose2('custom', 'default')
%  paramFile = paramFile_validateExist(['inputParameters_' ...
%     datestr(now, 'dd-mm-yyyy') '.mat'], 'inputParameters_', 2) ;
%  else
%  fprintf('File name (Do not include .mat):\n') ;
% paramFile = paramFile_validateExist([input('> ', 's') '.mat'], ...
%     'inputParameters_', 0) ;
%  end
paramFile = [datestr(now, 'dd-mm-yyyy') '_', grp_proc_info.beapp_curr_run_tag, '.mat'];
grp_proc_info.HAPPE_ER_parameters_file_location = {[grp_proc_info.src_dir{1,1} filesep, 'input_parameters', filesep, paramFile]};
% SAVE PARAMETERS: Save the params variable to a .mat file using the
% name created above.
params.HAPPEver = ver ;
fprintf('Saving parameters...') ;
save(paramFile, 'params') ;
fprintf('Parameters saved.') ;
end
