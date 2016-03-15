function summary = mbe_2gr_summary(mcmcChain)
%% mbe_2gr_summary
% Computes summary statistics for all parameters of a 2 group comparison.
%   This will only work for a mcmc chain with parameters mu1,mu2,sigma1,
%   sigma2 and nu.
%
% INPUT:
%   mcmcChain
%       structure with fields for mu, sigma, nu
%       mu and sigma need to have size m x n with m = number of chain steps
%       and n = 2 (for mu1 and mu2 and sigma1 and sigma2)
%
% OUTPUT:
%   summary
%       outputs structure containing mu1, mu2, muDiff, sigma1, sigma2,
%       sigmaDiff, nu, nuLog10 and effectSize
%
% EXAMPLE:
%   summary = mbe_2gr_summary(mcmcChain);

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis, 
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-13
% Version: v0.2 ()
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

summary.mu1 = mbe_summary(mcmcChain.mu(:,1));
summary.mu2 = mbe_summary(mcmcChain.mu(:,2));
summary.muDiff = mbe_summary((mcmcChain.mu(:,1) - mcmcChain.mu(:,2)),0);
summary.sigma1 = mbe_summary(mcmcChain.sigma(:,1));
summary.sigma2 = mbe_summary(mcmcChain.sigma(:,2));
summary.sigmaDiff = mbe_summary((mcmcChain.sigma(:,1) - mcmcChain.sigma(:,2)),0);
summary.nu = mbe_summary(mcmcChain.nu);
summary.nuLog10 = mbe_summary(log10(mcmcChain.nu));

effSzChain = ((mcmcChain.mu(:,1)-mcmcChain.mu(:,2))...
    ./ sqrt((mcmcChain.sigma(:,1).^2) + mcmcChain.sigma(:,2).^2)/2); %NEEDS TO BE CHECKED FOR MISTAKES
summary.effSz = mbe_summary(effSzChain,0);

% n1 = length(y1);    % for sample-size weighted version only
% n2 = length(y2);
% Or, use sample-size weighted version:
% effSz = ( mu1 - mu2 ) / sqrt( ( sigma1^2 *(N1-1) + sigma2^2 *(N2-1) )
%                               / (N1+N2-2) )
% Be sure also to change plot label in BESTplot function, below.
end

