function mbe_plotPairs(params,paramNames,nPtToPlot)
%% mbe_plotPairs
%   Plot matrix of scatter plots for any combination of parameters.
%
% INPUT:
%   params
%       is a m x n matrix of parameters with m = number of data points
%       and n = number of parameters
%   paramNames
%       cell array with n strings specifying parameter names
%   nPtToPlot
%       number of points to plot
%
% EXAMPLE:

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis,
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-14
% Version: v0.2 (2016-03-14)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% Plot the parameters pairwise, to see correlations:
figure('color','w','NumberTitle','Off','position', [0,0,700,600]);
idxPtToPlot = floor(1:(length(params(:,1))/nPtToPlot):length(params(:,1)));
X = params(idxPtToPlot,:);
nVar = size(X, 2);
ptSize = 2; %size of scatter plot points

for indVar = 1:nVar
    subplot(nVar,nVar, sub2ind([nVar, nVar], indVar, indVar));
    title([paramNames{indVar}]);
    for jindVar = 1:nVar
        if jindVar < indVar
            subplot(nVar, nVar, sub2ind([nVar, nVar], indVar, jindVar));
            scatter(X(:,indVar), X(:,jindVar), ptSize);
            box on;
            set(gca,'FontSize',6)
        elseif jindVar == indVar
            subplot(nVar,nVar,sub2ind([nVar,nVar],indVar,jindVar));
            ax = subplot(nVar, nVar, sub2ind([nVar, nVar], indVar, jindVar));
            set(ax,'Visible','off');
            text(4,5,['\' paramNames{indVar}],'FontWeight','bold','FontSize',14);
            rectangle('Position',[0 0 10 10]);
        else
            subplot(nVar, nVar, sub2ind([nVar, nVar], indVar, jindVar));
            [r,~] = corr(X(:,indVar), X(:,jindVar));
            ax = subplot(nVar, nVar, sub2ind([nVar, nVar], indVar, jindVar));
            rText = num2str(r,'%.3f');
            text(2,5,['r = ' rText]);
            set(ax,'visible','off');
            rectangle('Position',[0 0 10 10]);
        end
    end
end