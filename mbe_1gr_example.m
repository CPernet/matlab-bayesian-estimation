%% Matlab Toolbox for Bayesian Estimation - One Group Example
% This is an example script for a one group estimation.

% Largely based on R code introduced in the following paper:
% Kruschke, J.K., Bayesian Estimation supersedes the t-test.
% Journal of Experimental Psychology: General, Vol 142(2), May 2013, 573-603. 
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-04-25
% Version: v1.0 (2016-04-25)
%-------------------------------------------------------------------------
clear;clc;

%% Load some data
% EXAMPLE DATA (see Kruschke, 2013)
% Run this script one time with the small sample.
y = [101,100,102,104,102,97,105,105,98,101,100,123,105,103,100,95,102,106,...
    109,102,82,102,100,102,102,101,102,102,103,103,97,97,103,101,97,104,...
    96,103,124,101,101,100,101,101,104,100,101];
nTotal = length(y);
 
% % Then run it again but use the n=500 sample below to see the change
% % of the parameters and HDI.
% y = trnd(2,500,1);
% y = (y-mean(y))/sqrt(mean((y-mean(y)).^2))*6+102;
% nTotal = length(y);

%% Specify prior constants, shape and rate for gamma distribution
% See Kruschke (2013) for further description
muM = mean(y);
muP = 0.000001 * 1/std(y)^2;
sigmaLow = std(y)/1000;
sigmaHigh = std(y)*1000;

% Save prior constants in a structure for later use with matjags
dataList = struct('y',y,'nTotal',nTotal,...
    'muM',muM,'muP',muP,'sigmaLow',sigmaLow,'sigmaHigh',sigmaHigh);

%% Specify MCMC properties
% Number of MCMC steps that are saved for EACH chain
% This is different to Rjags, where you would define the number of 
% steps to be saved for all chains together (in this example 12000) 
numSavedSteps = 30000;

% Number of separate MCMC chains
nChains = 3;

% Number of steps that are thinned, matjags will only keep every nth 
% step. This does not affect the number of saved steps. I.e. in order
% to compute 10000 saved steps, matjags/JAGS will compute 50000 steps
% If memory isn't an issue, Kruschke recommends to use longer chains
% and no thinning at all.
thinSteps = 1;

% Number of burn-in samples
burnInSteps = 1000;

% The parameters that are to be monitored
parameters = {'mu','sigma','nu'};

%% Initialize the chain
% Initial values of MCMC chains based on data:
mu = mean(y);
sigma = std(y);
% Regarding initial values: (1) sigma will tend to be too big if
% the data have outliers, and (2) nu starts at 5 as a moderate value. These
% initial values keep the burn-in period moderate.

% Set initial values for latent variable in each chain
for i=1:nChains
    initsList(i) = struct('mu', mu, 'sigma',sigma,'nu',5);
end

%% Specify the JAGS model
% This will write a JAGS model to a text file
% You can also write the JAGS model directly to a text file

modelString = [' model {\n',...
    '    for ( i in 1:nTotal ) {\n',...
    '    y[i] ~ dt( mu , tau, nu )\n',...
    '    }\n',...
    '    mu ~ dnorm( muM , muP ) \n',...
    '    tau <- 1/pow(sigma , 2)\n',...
    '    sigma ~ dunif( sigmaLow , sigmaHigh )\n',...
    '    nu ~ dexp( 1/30 )\n'...
    '}'];
fileID = fopen('mbe_1gr_example.txt','wt');
fprintf(fileID,modelString);
fclose(fileID);
model = fullfile(pwd,'mbe_1gr_example.txt');

%% Run the chains using matjags and JAGS
% In case you have the Parallel Computing Toolbox, use ('doParallel',1)
[~, ~, mcmcChain] = matjags(...
    dataList,...
    model,...
    initsList,...
    'monitorparams', parameters,...
    'nChains', nChains,...
    'nBurnin', burnInSteps,...
    'thin', thinSteps,...
    'verbosity',1,...
    'nSamples',numSavedSteps);

%% Restructure the output
% This transforms the output of matjags into the format that mbe is 
% using
mcmcChain = mbe_restructChains(mcmcChain);

%% Examine the chains
mbe_diagMCMC(mcmcChain);

%% Examine the results
% At this point, we want to use all the chains at once, so we
% need to concatenate the individual chains to one long chain first
mcmcChain = mbe_concChains(mcmcChain);
% Get summary and posterior plots; comparisonValue = 100
summary = mbe_1gr_summary(mcmcChain,100);
% Data has to be in a cell array and the vectors have to be column vectors
data = {y'};
mbe_1gr_plots(data,mcmcChain,100);
