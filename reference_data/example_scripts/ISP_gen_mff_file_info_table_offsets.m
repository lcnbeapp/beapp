%% example script for mff_file_info_table generation
% only need grp_p


function ISP_gen_mff_file_info_table_offsets(grp_proc_info_in)

% set path, generate filelist
if (exist(grp_proc_info_in.beapp_format_mff_jar_lib,'file')~=2)
    error('EGI MFF JAR Library needed-- specify in proc_info');
end

javaaddpath(which(grp_proc_info_in.beapp_format_mff_jar_lib));
[ref_dir,~] = fileparts(grp_proc_info_in.beapp_format_mff_jar_lib);

addpath(genpath(ref_dir))

cd (grp_proc_info_in.src_dir{1});

flist = dir('*.mff');
flist = {flist.name}';
FileName = flist;
FileOffset = NaN(length(flist),1);

mff_file_info_table = table(FileName, FileOffset);
mff_file_info_table.Properties.VariableNames = {'FileName','FileOffset'};

for curr_file = 1: length(flist)
    full_filepath=strcat(grp_proc_info_in.src_dir{1},filesep,flist{curr_file});
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
        if  strcmp(signal_string,'[]')
            warning ([ flist{curr_file}' : file does not have a signalN.bin file, which contains the source EEG data. skipping']);
            continue;
        end
        signal_string=char(signal_string(2:end-1)); % in case need to change to loop
    end
    
    info_obj=mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Info, 'info.xml', full_filepath);
    tmp_signal_info.signal_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Signal, signal_string, full_filepath);
    sensor_layout_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_SensorLayout, ['sensorLayout.xml'], full_filepath);
    info_n_obj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_InfoN, ['info1.xml'], full_filepath); % this seems it could change, but we've never had this problem
    tmp_signal_info.sig_blocks = tmp_signal_info.signal_obj.getSignalBlocks();
    block_obj = tmp_signal_info.sig_blocks.get(0);
    
    mff_file_info_table.FileOffset(curr_file) = double(block_obj.signalFrequency(1));
    
    clearvars -except grp_proc_info_in mff_file_info_table curr_file flist
end
cd('C:\beapp_beta_ISP\user_inputs');
save('mff_file_info_table.mat','mff_file_info_table');