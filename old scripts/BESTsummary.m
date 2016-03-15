function summary = BESTsummary(mcmcChain)
%% BESTsummary

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis, 
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-13
% Changed:
% Version: v0.2
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

summary.mu1 = mcmcSummary(mcmcChain.mu(:,1));
summary.mu2 = mcmcSummary(mcmcChain.mu(:,2));
summary.muDiff = mcmcSummary((mcmcChain.mu(:,1) - mcmcChain.mu(:,2)),0);
summary.sigma1 = mcmcSummary(mcmcChain.sigma(:,1));
summary.sigma2 = mcmcSummary(mcmcChain.sigma(:,2));
summary.sigmaDiff = mcmcSummary((mcmcChain.sigma(:,1) - mcmcChain.sigma(:,2)),0);
summary.nu = mcmcSummary(mcmcChain.nu);
summary.nuLog10 = mcmcSummary(log10(mcmcChain.nu));

effSzChain = ((mcmcChain.mu(:,1)-mcmcChain.mu(:,2))...
    ./ sqrt((mcmcChain.sigma(:,1).^2) + mcmcChain.sigma(:,2).^2)/2); %NEEDS TO BE CHECKED FOR MISTAKES
summary.effSz = mcmcSummary(effSzChain,0);

% n1 = length(y1);    % for sample-size weighted version only
% n2 = length(y2);
% Or, use sample-size weighted version:
% effSz = ( mu1 - mu2 ) / sqrt( ( sigma1^2 *(N1-1) + sigma2^2 *(N2-1) )
%                               / (N1+N2-2) )
% Be sure also to change plot label in BESTplot function, below.
end

function summaryInfo = mcmcSummary(paramSampleVec,varargin)
if nargin > 1
    compVal = varargin{1};
end

summaryInfo.mean = mean(paramSampleVec);
summaryInfo.median = median(paramSampleVec);
summaryInfo.mode = mode(paramSampleVec);
hdiLim = HDIofMCMC(paramSampleVec,0.95);
summaryInfo.HDIlow = hdiLim(1);
summaryInfo.HDIhigh = hdiLim(2);

if exist('compVal','var')
    summaryInfo.pcgtZero = (100*sum(paramSampleVec > compVal) ...
        / length(paramSampleVec));
else
    summaryInfo.pcgtZero = NaN;
end

end