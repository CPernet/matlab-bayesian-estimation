function hdiLim = HDIofMCMC(sampleVec,credMass)
%% HDIofMCMC
% Computes highest density interval from a sample of representative values,
%   estimated as shortest credible interval.
%
% INPUT:
%   sampleVec
%     is a vector of representative values from a probability distribution.
%   credMass
%     is a scalar between 0 and 1, indicating the mass within the credible
%     interval that is to be estimated.
%
% OUTPUT:
%   HDIlim is a vector containing the limits of the HDI

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis, 
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-14
% Changed:
% Version: v0.2
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------

% Determine number of elements that belong to HDI
sortedVec = sort(sampleVec);
ciIdx = ceil(credMass * length(sortedVec));
nCIs = length(sortedVec) - ciIdx;  % number of vector elements that make HDI

% Determine middle of HDI to get upper and lower bound
ciWidth = zeros(nCIs,1); 
for ind = 1:nCIs 
    ciWidth(ind) = sortedVec(ind + ciIdx) - sortedVec(ind);
end
    [~,idxMin] = min(ciWidth);
    HDImin = sortedVec(idxMin);
    HDImax = sortedVec(idxMin + ciIdx);
    hdiLim = [HDImin, HDImax];

end


