%% beapp_read_mff_metadata
% loads file specific metadata from mff file and stores it locally in
% file_proc_info. 
% Inputs: 
% signal_string = .bin file string name
% full_filepath = full filepath to .mff file
%
% Many of the functions used to read in MFFs are adapted from the EGI
% API written by Colin Davey for FieldTrip in 2006-2014. 
% https://github.com/fieldtrip/fieldtrip/tree/master/external/egi_mff
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [grp_proc_info_in,file_proc_info,tmp_signal_info,time_units_exp,record_time]=beapp_read_mff_metadata(signal_string,full_filepath,grp_proc_info_in,file_proc_info,curr_file)

%% load Java objects with recording, signal, and net information
recording_info_obj=mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Info, 'info.xml', full_filepath);
tmp_signal_info.signal_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Signal, signal_string, full_filepath);
sensor_layout_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_SensorLayout, ['sensorLayout.xml'], full_filepath);

% used to get impedances, but API returns blank values. Contacted EGI
% info1.xml name could change, never seen in our datasets
info_n_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_InfoN, ['info1.xml'], full_filepath);

% get signal information from signal object
tmp_signal_info.sig_blocks = tmp_signal_info.signal_obj.getSignalBlocks();
signal_block_obj = tmp_signal_info.sig_blocks.get(0);
record_time = recording_info_obj.getRecordTime;
tmp_rec_time= strsplit(char(record_time), 'T');

%% store general eeg source file information
file_proc_info.src_nchan = double(signal_block_obj.numberOfSignals);
file_proc_info.src_srate = double(signal_block_obj.signalFrequency(1));
file_proc_info.src_mff_signal_version = tmp_signal_info.signal_obj.getVersion; % unclear if necessary, keeping for now
file_proc_info.src_mff_version = recording_info_obj.getMFFVersion;
file_proc_info.src_present_mff_version = recording_info_obj.getMFFVersionPresent;% unclear if this is actually important or different
file_proc_info.src_amp_type = char(recording_info_obj.getAmpFirmwareVersion());% amp firmware version
file_proc_info.src_amp_serial = char(recording_info_obj.getAmpSerialNumber());
file_proc_info.src_record_start_day = tmp_rec_time{1};
file_proc_info.src_record_start_time = tmp_rec_time{2};
file_proc_info.src_file_offset_in_ms = grp_proc_info_in.src_offsets_in_ms_all(curr_file);
file_proc_info.src_linenoise =  grp_proc_info_in.src_linenoise_all(curr_file);
file_proc_info.net_typ = {char(sensor_layout_obj.getName)};
grp_proc_info_in.src_net_typ_all{curr_file}= file_proc_info.net_typ{1};
grp_proc_info_in.src_srate_all(curr_file)=file_proc_info.src_srate;

% store general file information for beapp
file_proc_info.beapp_srate = file_proc_info.src_srate;
file_proc_info.beapp_nchan = file_proc_info.src_nchan;
file_proc_info.hist_run_tag = grp_proc_info_in.hist_run_tag;
file_proc_info.hist_run_table = beapp_init_file_hist_table (grp_proc_info_in.beapp_toggle_mods.Properties.RowNames);
file_proc_info.epoch_inds_to_process = grp_proc_info_in.epoch_inds_to_process;

% different mff versions are in nano or microseconds
if file_proc_info.src_mff_version==0
    time_units_exp= 9;
else
    time_units_exp=6;
end
clear block_obj signal_string tmp_rec_time info_obj sensor_layout_obj info_n_obj recording_info_obj

%% load and store net information locally

% if file net hasn't been seen in dataset or preloaded, check if in library + load
if ~any(strcmp(grp_proc_info_in.src_unique_nets,file_proc_info.net_typ{1}))
    grp_proc_info_in.src_unique_nets{end+1}=file_proc_info.net_typ{1};
    grp_proc_info_in.src_unique_nets(strcmp('',grp_proc_info_in.src_unique_nets)) = [];
    add_nets_to_library(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options,grp_proc_info_in.ref_net_library_dir,grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);
    [grp_proc_info_in.src_unique_net_vstructs,grp_proc_info_in.src_unique_net_ref_rows, grp_proc_info_in.src_net_10_20_elecs,grp_proc_info_in.largest_nchan] = load_nets_in_dataset(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options, grp_proc_info_in.ref_net_library_dir);
    cd(grp_proc_info_in.src_dir{1})
end

% store net information in file_proc_info
uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
file_proc_info.net_vstruct = grp_proc_info_in.src_unique_net_vstructs{uniq_net_ind};
file_proc_info.net_ref_elec_rnum = grp_proc_info_in.src_unique_net_ref_rows(uniq_net_ind);
file_proc_info.net_10_20_elecs = grp_proc_info_in.src_net_10_20_elecs{uniq_net_ind};

%% load subject information -- may not be necessary
if exist([full_filepath,filesep,'subject.xml'])
    subj_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Subject, 'subject.xml', full_filepath);
    fields = subj_obj.getFields; % for most data shouldn't have more than one, but just in case
    subs=cell(fields.size,1);
    
    for curr_field = 1:fields.size
        field= fields.get(curr_field-1);
        sub=field.getData;
        subs{curr_field}=char(sub);
    end
    
    file_proc_info.src_subject_id=[subs{:}]; % assumes one subject
end

clearvars -except grp_proc_info_in file_proc_info tmp_signal_info time_units_exp record_time