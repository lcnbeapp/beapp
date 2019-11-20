%% beapp_calc_comod: takes a signal (eeg data section) and generates a PAC comodulogram

function [comodulogram, result_z_scores, result_surr_max, phase_bins, amp_dist, shifts, phase_dist] = beapp_calc_comod(signal,srate,low_fq_range,high_fq_range,...
    method,low_fq_width,high_fq_width,low_fq_res,high_fq_res,calc_zscores,compute_shifts,shifts)
signal = py.numpy.array(signal);
%set settings for pactools
michaelsaysso = 1;
if michaelsaysso == 1
    curr_results = NaN(size(high_fq_range,2),size(low_fq_range,2));
    result_z_scores =  NaN(size(high_fq_range,2),size(low_fq_range,2));
    if calc_zscores
        amp_dist = NaN(size(high_fq_range,2),size(low_fq_range,2),18,201);
    else
        amp_dist = NaN(size(high_fq_range,2),size(low_fq_range,2),18);
    end
    comod_filter = 1;
    for lf = 1:size(low_fq_range,2)
        for hf = 1:size(high_fq_range,2)
            estimator = py.pactools.Comodulogram(srate,low_fq_range(lf));
            estimator.progress_bar = 0; %set to 0 cause it's broken
            estimator.method = py.str(method);
            estimator.high_fq_range = high_fq_range(hf);
            estimator.low_fq_width = py.float(low_fq_width);         
            if comod_filter
                hf_low = high_fq_range(hf) - 2;
                hf_high = high_fq_range(hf)+low_fq_range(lf);
                estimator.high_fq_width = hf_high - hf_low;
                estimator.high_fq_range = hf_low + (hf_high - hf_low)/2;
            else
                estimator.high_fq_width = py.float(high_fq_width);
            end
            if calc_zscores
%                 estimator.compute_shifts = compute_shifts;
%                 if ~compute_shifts
%                     %estimator.shifts_ = shifts;
%                 end

                estimator.compute_shifts = 1;
                estimator.n_surrogates = py.int(200);
                estimator.minimum_shift = 0.1;
            end
            fit = estimator.fit(signal);
%             if compute_shifts
%                 shifts = fit.shifts_;
%             end
            %shifts = load('E:\Datasets\ISP_PAC_Runs\shifts.mat');
%             if ~calc_zscores
%                 curr_results(hf,lf) = double(py.array.array('d',py.numpy.nditer(fit.comod_)));
%             end
            phase_bins = double(py.array.array('d',py.numpy.nditer(fit.phase_bins)));
            phase_dist = phase_bins;
            %phase_bins = NaN;
            %amp_dist = NaN(1,18);
            %comodulogram = reshape(curr_results,[high_fq_res low_fq_res]); 
            if calc_zscores
                allamps = double(py.array.array('d',py.numpy.nditer(fit.amp_dist)));
                amp_dist(hf,lf,:,:) = reshape(allamps,[18 201]);
                %result_z_scores(hf,lf) = double(py.array.array('d',py.numpy.nditer(fit.comod_z_score_))); 
                %result_z_scores = reshape(result_z_scores,[high_fq_res low_fq_res]);
                %result_surr_max = double(py.array.array('d',py.numpy.nditer(fit.surrogate_max_)));
                %result_surr_max = reshape(result_surr_max,[high_fq_res low_fq_res]);
            else 
                calc_btwn_chans = 1;
                if calc_btwn_chans
                    phase_dist = double(py.array.array('d',py.numpy.nditer(fit.phase)));
                    amps = double(py.array.array('d',py.numpy.nditer(fit.amp)));
                    phase_binned = discretize(phase_dist,18);
                     for b=1:18
                        selection = amps(phase_binned==b);
                        amplitude_dist(b) = mean(selection);
                     end
                end
                amp_dist(hf,lf,:) = double(py.array.array('d',py.numpy.nditer(fit.amp_dist)));
                %subtle differences between the amp_dist I make and the one
                %returned by pactools...
                divergence_kl = sum(amp_dist(hf,lf,:) .* log(amp_dist(hf,lf,:) * 18));
                curr_results(hf,lf) = divergence_kl / log(18);
            end
            result_surr_max = NaN(1,200);
        end
    end
    comodulogram = curr_results;
elseif michaelsaysso == 0
    estimator = py.pactools.Comodulogram(srate,low_fq_range); 
    estimator.high_fq_range = high_fq_range;
    estimator.progress_bar = 0; %set to 0 cause it's broken
    estimator.method = py.str(method);
    %estimator.n_jobs = py.int(2); %temp for super comp
    estimator.low_fq_width = py.float(low_fq_width);
    if calc_zscores
        estimator.n_surrogates = py.int(200);
    end
    %estimator.ax_special =  py.matplotlib.pyplot.plot(); %TEMP
    estimator.high_fq_width = py.float(high_fq_width); %TEMP:
    %let pactools set
    fit = estimator.fit(signal);
    curr_results = double(py.array.array('d',py.numpy.nditer(fit.comod_)));
    phase_bins = double(py.array.array('d',py.numpy.nditer(fit.phase_bins)));
    %phase_bins = NaN;
    %amp_dist = NaN(1,18);
    amp_dist = double(py.array.array('d',py.numpy.nditer(fit.amp_dist)));
    comodulogram = reshape(curr_results,[high_fq_res low_fq_res]); 
    if calc_zscores
        result_z_scores = double(py.array.array('d',py.numpy.nditer(fit.comod_z_score_))); 
        result_z_scores = reshape(result_z_scores,[high_fq_res low_fq_res]);
        result_surr_max = double(py.array.array('d',py.numpy.nditer(fit.surrogate_max_)));
        %result_surr_max = reshape(result_surr_max,[high_fq_res low_fq_res]);
    else 
        result_z_scores = NaN(size(comodulogram,1),size(comodulogram,2));
        result_surr_max = NaN(1,200);
    end
    
    %collect phase dist, amp dist of channels
elseif michaelsaysso == 2
    
    estimator = py.pactools.Comodulogram(srate,low_fq_range); 
    estimator.high_fq_range = high_fq_range;
    estimator.progress_bar = 0; %set to 0 cause it's broken
    estimator.method = py.str(method);
    %estimator.n_jobs = py.int(2); %temp for super comp
    estimator.low_fq_width = py.float(low_fq_width);
    if calc_zscores
        estimator.n_surrogates = py.int(200);
    end
    %estimator.ax_special =  py.matplotlib.pyplot.plot(); %TEMP
    estimator.high_fq_width = py.float(high_fq_width); %TEMP:
    %let pactools set
    fit = estimator.fit(signal);
    %curr_results = double(py.array.array('d',py.numpy.nditer(fit.comod_)));
    phase_bins = double(py.array.array('d',py.numpy.nditer(fit.phase_bins)));
    %phase_bins = NaN;
    %amp_dist = NaN(1,18);
    amp_dist = double(py.array.array('d',py.numpy.nditer(fit.amp_dist)));
    amps = double(py.array.array('d',py.numpy.nditer(fit.amp)));
    % = reshape(curr_results,[high_fq_res low_fq_res]); 
    phase_dist = double(py.array.array('d',py.numpy.nditer(fit.phase)));
    %procedure from pactools:
    %digitize phase dist 
    %then  for b in np.unique(phase_preprocessed):
     %       selection = amplitude[phase_preprocessed == b]
     %       amplitude_dist[b] = np.mean(selection)
     %my attempt to do things myself...doesn't replicate 
     %%THE AMPLITUDE DIST HERE IS ALL LF AMPLITUDE DISTS APPENDED
     %%TOGETHER...NEED TO CALC ONE AT A TIME
     phase_binned = discretize(phase_dist,18);
     for b=1:18
        selection = amp_dist(phase_binned==b);
        amplitude_dist(b) = mean(selection);
     end
     
end
    

% curr_amp = double(py.array.array('d',py.numpy.nditer(fit.amp)));
% curr_phase = double(py.array.array('d',py.numpy.nditer(fit.phase)));
% rounded_phase = round(curr_phase,2);
% rounded_amp = NaN(1000,size(phase_range,2));
% curr_chan_phase_amp(seg,:) = nanmean(rounded_amp,1);

