%% calc_CSDLP_toolbox_coordinates
% calculate coordinate positions in "EGI"/ CSD toolbox space
%
% uses some modified code originally written by Jürgen Kayser from the CSD toolbox
% puts our chanlocs into their coordinate system-- they follow the EGI
% chanlocs postitioning
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
function csdlp_coord_format =  calc_CSDLP_toolbox_coordinates (file_proc_info,curr_epoch)

% only grab channels that have not been excluded
desired_chans_vstruct = file_proc_info.net_vstruct(file_proc_info.beapp_indx{curr_epoch});

% build elocs structure equivalent for "EGI" coordinate system
% orientation
tmp_net_csdlp_vstruct(1,1:size(desired_chans_vstruct,2))=struct('labels',{desired_chans_vstruct.labels},'X', num2cell([desired_chans_vstruct.Y]*-1),'Y',{desired_chans_vstruct.X},'Z',{desired_chans_vstruct.Z});

% populate spherical coordinates using eeglab function but "egi"
% coordinate system orientation
tmp_net_csdlp_vstruct = convertlocs(tmp_net_csdlp_vstruct,'cart2sph');
csdlp_coord_format.lab = {desired_chans_vstruct.labels}';
csdlp_coord_format.theta = [tmp_net_csdlp_vstruct.sph_theta]';
csdlp_coord_format.phi = [tmp_net_csdlp_vstruct.sph_phi]';

% use conversions exactly as done in the toolbox
phiT = 90 - csdlp_coord_format.phi; % calculate phi from top of sphere
theta2 = (2 * pi *  csdlp_coord_format.theta) / 360;    % convert degrees to radians
phi2 = (2 * pi * phiT) / 360;
[x,y] = pol2cart(theta2,phi2);      % get plane coordinates
xy = [x y];
xy = xy./max(max(xy));               % set maximum to unit length
csdlp_coord_format.xy = xy/2 + 0.5;

