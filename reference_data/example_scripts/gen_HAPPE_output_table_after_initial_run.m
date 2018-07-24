% create HAPPE report table for all files in directory  after initial HAPPE
% run 
% may be useful if there was a crash during the run or if the user did not
% generate an initial report table
% function takes run template from previous run or can use previously
% existing user input script

gen_HAPPE_output_table_after_initial_run()
answer = questdlg('Are the parameters from your HAPPE run stored in a GUI template or a user input script?',...
    'Select Stored Run Parameters','GUI Template','User Input Script','GUI Template');

if strcmp(answer, 'GUI Template')
[load_template_file,load_template_path] = uigetfile(['~'   ...
    [fileparts(which('set_beapp_def.m')) filesep, 'run_templates']  filesep '*.mat'],...
    'Select BEAPP Template Used to Run HAPPE');
    load([load_template_path filesep load_template_file],'grp_proc_info');
else
    [load_template_file,load_template_path] = uigetfile(['~'   ...
    [fileparts(which('set_beapp_def.m')) filesep, 'user_inputs']  filesep '*.m'],...
    'Select BEAPP User Input Script Used to Run HAPPE'); 
    set_beapp_def;
    grp_proc_info.beapp_alt_user_input_location = [load_template_path filesep load_template_file];
    grp_proc_info = beapp_configure_settings;
end
grp_proc_info.beapp_dir_warn_off = 1;
grp_proc_info.beapp_toggle_mods{:,'Module_On'} = false(size(grp_proc_info.beapp_toggle_mods,1),1);
grp_proc_info.beapp_toggle_mods{'ica','Module_On'} = 1;
grp_proc_info = prepare_to_run_main (grp_proc_info);

cd(grp_proc_info.beapp_toggle_mods{'ica','Module_Dir'}{1});

% initialize report. depending on setting some values will not be generated
ica_report_categories = {'BEAPP_Fname','Time_Elapsed_For_File','Num_Rec_Periods', 'Number_Channels_UserSelected',...
    'File_Rec_Period_Lengths_In_Secs','Number_Good_Channels_Selected_Per_Rec_Period', ...
    'Interpolated_Channel_IDs_Per_Rec_Period', 'Percent_ICs_Rejected_Per_Rec_Period', ...
    'Percent_Variance_Kept_of_Data_Input_to_MARA_Per_Rec_Period', ...
    'Mean_Artifact_Probability_of_Kept_ICs_Per_Rec_Period','Median_Artifact_Probability_of_Kept_ICs_Per_Rec_Period'};
ICA_report_table= cell2table(cell(length(grp_proc_info.beapp_fname_all),length(ica_report_categories)));
ICA_report_table.Properties.VariableNames=ica_report_categories;
ICA_report_table.BEAPP_Fname = grp_proc_info.beapp_fname_all';

for curr_file=1:length(grp_proc_info.beapp_fname_all)
    if exist(strcat(grp_proc_info.beapp_toggle_mods{'ica','Module_Dir'}{1},filesep,grp_proc_info.beapp_fname_all{curr_file}),'file')
        
        load(grp_proc_info.beapp_fname_all{curr_file},'file_proc_info','eeg');
        ICA_report_table.Num_Rec_Periods(curr_file) = num2cell(file_proc_info.beapp_num_epochs);
        [~,epoch_lengths_in_samps] = cellfun(@size,eeg);
        ICA_report_table.File_Rec_Period_Lengths_In_Secs(curr_file) = {epoch_lengths_in_samps/file_proc_info.beapp_srate};
        
        chan_IDs_all = unique([grp_proc_info.name_10_20_elecs  file_proc_info.net_happe_additional_chans_lbls]);
        chan_IDs = intersect(chan_IDs_all,{file_proc_info.net_vstruct.labels});
        ICA_report_table.Number_Channels_UserSelected(curr_file) = {length(chan_IDs)};
        ICA_report_table.Number_Good_Channels_Selected_Per_Rec_Period(curr_file) = file_proc_info.ica_stats.Number_Good_Channels_Selected_Per_Rec_Period;
        if ~all(cellfun(@isempty,file_proc_info.beapp_bad_chans))
            tmp = cellfun(@mat2str,file_proc_info.beapp_bad_chans, 'UniformOutput',0);
            ICA_report_table.Interpolated_Channel_IDs_Per_Rec_Period(curr_file) =tmp;
        else
            ICA_report_table.Interpolated_Channel_IDs_Per_Rec_Period(curr_file) ={''};
        end
        
        ICA_report_table.Percent_ICs_Rejected_Per_Rec_Period(curr_file) = file_proc_info.ica_stats.Percent_ICs_Rejected_Per_Rec_Period;
        ICA_report_table.Percent_Variance_Kept_of_Data_Input_to_MARA_Per_Rec_Period(curr_file) = file_proc_info.ica_stats.Percent_Variance_Kept_of_Data_Input_to_MARA_Per_Rec_Period;
        ICA_report_table.Mean_Artifact_Probability_of_Kept_ICs_Per_Rec_Period(curr_file) = file_proc_info.ica_stats.Mean_Artifact_Probability_of_Kept_ICs_Per_Rec_Period;
        ICA_report_table.Median_Artifact_Probability_of_Kept_ICs_Per_Rec_Period(curr_file) =  file_proc_info.ica_stats.Median_Artifact_Probability_of_Kept_ICs_Per_Rec_Period;
    end
    clearvars -except grp_proc_info curr_file src_dir ICA_report_table
end

writetable(ICA_report_table, ['ICA_Report_Table ',grp_proc_info.beapp_curr_run_tag,'_after_initial.csv']);
clear grp_proc_info.