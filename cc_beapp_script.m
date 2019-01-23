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