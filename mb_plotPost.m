function postSummary = mb_plotPost(paramSampleVec,credMass,compVal,...
    rope, ylab, xlab, xLim, plotTitle,showMode)
%% plotPost
% Plotting prior and posterior distributions.
% paramSampleVec, credMass, compVal, rope, ylab, xlab, xlim,
% title, showMode

% Largely based on Kruschke, 2011.
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-13 21:29
% Changed:
% Version: v0.2
% Developed in Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------


if xLim == 0
    xLim(1) = min(paramSampleVec);
    xLim(2) = max([compVal;paramSampleVec]);
end
if ylab == 0, ylab = ''; end

postSummary.mean = mean(paramSampleVec);
postSummary.median = median(paramSampleVec);
[f,xi] = ksdensity(paramSampleVec);
[Y,I] = max(f);
postSummary.mode = xi(I);
HDI = HDIofMCMC(paramSampleVec,credMass);
postSummary.hdiMass = credMass;
postSummary.hdiLow = HDI(1);
postSummary.hdiHigh = HDI(2);

%% Plot histogram.
[f,x] = hist(paramSampleVec,30);
bar(x, f/sum(f),'BarWidth',0.85,'EdgeColor','None','FaceColor',[0.4 0.7 1]);
xlim(xLim); xlabel(xlab); ylabel(ylab); title(plotTitle,'FontWeight','bold');
yLim = max(f/sum(f));
box off;

%% Display mean or mode:
if showMode == 0
    %         meanParam = mean(paramSampleVec);
    %         text(num2str(meanParam), cenTendHt ,
    %               bquote(mean==.(signif(meanParam,3))) , adj=c(.5,0) , cex=cex )
else
    modeParam = postSummary.mode;
    text(modeParam,yLim,['mode = ' num2str(modeParam,'%.2f')]);
end

%% TO BE IMPLEMENTED. Display the comparison value.
%     if compVal ~= 0
%       cvCol = 'g';
%       pcgtCompVal = round(100*sum(paramSampleVec>compVal)...
%                             ./ length(paramSampleVec));
%        pcltCompVal = 100 - pcgtCompVal;
%        plot( c(compVal,compVal) , c(0.96*cvHt,0) ,
%               lty='dotted' , lwd=1 , col=cvCol )
%        text( compVal , cvHt ,
%              bquote( .(pcltCompVal)*'% < ' *
%                      .(signif(compVal,3)) * ' < '*.(pcgtCompVal)*'%' ) ,
%              adj=c(pcltCompVal/100,0) , cex=0.8*cex , col=cvCol )
%       postSummary[,'compVal'] = compVal
%       postSummary[,'pcGTcompVal'] = ( sum( paramSampleVec > compVal )
%                                   / length( paramSampleVec ) )
%     end

%% Display the ROPE.
if rope ~= 0
    pcInROPE = sum(paramSampleVec > rope(1) & paramSampleVec < rope(2))...
        ./ length(paramSampleVec);
    line([rope(1),rope(1)],[0,yLim*0.5],'Color','r','LineStyle','--');
    line([rope(2),rope(2)],[0,yLim*0.5],'Color','r','LineStyle','--');
    
    postSummary.ROPElow = rope(1);
    postSummary.ROPEhigh = rope(2);
    postSummary.pcInROPE = pcInROPE;
end


%% Display the HDI.
line(HDI,[0,0],'Color','k','LineWidth',5)
% text(mean(HDI),yLim*0.3, [num2str(100*credMass) '% HDI']);
text(HDI(1),yLim*0.4, num2str(HDI(1),'%.2f'));
text(HDI(2),yLim*0.4, num2str(HDI(2),'%.2f'));

%% Change font size
set(gca,'FontSize',8);
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',11)
end
