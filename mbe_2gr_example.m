%% Matlab Toolbox for Bayesian Estimation - Example
% This is an example script for a two group comparison.

% Largely based on R code introduced in the following paper:
% Kruschke, J.K., Bayesian Estimation supersedes the t-test.
% Journal of Experimental Psychology: General, Vol 142(2), May 2013, 573-603. 
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% Nils Winter (nils.winter1@gmail.com)
% Johann-Wolfgang-Goethe University, Frankfurt
% Created: 2016-03-15
% Version: v2.1 (2016-04-25)
%-------------------------------------------------------------------------
clear;clc;

%% Load some data
% EXAMPLE DATA (see Kruschke, 2013)
y1 = [101,100,102,104,102,97,105,105,98,101,100,123,105,103,100,95,102,106,...
    109,102,82,102,100,102,102,101,102,102,103,103,97,97,103,101,97,104,...
    96,103,124,101,101,100,101,101,104,100,101];
y2 = [99,101,100,101,102,100,97,101,104,101,102,102,100,105,88,101,100,...
    104,100,100,100,101,102,103,97,101,101,100,101,99,101,100,100,...
    101,100,99,101,100,102,99,100,99];

y = [y1,y2]; % combine data into one vector
x = [ones(1,length(y1)),2*ones(1,length(y2))]; % create group membership code
nTotal = length(y);


%% Specify prior constants, shape and rate for gamma distribution
% See Kruschke (2013) for further description
mu1PriorMean = mean(y);
mu1PriorSD = std(y)*5;    % flat prior
mu2PriorMean = mean(y);
mu2PriorSD = std(y)*5;
sigma1PriorMode = std(y);
sigma1PriorSD = std(y)*5;
sigma2PriorMode = std(y);
sigma2PriorSD = std(y)*5;
nuPriorMean = 30;
nuPriorSD = 30;

% Now get shape and rate values for gamma distribution
[Sh1, Ra1] = mbe_gammaShRa(sigma1PriorMode,sigma1PriorSD,'mode');
[Sh2, Ra2] = mbe_gammaShRa(sigma2PriorMode,sigma2PriorSD,'mode');
[ShNu, RaNu] = mbe_gammaShRa(nuPriorMean,nuPriorSD,'mean');

% Save prior constants in a structure for later use with matjags
dataList = struct('y',y,'x',x,'nTotal',nTotal,...
    'mu1PriorMean',mu1PriorMean,'mu1PriorSD',mu1PriorSD,...
    'mu2PriorMean',mu2PriorMean,'mu2PriorSD',mu2PriorSD,...
    'Sh1',Sh1,'Ra1',Ra1,'Sh2',Sh2,'Ra2',Ra2,'ShNu',ShNu,'RaNu',RaNu);

%% Specify MCMC properties
% Number of MCMC steps that are saved for EACH chain
% This is different to Rjags, where you would define the number of 
% steps to be saved for all chains together (in this example 12000) 
numSavedSteps = 4000;

% Number of separate MCMC chains
nChains = 3;

% Number of steps that are thinned, matjags will only keep every nth 
% step. This does not affect the number of saved steps. I.e. in order
% to compute 10000 saved steps, matjags/JAGS will compute 50000 steps
% If memory isn't an issue, Kruschke recommends to use longer chains
% and no thinning at all.
thinSteps = 5;

% Number of burn-in samples
burnInSteps = 1000;

% The parameters that are to be monitored
parameters = {'mu','sigma','nu'};

%% Initialize the chain
% Initial values of MCMC chains based on data:
mu = [mean(y1),mean(y2)];
sigma = [std(y1),std(y2)];
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
    '    y[i] ~ dt( mu[x[i]] , 1/sigma[x[i]]^2 , nu )\n',...
    '    }\n',...
    '    mu[1] ~ dnorm( mu1PriorMean , 1/mu1PriorSD^2 )  # prior for mu[1]\n',...
    '    sigma[1] ~ dgamma( Sh1 , Ra1 )     # prior for sigma[1]\n',...
    '    mu[2] ~ dnorm( mu2PriorMean , 1/mu2PriorSD^2 )  # prior for mu[2]\n',...
    '    sigma[2] ~ dgamma( Sh2 , Ra2 )     # prior for sigma[2]\n',...
    '    nu ~ dgamma( ShNu , RaNu ) # prior for nu \n'...
    '}'];
fileID = fopen('mbe_2gr_example.txt','wt');
fprintf(fileID,modelString);
fclose(fileID);
model = fullfile(pwd,'mbe_2gr_example.txt');

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
% Get summary and posterior plots
summary = mbe_2gr_summary(mcmcChain);
% Data has to be in a cell array
data{1} = y1;
data{2} = y2;
mbe_2gr_plots(data,mcmcChain);
