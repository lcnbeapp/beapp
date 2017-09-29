%% time2samples
% calculates .mff sample number from timestamp
% modified from EGI/ Colin Davey's mff_micros2Sample function to account
% for differences in file versions
% 
% Inputs:
% time = time from file start (micro or nanoseconds)
%
% exponent = exponent on MFF file version timestamps. 
% 6 = microseconds, 9 = nanoseconds
%
% fix_or_round = 'fix' (round towards zero, use to calculate sample number
% to read in signal) or 'round' (round towards nearest int, used for
% events)
%
% srate = current file sampling rate (file_proc_info.beapp_srate)
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function[sampleNum]= time2samples(time, srate, exponent,fix_or_round)
time = double(time);
sampDuration = (10^exponent)/srate;
sampleNum = time/sampDuration;

if strcmp(fix_or_round,'fix')
    sampleNum = fix(sampleNum);
elseif strcmp(fix_or_round, 'round')
    sampleNum = fix(sampleNum);
else
    error('sample number calculation setting input is not fix or round');
end
