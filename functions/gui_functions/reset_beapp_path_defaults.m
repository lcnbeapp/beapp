% reset beapp ref paths on template load in case the computer has changed 
function grp_proc_info = reset_beapp_path_defaults (grp_proc_info)

 %% version numbers for BEAPP and packages
grp_proc_info.beapp_ver={'BEAPP_v4_1'};
grp_proc_info.eeglab_ver = {'eeglab14_1_2b'};
grp_proc_info.fieldtrip_ver = {'fieldtrip-20160917'};
grp_proc_info.beapp_root_dir = {fileparts(which('set_beapp_def.m'))}; %sets the directory to the BEAPP code assuming that it is in same directory as set_beapp_def

%% paths for packages and tables
grp_proc_info.beapp_ft_pname={[grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,grp_proc_info.eeglab_ver{1},filesep,grp_proc_info.fieldtrip_ver{1}]}; 
grp_proc_info.beapp_format_mff_jar_lib = [grp_proc_info.beapp_root_dir{1} filesep 'reference_data' filesep 'MFF-1.2.jar']; %the java class file needed when reading mff source files
grp_proc_info.ref_net_library_dir=[grp_proc_info.beapp_root_dir{1},filesep,'reference_data',filesep,'net_library'];
grp_proc_info.ref_net_library_options = ([grp_proc_info.beapp_root_dir{1},filesep,'reference_data',filesep,'net_library_options.mat']);
grp_proc_info.ref_eeglab_loc_dir = [grp_proc_info.beapp_root_dir{1},filesep, 'Packages',filesep,grp_proc_info.eeglab_ver{1},filesep, 'sample_locs'];
grp_proc_info.ref_def_template_folder = [fileparts(mfilename('fullpath')) filesep, 'run_templates'];
grp_proc_info.rerun_file_info_table =[grp_proc_info.beapp_root_dir{1} filesep 'user_inputs',filesep,'rerun_fselect_table.mat'];
