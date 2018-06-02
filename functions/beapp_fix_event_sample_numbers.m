%% fix event sample numbers for files with offsets

% user inputs
src_dir = 'B:\ISP_BEAPRun20170817_auditory\12mo Data\detrend_LGD_task_power_10_5_17';
out_dir = 'B:\ISP_BEAPRun20170817_auditory\12mo Data\detrend_LGD_task_power_10_5_17';

cd (src_dir)
flist = dir('*.mat');
flist = {flist.name};

for curr_file=1:length(flist)
    
    cd(src_dir);
    
    if exist(strcat(src_dir,filesep,flist{curr_file}),'file')
        
        load(flist{curr_file},'eeg','file_proc_info');
        
        for curr_epoch = 1:size(eeg,2)
            
            if isfield(file_proc_info,'evt_info')
                if ~isempty(file_proc_info.evt_info{curr_epoch})
                    for curr_event = 1:length(file_proc_info.evt_info{curr_epoch})
                        file_proc_info.evt_info{curr_epoch}(curr_event).evt_times_samp_rel = double(time2samples(file_proc_info.evt_info{curr_epoch}(curr_event).evt_times_micros_rel,...
                            file_proc_info.beapp_srate,6,'round')) + file_proc_info.src_file_offset_in_ms *(file_proc_info.beapp_srate/1000);
                    end
                end
            end
        end
    end
    
    cd (out_dir);
    save(file_proc_info.beapp_fname{1},'eeg','file_proc_info');
    clearvars -except  curr_file src_dir out_dir flist
end

