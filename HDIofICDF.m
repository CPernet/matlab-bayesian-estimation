function hdiLim = HDIofICDF(ICDFname, credMass)
%% HDIofICDF
%   Computes highest density interval of inverse cumulative density function
%   (ICDF) of the distribution.
%
% INPUT:
%   credMass is the desired mass of the HDI region (default = 0.95).
%
% OUTPUT:
%   Highest density iterval (HDI) limits in a vector.
%
% EXAMPLE: 
%   HDI = HDIofICDF(ICDFname, 0.95)

% Largely based on R code by Kruschke, J. K. (2015). Doing Bayesian Data Analysis, 
% Second Edition: A Tutorial with R, JAGS, and Stan. Academic Press / Elsevier.
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-13
% Changed:
% Version: v0.2
% Matlab 8.1.0.604 (R2013a) on PCWIN
%-------------------------------------------------------------------------


% STILL IN PROGRESS. DO NOT USE.
if ~exist('credMass','var')
    credMass = 0.95;
end

incredMass =  1.0 - credMass;
intervalWidth = ICDFname(credMass+lowTailPr) - ICDFname(lowTailPr);
HDIlowTailPr = fminsearch(ICDFname, intervalWidth , [0,incredMass],...
     credMass);
hdiLim = [ICDFname(HDIlowTailPr),ICDFname(credMass+HDIlowTailPr)];

end


