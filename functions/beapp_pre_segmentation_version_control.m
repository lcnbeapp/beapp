% version control for BETA testers BEAPP 4.0

function file_proc_info = beapp_pre_segmentation_version_control (file_proc_info)

file_proc_info.beapp_nchans_used = cellfun(@length,file_proc_info.beapp_indx,'UniformOutput',1)';

if ~isfield(file_proc_info, 'evt_header_tag_information')
    file_proc_info.evt_header_tag_information = [];
end

[~,~,src_file_ext] =fileparts(file_proc_info.src_fname{1});

if isfield(file_proc_info,'evt_info') && isequal('.mff',src_file_ext)
    
    % fix event sample numbers (offset calculations were off in previous
    % versions of mff reader)
    for curr_epoch = 1:size(file_proc_info.evt_info,2)
        if ~isempty(file_proc_info.evt_info{curr_epoch})
            for curr_event = 1:length(file_proc_info.evt_info{curr_epoch})
                file_proc_info.evt_info{curr_epoch}(curr_event).evt_times_samp_rel = round(double(time2samples(file_proc_info.evt_info{curr_epoch}(curr_event).evt_times_micros_rel,...
                    file_proc_info.beapp_srate,6,'round')) + round(file_proc_info.src_file_offset_in_ms *(file_proc_info.beapp_srate/1000))+1);
            end
        end
    end
end