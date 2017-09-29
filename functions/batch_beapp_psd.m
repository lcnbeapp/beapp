%% batch_beapp_psd (grp_proc_info)
% calculate psd for desired analysis window for baseline and event-tagged
% segments. generate .mat and excel report tables if user selected
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C) 2015, 2016, 2017
% Authors: AR Levin, AS Méndez Leal, LJ Gabard-Durnam, HM O'Leary
%
% This software is being distributed with the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU General
% Public License for more details.
%
% In no event shall Boston Children’s Hospital (BCH), the BCH Department of
% Neurology, the Laboratories of Cognitive Neuroscience (LCN), or software
% contributors to BEAPP be liable to any party for direct, indirect,
% special, incidental, or consequential damages, including lost profits,
% arising out of the use of this software and its documentation, even if
% Boston Children’s Hospital,the Laboratories of Cognitive Neuroscience,
% and software contributors have been advised of the possibility of such
% damage. Software and documentation is provided “as is.” Boston Children’s
% Hospital, the Laboratories of Cognitive Neuroscience, and software
% contributors are under no obligation to provide maintenance, support,
% updates, enhancements, or modifications.
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License (version 3) as
% published by the Free Software Foundation.
%
% You should receive a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function batch_beapp_psd(grp_proc_info_in)

src_dir = find_input_dir('psd',grp_proc_info_in.beapp_toggle_mods);
save_warn_as_error= warning('error', 'MATLAB:save:sizeTooBigForMATFile');
report_initialized = 0;

nstats =  grp_proc_info_in.beapp_xlsout_av_on +grp_proc_info_in.beapp_xlsout_sd_on;
ndtyps =  grp_proc_info_in.beapp_xlsout_raw_on + grp_proc_info_in.beapp_xlsout_norm_on;
ntransfs = grp_proc_info_in.beapp_xlsout_log_on+grp_proc_info_in.beapp_xlsout_log10_on+1;
ntabs=nstats*ndtyps*ntransfs;

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
    
    cd(src_dir{1});
    
    if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
        load(grp_proc_info_in.beapp_fname_all{curr_file},'eeg_w','file_proc_info');
        tic;
        
        if grp_proc_info_in.src_data_type ==2 || grp_proc_info_in.src_data_type ==3
            analysis_win_start = file_proc_info.evt_seg_win_evt_ind + floor((grp_proc_info_in.evt_analysis_win_start .* file_proc_info.beapp_srate));
            analysis_win_end = file_proc_info.evt_seg_win_evt_ind + floor((grp_proc_info_in.evt_analysis_win_end .* file_proc_info.beapp_srate))-1;
            
            % may be negative if analyzing window after event
            file_proc_info.evt_seg_win_evt_ind = file_proc_info.evt_seg_win_evt_ind-(analysis_win_start-1);
        end
        
        % collect file information for output report if user selected
        if grp_proc_info_in.beapp_toggle_mods{'psd','Module_Xls_Out_On'}
            if ~report_initialized
                [report_info,all_condition_labels,all_obsv_sizes,psd_report_values] = beapp_init_generic_analysis_report (grp_proc_info_in.beapp_fname_all,...
                    file_proc_info.grp_wide_possible_cond_names_at_segmentation,grp_proc_info_in.largest_nchan,(length(grp_proc_info_in.bw_name)+1),ntabs);
                report_initialized = 1;
            end
            
            [report_info,all_condition_labels,all_obsv_sizes] = beapp_add_row_generic_analysis_report(report_info,...
                all_condition_labels,all_obsv_sizes,curr_file,file_proc_info,eeg_w);
        end
        
        % calculate PSD using user selected window for each condition set
        for curr_condition = 1:size(eeg_w,1)
            
            if ~isempty(eeg_w{curr_condition,1})
                
                % analyze desired part of segment for event related data
                if grp_proc_info_in.src_data_type ==2
                    try
                        eeg_w{curr_condition,1} = eeg_w{curr_condition,1}(:,analysis_win_start: analysis_win_end,:);
                    catch err
                        if strcmp(err.identifier,'MATLAB:badsubscript')
                            error('BEAPP: analysis segment boundary selected falls outside boundaries used to segment data. Change inputs or re-segment');
                        end
                    end
                end
                
                [eeg_wfp{curr_condition,1}, eeg_wf{curr_condition,1},f{curr_condition,1}] = calc_psd_of_win_typ(grp_proc_info_in.psd_win_typ,...
                    eeg_w{curr_condition,1},file_proc_info.beapp_srate,grp_proc_info_in.psd_pmtm_alpha,grp_proc_info_in.psd_nfft);
                
                % interpolate if flagged on by user
                if grp_proc_info_in.psd_interp_typ>1
                    [eeg_wf{curr_condition,1},interp_f{curr_condition,1}] = permute_and_interp_eeg(eeg_wf{curr_condition,1},...
                        f{curr_condition,1},grp_proc_info_in.psd_interp_typ_name{grp_proc_info_in.psd_interp_typ});
                    
                    [eeg_wfp{curr_condition,1},interp_f{curr_condition,1}] = permute_and_interp_eeg(eeg_wfp{curr_condition,1},...
                        f{curr_condition,1},grp_proc_info_in.psd_interp_typ_name{grp_proc_info_in.psd_interp_typ});
                    f{curr_condition,1}= interp_f{curr_condition,1};
                end
                
            else
                eeg_wf{curr_condition,1}=[];
                eeg_wfp{curr_condition,1} = [];
                f {curr_condition,1}= [];
            end
            
            % calculate output statistics selected by user
            if ~isempty(eeg_wfp{curr_condition,1}) && grp_proc_info_in.beapp_toggle_mods{'psd','Module_Xls_Out_On'}
                psd_report_values{curr_condition,1}(curr_file,:,:) = beapp_calc_psd_output(grp_proc_info_in,file_proc_info,eeg_wfp{curr_condition,1},f{curr_condition,1},grp_proc_info_in.largest_nchan);
            end
        end
        
        if ~all(cellfun('isempty',eeg_wfp))
             file_proc_info = beapp_prepare_to_save_file('psd',file_proc_info, grp_proc_info_in, src_dir{1});
            try
                save(file_proc_info.beapp_fname{1},'eeg_wfp','f','file_proc_info');
            catch ME
                if  (strcmp(ME.identifier,'MATLAB:save:sizeTooBigForMATFile'))
                    save(file_proc_info.beapp_fname{1},'eeg_wfp','f','file_proc_info','-v7.3');
                    disp([file_proc_info.beapp_fname{1} ': file is too large to save with v6, saving using MAT-file v7.3 (may take longer)']);
                end
            end
            
        end
        clearvars -except grp_proc_info_in curr_file src_dir report_info ...
            psd_report_values save_warn_as_error all_condition_labels all_obsv_sizes report_initialized ntabs
    end
end
warning(save_warn_as_error);

if grp_proc_info_in.beapp_toggle_mods{'psd','Module_Xls_Out_On'}
    cd(grp_proc_info_in.beapp_toggle_mods{'psd','Module_Dir'}{1});
    mk_psd_report(grp_proc_info_in,report_info,psd_report_values, all_condition_labels, all_obsv_sizes);
end
