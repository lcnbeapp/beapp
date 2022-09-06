function file_proc_info = update_file_proc_info_posthappe_er(grp_proc_info_in,file_proc_info,dataQCTab,params,eegByTags,chan_info)
    file_proc_info.evt_seg_win_evt_ind = [];
    counter = 1;
    while isempty(file_proc_info.evt_seg_win_evt_ind)
        try
            
file_proc_info.evt_seg_win_evt_ind = find(eegByTags{1,counter}.times == 0);
        catch
            counter=counter+1;
            if counter > length(eegByTags)
                file_proc_info.evt_seg_win_evt_ind = ['No data in eegByTags'];
                break
            end
            continue
        end
    end
file_proc_info.grp_wide_possible_cond_names_at_segmentation = unique(grp_proc_info_in.beapp_event_eprime_values.condition_names,'stable');        % .net_happe_additional_channs_lbls
try
file_proc_info.beapp_bad_chans = dataQCTab(1).dataQC(find(strcmp({dataQCTab.dataQCnames}, 'Bad_Chan_IDs')));
catch
    disp('couldnt split params')
end
file_proc_info.beapp_nchans_used = length(params.chans.IDs);
try
    file_proc_info.beapp_indx = {1:size(eegByTags{1,1}.data,1)}; % indices for electrodes being used for analysis at current time
catch
end
file_proc_info.net_vstruct = chan_info;
if  params.downsample>0
    file_proc_info.beapp_srate = params.downsample;
else
    file_proc_info.beapp_srate = eegByTags{1,counter}.srate; %will be same sampling rate for each condition, pulls from first
end
%% create and populate evt_conditions_being_analyzed
if ~grp_proc_info_in.beapp_event_use_tags_only 
    [file_proc_info.evt_info,file_proc_info.evt_conditions_being_analyzed,~] =...
        beapp_extract_condition_labels(file_proc_info.beapp_fname{1},file_proc_info.src_data_type,...
        file_proc_info.evt_header_tag_information,file_proc_info.evt_info,...
        grp_proc_info_in.beapp_event_eprime_values,grp_proc_info_in.beapp_event_code_onset_strs);
else
    [file_proc_info.evt_info,file_proc_info.evt_conditions_being_analyzed,~] = beapp_extract_conditions_tags_only ...
        (grp_proc_info_in.beapp_event_code_onset_strs , file_proc_info.evt_info, grp_proc_info_in.beapp_event_eprime_values,file_proc_info.beapp_fname{1});
end

if grp_proc_info_in.src_data_type == 1
    iterator = 1;
    file_proc_info.evt_conditions_being_analyzed = table;
else
    iterator = size(file_proc_info.evt_conditions_being_analyzed,1);
end

for condition_idx = 1:iterator
    if grp_proc_info_in.src_data_type == 1
        cond_phrase = '_';
    else
        cond_phrase = strcat('_',file_proc_info.evt_conditions_being_analyzed.Condition_Name(condition_idx),'_');
    end
    file_proc_info.evt_conditions_being_analyzed.Num_Segs_Pre_Rej(condition_idx) = cell2mat(dataQCTab(1).dataQC(find(strcmp({dataQCTab.dataQCnames},char(strcat('Number',cond_phrase,'Segs_Pre-Seg_Rej'))))));
    file_proc_info.evt_conditions_being_analyzed.Num_Segs_Post_Rej(condition_idx) = cell2mat(dataQCTab(1).dataQC(find(strcmp({dataQCTab.dataQCnames},char(strcat('Number',cond_phrase,'Segs_Post-Seg_Rej'))))));
end

