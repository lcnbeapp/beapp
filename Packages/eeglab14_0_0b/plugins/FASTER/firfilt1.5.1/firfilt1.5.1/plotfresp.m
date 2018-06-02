% plotfresp() - Plot FIR filter's impulse, step, frequency, magnitude,
%               and phase response
%
% Usage:
%   >> plotfresp(b, a, n, fs);
%
% Inputs:
%   b     - vector filter coefficients
%
% Optional inputs:
%   a     - currently unused, reserved for future compatibility with IIR
%           filters {default 1}
%   n     - scalar number of points
%   fs    - scalar sampling frequency
%
% Author: Andreas Widmann, University of Leipzig, 2005
%
% See also:
%   pop_firws, pop_firpm, pop_firma

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2005 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Id$

function plotfresp(b, a, n, fs)

if nargin < 4
    fs = 1;
end
if nargin < 3 || isempty(n)
    n = 2^fix(log2(length(b)));
    if n < 512
        n = 512;
    end
end
if nargin < 1
    error('Not enough input arguments.');
end

% Impulse resonse
ax(1) = subplot(2, 3, 1);
stem(b, 'fill')
title('Impulse response');
ylabel('Amplitude');

% Step response
ax(4) = subplot(2, 3, 4);
stem(cumsum(b), 'fill');
title('Step response');
foo = ylim;
if foo(2) < -foo(1) + 1;
    foo(2) = -foo(1) + 1;
    ylim(foo);
end
children = get(ax(4), 'Children');
for child =1:length(children)
    children(child) = length(get(children(child), 'xdata'));
end
set(ax([1 4]), 'xlim', [1 max(children)]);
ylabel('Amplitude');

% Frequency response
ax(2) = subplot(2, 3, 2);
m = fix((length(b) - 1) / 2); % Filter order
z = fft(b, n * 2);
z = z(1:fix(length(z) / 2) + 1);
foo = real(abs(z) .* exp(-i * (angle(z) + [0:1 / n:1] * m * pi))); % needs further testing
plot([0:1 / n:1] * fs / 2, foo);
title('Frequency response');
ylabel('Amplitude');

% Magnitude response
ax(5) = subplot(2, 3, 5);
db = abs(z);
db(find(db < eps^(2 / 3))) = eps^(2 / 3); % Log of zero warning
plot([0:1/n:1] * fs / 2, 20 * log10(db));
title('Magnitude response');
foo = ylim;
if foo(1) < 20 * log10(eps^(2 / 3))
    foo(1) = 20 * log10(eps^(2 / 3));
end
ylabel('Magnitude (dB)');
ylim(foo);

% Phase response
ax(3) = subplot(2, 3, 3);
z(find(abs(z) < eps^(2 / 3))) = NaN; % Phase is undefined for magnitude zero
phi = angle(z);
groupdelay = -mod([0:1 / n:1] * m * pi + pi, 2 * pi) + pi; % Group delay
phi = phi - groupdelay;
phi = phi + 2 * pi * (phi <= -pi + eps ^ (1/3)); % Unwrap
plot([0:1/n:1] * fs / 2, phi);
title('Phase response');
ylabel('Phase (rad)');
ylim([-pi / 2 1.5 * pi]);

set(ax(1:5), 'ygrid', 'on', 'xgrid', 'on', 'box', 'on');
titles = get(ax(1:5), 'title');
set([titles{:}],  'fontweight', 'bold');
xlabels = get(ax(1:5), 'xlabel');
if fs == 1
    set([xlabels{[2 3 5]}], 'String', 'Normalized frequency (2 pi rad / sample)');
else
    set([xlabels{[2 3 5]}], 'String', 'Frequency (Hz)');
end
set([xlabels{[1 4]}], 'String', 'Sample');
set(ax([2 3 5]), 'xlim', [0 fs / 2]);
set(ax(1:5), 'colororder', circshift(get(ax(1), 'colororder'), -1));
set(ax(1:5), 'nextplot', 'add');
