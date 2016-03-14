function mbe_makePlots(data, mcmcChain, varargin)
% mbe_makePlots
%   Make histogram of data with superimposed posterior prediction check
%   and plots posterior distribution of monitored parameters.
%
% INPUT:
%   data
%       vector or matrix of data variables ([y1,y2])
%   mcmcChain
%       structure with one MCMC-chain, should contain all monitored parameters
%
% Specify the following name/value pairs for additional plot options:
%        Parameter      Value
%       'plotPairs'     show correlation plot of parameters ([1],0)
%
%
% EXAMPLE:

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis,
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-14
% Version: v0.02 (2016-03-14)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% -----------------------------------------------------------------
% Get input
% -----------------------------------------------------------------
p = inputParser;
defaultPlotPairs = 1;
addOptional(p,'plotPairs',defaultPlotPairs);
parse(p,data,mcmcChain,varargin{:});
plotPairs = p.Results.plotPairs;

% Get parameters
names = fieldnames(mcmcChain);
paramNames = {};
params = [];
for indFields = 1:(numel(names)-1)  % -1 to skip 'deviance' parameter
    for indParam = 1:size(mcmcChain.(names{indFields}),2)
        params = [params,mcmcChain.(names{indFields})(:,indParam)];
        paramNames{end+1} = [names{indFields} num2str(indParam)];
    end
end


%% -----------------------------------------------------------------
% Plot correlations between parameters
%-----------------------------------------------------------------
if plotPairs
    mbe_plotPairs(params,paramNames,1000)
end


%% -----------------------------------------------------------------
% Plot data y1 and smattering of posterior predictive curves:
%-----------------------------------------------------------------
y = [y1',y2'];
nu = params(:,5);
mu1 = params(:,1);
sigma1 = params(:,2);
mu2 = params(:,3);
sigma2 = params(:,4);

mbe_plotData(y,nu,mu1,sigma1,mu2,sigma2);














end
