function mbe_acfPlot(mcmcParam)
%% mbe_acfPlot
%   Plots autocorrelation of MCMC chain parameter for every chain.
%
% INPUT:
%   mcmcParam
%       2d matrix with MCMC parameter as column vector for every chain
%
% EXAMPLE:
%   mbe_acfPlot(mcmcChain);

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-16
% Version: v1.1(2016-03-16)
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------
nChain = size(mcmcParam,2);
cc='rgbcy';
for indChain = 1:nChain
    nLags = 200;
    % This function is from file exchange, since autocorr.m comes only with
    % the Econometrics Toolbox
    acfInfo = nanautocorr(mcmcParam(:,indChain),nLags);
    xMat(:,indChain) = 1:nLags+1;
    yMat(:,indChain) = acfInfo;
    plot(xMat(:,indChain),yMat(:,indChain),'Color',cc(indChain));
    hold on;
end
% Make it nicer
ylim([-0.1 1]); xlim([-5 nLags]);
ylabel('Autocorrelation'); xlabel('Lag');
% Plot reference line
plot(-5:nLags,zeros(nLags+6),'LineStyle',':','color','k');
% % Display effective chain length
% effChainLength = mbe_effectiveSize(mcmcChain);
% dim = [.6 .5 .3 .3];
% str = ['EFF =' num2str(effChainLength)];
% annotation('textbox',dim,'String',str,'FitBoxToText','on');

end
