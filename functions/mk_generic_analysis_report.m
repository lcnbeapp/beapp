%% mk_generic_analysis_report
%
% make report_values tables (.mat and .csv) for output module
%
% Inputs:
% report_values- 3D file x channel+band x analysis array
% tname_out - tab/analysis name
% report_info - metadata for all files
% bw_names - set by user
% largest_nchan - largest number of channels for any net in dataset
% all_condition_labels - all conditions being used across files
% all_obsv_sizes - number of segments per file for all files
% beapp_out_dir - directory to save report in
%
% Outputs:
% hdr- report header (chan x frequency band x analysis type (e.g
% mean_power))
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
function [hdr] = mk_generic_analysis_report(report_values,tname_out,report_info,bw_names,largest_nchan,all_condition_labels, all_obsv_sizes, beapp_out_dir)
col_ctr = 0;
for curr_analysis = 1:length(tname_out)
    for curr_band =1:length(bw_names)
        hdr(curr_analysis,col_ctr+1:col_ctr+largest_nchan) = strcat('E',strread(num2str(1:largest_nchan),'%s'),['_',bw_names{curr_band},'_',tname_out{curr_analysis}]);
        col_ctr=col_ctr+largest_nchan;
    end
    col_ctr = 0;
end

% append psd values and output for each condition and each psd analysis
% type
for curr_condition= 1: length(report_values)
     report_info.Condition_Name=all_condition_labels(:,curr_condition);
     report_info.Number_of_Observations = cell2mat(all_obsv_sizes(:,curr_condition)); 
     
    for curr_analysis = 1:length(tname_out)
        curr_output_table = [report_info array2table(report_values{curr_condition}(:,:,curr_analysis))];
        curr_output_table.Properties.VariableNames(length(report_info.Properties.VariableNames)+1:end) = [hdr(curr_analysis,:)];
        empty_cond_names = cellfun(@isempty,report_info.Condition_Name);
        cd(beapp_out_dir)
        writetable(curr_output_table,[strjoin(unique(report_info.Condition_Name(~empty_cond_names)),'_'),'_',tname_out{curr_analysis},'.csv']);
    end
end