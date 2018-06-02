%% batch_beapp_prepp (grp_proc_info)
%
% Usage: Batch function that applies the PREP pipeline to the raw EEG data.
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

function grp_proc_info_in = batch_beapp_prepp(grp_proc_info_in)

prepp_def_loc = which('getPipelineDefaults');
if isempty(prepp_def_loc)
    prep_folder_path = fileparts(which('prepPipeline'));
    addpath(genpath(prep_folder_path));
else
    prep_folder_path = prepp_def_loc;
end

if grp_proc_info_in.beapp_toggle_mods{'prepp','Module_Xls_Out_On'}
    prepp_report_categories = {'BEAPP_Fname','PREP_Error_Status','Epochs_With_Errors','Num_Epochs',...
        'File_Epoch_Lengths_In_Secs','Number_Bad_Channels_Detected', ...
        'Interpolated_Channel_IDs_Per_Epoch'};
    PREP_report_table= cell2table(cell(length(grp_proc_info_in.beapp_fname_all),length(prepp_report_categories)));
    PREP_report_table.Properties.VariableNames=prepp_report_categories;
    PREP_report_table.BEAPP_Fname = grp_proc_info_in.beapp_fname_all';
end

% find the source directory
src_dir = find_input_dir('prepp',grp_proc_info_in.beapp_toggle_mods);

% for reporting errors
files_failed_in_prepp = {};
file_epochs_failed = {};

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1})
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg','file_proc_info');
        tic;
        
        epochs_w_errors =[];
        
        % cycle through epochs if necessary
        for curr_epoch = 1:size(eeg,2)
            
            %Update params for file
            params = struct();
            params.name=file_proc_info.beapp_fname{1};
            params.referenceChannels = file_proc_info.beapp_indx{curr_epoch};
            params.rereferenceChannels=file_proc_info.beapp_indx{curr_epoch};
            params.evaluationChannels=file_proc_info.beapp_indx{curr_epoch};
            params.rereferencedChannels=file_proc_info.beapp_indx{curr_epoch};
            params.lineFrequencies=file_proc_info.src_linenoise*(1:floor((file_proc_info.src_srate/2)/file_proc_info.src_linenoise));
            
            diary off;
            % convert to EEGLAB format, run PREP on epoch, convert back to BEAPP
            EEG_tmp= curr_epoch_beapp2eeglab(file_proc_info,eeg{curr_epoch},curr_epoch);
            EEG_structs{curr_epoch}=prepPipeline(EEG_tmp,params);
            eeg{curr_epoch} =  EEG_structs{curr_epoch}.data;
            diary on;
            
            % save error status for reporting
            error_status_by_epoch{curr_epoch}=EEG_structs{curr_epoch}.etc.noiseDetection.errors.status;
            epoch_lengths_in_secs(curr_epoch) = (length(eeg{curr_epoch})/file_proc_info.beapp_srate);
            
            if ~strcmp(EEG_structs{curr_epoch}.etc.noiseDetection.errors.status,'good')
                epochs_w_errors = [epochs_w_errors curr_epoch];
            end
            
            % save epoch/recording period specific bad channel information,
            % and convert bad channels to NaNs if selected by the user
            % this could be more efficient but can fix later
            if isfield(EEG_structs{curr_epoch}.etc,'noiseDetection')
                if isfield(EEG_structs{curr_epoch}.etc.noiseDetection,'reference')
                    if isfield(EEG_structs{curr_epoch}.etc.noiseDetection.reference,'interpolatedChannels')
                        if isfield(EEG_structs{curr_epoch}.etc.noiseDetection.reference.interpolatedChannels,'all')
                            file_proc_info.beapp_bad_chans{curr_epoch} = [EEG_structs{curr_epoch}.etc.noiseDetection.reference.interpolatedChannels.all];
                            if grp_proc_info_in.beapp_rmv_bad_chan_on
                                file_proc_info.beapp_indx{curr_epoch} = setdiff(file_proc_info.beapp_indx{curr_epoch}, [EEG_structs{curr_epoch}.etc.noiseDetection.reference.interpolatedChannels.all]);
                                file_proc_info.beapp_nchans_used(curr_epoch) = length(file_proc_info.beapp_indx{curr_epoch});
                                
                                % temporary catch for channels to exclude
                                 chans_exclude = setdiff([1:file_proc_info.src_nchan],file_proc_info.beapp_indx{curr_epoch});
                                 eeg{curr_epoch}(chans_exclude ,:) = deal(NaN);
                            end
                        end
                    end
                end
            end
        end
        
        % save reporting information
        if grp_proc_info_in.beapp_toggle_mods{'prepp','Module_Xls_Out_On'}
            if ~isempty (epochs_w_errors)
                err_status_strings = unique(error_status_by_epoch);
                PREP_report_table.Num_Epochs(curr_file) = num2cell(curr_epoch);
                PREP_report_table.PREP_Error_Status{curr_file} = [sprintf('%s ',err_status_strings{1:end-1}),err_status_strings{end}];
            end
            PREP_report_table.File_Epoch_Lengths_In_Secs(curr_file) = ...
            {strjoin(cellfun(@mat2str,num2cell(epoch_lengths_in_secs),'UniformOutput',0),',')};
            PREP_report_table.Epochs_With_Errors{curr_file} =...
                 {strjoin(cellfun(@mat2str,num2cell(epochs_w_errors),'UniformOutput',0),',')};
            PREP_report_table.Num_Epochs(curr_file) = num2cell(curr_epoch);
            PREP_report_table.File_Epoch_Lengths_In_Secs(curr_file) = ...
             {strjoin(cellfun(@mat2str,num2cell(epoch_lengths_in_secs),'UniformOutput',0),',')};
            PREP_report_table.Number_Bad_Channels_Detected(curr_file) = ...
                 {strjoin(cellfun(@mat2str,cellfun(@length,file_proc_info.beapp_bad_chans,'UniformOutput',0),'UniformOutput',0),',')};
            PREP_report_table.Interpolated_Channel_IDs_Per_Epoch(curr_file) = ...
                {strjoin(cellfun(@mat2str,file_proc_info.beapp_bad_chans,'UniformOutput',0),',')};
        end
        
        % store error information for outputs
        if ~isempty (epochs_w_errors)
            files_failed_in_prepp{curr_file} = file_proc_info.beapp_fname{1};
            file_epochs_failed(curr_file) = {strjoin(cellfun(@mat2str,num2cell(epochs_w_errors),'UniformOutput',0),',')};
        end
        
        cd(grp_proc_info_in.beapp_toggle_mods{'prepp','Module_Dir'}{1});
        
        % save data
        if ~all(cellfun(@isempty,eeg))
            
            file_proc_info = beapp_prepare_to_save_file('prepp',file_proc_info, grp_proc_info_in, src_dir{1});
            save(file_proc_info.beapp_fname{1},'eeg','file_proc_info','EEG_structs','params');
        end
        clearvars -except grp_proc_info_in curr_file src_dir files_failed_in_prepp file_epochs_failed PREP_report_table prep_folder_path
    end
end

cd (grp_proc_info_in.beapp_genout_dir{1})

% output error information if needed, delete old error info if not
if ~isempty(file_epochs_failed)
    warning('some files failed to process in PREP--see PREP error report in out folder');
    failed_files_output_table = table(files_failed_in_prepp',file_epochs_failed');
    failed_files_output_table.Properties.VariableNames = {'Files_Failed_In_PREP','Epochs_Failed'};
    writetable(failed_files_output_table,'PREP_Error_Reporting.csv');
elseif (exist('PREP_Error_Reporting.csv')==2)
    delete 'PREP_Error_Reporting.csv'
end

%generate output table
if grp_proc_info_in.beapp_toggle_mods{'prepp','Module_Xls_Out_On'}
    writetable(PREP_report_table, ['PREP_Report_Table ',grp_proc_info_in.beapp_curr_run_tag,'.csv']);
end

rmpath(genpath(prep_folder_path));

