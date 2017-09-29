%% this functionality is not yet supported and should not be used by most users
% will eventually align segment information from hand edited files that are
% exported as segments with continuous recordings

function eeg_w = align_segment_info_across_src_files (eeg,file_proc_info_in,seg_info_dir)
 
 subID = strsplit(file_proc_info_in.beapp_fname{1},'.');
 subID = subID{1};
 
 cd(seg_info_dir)
 
 seg_flist = dir('*.mat');
 seg_flist = {seg_flist.name};

 file_inda = strfind(seg_flist,subID);
 file_ind = find(not(cellfun('isempty', file_inda)));
 
 load(seg_flist{file_ind});
 
 