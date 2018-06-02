% version of a function taken from the REST toolbox to correspond with BEAPP format:
% The REST Toolbox:
%  Li Dong*, Fali Li, Qiang Liu, Xin Wen, Yongxiu Lai, Peng Xu and Dezhong Yao*.
% MATLAB Toolboxes for Reference Electrode Standardization Technique (REST) of Scalp EEG.
% Frontiers in Neuroscience, 2017:11(601).

function [leads] = load_REST_lead_matrices_and_create_gs(grp_proc_info_in)

load(grp_proc_info_in.ref_net_library_options);

for curr_net = 1:length(grp_proc_info_in.src_unique_nets)
    
    get_net_row_ind = find(ismember(net_library_options.Net_Full_Name,grp_proc_info_in.src_unique_nets(curr_net)));
    sensor_layout_short_name = net_library_options.Net_Variable_Name{get_net_row_ind};
    
    if ~exist([grp_proc_info_in.ref_net_library_dir,...
            filesep, 'REST_lead_field_library' filesep sensor_layout_short_name '_REST_lead_field.dat'],'file')
        
       disp(['Creating lead matrix for layout:' net_library_options.Net_Full_Name{get_net_row_ind}]);
        beapp_create_REST_lead_matrix(grp_proc_info_in.ref_net_library_dir,...
            grp_proc_info_in.src_unique_net_vstructs{curr_net}, sensor_layout_short_name,grp_proc_info_in.src_unique_nets{curr_net});
    end
    
    leads{curr_net}= load([grp_proc_info_in.ref_net_library_dir,...
            filesep, 'REST_lead_field_library' filesep sensor_layout_short_name '_REST_lead_field.dat']);
end