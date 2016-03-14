function postSummary = mbe_plotPost(paramSampleVec, varargin)
%% mbe_plotPost
% Plotting posterior distributions with highest density interval. 
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

% Largely based on code by Kruschke, 2011.
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-13
% Changed:
% Version: v0.2
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% Get input
p = inputParser;
defaultCredMass = 0.95;
defaultCompVal = NaN;
defaultYLab = '';
defaultXLab = '';
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
parse(p,paramSampleVec,varargin{:});
credMass = p.Results.credMass;
compVal = p.Results.compVal;
ylab = p.Results.ylab;
xlab = p.Results.xlab;
xLim = p.Results.xLim;
plotTitle = p.Results.plotTitle;
showMode = p.Results.showMode;
rope = p.Results.rope;
if xLim == 0
    xLim(1) = min(paramSampleVec);
    xLim(2) = max([compVal;paramSampleVec]);
end

%% Get statistics
% Get mean and median
postSummary.mean = mean(paramSampleVec);
postSummary.median = median(paramSampleVec);
% Get mode of continous variable using density function
[f,xi] = ksdensity(paramSampleVec);
[~,I] = max(f);
postSummary.mode = xi(I);
% Get highest density interval
HDI = HDIofMCMC(paramSampleVec,credMass);
postSummary.hdiMass = credMass;
postSummary.hdiLow = HDI(1);
postSummary.hdiHigh = HDI(2);

%% Plot histogram.
[f,x] = hist(paramSampleVec,30);
% To make sure that histogram sums to one, normalize with f/sum(f)
bar(x, f/sum(f),'BarWidth',0.85,'EdgeColor','None','FaceColor',[0.4 0.7 1]);
xlim(xLim); xlabel(xlab); ylabel(ylab); title(plotTitle,'FontWeight','bold');
yLim = max(f/sum(f));
box off;
hold on;

%% Display mean or mode
if showMode == 0
    meanParam = postSummary.mean;
    text(meanParam,yLim,['mean = ' num2str(meanParam,'%.2f')]);
else
    modeParam = postSummary.mode;
    text(modeParam,yLim,['mode = ' num2str(modeParam,'%.2f')]);
end

%% Display the comparison value
if ~isnan(compVal)
    pcRtCompVal = round(100 * sum(paramSampleVec > compVal)...
        ./ length(paramSampleVec));
    pcLtCompVal = 100 - pcRtCompVal;
    plot([compVal,compVal], [yLim,0],'g');
    text(compVal, 0.75*yLim, [num2str(pcLtCompVal) '% < ' num2str(compVal)...
        ' < ' num2str(pcRtCompVal) '%'],'Color','g');
    postSummary.compVal = compVal;
    postSummary.pcGTcompVal = sum((paramSampleVec > compVal)...
        ./ length(paramSampleVec));
end

%% Display the ROPE
if rope ~= 0
    pcInROPE = sum(paramSampleVec > rope(1) & paramSampleVec < rope(2))...
        ./ length(paramSampleVec);
    line([rope(1),rope(1)],[0,yLim],'Color','r','LineStyle','--');
    line([rope(2),rope(2)],[0,yLim],'Color','r','LineStyle','--');
    postSummary.ROPElow = rope(1);
    postSummary.ROPEhigh = rope(2);
    postSummary.pcInROPE = pcInROPE;
end

%% Display the HDI
line(HDI,[0,0],'Color','k','LineWidth',5)
text(HDI(1),yLim*0.4, num2str(HDI(1),'%.2f'));
text(HDI(2),yLim*0.4, num2str(HDI(2),'%.2f'));

%% Change font size
set(gca,'FontSize',8);
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',11)
end
