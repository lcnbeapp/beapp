% patch code to pull out behavioral coding information
% from BEAPP files retroactively, and stores them in a table (one for all
% files and conditions) in the out folder
% this information will eventually be included in BEAPP reporting
%
% src_dir is the string with the directory that contains the BEAPP source
% files of interest (ex. C:\my_src_dir\psd). Should be segment directory or
% an output directory
%
% condition_names is the cell array, equivalent to 
% what grp_proc_info.beapp_event_eprime_values.condition_names. Condition
% names used should be identical to those used during initial file
% segmentation (order doesn't matter). If set to '', function will
% use whatever conditions were selected during segmentation for the first
% file in the folder 

% example =  extract_num_attended_trials_pre_seg_rej
% ('C:\beapp_dev\U19_EEG\segment', {'Rest'});
% to use conditions in the first file for all:
% extract_num_attended_trials_pre_seg_rej('C:\beapp_dev\U19_EEG\segment', '');

function extract_num_attended_trials_pre_seg_rej (src_dir, condition_names)

cd (src_dir);
flist = dir('*.mat');
flist = {flist.name};

if ~strcmp(condition_names,'')
    
    output_table_cell = NaN(length(flist),length(condition_names)+1);
    output_table = array2table(output_table_cell);
    output_table.Properties.VariableNames = horzcat({'FileName'},strcat(condition_names,'_Num_Attended_Trials'));
    output_table.FileName = flist';
end

for curr_file =  1:length(flist)
    
    load(flist{curr_file},'file_proc_info');
    
    if strcmp (condition_names, '')
        condition_names = file_proc_info.grp_wide_possible_cond_names_at_segmentation;
        output_table_cell = NaN(length(flist),length(condition_names)+1);
        output_table = array2table(output_table_cell);
        output_table.Properties.VariableNames = horzcat({'FileName'},strcat(condition_names,'_Num_Attended_Trials'));
        output_table.FileName = flist';
    end
    
     evt_as_cell = cellfun(@(x) permute(squeeze(struct2cell(x)),[2 1]), file_proc_info.evt_info,'UniformOutput',0);
     stacked_evt_tags = vertcat(evt_as_cell{:});          
     behavioral_coding_column = find(ismember (fieldnames(file_proc_info.evt_info{1}),'behav_code'));
     type_column = find(ismember(fieldnames(file_proc_info.evt_info{1}),'type'));
      
     attended_trial_inds = find(cellfun(@(x) x==0,stacked_evt_tags(:,behavioral_coding_column)));
  
     for curr_condition = 1:length(condition_names)
         
         % indices of condition
         inds_cond = find(ismember(stacked_evt_tags(:,type_column),condition_names{curr_condition}));
         
         % number of good trials for this condition
         tot_att_for_cond_pre_rej = length(intersect(inds_cond,attended_trial_inds));
         
         % store in table
         output_table{curr_file, strcat(condition_names{curr_condition},'_Num_Attended_Trials')} = tot_att_for_cond_pre_rej;
     end 
     clear file_proc_info tot_att_for_cond_pre_rej inds_cond attended_trial_inds type_column behavioral_coding_column stacked_evt_tags...
         evt_as_cell
end

[modpath,mod_dir] = fileparts(src_dir);
outdir_str_split = strsplit (mod_dir,'_');
outdir_str_split = length(outdir_str_split{1});
run_tag = mod_dir(outdir_str_split +1 :end);

if ~isempty(run_tag)
    run_tag = ['_' run_tag];
end

outdir_path = [modpath filesep 'out' run_tag];

if ~isdir(outdir_path)
    mkdir(outdir_path);
end

cd(outdir_path);
writetable (output_table, ['All_Conditions_Num_Attended_Trials(Patch)' run_tag '.csv']);