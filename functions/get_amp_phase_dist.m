function [amp_dist, phase_dist] = get_amp_phase_dist(signal, lf, hf, srate, high_fq_width, pac_variable_hf_filt)
    estimator = py.pactools.Comodulogram(srate,lf);
    estimator.progress_bar = 0; %set to 0 cause it's broken
    estimator.method = py.str('tort');
    estimator.high_fq_range = hf;
    estimator.low_fq_width = py.float(2);         
    if pac_variable_hf_filt
        hf_low = hf - 2;
        hf_high = hf+lf;
        estimator.high_fq_width = hf_high - hf_low;
        estimator.high_fq_range = hf_low + (hf_high - hf_low)/2;
    else
        estimator.high_fq_width = py.float(high_fq_width);
    end
    calc_zscores = 0;
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
    %TEMP!!! stopped descritizing phase dist
    %phase_dist_raw = double(py.array.array('d',py.numpy.nditer(fit.phase)));
    amp_dist = double(py.array.array('d',py.numpy.nditer(fit.amp)));
    %phase_dist = discretize(phase_dist_raw,linspace(-pi,pi,19));
    phase_dist = double(py.array.array('d',py.numpy.nditer(fit.phase)));
end