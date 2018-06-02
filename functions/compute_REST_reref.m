% version of the REST_Reference_Callback function taken from the REST toolbox to correspond with BEAPP format:
% The REST Toolbox:
%  Li Dong*, Fali Li, Qiang Liu, Xin Wen, Yongxiu Lai, Peng Xu and Dezhong Yao*.
% MATLAB Toolboxes for Reference Electrode Standardization Technique (REST) of Scalp EEG.
% Frontiers in Neuroscience, 2017:11(601).

function rest_ref_eeg_out = compute_REST_reref(eeg_arr_in,lead_field_matrix)

    % BEAPP: don't actually need to calculate G every time, but we do here since
    % our nets/ lead matrices can change from file to file
    if ~isempty(lead_field_matrix)
        if (size(lead_field_matrix, 2) == size(eeg_arr_in,1))
            G = lead_field_matrix;
            G = G';
            G_ave = mean(G);
            G_ave = G-repmat(G_ave,size(G,1),1);
            Ra = G*pinv(G_ave,0.05);   %the value 0.05 is for real data; for simulated data, it may be set as zero.

                try
                    Ref_data = [];
                    tmp_data = eeg_arr_in;
                    cur_ave = mean(tmp_data);
                    cur_var1 = tmp_data - repmat(cur_ave,size(tmp_data,1),1);
                    tmp_data = Ra * cur_var1;
                    tmp_data = cur_var1 + repmat(mean(tmp_data),size(tmp_data,1),1); % edit by Li Dong (2017.8.28)
                    % Vr = V_avg + AVG(V_0)
                   rest_ref_eeg_out = tmp_data;
                end
        else
            errordlg('Wrong Leadfield has been imported, please import the right Leadfield !!!','Error');
            return;
        end
    else
        errordlg('No Leadfield has been imported, please import Leadfield !!!','Error');
        return;
    end
end
