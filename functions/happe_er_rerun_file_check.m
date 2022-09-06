
function [src_dir] = happe_er_rerun_file_check(happe_er_reprocessing,src_dir_base,dest_dir_base,fname_all)

if happe_er_reprocessing == 0
    src_dir = src_dir_base;
elseif happe_er_reprocessing == 1
        %% copy file_proc_infos 
    if ~isdir([dest_dir_base{1,1} filesep '0 - rerun_file_proc_infos'])
        mkdir([dest_dir_base{1,1} filesep '0 - rerun_file_proc_infos'])
    end
    for ii = 1:length(fname_all)
        load([src_dir_base{1,1} filesep fname_all{1,ii}],'file_proc_info')
        save([dest_dir_base{1,1} filesep '0 - rerun_file_proc_infos' filesep strcat(fname_all{1,ii}(1:end-4),'file_info.mat')],'file_proc_info')
        clear file_proc_info
    end
    %% copy necessary files to load for rerun
    folder_key = {'1 - intermediate_processing', '_filtered_lnreduced'; '2 - wavelet_cleaned_continuous','_wavclean' };
    for folder = 1:size(folder_key,1)
    src_dir_clean = {dir([src_dir_base{1,1} filesep folder_key{folder,1} filesep strcat('*',folder_key{folder,2},'.set*')]).name};
    dest_dir_clean = {dir([dest_dir_base{1,1} filesep folder_key{folder,1} filesep '*.set*']).name};
    temp_files_to_be_copied =src_dir_clean(~ismember(src_dir_clean, dest_dir_clean)); %vector of 1s and 0s where 1 indicates the wavelet cleaned files are in both dest and src and 0 indicates in src but not dest
    if ~isempty(temp_files_to_be_copied)
        FilesToBeCopied = ismember(cellfun(@(v)strrep(v,'.mat','.set'),fname_all,'UniformOutput',false),cellfun(@(v)strrep(v,folder_key{folder,2},''),temp_files_to_be_copied,'UniformOutput',false));
    else
        FilesToBeCopied = [];
    end
    src_dir = dest_dir_base;
    if sum(FilesToBeCopied) > 0
        addpath(genpath([src_dir_base{1,1} filesep folder_key{folder,1}]))
    for ii = 1:length(fname_all)
        if FilesToBeCopied(ii)
            copyfile([src_dir_base{1,1} filesep folder_key{folder,1} filesep strcat(fname_all{1,ii}(1:end-4),folder_key{folder,2},'.set')],[dest_dir_base{1,1} filesep folder_key{folder,1} filesep strcat(fname_all{1,ii}(1:end-4),folder_key{folder,2},'.set')])
            copyfile([src_dir_base{1,1} filesep folder_key{folder,1} filesep strcat(fname_all{1,ii}(1:end-4),folder_key{folder,2},'.fdt')],[dest_dir_base{1,1} filesep folder_key{folder,1} filesep strcat(fname_all{1,ii}(1:end-4),folder_key{folder,2},'.fdt')])
        end 
    end
    end
    end
else
    error(strcat('happe_er_reprocessing is set to', happe_er_reprocessing,'Set grp_proc_info.happe_er_reprocessing to either 1 or 0'))
end
end