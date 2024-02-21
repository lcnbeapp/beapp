% batch_mff2beapp (grp_proc_info_in)
% 
% Converts .mff files (continuous or pre-segmented) to BEAPP format,
% including event tags if applicable. 
% Takes BEAPP grp_proc_info structure and, if files have different line
% noise frequencies or event tag offsets,  beapp_file_info_table. 
%
% Many of the functions used to read in MFFs below are adapted from the EGI
% API written by Colin Davey for FieldTrip in 2006-2014. 
% https://github.com/fieldtrip/fieldtrip/tree/master/external/egi_mff
%
% Note: 
% This may need to be adjusted over time depending on the MFF version
% number. This function assumes timestamps are in microseconds or
% nanoseconds depending on version number, and that event tag timestamps are in
% microseconds. 
%
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
function grp_proc_info_in = batch_mff2beapp(grp_proc_info_in)

%% prepare to convert files, set path
if (exist(grp_proc_info_in.beapp_format_mff_jar_lib,'file')~=2)
    error('EGI MFF JAR Library needed-- specify in set_beapp_def');
end
[ref_dir,~]=fileparts(grp_proc_info_in.beapp_format_mff_jar_lib);
javaaddpath(which(grp_proc_info_in.beapp_format_mff_jar_lib));
addpath(ref_dir);
addpath(genpath(grp_proc_info_in.beapp_format_mff_matlab_package))
% get file list and extract file specific information from input tables
[grp_proc_info_in.src_fname_all,grp_proc_info_in.src_linenoise_all,...
    grp_proc_info_in.src_offsets_in_ms_all,grp_proc_info_in.beapp_fname_all,~] = ...
    beapp_load_nonmat_flist_and_evt_table(grp_proc_info_in.src_dir,'.mff',...
    grp_proc_info_in.event_tag_offsets,grp_proc_info_in.src_linenoise,grp_proc_info_in.beapp_file_info_table,...
    grp_proc_info_in.src_format_typ,grp_proc_info_in.beapp_run_per_file,grp_proc_info_in.beapp_file_idx);

% load nets the user has input, for speed
if ~isempty(grp_proc_info_in.src_unique_nets{1})
    
    % add new nets if not in library, load nets used into grp_proc_info_in
    add_nets_to_library(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options,grp_proc_info_in.ref_net_library_dir,grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);
    [grp_proc_info_in.src_unique_net_vstructs,grp_proc_info_in.src_unique_net_ref_rows, grp_proc_info_in.src_net_10_20_elecs,grp_proc_info_in.largest_nchan] = load_nets_in_dataset(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options, grp_proc_info_in.ref_net_library_dir);
    cd(grp_proc_info_in.src_dir{1})
end

% if user wants to ignore specific channels, store which channels for which
% nets (otherwise get all net information from beapp_file_info_table)
if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)
    if ~(isequal(length(grp_proc_info_in.src_unique_nets),length(grp_proc_info_in.beapp_indx_chans_to_exclude))&& ~isempty(grp_proc_info_in.src_unique_nets))
        if isempty(grp_proc_info_in.src_unique_nets)
            error ('User has asked to exclude channels but not included net information in grp_proc_info.src_unique_nets');
        elseif ~isequal(length(grp_proc_info_in.src_unique_nets),length(grp_proc_info_in.beapp_indx_chans_to_exclude))
            error ('User has asked to exclude channels but number of nets in grp_proc_info.src_unique_nets does not \n%s',...
                'correspond to number of nets expected from grp_proc_info.beapp_indx_chans_to_exclude');
        end
    end
end

%% extract events and eeg data for each file
for curr_file = 1:length(grp_proc_info_in.src_fname_all)
    tic;
    % save filename and path
    file_proc_info.src_fname=grp_proc_info_in.src_fname_all(curr_file);
    file_proc_info.beapp_fname=grp_proc_info_in.beapp_fname_all(curr_file);
    full_filepath=strcat(grp_proc_info_in.src_dir{1},filesep,file_proc_info.src_fname{1});
    cd(full_filepath)
    
    % get list of files containing signal using EGI API function
    % patch for path problem caused by packages
    try
        curr_file_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_MFFFile, [], full_filepath);
    catch err
        if strcmp(err.message,'Undefined variable "com" or class "com.egi.services.mff.api.MFFResourceType.kMFF_RT_MFFFile".') || strcmp(err.message, 'Unable to resolve the name com.egi.services.mff.api.MFFResourceType.kMFF_RT_MFFFile.') %RL edit added or
            javaaddpath(which(grp_proc_info_in.beapp_format_mff_jar_lib));
            addpath(ref_dir);
        end
        curr_file_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_MFFFile, [], full_filepath);
    end
    
    mff_binary_signal_flist = curr_file_obj.getSignalResourceList(false);
    
    if length(mff_binary_signal_flist)>1
        % will need modification if more than one .bin file - not seen to date
        warning (['BEAPP file' file_proc_info.beapp_fname{1} ': files with more than one .bin file are not supported']);
        continue;
    else
        
        %% read mff file metadata
        
        signal_name_str=char(mff_binary_signal_flist(1));
        if  strcmp(signal_name_str,'[]')
            warning (['BEAPP file' file_proc_info.beapp_fname{1} ' : file does not have a signalN.bin file, which contains the source EEG data. Skipping']);
            continue;
        end
        if contains(signal_name_str,',') %above if statement didn't catch files with 2 signal bins, this checks nad gets rid of signal bins following first one
            temp_signal_name = strsplit(signal_name_str,',');
            signal_name_str = char(temp_signal_name{1}(2:end));
        else
        
        signal_name_str=char(signal_name_str(2:end-1)); % avoids compatibility issues with 2014a as extractfrombetween
        end
        % get file metadata and basic signal information
        [grp_proc_info_in,file_proc_info,tmp_signal_info,time_units_exp,record_time] = ...
            beapp_read_mff_metadata(signal_name_str,full_filepath,grp_proc_info_in,file_proc_info,curr_file);
        clear mff_binary_signal_flist signal_name_str
        
        %% read mff recording period information (called epochs in NetStation)
        [file_proc_info,tmp_signal_info.epoch_first_blocks,tmp_signal_info.epoch_last_blocks] = beapp_read_mff_rec_period_info(full_filepath,file_proc_info,time_units_exp);
        
        %% segment/category and hand editing info
        file_proc_info= beapp_read_mff_segment_info(full_filepath,file_proc_info,time_units_exp);   
        
        %% initialize file channel related variables 
        
        beapp_indx_init = 1:file_proc_info.src_nchan;
        if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)
              uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
              chans_to_exclude = grp_proc_info_in.beapp_indx_chans_to_exclude{uniq_net_ind};
              beapp_indx_init  = setdiff(beapp_indx_init,chans_to_exclude);
        end
        
        file_proc_info.beapp_indx= cell(file_proc_info.src_num_epochs,1);
        file_proc_info.beapp_indx(:) = {[beapp_indx_init]};
        file_proc_info.beapp_bad_chans= cell(file_proc_info.src_num_epochs,1);
        file_proc_info.beapp_bad_chans(:) = {[]};
        file_proc_info.beapp_nchans_used=length(beapp_indx_init)*ones(1,file_proc_info.src_num_epochs);
        clear beapp_indx_init
    end
    
    %% read in mff events: read in all tracks, sorts by sample number, and split by recording period
    [file_proc_info.evt_info,file_proc_info.evt_header_tag_information] = ...
        beapp_read_mff_events(curr_file_obj,full_filepath,record_time,time_units_exp,file_proc_info,grp_proc_info_in);
    
    if grp_proc_info_in.src_format_typ ==3
        seg_cond_names = unique({file_proc_info.seg_info.condition_name});
        file_proc_info.evt_conditions_being_analyzed= table();
        file_proc_info.evt_conditions_being_analyzed.Condition_Name (1:length(seg_cond_names),1)= seg_cond_names';
        file_proc_info.evt_conditions_being_analyzed((length(seg_cond_names)+1):end,:) =[]; 
    end
    clear curr_file_obj record_time
    
    %% read in actual eeg data
    % adjusted from EGI API function. Starting at sample 1 and reading data
    % in 500000 sample chunks as default, since batch processing
    % channels read in depends on channels in .beapp_indx
    
    total_samples_in_file=sum(file_proc_info.src_epoch_nsamps);
    total_samples_in_file=total_samples_in_file(1);
    eeg=beapp_read_mff_eeg_data(1,total_samples_in_file,500000,tmp_signal_info,file_proc_info);
    if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)
        eeg = cellfun(@(x) exclude_data_for_chans(chans_to_exclude,x),eeg,'UniformOutput',0);
    end
    
    %% format and save
    
    % delete data inside recording periods not selected
    if ~ isempty(file_proc_info.epoch_inds_to_process)
        try
            eeg = eeg(file_proc_info.epoch_inds_to_process);
            file_proc_info.evt_info = file_proc_info.evt_info(file_proc_info.epoch_inds_to_process);
            file_proc_info.beapp_num_epochs = length(file_proc_info.epoch_inds_to_process);
            file_proc_info.beapp_indx = file_proc_info.beapp_indx(file_proc_info.epoch_inds_to_process);
            file_proc_info.beapp_bad_chans = file_proc_info.beapp_bad_chans(file_proc_info.epoch_inds_to_process);
            file_proc_info.beapp_nchans_used =  file_proc_info.beapp_nchans_used(file_proc_info.epoch_inds_to_process);
        catch ME
            if strcmp(ME.identifier,'MATLAB:badsubscript')
                warning ([file_proc_info.beapp_fname{1} ' : does not contain one or all of recording selected in user inputs. Skipping this file in this analysis']);
                continue;
            end
        end
    end
    
     file_proc_info = beapp_prepare_to_save_file('format',file_proc_info, grp_proc_info_in,grp_proc_info_in.src_dir{1});

    % if segmented files, make data into condition x epoch array containing
    % 3d data arrays, as produces in segmentation modules
    % throw out bad segments if desired
    if grp_proc_info_in.src_format_typ ==3
        if isfield(file_proc_info,'seg_info')
            [eeg_w, file_proc_info] = format_segmented_mff_data (eeg,file_proc_info,...
                grp_proc_info_in.beapp_event_eprime_values.condition_names,grp_proc_info_in.mff_seg_throw_out_bad_segments);
            if ~all(cellfun(@isempty,eeg_w))
                save(file_proc_info.beapp_fname{1},'file_proc_info','eeg_w');
            end
        else
            warning ([file_proc_info.beapp_fname{1} ': src format typ indicated as segmented .mff, but file does not contain segment information']);
            save(file_proc_info.beapp_fname{1},'file_proc_info','eeg');
        end
    elseif grp_proc_info_in.src_format_typ == 37
        seg_info_out_dir = [grp_proc_info_in.beapp_toggle_mods{'format','Module_Dir'}{1} filesep 'seg_info'];
        eeg_w = align_segment_info_across_src_files (eeg,file_proc_info,seg_info_out_dir);
    elseif ~all(cellfun(@isempty,eeg))
        save(file_proc_info.beapp_fname{1},'file_proc_info','eeg');
    end
    
    clearvars -except grp_proc_info_in curr_file grp_proc_info_in.src_offsets_in_ms_all ref_dir
end

clear grp_proc_info_in.src_srate_all file_proc_info
end

function eeg_curr_rec_period = exclude_data_for_chans(chans_to_exclude,eeg_curr_rec_period)
    eeg_curr_rec_period(chans_to_exclude ,:) = deal(NaN);  
end
