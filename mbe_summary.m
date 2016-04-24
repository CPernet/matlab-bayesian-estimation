function summary = mbe_summary(mcmcChain,varargin)
%% mbe_summary
%   Computes summary statistics for one parameter of mcmc chain.
%   Summary statistics include mean, median, mode, HDI and if a
%   comparison value is specified the percentage of parameter data
%   points above the threshold. This is useful i.e. for comparing
%   groups and calculating the difference. The comparison value would
%   then be 0.
%
% INPUT:
%   mcmcChain
%       mcmc chain of one parameter or more parameters
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
% Version: v2.00 (2016-04-13)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

if nargin > 1
    compVal = varargin{1};
end

if isstruct(mcmcChain)
    names = fieldnames(mcmcChain);
    for indPar = 1:numel(names)
        summary.(names{indPar}).mean = squeeze(mean(mcmcChain.(names{indPar})));
        summary.(names{indPar}).median = squeeze(median(mcmcChain.(names{indPar})));
        % Get mode (for continous variables) by using ksdensity
        for indTime = 1:size(mcmcChain.(names{1}),3)
            for indChain = 1:size(mcmcChain.(names{1}),2)
                [f,xi] = ksdensity(mcmcChain.(names{indPar})(:,indChain,indTime));
                [~,I] = max(f);
                summary.(names{indPar}).mode(indChain,indTime) = xi(I);
                hdiLim = mbe_hdi(mcmcChain.(names{indPar})(:,indChain,indTime),0.95);
                summary.(names{indPar}).HDIlow(indChain,indTime) = hdiLim(1);
                summary.(names{indPar}).HDIhigh(indChain,indTime) = hdiLim(2);
                if exist('compVal','var')
                    summary.(names{indPar}).pcgtZero(indChain,indTime) = ...
                        (100*sum(mcmcChain.(names{indPar})(:,indChain,indTime)...
                        > compVal) / length(mcmcChain.(names{indPar})(:,indChain,indTime)));
                end
            end
        end
    end
    
elseif ismatrix(mcmcChain)
    summary.mean = squeeze(mean(mcmcChain));
    summary.median = squeeze(median(mcmcChain));
    for indTime = 1:size(mcmcChain,3)
        for indChain = 1:size(mcmcChain,2)
            [f,xi] = ksdensity(mcmcChain(:,indChain,indTime));
            [~,I] = max(f);
            summary.mode(indChain,indTime) = xi(I);
            hdiLim = mbe_hdi(mcmcChain(:,indChain,indTime),0.95);
            summary.HDIlow(indChain,indTime) = hdiLim(1);
            summary.HDIhigh(indChain,indTime) = hdiLim(2);
            if exist('compVal','var')
                summary.pcgtZero(indChain,indTime) = ...
                    (100*sum(mcmcChain(:,indChain,indTime)...
                    > compVal) / length(mcmcChain(:,indChain,indTime)));
            end
        end
    end
else
    error(['Input must be either structure of mcmc chains or'...
        ' matrix for one mcmc chain parameter.'])
end
end