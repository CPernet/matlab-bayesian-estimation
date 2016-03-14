function mbe_plotData(y,nu,mu1,sigma1,mu2,sigma2)
%% mbe_plotData
%   Plot histogram of observed data. If specified, adds superimposed
%   posterior predictive check.
%
% INPUT:
%   y
%       column vector of observed data
%       or matrix of observed data ([y1,y2])
%   showPost
%       superimpose posterior predictive check ([1],0)
%   mu
%       vector for parameter mu (output of MCMC)
%   sigma
%       vector for parameter sigma (output of MCMC)
%   nu
%       vector for parameter nu (output of MCMC)
%
% EXAMPLE:

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis,
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-14
% Version: v0.02 (2016-03-14)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% Error checking and input handling
if size(y,2) < 2
    y1 = y;
    minX = min(y1);
    maxX = max(y1);
    meanSigma = mean(sigma1);
elseif size(y,2) == 2
    y1 = y(:,1);
    y2 = y(:,2);
    minX = min([y1;y2]);
    maxX = max([y1;y2]);
    if ~exist('mu2','var') || ~exist('sigma2','var')
        error('Specify mu2 and sigma2 for y2.')
    end
    meanSigma = mean([sigma1;sigma2]);
else
    error('Y has to be either a vector or matrix with dimensions n X 2.')
end

%% Plot data for y1
figure('Color','w','NumberTitle','Off','Position',[100,50,800,600]);
subplot(size(y,2),1,1);
% Select thinned steps in chain for plotting of posterior predictive curves:
chainLength = size(mu1,1);
nCurvesToPlot = 30;
stepIdxVec = 1:floor(chainLength/nCurvesToPlot):chainLength;

% Get y- and x-Limits
xRange = [minX,maxX];
if isequal(xRange(1),xRange(2))
    xRange(1) = xRange(1) - meanSigma;
    xRange(2) = xRange(2) + meanSigma;
end

xLim = [xRange(1)-0.1*(xRange(2)-xRange(1)),xRange(2)+0.1*(xRange(2)-xRange(1))];
% xVec will store the x-coordinates for the posterior plots
xVec = linspace(xLim(1),xLim(2),200);

% Get y-Limits
if exist('mu2','var') || exist('sigma2','var')
    maxY = max(tpdf(0, max(nu(stepIdxVec))) /...
        min([sigma1(stepIdxVec);sigma2(stepIdxVec)]));
else
    maxY = max(tpdf(0, max(nu(stepIdxVec))) /...
        min(sigma1(stepIdxVec)));
end
% Here tpdf is the student's t distribution, which is also later used for
% superimposing the posterior predictive curves
% This part of the script will find the peak of the highest posterior
% distribution

% Plot first posterior predictive check curve and add title
stepIdx = 1;
plot(xVec, tpdf((xVec-mu1(stepIdxVec(stepIdx))) / sigma1(stepIdxVec(stepIdx)),...
    nu(stepIdxVec(stepIdx))) / sigma1(stepIdxVec(stepIdx)),...
    'Color',[0.4 0.7 1]);
xlabel('y'); ylabel('p(y)'); title('Data Group 1 w. Post. Pred.','FontWeight','bold');
ylim([0,maxY]);
hold on;

% Plot the remaining posterior predicitive curves
for stepIdx = 2:length(stepIdxVec)
    plot(xVec, tpdf((xVec-mu1(stepIdxVec(stepIdx)))/sigma1(stepIdxVec(stepIdx)),...
        nu(stepIdxVec(stepIdx)))/sigma1(stepIdxVec(stepIdx)),...
        'Color',[0.4 0.7 1]);
end

% Plot histogram of data y1
[f,x] = hist(y1,20);
bar(x, f/sum(f)/(x(2)-x(1)),'r','BarWidth',0.6,'EdgeColor','None');
hold off

%% Plot data for y2
if exist('y2','var')
    subplot(size(y,2),1,2);
    % Plot first curve with title
    stepIdx = 1;
    plot(xVec, tpdf((xVec-mu2(stepIdxVec(stepIdx)))/sigma2(stepIdxVec(stepIdx)),...
        nu(stepIdxVec(stepIdx)) )/sigma2(stepIdxVec(stepIdx)),...
        'Color',[0.4 0.7 1]);
    xlabel('y'); ylabel('p(y)'); title('Data Group 2 w. Post. Pred.','FontWeight','bold');
    ylim([0,maxY]);
    hold on;
    
    % Plot remaining curves
    for stepIdx = 2:length(stepIdxVec)
        plot(xVec, tpdf((xVec-mu2(stepIdxVec(stepIdx)))/sigma2(stepIdxVec(stepIdx)),...
            nu(stepIdxVec(stepIdx)))/sigma2(stepIdxVec(stepIdx)),...
            'Color',[0.4 0.7 1]);
    end
    
    % Plot histogram of data y2
    [f,x] = hist(y2,20);
    bar(x,f/sum(f)/(x(2)-x(1)),'r','BarWidth',0.6,'EdgeColor','None');
    hold off
end
end
