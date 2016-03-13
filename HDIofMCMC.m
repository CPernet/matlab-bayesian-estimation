function hdiLim = HDIofMCMC(sampleVec,credMass)
% Computes highest density interval from a sample of representative values,
%   estimated as shortest credible interval.
% Input:
%   sampleVec
%     is a vector of representative values from a probability distribution.
%   credMass
%     is a scalar between 0 and 1, indicating the mass within the credible
%     interval that is to be estimated.
% Output:
%   HDIlim is a vector containing the limits of the HDI

sortedPts = sort(sampleVec);
ciIdxInc = floor(credMass * length(sortedPts));
nCIs = length(sortedPts) - ciIdxInc;
ciWidth = zeros(nCIs,1);

for ind = 1:nCIs 
    ciWidth(ind) = sortedPts(ind + ciIdxInc) - sortedPts(ind);
    [~,idxMin] = min(ciWidth);
    HDImin = sortedPts(idxMin);
    HDImax = sortedPts(idxMin + ciIdxInc);
    hdiLim = [HDImin, HDImax];
end
end


