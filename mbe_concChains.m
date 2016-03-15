function mcmcChainOut = mbe_concChains(mcmcChain)
%% mbe_concChains
%   Concatenate several MCMC chains into one.
%
% INPUT: 
%   mcmcChain
%       is a structure containing one structure for every MCMC chain.
%       This is the default output of matjags.
%
% OUTPUT:   
%   mcmcChainOut
%       one structure with fields for every parameter
%
% EXAMPLE:   
%   mcmcChainOut = mbe_concChains(mcmcChains);

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-15
% Version: v1.00 (2016-03-15)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

names = fieldnames(mcmcChain(1,1));
for indNames = 1:numel(names)
    mcmcChainOut.(names{indNames}) = [];
end
    
for indChain = 1:size(mcmcChain,2)
    for indNames = 1:size(names,1)
    mcmcChainOut.(names{indNames}) = [mcmcChainOut.(names{indNames});...
        mcmcChain(indChain).(names{indNames})];
    end
end
end
