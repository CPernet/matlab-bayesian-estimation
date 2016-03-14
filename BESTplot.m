function BESTplot(y1, y2, mcmcChain, ROPEm, ROPEsd ,...
    ROPEeff , showCurve , pairsPlot)
%% This function plots the posterior distribution (and data).
% Description of arguments:
% y1 and y2 are the data vectors.
% mcmcChain is a list of the type returned by function BTT.
% ROPEm is a two element vector, such as c(-1,1), specifying the limit
%   of the ROPE on the difference of means.
% ROPEsd is a two element vector, such as c(-1,1), specifying the limit
%   of the ROPE on the difference of standard deviations.
% ROPEeff is a two element vector, such as c(-1,1), specifying the limit
%   of the ROPE on the effect size.
% showCurve is TRUE or FALSE and indicates whether the posterior should
%   be displayed as a histogram (by default) or by an approximate curve.
% pairsPlot is TRUE or FALSE and indicates whether scatterplots of pairs
%   of parameters should be displayed.
mu1 = mcmcChain.mu(:,1);
mu2 = mcmcChain.mu(:,2);
sigma1 = mcmcChain.sigma(:,1);
sigma2 = mcmcChain.sigma(:,2);
nu = mcmcChain.nu(:);

%% -----------------------------------------------------------------
% Plot correlations between parameters
%-----------------------------------------------------------------
if pairsPlot
    % Plot the parameters pairwise, to see correlations:
    figure('color','w','NumberTitle','Off','position', [0,0,700,600]);
    nPtToPlot = 1000;
    idxPtToPlot = floor(1:(length(mu1)/nPtToPlot):length(mu1));
    names = {'mu1','mu2','sigma1','sigma2','nu'};
    X = [mu1(idxPtToPlot),mu2(idxPtToPlot),sigma1(idxPtToPlot),...
        sigma2(idxPtToPlot),nu(idxPtToPlot)];
    nVar = size(X, 2);
    ptSize = 2; %size of scatter plot points
    
    for indVar = 1:nVar
        subplot(nVar,nVar, sub2ind([nVar, nVar], indVar, indVar));
        title([names{indVar}]);
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
                text(4,5,['\' names{indVar}],'FontWeight','bold','FontSize',14);
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
end


%% -----------------------------------------------------------------
% Plot data y1 and smattering of posterior predictive curves:
%-----------------------------------------------------------------
figure('Color','w','NumberTitle','Off','Position',[100,50,800,600]);
subplot(5,2,2)
% Select thinned steps in chain for plotting of posterior predictive curves:
chainLength = size(mu1,1);
nCurvesToPlot = 30;
stepIdxVec = 1:floor(chainLength/nCurvesToPlot):chainLength;
minX = min([y1,y2]);
maxX = max([y1,y2]);
xRange = [minX,maxX];

if isequal(xRange(1),xRange(2))
    meanSigma = mean([sigma1;sigma2]);
    xRange(1) = xRange(1)-meanSigma;
    xRange(2) = xRange(2)+meanSigma;
end

xLim = [xRange(1)-0.1*(xRange(2)-xRange(1)),xRange(2)+0.1*(xRange(2)-xRange(1))];
xVec = linspace(xLim(1),xLim(2),200);
maxY = max(tpdf(0, max(nu(stepIdxVec))) /...
    min([sigma1(stepIdxVec);sigma2(stepIdxVec)]));


stepIdx = 1;
plot(xVec, tpdf((xVec-mu1(stepIdxVec(stepIdx)))/sigma1(stepIdxVec(stepIdx)),...
    nu(stepIdxVec(stepIdx)) )/sigma1(stepIdxVec(stepIdx)),...
    'Color',[0.4 0.7 1]);
xlabel('y'); ylabel('p(y)'); title('Data Group 1 w. Post. Pred.','FontWeight','bold');
ylim([0,maxY]);
hold on;
for stepIdx = 2:length(stepIdxVec)
    plot(xVec, tpdf((xVec-mu1(stepIdxVec(stepIdx)))/sigma1(stepIdxVec(stepIdx)),...
        nu(stepIdxVec(stepIdx)))/sigma1(stepIdxVec(stepIdx)),...
        'Color',[0.4 0.7 1]);
end
[f,x] = hist(y1,20);
bar(x, f/sum(f)/(x(2)-x(1)),'r','BarWidth',0.6,'EdgeColor','None');
hold off

%%-----------------------------------------------------------------
% Plot data y2 and smattering of posterior predictive curves:
%-----------------------------------------------------------------
subplot(5,2,4);
stepIdx = 1;
plot(xVec, tpdf((xVec-mu2(stepIdxVec(stepIdx)))/sigma2(stepIdxVec(stepIdx)),...
    nu(stepIdxVec(stepIdx)) )/sigma2(stepIdxVec(stepIdx)),...
    'Color',[0.4 0.7 1]);
xlabel('y'); ylabel('p(y)'); title('Data Group 2 w. Post. Pred.','FontWeight','bold');
ylim([0,maxY]);
hold on;
for stepIdx = 2:length(stepIdxVec)
    plot(xVec, tpdf((xVec-mu2(stepIdxVec(stepIdx)))/sigma2(stepIdxVec(stepIdx)),...
        nu(stepIdxVec(stepIdx)))/sigma2(stepIdxVec(stepIdx)),...
        'Color',[0.4 0.7 1]);
end
[f,x] = hist(y2,20);
bar(x, f/sum(f)/(x(2)-x(1)),'r','BarWidth',0.6,'EdgeColor','None');
hold off


%%-----------------------------------------------------------------
% Plot posterior distribution of parameter nu:
%-----------------------------------------------------------------
subplot(5,2,9);
mbe_plotPost(log10(nu),'credMass',0.95,'xlab','log10(\nu)');

%-----------------------------------------------------------------
% Plot posterior distribution of parameters mu1, mu2, and their difference:
%-----------------------------------------------------------------
xLim(1) = min([mu1;mu2]);
xLim(2) = max([mu1;mu2]);

subplot(5,2,1);
mbe_plotPost(mu1,'xlab','\mu1','xlim',xLim,'Plottitle','Group 1 Mean');
subplot(5,2,3);
mbe_plotPost(mu2,'xlab','\mu2','xlim',xLim,'PlotTitle','Group 2 Mean');
subplot(5,2,6);
mbe_plotPost(mu1-mu2,'xlab','\mu1-\mu2','PlotTitle','Difference of Means');


%-----------------------------------------------------------------
% Plot posterior distribution of param's sigma1, sigma2, and their difference:
%-----------------------------------------------------------------
xLim(1) = min([sigma1;sigma2]);
xLim(2) = max([sigma1;sigma2]);
subplot(5,2,5);
mbe_plotPost(sigma1,'xlab','\sigma1','xlim',xLim,'PlotTitle','Group 1 Std. Dev.');
subplot(5,2,7);
mbe_plotPost(sigma2,'xlab','\sigma2','xlim',xLim,'PlotTitle','Group 2 Std. Dev.');
subplot(5,2,8);
mbe_plotPost(sigma1-sigma2,'xlab','\sigma1-\sigma2','PlotTitle','Difference of Std. Dev.');

%-----------------------------------------------------------------
% Plot of estimated effect size. Effect size is d-sub-a from
%-----------------------------------------------------------------
% Macmillan & Creelman, 1991; Simpson & Fitter, 1973; Swets, 1986a, 1986b.
effectSize = (mu1 - mu2) ./ sqrt(( sigma1.^2 + sigma2.^2 ) / 2 );
subplot(5,2,10);
% str = '(\mu1-\mu2)/\sqrt((\sigma1^2+\sigma2^2)/2';
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
