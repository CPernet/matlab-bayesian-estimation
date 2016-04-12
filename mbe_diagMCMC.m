function mcmcInfo = mbe_diagMCMC(mcmcChain)
%% mbe_diagMCMC
%   Plots autocorrelation, parameter trace, shrink factor and parameter
%   density.
%
% INPUT:
%   mcmcChain
%       structure containing all parameters.
%       Use mbe_restructChains.m to change structure of matjags output.
%
% OUTPUT:
%   mcmcDiagInfo
%       structure with diagnostic information on chains.
%
% EXAMPLE:

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-16
% Version: v1.2(2016-04-12)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

%% Get parameters
% make it a MxNxP-matrix (M=steps,N=parameters,P=chains)
names = fieldnames(mcmcChain);


%% Check if input is only one mcmc simulation (with multiple chains)
t = 1;
if size(mcmcChain.(names{1}),3) > 1
    t = inputdlg('Which time step do you want to diagnose?');
    t = str2num(t{1});
    if t > size(mcmcChain.(names{1}),3)
        error('The time step you specified is not valid.')
    end
end

%% Loop through every parameter and create diagnostic plots
for indParam = 1:numel(names)
    % Make one figure for every parameter
    figure('NumberTitle','Off','Color','w','Position',[100,50,800,600]);
    
    % Plot trace of parameter
    subplot(2,2,1);
    mbe_tracePlot(squeeze(mcmcChain.(names{indParam})(:,:,t)));
    
    % Plot autocorrelation of parameters
    subplot(2,2,2);
    mbe_acfPlot(squeeze(mcmcChain.(names{indParam})(:,:,t)));  
    
    % Plot density
    subplot(2,2,4);
    mbe_mcmcDensPlot(squeeze(mcmcChain.(names{indParam})(:,:,t)));
    
    % Plot evolution of shrinkage factor
    subplot(2,2,3);
    mbe_gelmanPlot(squeeze(mcmcChain.(names{indParam})(:,:,t)));
    
    % Title
    dim = [.35 .7 .3 .3];
    str = ['Chain Diagnostics for: ' names{indParam}];
    a = annotation('textbox',dim,'String',str,'FitBoxToText','on',...
        'EdgeColor','None');
    set(a,'FontSize',14,'FontWeight','bold');
end
end



