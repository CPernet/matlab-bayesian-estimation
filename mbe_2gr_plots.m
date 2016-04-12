function mbe_2gr_plots(y, mcmcChain, varargin)
% mbe_makePlots
%   Make histogram of data with superimposed posterior prediction check
%   and plots posterior distribution of monitored parameters.
%
% INPUT:
%   y
%       cell array containing vectors for y1 and y2
%   mcmcChain
%       structure with one MCMC-chain, should contain all monitored parameters
%
% Specify the following name/value pairs for additional plot options:
%        Parameter      Value
%       'plotPairs'     show correlation plot of parameters ([1],0)
%
%
% EXAMPLE:

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis,
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-14
% Version: v1.00 (2016-03-15)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% -----------------------------------------------------------------
% Get input
% -----------------------------------------------------------------
p = inputParser;
defaultPlotPairs = 1;
addOptional(p,'plotPairs',defaultPlotPairs);
parse(p,varargin{:});
plotPairs = p.Results.plotPairs;

% Get parameter names
names = fieldnames(mcmcChain);


%% -----------------------------------------------------------------
% Plot correlations between parameters
%-----------------------------------------------------------------
if plotPairs
    mbe_plotPairs(mcmcChain,1000)
end


%% -----------------------------------------------------------------
% Plot data y and smattering of posterior predictive curves:
%-----------------------------------------------------------------
nu = mcmcChain.(names{5});
mu1 = mcmcChain.(names{1});
mu2 = mcmcChain.(names{2});
sigma1 = mcmcChain.(names{3});
sigma2 = mcmcChain.(names{4});

mbe_plotData(y,nu,mu1,sigma1,mu2,sigma2);

%% -----------------------------------------------------------------
% Plot posterior distribution of parameter nu:
%-----------------------------------------------------------------
figure('Color','w','NumberTitle','Off','Position',[100,50,800,600]);
subplot(4,2,6);
mbe_plotPost(log10(nu),'credMass',0.95,'xlab','log10(\nu)','PlotTitle','Nu');

%-----------------------------------------------------------------
% Plot posterior distribution of parameters mu1, mu2, and their difference:
%-----------------------------------------------------------------
xLim(1) = min([mu1;mu2]);
xLim(2) = max([mu1;mu2]);

subplot(4,2,1);
mbe_plotPost(mu1,'xlab','\mu1','xlim',xLim,'Plottitle','Group 1 Mean');
subplot(4,2,3);
mbe_plotPost(mu2,'xlab','\mu2','xlim',xLim,'PlotTitle','Group 2 Mean');
subplot(4,2,5);
mbe_plotPost(mu1-mu2,'xlab','\mu1-\mu2','PlotTitle','Difference of Means','CompVal',0);


%-----------------------------------------------------------------
% Plot posterior distribution of param's sigma1, sigma2, and their difference:
%-----------------------------------------------------------------
xLim(1) = min([sigma1;sigma2]);
xLim(2) = max([sigma1;sigma2]);
subplot(4,2,2);
mbe_plotPost(sigma1,'xlab','\sigma1','xlim',xLim,'PlotTitle','Group 1 Std. Dev.');
subplot(4,2,4);
mbe_plotPost(sigma2,'xlab','\sigma2','xlim',xLim,'PlotTitle','Group 2 Std. Dev.');
subplot(4,2,7);
mbe_plotPost(sigma1-sigma2,'xlab','\sigma1-\sigma2','PlotTitle','Difference of Std. Dev.');

%-----------------------------------------------------------------
% Plot of estimated effect size. Effect size is d-sub-a from
%-----------------------------------------------------------------
% Macmillan & Creelman, 1991; Simpson & Fitter, 1973; Swets, 1986a, 1986b.
effectSize = (mu1 - mu2) ./ sqrt(( sigma1.^2 + sigma2.^2 ) / 2 );
subplot(4,2,8);
str = '(\mu1-\mu2)/sqrt((\sigma1^2+\sigma2^2)/2)';
mbe_plotPost(effectSize,'rope',[-0.1,0.1],'xlab',str,'PlotTitle','Effect Size');

% Or use sample-size weighted version:
% Hedges 1981; Wetzels, Raaijmakers, Jakab & Wagenmakers 2009.
% N1 = length(y1)
% N2 = length(y2)
% effectSize = ( mu1 - mu2 ) / sqrt( ( sigma1^2 *(N1-1) + sigma2^2 *(N2-1) )
%                                    / (N1+N2-2) )
% Be sure also to change BESTsummary function, above.
% histInfo = plotPost( effectSize , compVal=0 ,  ROPE=ROPEeff ,
%          showCurve=showCurve ,
%          xlab=bquote( (mu[1]-mu[2])
%          /sqrt((sigma[1]^2 *(N[1]-1)+sigma[2]^2 *(N[2]-1))/(N[1]+N[2]-2)) ),
%          cenTend=c('mode','median','mean')[1] , cex.lab=1.0 , main='Effect Size' , col='skyblue' )

end
