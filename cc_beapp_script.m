function cc_beapp_script(file)
%For use on a computer cluster. Write your user inputs script then run. 
% Allows user to submit each individual file as its own job, which rapidly
% speeds things up.

%%
try
   cd beapp_dev %beapp_dev must be located in your 
   grp_proc_info = beapp_configure_settings;
   grp_proc_info.beapp_file_idx = file;
   grp_proc_info.beapp_run_per_file = 1;
   grp_proc_info.beapp_dir_warn_off = 1;
   beapp_main(grp_proc_info);    
catch my_error     
    my_error
    exit(1)
end
exit

grp_proc_info.beapp_ica_additional_chans_lbls{1} = [17,21,14,15,18,10,19,4,16];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [25,32,26,23,27,28,29,20,12];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [34,48,43,44,39,40,35,41,38];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [49,56,57,50,51,46,47,42,53];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [63,68,64,65,59,66,60,67,69];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [72,71,76,74,82,73,81,88];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [77,85,84,91,90,89,95,94,99];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [86,93,98,97,102,101,100,107,113];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [103,110,109,116,121,115,114,120,119];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [8,1,2,3,123,117,111,118,5];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [6,13,112,30,7,106,105];
grp_proc_info.beapp_ica_additional_chans_lbls{1} = [31,80,37,87,54,55,79,61,78];