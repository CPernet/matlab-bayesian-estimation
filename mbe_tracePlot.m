function mbe_tracePlot(mcmcParam)
%% mbe_tracePlot
%   Creates a trace plot for a parameter of a MCMC chain.
%
% INPUT:
%   mcmcParam
%       2d matrix with MCMC parameter as column vector for every chain
%
% EXAMPLE:

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-16
% Version: v1.1 (2016-03-16)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

nChain = size(mcmcParam,2);
nSteps = size(mcmcParam,1);
X = 1:nSteps;
cc='rgbcy';
for indChain = 1:nChain
    Y = mcmcParam(:,indChain);
    plot(X,Y,'color',cc(indChain));
    ylabel('Param. Value','FontWeight','bold','fontSize',12); 
    xlabel('Iterations','FontWeight','bold','fontSize',12);
    box on;
    hold on;
end
