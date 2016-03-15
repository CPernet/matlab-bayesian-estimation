function summary = mbe_summary(sampleVec,varargin)
%% mbe_summary
%   Computes summary statistics for one parameter of mcmc chain.
%   Summary statistics include mean, median, mode, HDI and if a 
%   comparison value is specified the percentage of parameter data
%   points above the threshold. This is useful i.e. for comparing 
%   groups and calculating the difference. The comparison value would
%   then be 0.
%
% INPUT: 
%   sampleVec
%       mcmc chain of one parameter (vector)
%   compVal
%       comparison value
%
% OUTPUT:   
%   summary
%       structure with individual fields for statistics
%
% EXAMPLE:   
%   summary = mbe_summary(sampleVec,0);

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-15
% Version: v1.00 (2016-03-15)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

if nargin > 1
    compVal = varargin{1};
end

summary.mean = mean(sampleVec);
summary.median = median(sampleVec);
% Get mode (for continous variables) by using ksdensity 
[f,xi] = ksdensity(sampleVec);
[~,I] = max(f);
summary.mode = xi(I);
hdiLim = HDIofMCMC(sampleVec,0.95);
summary.HDIlow = hdiLim(1);
summary.HDIhigh = hdiLim(2);

if exist('compVal','var')
    summary.pcgtZero = (100*sum(sampleVec > compVal) ...
        / length(sampleVec));
end
end