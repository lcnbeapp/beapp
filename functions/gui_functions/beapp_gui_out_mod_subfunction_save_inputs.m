function grp_proc_info = beapp_gui_out_mod_subfunction_save_inputs (current_sub_panel,resstruct_out_mod_settings,...
    resstruct_adv_out_mod_settings,strhalt_adv,grp_proc_info)

switch current_sub_panel
      case 'out_mod_general'
          
          % grab preproc module indicies
          out_mod_inds = find(ismember(grp_proc_info.beapp_toggle_mods.Module_Output_Type,'out'));
          
          % save module on settings
          grp_proc_info.beapp_toggle_mods.Module_On(out_mod_inds) = ...
              logical(cell2mat(resstruct_out_mod_settings.out_mod_sel_table.data(:,2)));
          
          % save module export on settings
          grp_proc_info.beapp_toggle_mods.Module_Export_On(out_mod_inds) = ...
              logical(cell2mat(resstruct_out_mod_settings.out_mod_sel_table.data(:,3)));
          
       % save band names and bound frequencies
           non_empty_band_inds = cellfun(@ (x) (~isempty(x)),...
            resstruct_out_mod_settings.out_mod_band_table.data(:,1),'UniformOutput',1);
        
        if any( non_empty_band_inds)
            grp_proc_info.bw_name = resstruct_out_mod_settings.out_mod_band_table.data(non_empty_band_inds,1)';
            tmp_bw (:,1) = cell2mat(resstruct_out_mod_settings.out_mod_band_table.data(non_empty_band_inds,2));
            tmp_bw (:,2) = cell2mat(resstruct_out_mod_settings.out_mod_band_table.data(non_empty_band_inds,3));
            grp_proc_info.bw = tmp_bw;
        else
            warndlg('No bands selected for analysis');
        end
        
        % save total freqs 
         tmp_total_freqs=  eval(resstruct_out_mod_settings.bw_total_freqs_resp);
         if isa(tmp_total_freqs,'double') && ~isempty(tmp_total_freqs)
            grp_proc_info.bw_total_freqs =tmp_total_freqs;
         else
             disp_str_total_freqs_warn = beapp_arr_to_colon_note_string (grp_proc_info.bw_total_freqs);
             warndlg(['Value entered for total power frequencies is invalid, please check. BEAPP will use previous value ' disp_str_total_freqs_warn ]);
         end
         
         if grp_proc_info.src_data_type == 2
             
             seg_analysis_win_start = str2double(resstruct_out_mod_settings.evt_analysis_win_start);
            if isnan(seg_analysis_win_start)
                warndlg(['Segment analysis start time relative to event marker (in seconds) must be a number.'...
                    'BEAPP will use previously set segment analysis start time: '  num2str(grp_proc_info.evt_seg_win_start)]);
            else
               grp_proc_info.evt_analysis_win_start = seg_analysis_win_start;
            end
            
            seg_analysis_win_end = str2double(resstruct_out_mod_settings.evt_analysis_win_end);
            if isnan(seg_analysis_win_end)
                warndlg(['Segment analysis end time relative to event marker (in seconds) must be a number.'...
                    'BEAPP will use previously set segment analysis end time: ' num2str(grp_proc_info.evt_seg_win_end)]);
            else
                grp_proc_info.evt_analysis_win_end = seg_analysis_win_end;
            end
         end
         
    case 'psd'
        % save psd window type 0=rectangular window, 1=hanning window, 2=multitaper (recomended 2 seconds or longer)
        grp_proc_info.psd_win_typ = resstruct_out_mod_settings.psd_win_typ -1;
        
        % save psd interpolation type  1 none, 2 linear, 3 nearest neighbor, 4 piecewise cubic spline  
        grp_proc_info.psd_interp_typ = resstruct_out_mod_settings.psd_interp_typ;
        
         %flags the export data to xls report option on
        grp_proc_info.beapp_toggle_mods{'psd','Module_Xls_Out_On'} = resstruct_out_mod_settings.psd_xls_rep_on;  
        
    case 'itpc'
        tmp_win_size = str2double(resstruct_out_mod_settings.itpc_win_size);
        if isnan(tmp_win_size) || isempty(tmp_win_size) || tmp_win_size<0
             warndlg( ['ITPC window size must be a number greater than 0. BEAPP will use previously entered value: '  num2str(grp_proc_info.beapp_itpc_params.win_size)]);
        else 
            %the win_size (in seconds) to calculate ERSP and ITPC from the ERPs of the composed dataset (e.g. should result in a number of samples an integer and divide trials equaly ex: 10)
             grp_proc_info.beapp_itpc_params.win_size=  tmp_win_size; 
        end
        
        %flags the export data to xls report option on
        grp_proc_info.beapp_toggle_mods{'itpc','Module_Xls_Out_On'} = resstruct_out_mod_settings.itpc_xls_rep_on;  
        
    otherwise 
        warndlg (['Output module ' current_panel ' is not yet available in BEAPP']);
        
end
if ~isequal(strhalt_adv,'')
    grp_proc_info = beapp_gui_adv_out_mod_settings_save_inputs(current_sub_panel,resstruct_adv_out_mod_settings,grp_proc_info);
end
end