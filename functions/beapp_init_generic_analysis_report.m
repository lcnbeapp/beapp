%% beapp_init_generic_analysis_report(report_info,all_condition_labels,all_obsv_sizes,curr_file,file_proc_info,eeg_w)
% 
% initialize the output report for the current output module
% Inputs:
% fname_all: grp_proc_info.beapp_fname_all, list of files being analyzed
% all_possible_conds: all conditions being analyzed across all files in this run
% largest_nchan: largest number of channels for any net in dataset
% bands_incl_total: number of frequency bands being analyzed in report
% ntabs : number of tabs for report, depending on user analysis preferences
% (e.g. mean, log, std power etc)
%
% Output: 
% report_info: structure with current report info for previous files
%           -.Src_Net_Type = array of net names for files run in mod
%           -.Src_SRate = src srates for files run in mod
%           -.Current_SRate=  current srates for files run in mod
%           -.Src_Num_Rec_Periods = number of recording periods in source file
%           -.Idx_Rec_Periods_Analyzed = indexes of recording periods analyzed
%           -.Num_Bad_Chans_By_Rec_Period = bad channels for each recording period
%           -.Num_Good_Chans_Analyzed_By_Rec_Period = number of good channels 
% all_condition_labels : conditions being analyzed during run
% all_obsv_sizes : number of segments preserved for each file
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
function [report_info,all_condition_labels,all_obsv_sizes,report_values] = beapp_init_generic_analysis_report (fname_all, all_possible_conds,largest_nchan,bands_incl_total,ntabs)

FileName = fname_all';
Condition_Name = cell(length(fname_all),1);
Src_Net_Type = cell(length(fname_all),1);
Src_SRate = NaN(length(fname_all),1);
Current_SRate = NaN(length(fname_all),1);
Src_Num_Rec_Periods = NaN(length(fname_all),1);
Idx_Rec_Periods_Analyzed =cell(length(fname_all),1);
Num_Bad_Chans_By_Rec_Period = cell(length(fname_all),1);
Bad_Chans_By_Rec_Period= cell(length(fname_all),1);
Num_Good_Chans_By_Rec_Period = cell(length(fname_all),1);
Num_Segs_Used = NaN(length(fname_all),1);
Num_Segs_Pre_Rej = NaN(length(fname_all),1);
Num_Segs_Good_Behav = NaN(length(fname_all),1);
Diagnosis= string.empty(length(fname_all),0); %TH

report_info = table(FileName, Condition_Name, Diagnosis, Src_Net_Type, Src_SRate,...
    Current_SRate,Src_Num_Rec_Periods, Idx_Rec_Periods_Analyzed, Num_Bad_Chans_By_Rec_Period,...
    Num_Good_Chans_By_Rec_Period,Num_Segs_Used,Num_Segs_Pre_Rej,Num_Segs_Good_Behav, Bad_Chans_By_Rec_Period);
all_condition_labels = cell(length(fname_all),length(all_possible_conds));

% 3d array -- file x condition x seg_count_type (final segs, segs pre_rej,
% segs good behav) 
all_obsv_sizes = NaN(length(fname_all),length(all_possible_conds),3);

report_values =cell(length(all_possible_conds),1);
[report_values{:}] =deal(NaN(length(fname_all),(bands_incl_total*largest_nchan),ntabs));
