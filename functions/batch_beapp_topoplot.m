%% batch_beapp_topoplot(grp_proc_info)
%
%  a template for new modules in BEAPP
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

function grp_proc_info_in = batch_beapp_topoplot(grp_proc_info_in)

src_dir = find_input_dir('topoplot',grp_proc_info_in.beapp_toggle_mods);

for curr_file=1:length(grp_proc_info_in.beapp_fname_all)
  
    cd(src_dir{1});
    
      if exist(strcat(src_dir{1},filesep,grp_proc_info_in.beapp_fname_all{curr_file}),'file')
         tic;
         
         
        load(grp_proc_info_in.beapp_fname_all{curr_file});     
        for curr_condition = 1:size(eeg_wfp,1)
            for bw_idx = 1:size(grp_proc_info_in.bw,1)
                bw = grp_proc_info_in.bw(bw_idx,:);
                [x min_idx] = min(abs(f{curr_condition,1} - bw(1,1)));
                [y max_idx] = min(abs(f{curr_condition,1} - bw(1,2)));
                if ~exist('all_psd','var')
                    if length(grp_proc_info_in.src_unique_nets) < 2
                        all_psd = NaN(size(grp_proc_info_in.bw,1),length(file_proc_info.net_vstruct),length(grp_proc_info_in.beapp_fname_all));
                    else %use only 10_20s
                        all_psd = NaN(size(grp_proc_info_in.bw,1),18,length(grp_proc_info_in.beapp_fname_all));
                    end
                end
                if length(grp_proc_info_in.src_unique_nets) < 2
                    all_psd(bw_idx,:,curr_file) = nanmean(nanmean(eeg_wfp{curr_condition,1}(:,min_idx:max_idx,:),2),3);
                else
                    all_psd(bw_idx,:,curr_file) = nanmean(nanmean(eeg_wfp{curr_condition,1}(file_proc_info.net_10_20_elecs,min_idx:max_idx,:),2),3);
                end
                subplot(1,size(grp_proc_info_in.bw,1),bw_idx)
                topoplot(nanmean(nanmean(eeg_wfp{curr_condition,1}(:,min_idx:max_idx,:),2),3),file_proc_info.net_vstruct,'maplimits','maxmin','electrodes','on');
                title(grp_proc_info_in.bw_name{1,bw_idx})
                %cbar;
                
                
            end
        end
        
        %% save and update file history
        cd(grp_proc_info_in.beapp_toggle_mods{'topoplot','Module_Dir'}{1});
        
        savefig(strcat(file_proc_info.beapp_fname{1},'.fig'));
        close all
        
        if ~all(cellfun(@isempty,eeg_wfp))
            file_proc_info = beapp_prepare_to_save_file('topoplot',file_proc_info, grp_proc_info_in, src_dir{1});
           % save(file_proc_info.beapp_fname{1},'eeg_w','file_proc_info');
        end
        
        clearvars -except grp_proc_info_in src_dir curr_file all_psd file_proc_info
      end

end
if length(grp_proc_info_in.src_unique_nets) < 2
    for bw_idx = 1:size(grp_proc_info_in.bw,1)
        subplot(1,size(grp_proc_info_in.bw,1),bw_idx)
        topoplot(nanmean(all_psd(bw_idx,:,:),3),file_proc_info.net_vstruct,'maplimits','maxmin','electrodes','on');
        title(grp_proc_info_in.bw_name{1,bw_idx})
       % cbar;   
    end
    savefig('Group_Average.fig');
    close all
else
    %just plot 10_20s
    for bw_idx = 1:size(grp_proc_info_in.bw,1)
        subplot(1,size(grp_proc_info_in.bw,1),bw_idx)
        topoplot(nanmean(all_psd(bw_idx,:,:),3),file_proc_info.net_vstruct(file_proc_info.net_10_20_elecs),'maplimits','maxmin','electrodes','on');
        title(grp_proc_info_in.bw_name{1,bw_idx})
       % cbar;   
    end
    savefig('Group_Average.fig');
    close all
end
    
