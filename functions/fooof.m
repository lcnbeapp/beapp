% fooof() - run the fooof model on a neural power spectrum
%
% Usage:
%   >> fooof_results = fooof(freqs, psd, f_range, settings);
%
% Inputs:
%   freqs           = row vector of frequency values
%   psd             = row vector of power values
%   f_range         = fitting range (Hz)
%   settings        = fooof model settings, in a struct, including:
%       settings.peak_width_limts
%       settings.max_n_peaks
%       settings.min_peak_amplitude
%       settings.peak_threshold
%       settings.background_mode
%       settings.verbose
%
% Outputs:
%   fooof_results   = fooof model ouputs, in a struct, including:
%       fooof_results.background_params
%       fooof_results.peak_params
%       fooof_results.gaussian_params
%       fooof_results.error
%       fooof_results.r_squared
%
% Notes
%   Not all settings need to be set. Any settings that are not 
%     provided as set to default values. To run with all defaults, 
%     input settings as an empty struct. 

function fooof_results = fooof(freqs, psd, f_range, settings, filename, grp_proc_info_in, save_report)

    % Check settings - get defaults for those not provided
    settings = fooof_check_settings(settings);
    
    % Convert inputs
    freqs_py = py.numpy.array(freqs);     
    psd_py = py.numpy.array(psd);
    f_range = py.list(f_range);
    width_range = py.list(settings.peak_width_limits);
    
    % Initialize FOOOF object
    fm = py.fooof.FOOOF(width_range, ...
                        settings.max_n_peaks, ...
                        settings.min_peak_amplitude, ...
                        settings.peak_threshold, ...
                        settings.background_mode, ...
                        settings.verbose);
    
    % Run FOOOF fit
    fm.fit(freqs_py, psd_py, f_range)
    
    % Extract outputs
    fooof_results = fm.get_results();
    fooof_results = fooof_unpack_results(fooof_results);
   
    
    %CD into fooof directory, save report 
    if save_report == 1  %temp: allow it for everything unconditionally
        cd(grp_proc_info_in.beapp_toggle_mods{'fooof','Module_Dir'}{1});
%         fm.save_report(filename); -- stopped working 
%         fm.report(freqs,psd,f_range)
        if grp_proc_info_in.fooof_background_mode == 1 %fixed
            fooofed_psd = fooof_results.background_params(1,1) - log10(freqs.^fooof_results.background_params(1,2)); %knee parameter is 0, and not output
        else %knee
            fooofed_psd = fooof_results.background_params(1,1) - log10(fooof_results.background_params(1,2) + freqs.^fooof_results.background_params(1,3));
            %fooofed_psd = 10^fooof_results.background_params(1,1) * (1./(fooof_results.background_params(1,2)+freqs.^fooof_results.background_params(1,3)));
        end
        background_fit = fooofed_psd;
        for i=1:size(fooof_results.peak_params,1)
            fooofed_psd = fooofed_psd + fooof_results.gaussian_params(i,2) * exp(-((freqs - fooof_results.gaussian_params(i,1)).^2) / (2*fooof_results.gaussian_params(i,3)).^2);
        end
        h = figure;
        plot(freqs,log10(psd),freqs,fooofed_psd,freqs,background_fit,'--')
        xlabel('Frequency')
        ylabel('Power')
        legend('Original Spectrum', 'Full Model Fit', 'Background Fit')
        %TH
         if grp_proc_info_in.include_diagnosis
            diagnosis_folder=grp_proc_info_in.diagnosis_map{([grp_proc_info_in.diagnosis_map{:,[1]}]==file_proc_info.diagnosis),2};
            if exist(fullfile(cd,diagnosis_folder),'file')==0
                mkdir(cd,diagnosis_folder);
            end
            cd(fullfile(cd, diagnosis_folder));
        end
        saveas(h, strcat(filename,'.png'))
        src_dir = find_input_dir('fooof',grp_proc_info_in.beapp_toggle_mods);
        close;
        cd(src_dir{1});
    end
    
%     %%--FOR TESTING--%%
%     x = rand;
%     if x < .1
%         cd(grp_proc_info_in.beapp_toggle_mods{'fooof','Module_Dir'}{1});
%         fm.save_report(filename);
%         src_dir = find_input_dir('fooof',grp_proc_info_in.beapp_toggle_mods);
%         cd(src_dir{1});
%     end
    clearvars -except fooof_results grp_proc_info_in
end
