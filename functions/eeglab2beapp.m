%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Boston EEG Automated Processing Pipeline (BEAPP)
% Copyright (C) 2015, 2016, 2017
%
% Developed at Boston Children's Hospital Department of Neurology and the
% Laboratories of Cognitive Neuroscience
%
% All rights reserved.
%
% This software is being distributed with the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU General
% Public License for more details.
%
% In no event shall Boston Children’s Hospital (BCH), the BCH Department of
% Neurology, the
% Laboratories of Cognitive Neuroscience (LCN), or software contributors to BEAPP be
% liable to any party for direct, indirect, special, incidental, or
% consequential damages, including lost profits, arising out of the use of
% this software and its documentation, even if Boston Children’s Hospital,
% the Lab of Cognitive Neuroscience, and software contributors have been
% advised of the possibility of such damage. Software and documentation is
% provided “as is.” Boston Children’s Hospital, the Lab of Cognitive
% Neuroscience, and software contributors is under no obligation to
% provide maintenance, support, updates, enhancements, or modifications.
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License (version 3) as
% published by the Free Software Foundation.
%
% You should receive a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
%
% Description:
% BEAPP is MATLAB-based software designed to facilitate batch processing
% of EEG files for artifact removal and spectral analysis. Users have the
% option to alter multiple settings, to customize processing to their
% needs. The current version offers the following functionality for
% artifact removal and signal processing:
%
%  1. Embedded PREP pipeline (see Bigdely-Shamlo reference below) to remove
%     line noise, detect and interpolate bad channels, and robustly
%     reference to average, while retaining sufficient information to allow
%     users to re-reference using another method.
%  2. Filter and resample as needed, if EEGs being processed contain
%     differing sampling rates.
%  3. Detrend data using a mean, linear, or Kalman detrend.
%  4. Identify epochs of high-amplitude artifact in any channel (with exact
%     amplitude cutoffs set by the user), extended to the zero crossing
%     before and after the high-amplitude epoch.  These epochs are then
%     marked for exclusion from further analysis.
%  5. Reference data to a Laplacian reference (available for EGI
%     128-channel Hydrocel Geodesic Sensor Net and EGI 64-channel Geodesic
%     Sensory Net v2.0)
%  6. Segment non-excluded data into windows of length set by the user
%    (default is 1 second).
%  7. Set windowing type (rectangular, hanning, or multitaper) for spectral
%     analysis.
%  8. Evaluate the power spectrum on each window using MATLAB-based fft or
%     pmtm.
%  9. Interpolate the frequency axis of the power spectrum.
% 10. Export results of spectral analysis, binned by user-defined frequency
%     bands, for all channels or a user-defined subset of channels, into a
%     *.dat file. Results can include mean and/or standard deviation of
%     absolute and/or normalized power, in raw, natural log, or log10
%     format.
%
% BEAPP is designed for users who are comfortable using the MATLAB
% environment to run software but does not require advanced programing
% knowledge.
%
% Contributors to BEAPP:
% Heather M. O'Leary (heather.oleary@childrens.harvard.edu)
% April R. Levin (april.levin@childrens.harvard.edu)
% Adriana Mendez Leal (amendezleal@college.harvard.edu)
% Juan Manuel Mayor Torres (juan.mayortorres@childrens.harvard.edu, juan.mayortorres@unitn.it)
%
% Additional Credits:
% BEAPP incorporates the PREP pipeline Version 0.52
% https://github.com/VisLab/EEG-Clean-Tools
%
% The PREP pipeline is an EEGLAB plugin, thus BEAPP incorporates code from
% EEGLAB Version 13.4.4b
% http://sccn.ucsd.edu/wiki/EEGLAB_revision_history_version_13
%
% If the user chooses to use the PREP pipeline to correct bad EEG channels
% when running BEAPP the user should cite the following paper in their
% publications.
%
% Bigdely-Shamlo N, Mullen T, Kothe C, Su K-M and Robbins KA (2015)
% The PREP pipeline: standardized preprocessing for large-scale EEG analysis
% Front. Neuroinform. 9:16. doi: 10.3389/fninf.2015.00016
%
% Delorme A & Makeig S (2004) EEGLAB: an open source toolbox for analysis
% of single-trial EEG dynamics. Journal of Neuroscience Methods 134:9-21
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [eeg_curr_epoch,file_proc_info,grp_proc_info]=eeglab2beapp(EEG_holder,file_proc_info,grp_proc_info,curr_epoch)
% Usage: reset eeg to EEG from PREPP
% Inputs
% EEG structure output from PREPP
% proc_info structure with default and user settings

eeg_curr_epoch=EEG_holder.data;


% shouldn't change across epochs but stored just in case
file_proc_info.prepp_srate(curr_epoch)=EEG_holder.srate;
file_proc_info.prepp_mx_good_freq(curr_epoch)=EEG_holder.srate/2;

grp_proc_info.prepp_filt_typ=2; %signifies the bandpass filter from the PREP pipeline
grp_proc_info.prepp_filt_name={'lineNoise'};
grp_proc_info.prepp_filt_attenpband=0;
grp_proc_info.prepp_filt_attensband=0;
grp_proc_info.prepp_resamp_typ=0;
%grp_proc_info.prepp_lp_filt=0;

if isfield(EEG_holder.etc.noiseDetection,'name')
    file_proc_info.prepp_name{curr_epoch}={EEG_holder.etc.noiseDetection.name};
else
    file_proc_info.prepp_name{curr_epoch}={''};
end

if isfield(EEG_holder.etc.noiseDetection,'version')
    file_proc_info.prepp_version.Detrend{curr_epoch}=EEG_holder.etc.noiseDetection.version.Detrend;
    file_proc_info.prepp_version.GlobalTrend{curr_epoch}=EEG_holder.etc.noiseDetection.version.GlobalTrend;
    file_proc_info.prepp_version.LineNoise{curr_epoch}=EEG_holder.etc.noiseDetection.version.LineNoise;
    file_proc_info.prepp_version.Resampling{curr_epoch}=EEG_holder.etc.noiseDetection.version.Resampling;
    file_proc_info.prepp_version.Reference{curr_epoch}=EEG_holder.etc.noiseDetection.version.Reference;
    file_proc_info.prepp_version.Interpolation{curr_epoch}=EEG_holder.etc.noiseDetection.version.Interpolation;
else
    file_proc_info.prepp_version.Detrend{curr_epoch}='';
    file_proc_info.prepp_version.GlobalTrend{curr_epoch}='';
    file_proc_info.prepp_version.LineNoise{curr_epoch}='';
    file_proc_info.prepp_version.Resampling{curr_epoch}='';
    file_proc_info.prepp_version.Reference{curr_epoch}='';
    file_proc_info.prepp_version.Interpolation{curr_epoch}='';
end

if isfield(EEG_holder.etc.noiseDetection,'errors')
    
    if isfield(EEG_holder.etc.noiseDetection.errors,'status')
        file_proc_info.prepp_errors.status{curr_epoch}=EEG_holder.etc.noiseDetection.errors.status;
    end
    if isfield(EEG_holder.etc.noiseDetection.errors,'boundary')
        file_proc_info.prepp_errors.boundary{curr_epoch}=EEG_holder.etc.noiseDetection.errors.boundary;
    end
    if isfield(EEG_holder.etc.noiseDetection.errors,'resampling')
        file_proc_info.prepp_errors.resampling{curr_epoch}=EEG_holder.etc.noiseDetection.errors.resampling;
    end
    if isfield(EEG_holder.etc.noiseDetection.errors,'globalTrend')
        file_proc_info.prepp_errors.globalTrend{curr_epoch}=EEG_holder.etc.noiseDetection.errors.globalTrend;
    end
    if isfield(EEG_holder.etc.noiseDetection.errors,'detrend')
        file_proc_info.prepp_errors.detrend{curr_epoch}=EEG_holder.etc.noiseDetection.errors.detrend;
    end
    if isfield(EEG_holder.etc.noiseDetection.errors,'lineNoise')
        file_proc_info.prepp_errors.lineNoise{curr_epoch}=EEG_holder.etc.noiseDetection.errors.lineNoise;
    end
    if isfield(EEG_holder.etc.noiseDetection.errors,'reference')
        file_proc_info.prepp_errors.reference{curr_epoch}=EEG_holder.etc.noiseDetection.errors.reference;
    end
else
    file_proc_info.prepp_errors.status{curr_epoch}='';
    file_proc_info.prepp_errors.boundary{curr_epoch}='';
    file_proc_info.prepp_errors.resampling{curr_epoch}='';
    file_proc_info.prepp_errors.globalTrend{curr_epoch}='';
    file_proc_info.prepp_errors.detrend{curr_epoch}='';
    file_proc_info.prepp_errors.lineNoise{curr_epoch}='';
    file_proc_info.prepp_errors.reference{curr_epoch}='';
end

if isfield(EEG_holder.etc.noiseDetection,'boundary')
    file_proc_info.prepp_boundary.ignoreBoundaryEvents{curr_epoch}=EEG_holder.etc.noiseDetection.boundary.ignoreBoundaryEvents;
else
    file_proc_info.prepp_boundary.ignoreBoundaryEvents{curr_epoch}=[];
end

if isfield(EEG_holder.etc.noiseDetection,'detrend')
    file_proc_info.prepp_detrend.chan{curr_epoch}=EEG_holder.etc.noiseDetection.detrend.detrendChannels;
    file_proc_info.prepp_detrend.type{curr_epoch}=EEG_holder.etc.noiseDetection.detrend.detrendType;
    file_proc_info.prepp_detrend.cutoff{curr_epoch}=EEG_holder.etc.noiseDetection.detrend.detrendCutoff;
    file_proc_info.prepp_detrend.stepsize{curr_epoch}=EEG_holder.etc.noiseDetection.detrend.detrendStepSize;
    file_proc_info.prepp_detrend.command{curr_epoch}={EEG_holder.etc.noiseDetection.detrend.detrendCommand};
else
    file_proc_info.prepp_detrend.chan{curr_epoch}=[];
    file_proc_info.prepp_detrend.type{curr_epoch}='';
    file_proc_info.prepp_detrend.cutoff{curr_epoch}=[];
    file_proc_info.prepp_detrend.stepsize{curr_epoch}=[];
    file_proc_info.prepp_detrend.command{curr_epoch}='';
end

if isfield(EEG_holder.etc.noiseDetection,'lineNoise')
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'lineNoiseChannels')
        file_proc_info.prepp_lineNoise.chan{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.lineNoiseChannels;
    else
        file_proc_info.prepp_lineNoise.chan{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'Fs')
        file_proc_info.prepp_lineNoise.srate{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.Fs;
    else
        file_proc_info.prepp_lineNoise.srate{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'lineFrequencies')
        file_proc_info.prepp_lineNoise.freq{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.lineFrequencies;
    else
        file_proc_info.prepp_lineNoise.freq{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'p')
        file_proc_info.prepp_lineNoise.p{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.p;
    else
        file_proc_info.prepp_lineNoise.p{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'fScanBandWidth')
        file_proc_info.prepp_lineNoise.fScan_bw{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.fScanBandWidth;
    else
        file_proc_info.prepp_lineNoise.fScan_bw{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'taperBandWidth')
        file_proc_info.prepp_lineNoise.taper_bw{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.taperBandWidth;
    else
        file_proc_info.prepp_lineNoise.taper_bw{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'taperWindowSize')
        file_proc_info.prepp_lineNoise.taper_win_sz{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.taperWindowSize;
    else
        file_proc_info.prepp_lineNoise.taper_win_sz{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'taperWindowStep')
        file_proc_info.prepp_lineNoise.taper_win_step{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.taperWindowStep;
    else
        file_proc_info.prepp_lineNoise.taper_win_step{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'tau')
        file_proc_info.prepp_lineNoise.tau{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.tau;
    else
        file_proc_info.prepp_lineNoise.tau{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'pad')
        file_proc_info.prepp_lineNoise.pad{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.pad;
    else
        file_proc_info.prepp_lineNoise.pad{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'fPassBand')
        file_proc_info.prepp_lineNoise.fPassBand{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.fPassBand;
    else
        file_proc_info.prepp_lineNoise.fPassBand{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'maximumIterations')
        file_proc_info.prepp_lineNoise.mx_iter{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.maximumIterations;
    else
        file_proc_info.prepp_lineNoise.mx_iter{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'taperTemplate')
        file_proc_info.prepp_lineNoise.taper_temp{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.taperTemplate;
    else
        file_proc_info.prepp_lineNoise.taper_temp{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.lineNoise,'tapers')
        file_proc_info.prepp_lineNoise.tapers{curr_epoch}=EEG_holder.etc.noiseDetection.lineNoise.tapers;
    else
        file_proc_info.prepp_lineNoise.tapers{curr_epoch}=[];
    end
else
    file_proc_info.prepp_lineNoise.chan{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.srate{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.freq{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.p{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.fScan_bw{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.taper_bw{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.taper_win_sz{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.taper_win_step{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.tau{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.pad{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.fPassBand{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.mx_iter{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.taper_temp{curr_epoch}=[];
    file_proc_info.prepp_lineNoise.tapers{curr_epoch}=[];
end

if isfield(EEG_holder.etc.noiseDetection,'reference')
    if isfield(EEG_holder.etc.noiseDetection.reference,'referenceChannels')
        file_proc_info.prepp_refChannels{curr_epoch}=EEG_holder.etc.noiseDetection.reference.referenceChannels;
    else
        file_proc_info.prepp_refChannels{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'evaluationChannels')
        file_proc_info.prepp_evalChannels{curr_epoch}=EEG_holder.etc.noiseDetection.reference.evaluationChannels;
    else
        file_proc_info.prepp_evalChannels{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'referencedChannels')
        file_proc_info.prepp_rerefedChannels{curr_epoch}=EEG_holder.etc.noiseDetection.reference.rereferencedChannels;
    else
        file_proc_info.prepp_rerefedChannels{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'channelLocations')
        file_proc_info.prepp_channelLocations{curr_epoch}=EEG_holder.etc.noiseDetection.reference.channelLocations;
    else
        file_proc_info.prepp_channelLocations{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'channelInformation')
        file_proc_info.prepp_channelInformation{curr_epoch}=EEG_holder.etc.noiseDetection.reference.channelInformation;
    else
        file_proc_info.prepp_channelInformation{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'maxReferenceIterations')
        file_proc_info.prepp_mx_iter{curr_epoch}=EEG_holder.etc.noiseDetection.reference.maxReferenceIterations;
    else
        file_proc_info.prepp_mx_iter{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'actualReferenceIterations')
        file_proc_info.prepp_actual_iter{curr_epoch}=EEG_holder.etc.noiseDetection.reference.actualReferenceIterations;
    else
        file_proc_info.prepp_actual_iter{curr_epoch}=[];
    end
    
    if isfield(EEG_holder.etc.noiseDetection.reference,'interpolatedChannels')
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'all')
            file_proc_info.prepp_interpolatedChannels.all{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.all;
        else
            file_proc_info.prepp_interpolatedChannels.all{curr_epoch}=[];
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromNaNs')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromNaNs{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromNaNs;
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromNoData')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromNoData{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromNoData;
        else
            file_proc_info.prepp_interpolatedChannels.badChannelsFromNoData{curr_epoch}=[];
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromLowSNR')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromLowSNR{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromLowSNR;
        else
            file_proc_info.prepp_interpolatedChannels.badChannelsFromLowSNR{curr_epoch}=[];
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromHFNoise')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromHFNoise{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromHFNoise;
        else
            file_proc_info.prepp_interpolatedChannels.badChannelsFromHFNoise{curr_epoch}=[];
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromCorrelation')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromCorrelation{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromCorrelation;
        else
            file_proc_info.prepp_interpolatedChannels.badChannelsFromCorrelation{curr_epoch}=[];
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromDeviation')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromDeviation{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromDeviation;
        else
            file_proc_info.prepp_interpolatedChannels.badChannelsFromDeviation{curr_epoch}=[];
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromRansac')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromRansac{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromRansac;
        else
            file_proc_info.prepp_interpolatedChannels.badChannelsFromRansac{curr_epoch}=[];
        end
        
        if isfield(EEG_holder.etc.noiseDetection.reference.interpolatedChannels,'badChannelsFromDropOuts')
            file_proc_info.prepp_interpolatedChannels.badChannelsFromDropOuts{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolatedChannels.badChannelsFromDropOuts;
        else
            file_proc_info.prepp_interpolatedChannels.badChannelsFromDropOuts{curr_epoch}=[];
        end
        
        file_proc_info.prepp_interpolatedChannels.src_vname{curr_epoch}={'EEG.etc.noiseDetection.reference.interpolatedChannels'};
    else
        
        file_proc_info.prepp_interpolatedChannels.all{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromNaNs{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromNoData{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromLowSNR{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromHFNoise{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromCorrelation{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromDeviation{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromRansac{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.badChannelsFromDropOuts{curr_epoch}=[];
        file_proc_info.prepp_interpolatedChannels.src_vname{curr_epoch}={' '};
    end
    
    if isfield(EEG_holder.etc.noiseDetection.reference,'badSignalsUninterpolated')
        file_proc_info.prepp_badSignalsUninterp{curr_epoch}=EEG_holder.etc.noiseDetection.reference.badSignalsUninterpolated;
    else
        file_proc_info.prepp_badSignalsUninterp{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'referenceSignalOriginal')
        file_proc_info.prepp_refSigOrig{curr_epoch}=EEG_holder.etc.noiseDetection.reference.referenceSignalOriginal;
    else
        file_proc_info.prepp_refSigOrig{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'referenceSignal')
        file_proc_info.prepp_refSignal{curr_epoch}=EEG_holder.etc.noiseDetection.reference.referenceSignal;
    else
        file_proc_info.prepp_refSignal{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'noisyStatisticsOriginal')
        file_proc_info.prepp_noisyStatisticsOriginal{curr_epoch}=EEG_holder.etc.noiseDetection.reference.noisyStatisticsOriginal;
    else
        file_proc_info.prepp_noisyStatisticsOriginal{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'noisyStatisticsBeforeInterpolation')
        file_proc_info.prepp_noisyStatisticsBeforeInerpolation{curr_epoch}=EEG_holder.etc.noiseDetection.reference.noisyStatisticsBeforeInterpolation;
    else
        file_proc_info.prepp_noisyStatisticsBeforeInerpolation{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'noisyStatistics')
        file_proc_info.prepp_noisyStatistics{curr_epoch}=EEG_holder.etc.noiseDetection.reference.noisyStatistics;
    else
        file_proc_info.prepp_noisyStatistics{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'reportingLevel')
        file_proc_info.prepp_reportLevel{curr_epoch}={EEG_holder.etc.noiseDetection.reference.reportingLevel};
    else
        file_proc_info.prepp_reportLevel{curr_epoch}={''};
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'robustDeviationThreshold')
        file_proc_info.prepp_robustDeviationThreshold{curr_epoch}=EEG_holder.etc.noiseDetection.reference.robustDeviationThreshold;
    else
        file_proc_info.prepp_robustDeviationThreshold{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'highFrequencyNoiseThreshold')
        file_proc_info.prepp_highFrequencyNoiseThreshold{curr_epoch}=EEG_holder.etc.noiseDetection.reference.highFrequencyNoiseThreshold;
    else
        file_proc_info.prepp_highFrequencyNoiseThreshold{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'correlationWindowSeconds')
        file_proc_info.prepp_correlationWindowSeconds{curr_epoch}=EEG_holder.etc.noiseDetection.reference.correlationWindowSeconds;
    else
        file_proc_info.prepp_correlationWindowSeconds{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'correlationThreshold')
        file_proc_info.prepp_correlationThreshold{curr_epoch}=EEG_holder.etc.noiseDetection.reference.correlationThreshold;
    else
        file_proc_info.prepp_correlationThreshold{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'badTimeThreshold')
        file_proc_info.prepp_badTimeThreshold{curr_epoch}=EEG_holder.etc.noiseDetection.reference.badTimeThreshold;
    else
        file_proc_info.prepp_badTimeThreshold{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'ransacOff')
        file_proc_info.prepp_ransacOff{curr_epoch}=EEG_holder.etc.noiseDetection.reference.ransacOff;
    else
        file_proc_info.prepp_ransacOff{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'ransacSampleSize')
        file_proc_info.prepp_ransacSampleSize{curr_epoch}=EEG_holder.etc.noiseDetection.reference.ransacSampleSize;
    else
        file_proc_info.prepp_ransacSampleSize{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'ransacChannelFraction')
        file_proc_info.prepp_ransacChannelFraction{curr_epoch}=EEG_holder.etc.noiseDetection.reference.ransacChannelFraction;
    else
        file_proc_info.prepp_ransacChannelFraction{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'ransacCorrelationThreshold')
        file_proc_info.prepp_ransacCorrelationThreshold{curr_epoch}=EEG_holder.etc.noiseDetection.reference.ransacCorrelationThreshold;
    else
        file_proc_info.prepp_ransacCorrelationThreshold{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'ransacUnbrokenTime')
        file_proc_info.prepp_ransacUnbrokenTime{curr_epoch}=EEG_holder.etc.noiseDetection.reference.ransacUnbrokenTime;
    else
        file_proc_info.prepp_ransacUnbrokenTime{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'ransacWindowSeconds')
        file_proc_info.prepp_ransacWindowSeconds{curr_epoch}=EEG_holder.etc.noiseDetection.reference.ransacWindowSeconds;
    else
        file_proc_info.prepp_ransacWindowSeconds{curr_epoch}=[];
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'referenceType')
        file_proc_info.prepp_referenceType{curr_epoch}=EEG_holder.etc.noiseDetection.reference.referenceType;
    else
        file_proc_info.prepp_referenceType{curr_epoch}='';
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'interpolationOrder')
        file_proc_info.prepp_interpolationOrder{curr_epoch}=EEG_holder.etc.noiseDetection.reference.interpolationOrder;
    else
        file_proc_info.prepp_interpolationOrder{curr_epoch}='';
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'meanEstimateType')
        file_proc_info.prepp_meanEstimationType{curr_epoch}=EEG_holder.etc.noiseDetection.reference.meanEstimateType;
    else
        file_proc_info.prepp_meanEstimationType{curr_epoch}='';
    end
    if isfield(EEG_holder.etc.noiseDetection.reference,'keepFiltered')
        file_proc_info.prepp_keepFiltered{curr_epoch}=EEG_holder.etc.noiseDetection.reference.keepFiltered;
    else
        file_proc_info.prepp_keepFiltered{curr_epoch}=[];
    end
    
else
    file_proc_info.prepp_refChannels{curr_epoch}=[];
    file_proc_info.prepp_evalChannels{curr_epoch}=[];
    file_proc_info.prepp_rerefedChannels{curr_epoch}=[];
    file_proc_info.prepp_channelLocations{curr_epoch}=[];
    file_proc_info.prepp_channelInformation{curr_epoch}=[];
    file_proc_info.prepp_mx_iter{curr_epoch}=[];
    file_proc_info.prepp_actual_iter{curr_epoch}=[];
    
    file_proc_info.prepp_interpolatedChannels.all{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromNaNs{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromNoData{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromLowSNR{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromHFNoise{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromCorrelation{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromDeviation{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromRansac{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.badChannelsFromDropOuts{curr_epoch}=[];
    file_proc_info.prepp_interpolatedChannels.src_vname{curr_epoch}={' '};
    
    file_proc_info.prepp_badSignalsUninterp{curr_epoch}=[];
    file_proc_info.prepp_refSigOrig{curr_epoch}=[];
    file_proc_info.prepp_refSignal{curr_epoch}=[];
    file_proc_info.prepp_noisyStatisticsOriginal{curr_epoch}=[];
    file_proc_info.prepp_noisyStatisticsBeforeInerpolation{curr_epoch}=[];
    file_proc_info.prepp_noisyStatistics{curr_epoch}=[];
    file_proc_info.prepp_reportLevel{curr_epoch}={''};
    file_proc_info.prepp_robustDeviationThreshold{curr_epoch}=[];
    file_proc_info.prepp_highFrequencyNoiseThreshold{curr_epoch}=[];
    file_proc_info.prepp_correlationWindowSeconds{curr_epoch}=[];
    file_proc_info.prepp_correlationThreshold{curr_epoch}=[];
    file_proc_info.prepp_badTimeThreshold{curr_epoch}=[];
    file_proc_info.prepp_ransacOff{curr_epoch}=[];
    file_proc_info.prepp_ransacSampleSize{curr_epoch}=[];
    file_proc_info.prepp_ransacChannelFraction{curr_epoch}=[];
    file_proc_info.prepp_ransacCorrelationThreshold{curr_epoch}=[];
    file_proc_info.prepp_ransacUnbrokenTime{curr_epoch}=[];
    file_proc_info.prepp_ransacWindowSeconds{curr_epoch}=[];
    file_proc_info.prepp_referenceType{curr_epoch}='';
    file_proc_info.prepp_interpolationOrder{curr_epoch}='';
    file_proc_info.prepp_meanEstimationType{curr_epoch}='';
    file_proc_info.prepp_keepFiltered{curr_epoch}='';
end

if isfield(EEG_holder.etc.noiseDetection,'resampling')
    file_proc_info.prepp_resampleFrequency{curr_epoch}=EEG_holder.etc.noiseDetection.resampling.resampleFrequency;
    file_proc_info.prepp_lowPassFrequency{curr_epoch}=EEG_holder.etc.noiseDetection.resampling.lowPassFrequency;
    file_proc_info.prepp_originalFrequency{curr_epoch}=EEG_holder.etc.noiseDetection.resampling.originalFrequency;
    file_proc_info.prepp_resampleCommand{curr_epoch}=EEG_holder.etc.noiseDetection.resampling.resampleCommand;
    file_proc_info.prepp_lowPassCommand{curr_epoch}=EEG_holder.etc.noiseDetection.resampling.lowPassCommand;
    file_proc_info.prepp_resampleOff{curr_epoch}=EEG_holder.etc.noiseDetection.resampling.resampleOff;
else
    file_proc_info.prepp_resampleFrequency{curr_epoch}=[];
    file_proc_info.prepp_lowPassFrequency{curr_epoch}=[];
    file_proc_info.prepp_originalFrequency{curr_epoch}=[];
    file_proc_info.prepp_resampleCommand{curr_epoch}='';
    file_proc_info.prepp_lowPassCommand{curr_epoch}='';
    file_proc_info.prepp_resampleOff{curr_epoch}=[];
end