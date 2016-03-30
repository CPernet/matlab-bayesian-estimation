function mcmcChainOut = mbe_restructChains(mcmcChain)
%% mbe_restructChains
%   Restructures MCMC output in order to split up parameters with same
%   name. This happens if JAGS and matjags monitor more than one parameter
%   with the same name (i.e. "mu"). This function creates a structure with
%   one field per parameter (i.e. "mu1","mu2").
%
% INPUT: 
%   mcmcChain
%       - default output created by matjags
%
% OUTPUT:   
%   mcmcChainOut
%       - structure with one field for every parameter of the chain
%
% EXAMPLE:   

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-30
% Version: v1.1
%------------------------------------------------------------------------
%% Checking for correct input
if size(mcmcChain{1},2) > 1
    error('Currently only works on concatenated chains. Use mbe_concChain.m first.')
end

%% Get parameter names
names = fieldnames(mcmcChain{1});
paramNames = {};
cnt = 1;
for indFields = 1:(numel(names)-1)  % -1 to skip 'deviance' parameter
        for indParam = 1:size(mcmcChain{1}.(names{indFields}),2)
            paramNames{cnt} = [names{indFields} num2str(indParam)];
            cnt = cnt+1;
        end
end

%% Get parameters
cnt = 1;
for indTime = 1:numel(mcmcChain)
    for indFields = 1:(numel(names)-1)  % -1 to skip 'deviance' parameter
        for indParam = 1:size(mcmcChain{1}.(names{indFields}),2)
            mcmcChainOut{indTime}.(paramNames{cnt}) = mcmcChain{indTime}.(names{indFields})(:,indParam);
            cnt = cnt+1;
        end
    end
    cnt = 1;
end
