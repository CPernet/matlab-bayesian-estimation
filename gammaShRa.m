function [shape,rate] = gammaShRa(centTend,sd,type)
% gammaShRa
%   Calculates shape and rate for gamma distribution.
%
% INPUT:
%   centTend
%      central tendency of data, use either mode (default) or mean
%   sd
%      standard deviation of data
%   type
%      string variable specifying if mode or mean is used
%      'mode' or 'mean'
%
% OUTPUT:
%   vector containing shape and rate for gamma distribution
%
% EXAMPLE:
%   [shape,rate] = gammaShRa(centTend,sd,'mode');

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis,
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-13
% Version: v1.00 (2016-03-15)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% Error checking
if centTend <=0
    error('Mode or mean must be > 0');
end
if sd <=0
    error('sd must be > 0');
end

switch lower(type)
    case 'mode'
        rate = (centTend + sqrt(centTend.^2 + 4.*sd.^2)) / (2.*sd.^2);
        shape = 1 + centTend * rate;
    case 'mean'
        shape = centTend.^2./sd.^2;
        rate = centTend./sd.^2;
    otherwise
        error('Specify type: "mode" or "median"')
end
end