function mcmcInfo = mbe_diagMCMC(mcmcChain)
%% mbe_diagMCMC
%   Plots autocorrelation, parameter trace, shrink factor and parameter
%   density.
%
% INPUT:
%   mcmcChain
%       structure containing one structure for every chain.
%       Fieldnames of substructures refer to parameter values.
%       This is the default output of matjags.m.
%
% OUTPUT:
%   mcmcDiagInfo
%       structure with diagnostic information on chains.
%
% EXAMPLE:

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-16
% Version: v1.1 (2016-03-16)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

%% Get parameters
% make it a MxNxP-matrix (M=steps,N=parameters,P=chains)
names = fieldnames(mcmcChain(1));
paramNames = {};
params = [];
cnt = 1;
for indChain = 1:numel(mcmcChain)
    for indFields = 1:(numel(names)-1)  % -1 to skip 'deviance' parameter
        for indParam = 1:size(mcmcChain(1).(names{indFields}),2)
            params(:,cnt,indChain) = mcmcChain(indChain).(names{indFields})(:,indParam);
            paramNames{cnt} = [names{indFields} num2str(indParam)];
            cnt = cnt+1;
        end
    end
    cnt = 1;
end

%% Loop through every parameter and create diagnostic plots
for indParam = 1:numel(paramNames)
    % Make one figure for every parameter
    figure('NumberTitle','Off','Color','w','Position',[100,50,800,600]);
    dim = [.35 .7 .3 .3];
    str = ['Chain Diagnostics for: ' paramNames{indParam}];
    a = annotation('textbox',dim,'String',str,'FitBoxToText','on');
    set(a,'FontSize',14,'FontWeight','bold');
    % Plot trace of parameter
    subplot(2,2,1);
    mbe_tracePlot(squeeze(params(:,indParam,:)));
    
    % Plot autocorrelation of parameters
    subplot(2,2,2);
    mbe_acfPlot(squeeze(params(:,indParam,:)));     
end



