function mbe_acfPlot(mcmcParam)
%% mbe_acfPlot
%   Plots autocorrelation of MCMC chain parameter for every chain.
%
% INPUT:
%   mcmcParam
%       2d matrix with MCMC parameter as column vector for every chain
%
% EXAMPLE:
%   mbe_acfPlot(mcmcChain.mu1);

% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-16
% Version: v1.1(2016-03-16)
%-------------------------------------------------------------------------
%% Checking input
if size(size(mcmcParam),2) > 2
    error(['Your mcmc input has three dimensions, which suggests a time '...
        'series analysis. The autocorrelation plot works only for one time '...
        'point/mcmc simulation with multiple chains.']);
end

%% Plot autocorrelation
nChain = size(mcmcParam,2);
cc='rgbcy';
for indChain = 1:nChain
    nLags = 200;
    % This function is from file exchange
    acfInfo = acorr(mcmcParam(:,indChain),nLags);
    xMat(:,indChain) = 1:nLags;
    yMat(:,indChain) = acfInfo;
    plot(xMat(:,indChain),yMat(:,indChain),'Color',cc(indChain));
    hold on;
end
% Make it nicer
ylim([-0.1 1]); xlim([-5 nLags]);
ylabel('Autocorrelation','FontWeight','bold','fontSize',12);
xlabel('Lag','FontWeight','bold','fontSize',12);
% Plot reference line
plot(-5:nLags,zeros(nLags+6),'LineStyle',':','color','k');

% Display effective chain length
[~,neff,~,~,~,~,~] = psrf(mcmcParam);
neffSum = sum(neff(:));
str = ['ESS: ' num2str(neffSum,'%.0f')];
t = text(nLags*.5,0.8,str);
set(t,'FontSize',12);
end
