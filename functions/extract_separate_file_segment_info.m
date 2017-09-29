%% this functionality is not yet supported and should not be used by most users
% will eventually align segment information from hand edited files that are
% exported as segments with continuous recordings

function extract_separate_file_segment_info(grp_proc_info_in)

%% set path, generate filelist
if (exist(grp_proc_info_in.beapp_format_mff_jar_lib,'file')~=2)
    error('EGI MFF JAR Library needed-- specify in proc_info');
end
javaaddpath(which(grp_proc_info_in.beapp_format_mff_jar_lib));

cd(grp_proc_info_in.seg_info_mff_src_dir{1});
mff_flist = dir('*.mff');
seg_info_src_flist = {mff_flist.name};
seg_info_beapp_flist = strrep(seg_info_src_flist, '.mff', '.mat');

seg_info_out_dir = [grp_proc_info_in.beapp_toggle_mods{'format','Module_Dir'}{1} filesep 'seg_info'];

if ~isdir(seg_info_out_dir)
    mkdir(seg_info_out_dir);
end

% extract events and eeg data for each file
for curr_file=1:length(seg_info_src_flist)
    
    curr_fname = seg_info_src_flist{curr_file};
    full_filepath=strcat(grp_proc_info_in.seg_info_mff_src_dir{1},filesep,curr_fname);
    cd(full_filepath)
    
    % get list of files containing signal using EGI API function
    curr_file_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_MFFFile, [], full_filepath);
    bin_flist = curr_file_obj.getSignalResourceList(false);
    
    % will need modification if more than one .bin file - not seen to date
    if length(bin_flist)>1
        error('Developer:more than one signal file, adjust script')
        % will also affect infoN file/ infoN_obj
    else
        
        %% read mff demographic data
        signal_string=char(bin_flist(1));
        signal_string=char(signal_string(2:end-1)); % in case need to change to loop
            % load demographic info, net, and eeg blocks

        signal_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Signal, signal_string, full_filepath);
        sig_blocks = signal_obj.getSignalBlocks();
        block_obj = sig_blocks.get(0);
        
        info_obj=mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Info, 'info.xml', full_filepath);
        mff_version=info_obj.getMFFVersion;
         if mff_version==0
            time_units_exp= 9;
        else
            time_units_exp=6;
        end

        record_time = info_obj.getRecordTime; 
        file_proc_info.beapp_srate = double(block_obj.signalFrequency(1));
        file_proc_info=read_mff_segment_info(full_filepath,file_proc_info,time_units_exp,record_time);
        %clear time_units_exp
    end
   
    segment_info = file_proc_info.seg_info;
    tasks = file_proc_info.seg_tasks;
    cd(seg_info_out_dir)
    
    split_fname = strsplit(curr_fname,'.');
    save([split_fname{1} '.mat'],'segment_info','tasks');
end
chk = 0;