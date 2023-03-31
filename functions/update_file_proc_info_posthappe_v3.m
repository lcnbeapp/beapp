function file_proc_info = update_file_proc_info_posthappe_v3(grp_proc_info_in,file_proc_info,dataQCTab,params,eegByTags,chan_info,curr_file,curr_rec_period)
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
file_proc_info.beapp_bad_chans{curr_rec_period} = dataQCTab(1).dataQC(find(strcmp({dataQCTab.dataQCnames}, 'Bad_Chan_IDs')));
catch
    disp('couldnt split params')
end
file_proc_info.beapp_nchans_used = length(params.chans.IDs);
net_vstruct_temp = chan_info; %commented out so that all channel
%info would be preservered, and unused channels will have nan in data
if length(file_proc_info.beapp_indx{curr_rec_period,1}) ~= size(chan_info,2)
    file_proc_info.beapp_indx{curr_rec_period,1} = cell2mat(cellfun(@(x) str2num(x(2:end)),{net_vstruct_temp.labels},'UniformOutput',false)); % indices for electrodes being used for analysis at current time
    if sum(contains({net_vstruct_temp.labels},'Cz'))==1
        file_proc_info.beapp_indx{curr_rec_period,1}= [file_proc_info.beapp_indx{curr_rec_period,1} 129];
    end
end

if  params.downsample>0
    file_proc_info.beapp_srate = params.downsample;
else
    file_proc_info.beapp_srate = eegByTags{1,counter}.srate; %will be same sampling rate for each condition, pulls from first
end

if grp_proc_info_in.happe_segment_on
%% create and populate evt_conditions_being_analyzedif happe segmentation was run
if grp_proc_info_in.src_data_type ==1 %standard baseline, not between tags
    file_proc_info.grp_wide_possible_cond_names_at_segmentation = {'baseline'};
    file_proc_info.evt_conditions_being_analyzed = table(NaN,{'baseline'},{''},...
        NaN(1,1),NaN(1,1),NaN(1,1),...
        'VariableNames',{'Eprime_Cell_Name','Condition_Name','Evt_Codes',...
        'Num_Segs_Pre_Rej','Num_Segs_Post_Rej','Good_Behav_Trials_Pre_Rej'});
    iterator = 1;

else
    if ~grp_proc_info_in.beapp_event_use_tags_only
        [file_proc_info.evt_info,file_proc_info.evt_conditions_being_analyzed,~] =...
            beapp_extract_condition_labels(file_proc_info.beapp_fname{1},file_proc_info.src_data_type,...
            file_proc_info.evt_header_tag_information,file_proc_info.evt_info,...
            grp_proc_info_in.beapp_event_eprime_values,grp_proc_info_in.beapp_event_code_onset_strs);
    else
        [file_proc_info.evt_info,file_proc_info.evt_conditions_being_analyzed,~] = beapp_extract_conditions_tags_only ...
            (grp_proc_info_in.beapp_event_code_onset_strs , file_proc_info.evt_info, grp_proc_info_in.beapp_event_eprime_values,file_proc_info.beapp_fname{1});
    end
    iterator = size(file_proc_info.evt_conditions_being_analyzed,1);

end


for condition_idx = 1:iterator
    if grp_proc_info_in.src_data_type == 1 
        cond_phrase = '_';
    else
        cond_phrase = strcat('_',file_proc_info.evt_conditions_being_analyzed.Condition_Name(condition_idx),'_');
    end
    try
    file_proc_info.evt_conditions_being_analyzed.Num_Segs_Pre_Rej(condition_idx) = cell2mat(dataQCTab(1).dataQC(curr_file,find(strcmp({dataQCTab.dataQCnames},char(strcat('Number',cond_phrase,'Segs_Pre-Seg_Rej'))))));
    file_proc_info.evt_conditions_being_analyzed.Num_Segs_Post_Rej(condition_idx) = cell2mat(dataQCTab(1).dataQC(curr_file,find(strcmp({dataQCTab.dataQCnames},char(strcat('Number',cond_phrase,'Segs_Post-Seg_Rej'))))));
    catch
        disp('couldnt update condition_tags')
    end

end

end

