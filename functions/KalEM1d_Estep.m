%% [x_T,v_T,Koviip1,x_prior] = KalEM1d_Estep(y,x_init,q_init,q)
% written by Demba Ba, 2014
% applies Kalman filter to data
% uses the KalEM1d_Estep function written by Demba Ba for the Kalman filter
% 
% Inputs:
% y - the data in an EEG channel
% x_init - first value in the channel
% q - q matrix for kalman
%
% x_T is the trend to be removed from the EEG
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
function [x_T,v_T,Koviip1,x_prior] = KalEM1d_Estep(y,x_init,q_init,q)

T = length(y); % length of series

% Filtering data structures
x_prior = zeros(1,T+1); % x_prior(t) = x_{t|t-1}
x_post = zeros(1,T+1); % x_post(t)  = x_{t|t}
v_prior = zeros(1,T+1); % v_prior(t)= V_{t|t-1}
v_post = zeros(1,T+1); % v_post(t) = V_{t|t}

% Smoothing data structures
x_T = zeros(1,T+1); x_T(1) = x_init;
v_T = zeros(1,T+1); v_T(1) = q_init;

b = zeros(1,T+1);
k = zeros(1,T+1);
   
%disp('      - Filtering')
% Initialize filtering step
x_post(1) = x_T(1); v_post(1) = v_T(1); % note, these are the values from the previous iteration
% at the 1st iteration, these are simply the initial values
% passed to the function (i.e. x_init,q_init)

%HMO comment 10/9/2014: makes y the same size as the other arrays
y = [0 y];

for t=2:T+1
    % Prediction step
    x_prior(t) = x_post(t-1);
    v_prior(t) = v_post(t-1) + q;
    
    % Intermediate computations
    k(t) = v_prior(t)*(v_prior(t) + 1)^-1;
  
    % Correciton step
    x_post(t) = x_prior(t) + k(t)*(y(t)-x_prior(t));
    v_post(t) = v_prior(t) - k(t)*v_prior(t);
    
end

%disp('      - Smoothing')
% Initialize smoothing step
x_T(T+1) = x_post(T+1); v_T(T+1) = v_post(T+1);

for t=T+1:-1:2
    b(t) = v_post(t-1)*(1/v_prior(t));
    x_T(t-1) = x_post(t-1) + b(t)*(x_T(t)-x_prior(t));
    v_T(t-1) = v_post(t-1) + b(t)^2*(v_T(t)-v_prior(t));
end

% ----------------------------------------------------------------
% COVARIANCE ALGORITHM
%
%disp(['      - Covariance alg.'])
Koviip1=zeros(1,T); % The ith guy corresponds to Kov(i-1,i)

for u=T:-1:2
    k = u - 1;
    Koviip1(u)=b(k)*v_T(u);
end
