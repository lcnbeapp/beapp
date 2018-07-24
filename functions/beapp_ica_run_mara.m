%%beapp_ica_run_mara 
%
% runs MARA toolbox in BEAPP ICA module
%
% Inputs:
% EEG_after_ICA: EEGLAB struct after ICA
% fname: filename, file_proc_info.beapp_fname{1}
% happe_plotting_on: if 1, happe/mara plotting on, forces user input for each file
% ica_report_struct : structure containing report values
% curr_rec_period: current recording period/epoch
%
% Outputs:
% EEG_out: EEGLAB struct after MARA
% skip_file: 1 if MARA rejected all components, skip this epoch
% ica_report_struct : structure containing report values
%
% MARA
% Irene Winkler, Stefan Haufe and Michael Tangermann. Automatic Classification of Artifactual
% ICA-Components for Artifact Removal in EEG Signals. Behavioral and Brain Functions, 7:30, 2011.
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
function [EEG_out,ica_report_struct,skip_file] = beapp_ica_run_mara (EEG_after_ICA,fname,happe_plotting_on,ica_report_struct,curr_rec_period)
skip_file = 0;

%use MARA to flag artifactual IComponents automatically if
%artifact probability > .5
[~,EEG_pst_mara,~] = processMARA (EEG_after_ICA,EEG_after_ICA,EEG_after_ICA, [0, 0, happe_plotting_on, happe_plotting_on, happe_plotting_on]);
EEG_pst_mara.reject.gcompreject = zeros(size(EEG_pst_mara.reject.gcompreject));
EEG_pst_mara.reject.gcompreject(EEG_pst_mara.reject.MARAinfo.posterior_artefactprob > 0.5) = 1;

%reject the ICs that MARA flagged as artifact
artifact_ICs=sort(find(EEG_pst_mara.reject.gcompreject == 1));
ICs_to_keep =find(EEG_pst_mara.reject.gcompreject == 0);
ICA_act = EEG_pst_mara.icaact;
ICA_winv = EEG_pst_mara.icawinv;

% if all ICs are marked artifact, skip file
diary on;
if isequal(artifact_ICs,1:EEG_pst_mara.nbchan)
    warning(['BEAPP: MARA rejected all components for file ' fname ', not saving file']);
    skip_file = 1;
    EEG_out = [];
else
    EEG_out= pop_subcomp(EEG_pst_mara, artifact_ICs, happe_plotting_on,0);
end

% save relevant reporting information
index_ICs_kept=(EEG_pst_mara.reject.MARAinfo.posterior_artefactprob < 0.5);
ica_report_struct.percent_ICs_rej_per_rec_period(curr_rec_period) = (length(artifact_ICs)/ica_report_struct.good_chans_per_rec_period(curr_rec_period));
ica_report_struct.mn_art_prob_per_rec_period (curr_rec_period) = mean(EEG_pst_mara.reject.MARAinfo.posterior_artefactprob(index_ICs_kept));
ica_report_struct.median_art_prob_per_rec_period (curr_rec_period) = median(EEG_pst_mara.reject.MARAinfo.posterior_artefactprob(index_ICs_kept));
[~, ica_report_struct.perc_var_post_wave_per_rec_period(curr_rec_period)] =compvar(EEG_pst_mara.data, ICA_act, ICA_winv, ICs_to_keep);