%% beapp_add_row_generic_analysis_report(report_info,all_condition_labels,all_obsv_sizes,curr_file,file_proc_info,eeg_w)
% 
% add a row for a file in the output report for the current output module
% see beapp_init_generic_analysis_report
% Inputs: 
% report_info: structure with current report info for previous files
%           -.Src_Net_Type = array of net names for files run in mod
%           -.Src_SRate = src srates for files run in mod
%           -.Current_SRate=  current srates for files run in mod
%           -.Src_Num_Rec_Periods = number of recording periods in source file
%           -.Idx_Rec_Periods_Analyzed = indexes of recording periods analyzed
%           -.Bad_Chans_By_Rec_Period = bad channels for each recording period
%           -.Num_Good_Chans_Analyzed_By_Rec_Period = number of good channels 
% all_condition_labels : conditions being analyzed during run
% all_obsv_sizes : number of segments preserved for each file
% curr_file: current file in analysis loop
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

function [report_info,all_condition_labels,all_obsv_sizes] = beapp_add_row_generic_analysis_report(report_info,all_condition_labels,all_obsv_sizes,curr_file,file_proc_info,eeg_w)
if isfield(file_proc_info,'evt_conditions_being_analyzed')
    all_condition_labels(curr_file,:)=file_proc_info.grp_wide_possible_cond_names_at_segmentation';
end

report_info.Src_Net_Type(curr_file) = file_proc_info.net_typ;
report_info.Src_SRate(curr_file) = file_proc_info.src_srate;
report_info.Current_SRate(curr_file) = file_proc_info.beapp_srate;
report_info.Src_Num_Rec_Periods(curr_file) = file_proc_info.src_num_epochs;
report_info.Idx_Rec_Periods_Analyzed(curr_file)={file_proc_info.epoch_inds_to_process};
report_info.Bad_Chans_By_Rec_Period(curr_file) = {strjoin(cellfun(@mat2str,file_proc_info.beapp_bad_chans,'UniformOutput',0),',')};
if cellfun(@strcmp,report_info.Bad_Chans_By_Rec_Period(curr_file),{'zeros(0,1)'}) %MM added 11/20/19, fixed 'zeros(0,1)' error
    report_info.Bad_Chans_By_Rec_Period(curr_file) = {NaN};
end
report_info.Num_Bad_Chans_By_Rec_Period(curr_file) = {strjoin(cellfun(@ (x) num2str(length(x)),file_proc_info.beapp_bad_chans,'UniformOutput',0),',')};
report_info.Num_Good_Chans_By_Rec_Period(curr_file) = {strjoin(cellfun(@mat2str,num2cell(file_proc_info.beapp_nchans_used),'UniformOutput',0),',')};

cinds = ismember(file_proc_info.grp_wide_possible_cond_names_at_segmentation,...
    file_proc_info.evt_conditions_being_analyzed.Condition_Name);

all_obsv_sizes(curr_file,cinds,1)=file_proc_info.evt_conditions_being_analyzed.Num_Segs_Post_Rej;
all_obsv_sizes(curr_file,cinds,2)=file_proc_info.evt_conditions_being_analyzed.Num_Segs_Pre_Rej;
all_obsv_sizes(curr_file,cinds,3)=file_proc_info.evt_conditions_being_analyzed.Good_Behav_Trials_Pre_Rej;
