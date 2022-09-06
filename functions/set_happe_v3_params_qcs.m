function [qual_control,params] = set_happe_v3_params_qcs(grp_proc_info_in)


if ~isempty(grp_proc_info_in.HAPPE_ER_parameters_file_location{1,1}) && ~exist(grp_proc_info_in.HAPPE_ER_parameters_file_location{1,1})
    error('Cannot find HAPPE+ER Parameter file at given path, please check path in beapp_set_input_file_locations')
elseif isempty(grp_proc_info_in.HAPPE_ER_parameters_file_location{1,1})
        grp_proc_info_in =beapp_translate_to_happe_inputs_clean(grp_proc_info_in);% beapp_create_happe_params(grp_proc_info_in);
end
load(grp_proc_info_in.HAPPE_ER_parameters_file_location{1,1})

%% INITIALIZE QUALITY REPORT METRICS
fprintf('Initializing report metrics...\n') ;
% DATA QUALITY METRICS: create a variable holding all the names of each
% metric and a variable to hold the metrics for each file.
dataQCnames = {'File_Length_in_Seconds', 'Number_User-Selected_Chans', ...
    'Number_Good_Chans_Selected', 'Percent_Good_Chans_Selected', 'Bad_Chan_IDs', ...
    'Percent_Var_Retained_Post-Wav', 'Number_ICs_Rej', 'Percent_ICs_Rej', ...
    'Chans_Interpolated_per_Seg', 'Number_Segs_Pre-Seg_Rej', ...
    'Number_Segs_Post-Seg_Rej', 'Percent_Segs_Post-Seg_Rej'} ;
%dataQC = cell(length(FileNames), length(dataQCnames)) ;
% If processing for tasks, create an additional variable to hold specific
% data metrics for each onset tag.
if params.paradigm.task
  %  dataQC_task = cell(length(FileNames), length(params.paradigm.onsetTags)*3) ;
    dataQCnames_task = cell(1, length(params.paradigm.onsetTags)*3) ;
    for i=1:size(params.paradigm.onsetTags,2)
        dataQCnames_task{i*3-2} = ['Number_' params.paradigm.onsetTags{i} ...
            '_Segs_Pre-Seg_Rej'] ;
        dataQCnames_task{i*3-1} = ['Number_' params.paradigm.onsetTags{i} ...
            '_Segs_Post-Seg_Rej'] ;
        dataQCnames_task{i*3} = ['Percent_' params.paradigm.onsetTags{i} ...
            '_Segs_Post-Seg_Rej'] ;
    end
    
    % If grouping any tags by condition, create additional variable to hold
    % specific data metrics for each condition.
    if params.paradigm.conds.on
      %  dataQC_conds = cell(length(FileNames), ...
         %   size(params.paradigm.conds.groups,1)*3) ;
        dataQCnames_conds = cell(1, size(params.paradigm.conds.groups,1)*3) ;
        for i = 1:size(params.paradigm.conds.groups,1)
            dataQCnames_conds{i*3-2} = ['Number_' params.paradigm.conds.groups{i, ...
                1} '_Segs_Pre-Seg_Rej'] ;
            dataQCnames_conds{i*3-1} = ['Number_' params.paradigm.conds.groups{i, ...
                1} '_Segs_Post-Seg_Rej'] ;
            dataQCnames_conds{i*3} = ['Percent_' params.paradigm.conds.groups{i, ...
                1} '_Segs_Post-Seg_Rej'] ;
        end
    end
end

 if params.paradigm.task && size(params.paradigm.onsetTags,2) > 1
        dataQCnames = [dataQCnames dataQCnames_task] ;
      %  dataQC = [dataQC dataQC_task] ;
        if params.paradigm.conds.on
            dataQCnames = [dataQCnames dataQCnames_conds] ;
          %  dataQC = [dataQC dataQC_conds] ;
        end
 end
%% loop through files
qual_control=struct('lnMean',[],'wavMean',[],'dataQC',[],'dataQCnames',dataQCnames);
