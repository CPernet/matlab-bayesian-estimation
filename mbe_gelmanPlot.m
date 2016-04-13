function mbe_gelmanPlot(mcmcParam)
%% mbe_gelmanPlot
% This plot shows the evolution of Gelman and Rubin's shrink factor as
% the number of iterations increases. More than one chain is needed.
%
% INPUT:
%   mcmcParam
%       2d matrix with MCMC parameter as column vector for every chain
%
% EXAMPLE:
%   mbe_gelmanPlot(mcmcParam);

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-22
% Version: v2.00 (2016-04-13)
%-------------------------------------------------------------------------
nChains = size(mcmcParam,2);
% Shrink factor only works for more than one chain
if nChains > 1
    % Create right format for psrf.m
    for indChain = 1:nChains
        X(:,1,indChain) = mcmcParam(:,indChain);
    end
    
    % Calculate shrink factor for increasing number of steps to see evolution
    nSteps = size(X,1);
    maxBins = 50;
    binSize = floor((nSteps-50) / maxBins);
    R = [];
    for indSteps = 50:binSize:nSteps
       R(end+1) = psrf(X(1:indSteps,:,:));
    end
    
    % Plot evolution of shrink factor
    plot(50:binSize:nSteps,R);
    xlabel('last iteration in chain','FontWeight','bold','fontSize',12);
    ylabel('shrink factor','FontWeight','bold','fontSize',12);
    hold on;
    plot(1:nSteps,ones(nSteps,1),'Color','k','LineStyle',':');
end



