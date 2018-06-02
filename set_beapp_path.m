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
function grp_proc_info = set_beapp_path (grp_proc_info)
if isdir(grp_proc_info.beapp_root_dir{1})
%     warning('EEGLAB packages have a number of functions with the same names as MATLAB builtins. This may cause errors');
%     warning('off','MATLAB:dispatcher:nameConflict');
%     warning('off','MATLAB:rmpath:DirNotFound');
    addpath(grp_proc_info.beapp_root_dir{1});
    addpath(genpath([grp_proc_info.beapp_root_dir{1},filesep,'user_inputs']));
    addpath(genpath([grp_proc_info.beapp_root_dir{1},filesep,'functions']));
    
    % add EEGLAB and plugin paths
    addpath([grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,grp_proc_info.eeglab_ver{1}]);
    try
        beapp_eeglab_path_adding;
    catch
        error('Please make sure Packages folder is in the beapp source directory');
    end
    addpath(genpath([grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,'CSDtoolbox']));
    addpath([grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,'REST_MATLAB_v1.1_20170828']);
     addpath(genpath([grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,'REST_MATLAB_v1.1_20170828',filesep,'function',filesep,'LeadField']));
    
%     rmpath(genpath([grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,grp_proc_info.eeglab_ver{1},filesep,'functions',filesep,'octavefunc']));
%     rmpath(genpath([grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,grp_proc_info.eeglab_ver{1},filesep,'plugins',filesep,'tmullen-cleanline-696a7181b7d0'...
%         'external',filesep,'bcilab_partial',filesep,'dependencies',filesep,'PropertyGrid-2010-09-16-mod']));
%     rmpath([grp_proc_info.beapp_root_dir{1},filesep,'Packages',filesep,grp_proc_info.eeglab_ver{1},filesep,'plugins',filesep,...
%         'fieldtrip-20160917',filesep,'external',filesep,'signal',filesep,'dpss_hack']);
    rmpath(genpath(grp_proc_info.beapp_ft_pname{1}));
    warning('on','MATLAB:dispatcher:nameConflict');
    warning('on','MATLAB:rmpath:DirNotFound');
else
    disp(['The directory ',grp_proc_info.beapp_root_dir{1},' does not exist.']);
    grp_proc_info.beapp_root_dir={input('Please enter the full path of the BEAPP software directory in single quotes:')};
    disp('Exiting Code.');
    return;
end