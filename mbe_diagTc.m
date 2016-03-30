function summary = mbe_diagTc(mcmcChainTc)
%% mbe_diagTc
%  Compute diagnostics for MCMC time course analysis (i.e. EEG ERP time
%  courses, one MCMC chain for every time step).
%
% INPUT:
%   mcmcChainTc
%       - is a structure containing one MCMC chain (structure) for every
%         time step
%       - this currently works only for one long chain, use mbe_concChain.m
%         first
% OUTPUT:
%   summary
%       - structure with ESS, Rhat, and MCSE for every parameter and every
%         time step
%
% EXAMPLE:

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-30
% Version: v1.1
%-------------------------------------------------------------------------

%% Make summary
mcmcChainTc = mbe_restructChains(mcmcChainTc);
names = fieldnames(mcmcChainTc{1});
nTime = numel(mcmcChainTc);

% Prepare for psrf function
for indParam = 1:numel(names)
    for indTime = 1:nTime
        X.(names{indParam})(:,indTime) = mcmcChainTc{indTime}.(names{indParam});
    end
end

% calculate ESS, MCSE, Rhat
for indParam = 1:numel(names)
    [Rhat, neff] = psrf(X.(names{indParam}));
    MCSE = std(X.(names{indParam}))...
        /sqrt(neff);
    summary.(names{indParam}).ESS = neff;
    summary.(names{indParam}).MCSE = MCSE;
    summary.(names{indParam}).Rhat = Rhat;
end

%% Make plots
for indParam = 1:numel(names)
    figure('NumberTitle','Off','Color','w','Position',[100,50,800,600]);
    dim = [.35 .7 .3 .3];
    str = ['Chain Diagnostics (Time Course) for: ' paramNames{indParam}];
    a = annotation('textbox',dim,'String',str,'FitBoxToText','on',...
        'EdgeColor','None');
    set(a,'FontSize',14,'FontWeight','bold');
    
    subplot(3,1,1);
    plot(1:nTime,summary.(names{indParam}).ESS);
    xlabel('time'); ylabel('ESS');
    
    subplot(3,1,2);
    plot(1:nTime,summary.(names{indParam}).MCSE);
    xlabel('time'); ylabel('MCSE');
    
    subplot(3,1,3);
    plot(1:nTime,summary.(names{indParam}).Rhat);
    xlabel('time'); ylabel('Rhat (Shrinkage)');
end
