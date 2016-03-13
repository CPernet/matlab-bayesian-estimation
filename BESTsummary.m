function summary = BESTsummary(y1,y2,mcmcChain)
%source('HDIofMCMC.R') % in DBDA2E-utilities.R

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