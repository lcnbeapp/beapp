%% beapp_read_mff_signal
% reads eeg data from MFF file using EGI API, separates recording periods
% (epochs) and/or segments from each other 
%
% this function is adapted from the EGI
% API written by Colin Davey for FieldTrip in 2006-2014. 
% https://github.com/fieldtrip/fieldtrip/tree/master/external/egi_mff
%
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
% adapted for BEAPP 6/2016 from a function written for EGI API 
% Original function written by Colin Davey
% date 3/2/2012, 4/15/2014
% Copyright 2012, 2014 EGI. All rights reserved.

function data = beapp_read_mff_signal(filePath, indType, beginInd, endInd, chanInds, tmp_signal_info, epoch_lengths_samps)

if strcmp(indType, 'sample')
    [beginEpoch, beginSample] = epochSample2EpochAndSample(beginInd, epoch_lengths_samps);
    [endEpoch, endSample] = epochSample2EpochAndSample(endInd, epoch_lengths_samps);
    beginBlock = tmp_signal_info.epoch_first_blocks(beginEpoch);
    endBlock = tmp_signal_info.epoch_last_blocks(endEpoch);
else
    % won't happen until we adjust to read in segments, for now ignore
end

data = read_mff_data_blocks(tmp_signal_info.signal_obj, tmp_signal_info.sig_blocks, beginBlock, endBlock);

% if channel indices were provided, downsize to the requested channels
if size(chanInds,1) ~= 0
    data = data(chanInds,:);
end
if strcmp(indType, 'sample')
    data = data(:,beginSample:beginSample + (endInd-beginInd));
else
      % won't happen until we adjust to read in segments, for now ignore
end
end