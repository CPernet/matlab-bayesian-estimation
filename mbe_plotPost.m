function postSummary = mbe_plotPost(SampleVec, varargin)
%% mbe_plotPost
% Plotting posterior distribution with highest density interval. 
% 
% INPUT:
% paramSampleVec is a MCMC chain with n iterations.
%
% Specify the following name/value pairs for additional plot options:
%
%       Parameter        Value
%       'credMass'       credibility mass (default = 0.95)
%       'compVal'        comparison value, i.e. for differences use 0    
%       'rope'           region of practical equivalence, i.e. [-0.1 0.1]
%       'ylab'           y-Label
%       'xlab'           x-Label
%       'plotTitle'      plot title
%       'showMode'       show mode (=0) or mean (=1); default is mode
%       'xLim'           provide x-axis limit, i.e. [-3 3]
%
%
% EXAMPLE:
% postSummary = mbe_plotPost(paramSampleVec,'rope',[-0.1 0.1],'credMass',0.95)

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis, 
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-13
% Version: v1.00 (2016-03-15)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% Get input
p = inputParser;
defaultCredMass = 0.95;
defaultCompVal = NaN;
defaultYLab = '';
defaultXLab = '\theta';
defaultXLim = 0;
defaultPlotTitle = '';
defaultShowMode = 1;
defaultRope = 0;
addRequired(p,'paramSampleVec',@isnumeric);
addOptional(p,'credMass',defaultCredMass,@isnumeric);
addOptional(p,'compVal',defaultCompVal,@isnumeric);
addOptional(p,'ylab',defaultYLab);
addOptional(p,'xlab',defaultXLab);
addOptional(p,'xLim',defaultXLim);
addOptional(p,'plotTitle',defaultPlotTitle);
addOptional(p,'showMode',defaultShowMode);
addOptional(p,'rope',defaultRope);
parse(p,SampleVec,varargin{:});
credMass = p.Results.credMass;
compVal = p.Results.compVal;
ylab = p.Results.ylab;
xlab = p.Results.xlab;
xLim = p.Results.xLim;
plotTitle = p.Results.plotTitle;
showMode = p.Results.showMode;
rope = p.Results.rope;
if xLim == 0
    xLim(1) = min(SampleVec);
    xLim(2) = max([compVal;SampleVec]);
end

%% Get statistics
% Get mean and median
postSummary.mean = mean(SampleVec);
postSummary.median = median(SampleVec);
% Get mode of continous variable using density function
[f,xi] = ksdensity(SampleVec);
[~,I] = max(f);
postSummary.mode = xi(I);
% Get highest density interval
HDI = mbe_hdi(SampleVec,credMass);
postSummary.hdiMass = credMass;
postSummary.hdiLow = HDI(1);
postSummary.hdiHigh = HDI(2);

%% Plot histogram
[f,x] = hist(SampleVec,30);
% To make sure that histogram sums to one, normalize with f/sum(f)
bar(x, f/sum(f),'BarWidth',0.85,'EdgeColor','None','FaceColor',[0.4 0.7 1]);
xlim(xLim); xlabel(xlab); ylabel(ylab); title(plotTitle,'FontWeight','bold');
yLim = max(f/sum(f));
box off;
hold on;

%% Display mean or mode
if showMode == 0
    meanParam = postSummary.mean;
    text(meanParam,yLim,['mean = ' num2str(meanParam,'%.4f')]);
else
    modeParam = postSummary.mode;
    text(modeParam,yLim,['mode = ' num2str(modeParam,'%.4f')]);
end

%% Display comparison value
if ~isnan(compVal)
    pcRtCompVal = round(100 * sum(SampleVec > compVal)...
        ./ length(SampleVec));
    pcLtCompVal = 100 - pcRtCompVal;
    plot([compVal,compVal], [yLim,0],'Color',[0 0.5 0],'LineWidth',2);
    text(compVal, 0.75*yLim, ['cV: ' num2str(pcLtCompVal) '% < '...
        num2str(compVal) ' < ' num2str(pcRtCompVal) '%'],'Color',[0 0.5 0]);
    postSummary.compVal = compVal;
    postSummary.pcGTcompVal = sum((SampleVec > compVal)...
        ./ length(SampleVec));
end

%% Display ROPE
if rope ~= 0
    pcInROPE = sum(SampleVec > rope(1) & SampleVec < rope(2))...
        ./ length(SampleVec);
    line([rope(1),rope(1)],[0,yLim],'Color','r','LineStyle','--','LineWidth',2);
    line([rope(2),rope(2)],[0,yLim],'Color','r','LineStyle','--','LineWidth',2);
    text(rope(2), 0.65*yLim,[num2str(round(100*pcInROPE)) '% in ROPE'],'Color','r');
    postSummary.ROPElow = rope(1);
    postSummary.ROPEhigh = rope(2);
    postSummary.pcInROPE = pcInROPE;
end

%% Display HDI
line(HDI,[0,0],'Color','k','LineWidth',5)
text(HDI(1),yLim*0.4, num2str(HDI(1),'%.4f'));
text(HDI(2),yLim*0.4, num2str(HDI(2),'%.4f'));

%% Change font size
set(gca,'FontSize',8);
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',11)
end
