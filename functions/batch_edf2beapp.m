% this function is entirely adapted from the Biosig toolbox for EEGLAB
% and from the following functions:
% pop_readedf() - Read a European data format .EDF data file.
% Author: Arnaud Delorme, CNL / Salk Institute, 13 March 2002
%
% pop_readbdf() - Read Biosemi 24-bit BDF file
% Author: Arnaud Delorme, CNL / Salk Institute, 13 March 2002

function grp_proc_info_in = batch_edf2beapp(grp_proc_info_in)

cd(grp_proc_info_in.src_dir{1});

flist = dir('*.edf');
grp_proc_info_in.src_fname_all = {flist.name};

for curr_file = 1:length(flist)
    
    fprintf('Reading EDF format using BIOSIG...\n');
    EDF = sopen(grp_proc_info_in.src_fname_all{curr_file}, 'r');
    [tmpdata EDF] = sread(EDF, Inf); tmpdata = tmpdata';
    eeg{1} = tmpdata;
    
    % save source file variables
    file_proc_info.src_fname=grp_proc_info_in.src_fname_all(curr_file);
    file_proc_info.src_srate=grp_proc_info_in.src_srate_all(curr_file);
    file_proc_info.src_nchan=size(eeg{1},1);
    file_proc_info.src_epoch_nsamps(1)=size(eeg{1},2);
    file_proc_info.src_num_epochs = 1;
    file_proc_info.src_linenoise =  grp_proc_info_in.src_linenoise_all(curr_file);
    file_proc_info.epoch_inds_to_process = [1]; % assumes mat files only have one recording period
    
    % save starting beapp file variables from source information
    file_proc_info.beapp_fname=grp_proc_info_in.beapp_fname_all(curr_file);
    file_proc_info.beapp_srate=file_proc_info.src_srate;
    file_proc_info.beapp_bad_chans ={[]};
    file_proc_info.beapp_nchans_used=[file_proc_info.src_nchan];
    file_proc_info.beapp_indx={1:size(eeg{1},1)}; % indices for electrodes being used for analysis at current time
    file_proc_info.beapp_num_epochs = 1; % assumes mat files only have one recording period
    
    %[EEG.data, header]  = readedf(filename);
    EEG.nbchan          = size(EEG.data,1);
    EEG.pnts            = size(EEG.data,2);
    EEG.trials          = 1;
    EEG.srate           = EDF.SampleRate(1);
    EEG.setname 		= 'EDF file';
    disp('Event information might be encoded in the last channel');
    disp('To extract these events, use menu File > Import event info > From data channel');
    EEG.filename        = filename;
    EEG.filepath        = '';
    EEG.xmin            = 0;
    EEG.chanlocs        = struct('labels', cellstr(EDF.Label));
    
    
    
end
