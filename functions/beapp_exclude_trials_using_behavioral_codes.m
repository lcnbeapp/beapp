%% beapp_exclude_trials_using_behavioral_codes
% 
% exclude trials from evt_info (mark as Non_Target) if behavioral code is marked bad
% modeled for ABCCT behavioral coding, but can be adapted if others are
% using similar behavioral coding
%
% Assumes the closest behavioral code after
% an event of interest is the one that applies to it, in a 1:1 ratio, will
% be adapted once we have alternative examples of live behavioral coding
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
function [evt_info,any_behav_vals] =  beapp_exclude_trials_using_behavioral_codes (evt_info)
behav_value_current = 0;
any_behav_vals = 0;

for curr_epoch = 1:length(evt_info)
    
    % move backwards through tags
    for curr_tag = length(evt_info{curr_epoch}): -1: 1 
        
        % if tag has a behavioral code, save it to apply to closest evt tag
        % of interest
        if ~isnan(evt_info{curr_epoch}(curr_tag).behav_code)
            behav_value_current = evt_info{curr_epoch}(curr_tag).behav_code;
            any_behav_vals = 1;
        
            % if tag is evt tag AND there isn't already a behavioral code,
            % use the saved behavioral code for this tag
        elseif ~strcmp(char(evt_info{curr_epoch}(curr_tag).type),'Non_Target')
             evt_info{curr_epoch}(curr_tag).behav_code = behav_value_current;
             
             % if bad value, exclude this event
             if behav_value_current
                evt_info{curr_epoch}(curr_tag).type = 'Non_Target';
             end
        end     
    end
end
