function [new_zscore_comod, rawmi_comod] = beapp_calc_mi_zscore(amp_dist,calc_zscore)
n_bins = 18;
new_zscore_comod = NaN(size(amp_dist,1),size(amp_dist,2),size(amp_dist,4));
rawmi_comod = NaN(size(amp_dist,1),size(amp_dist,2),size(amp_dist,4));
for chan = 1:size(amp_dist,4)
    if ~isnan(amp_dist(1,1,1,chan,1))
        for hf = 1:size(amp_dist,1)
            for lf =  1:size(amp_dist,2)
                %calc MI on hf, lf, chan, surrogate
                if calc_zscore
                    surr_mis = NaN(1,size(amp_dist,5)-1);
                end
                for surr = 1:size(amp_dist,5)
                    amp_dist(hf,lf,:,chan,surr) = amp_dist(hf,lf,:,chan,surr) ./ sum(amp_dist(hf,lf,:,chan,surr));
                    amplitude_dist = amp_dist(hf,lf,:,chan,surr);
                    amplitude_dist = squeeze(amplitude_dist)';
                    divergence_kl = sum(amplitude_dist .* log(amplitude_dist * n_bins));
                    if surr == 1
                        real_mi = divergence_kl / log(n_bins);
                        rawmi_comod(hf,lf,chan) = real_mi;
                    else
                        surr_mis(1,surr-1) = divergence_kl / log(n_bins);
                    end                       
                end
                if calc_zscore
                    comod_z_score = real_mi;
                    comod_z_score = comod_z_score - mean(surr_mis,2);
                    comod_z_score = comod_z_score / std(surr_mis);
                    new_zscore_comod(hf,lf,chan) = comod_z_score;
                end
            end
        end
    end
end