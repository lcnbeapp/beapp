%% beapp_calc_comod: takes a signal (eeg data section) and generates a PAC comodulogram

function [comodulogram, result_z_scores, result_surr_max] = beapp_calc_comod(signal,srate,low_fq_range,high_fq_range,method,low_fq_width,high_fq_width,low_fq_res,high_fq_res,calc_zscores)
signal = py.numpy.array(signal);
%set settings for pactools
estimator = py.pactools.Comodulogram(srate,low_fq_range); 
estimator.high_fq_range = high_fq_range;
estimator.progress_bar = 0; %set to 0 cause it's broken
estimator.method = py.str(method);
%estimator.n_jobs = py.int(2); %temp for super comp
estimator.low_fq_width = py.float(low_fq_width);
if calc_zscores
    estimator.n_surrogates = py.int(200);
end
% estimator.ax_special =  py.matplotlib.pyplot.plot(); %TEMP
estimator.high_fq_width = py.float(high_fq_width); %TEMP:
%let pactools set
fit = estimator.fit(signal);
curr_results = double(py.array.array('d',py.numpy.nditer(fit.comod_))); 
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
% curr_amp = double(py.array.array('d',py.numpy.nditer(fit.amp)));
% curr_phase = double(py.array.array('d',py.numpy.nditer(fit.phase)));
% rounded_phase = round(curr_phase,2);
% rounded_amp = NaN(1000,size(phase_range,2));
% curr_chan_phase_amp(seg,:) = nanmean(rounded_amp,1);

