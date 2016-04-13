# Matlab Toolbox for Bayesian Estimation (MBE)

## Synopsis

This is an easy-to-use Matlab Toolbox for Bayesian Estimation. The basis of the code is a Matlab implementation of Kruschke's R code described in the following paper (Kruschke, 2013), book (Kruschke, 2014) and website (http://www.indiana.edu/~kruschke/BEST/). This toolbox is intended to provide the user with similiar possible analyses as Kruschke's code does, yet makes it applicable in a Matlab-only environment. In addition, it strives to provide the user with better structured and thus more comprehensible code.

Since I am using this code to do Bayesian Estimation in EEG data analyses, I added functions and examples providing the user with the possibility to do time series analyses.


## Code Example

This example uses the data provided in Kruschke's BEST paper (2011).
Run the script mbe_example.m.

```
%% Load some data
% EXAMPLE DATA (see Kruschke, 2011)
% see http://www.indiana.edu/~kruschke/BEST/ for R code

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
% See Kruschke (2011) for further description
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

% Now get shape and rate for gamma distribution
[Sh1, Ra1] = mbe_gammaShRa(sigma1PriorMode,sigma1PriorSD,'mode');
[Sh2, Ra2] = mbe_gammaShRa(sigma2PriorMode,sigma2PriorSD,'mode');
[ShNu, RaNu] = mbe_gammaShRa(nuPriorMean,nuPriorSD,'mean');

% Save prior constants in a structure for later use with matjags
dataList = struct('y',y,'x',x,'nTotal',nTotal,...
    'mu1PriorMean',mu1PriorMean,'mu1PriorSD',mu1PriorSD,...
    'mu2PriorMean',mu2PriorMean,'mu2PriorSD',mu2PriorSD,...
    'Sh1',Sh1,'Ra1',Ra1,'Sh2',Sh2,'Ra2',Ra2,'ShNu',ShNu,'RaNu',RaNu);
```
Now specify the MCMC properties and run JAGS:
```
%% Specify MCMC properties
% Number of MCMC steps that are saved for each chain
numSavedSteps = 10000;

% Number of separate MCMC chains
nChains = 3;

% Number of steps that are thinned, matjags will only keep every nth step
% This does not affect the number of saved steps. I.e. in order to compute
% 10000 saved steps, matjags/JAGS will compute 50000 steps
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
% You can also write the JAGS model directly to a text file or use
% one of the models that come with this toolbox

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
[samples, stats, mcmcChain] = matjags(...
    dataList,...
    model,...
    initsList,...
    'monitorparams', parameters,...
    'nChains', nChains,...
    'nBurnin', burnInSteps,...
    'thin', thinSteps,...
    'verbosity',2,...
    'nSamples',numSavedSteps);

```
Examine the chains with the mbe_diagMCMC() function:
```
mbe_diagMCMC(mcmcChain);
```
You will get these figures:
![alt tag](https://cloud.githubusercontent.com/assets/17763631/14428037/2d3a72a4-ffef-11e5-8d12-eb2f98f4f108.jpg)

Now examine the posterior distributions of the parameters.
```
mcmcChain = mbe_concChains(mcmcChain);
summary = mbe_2gr_summary(mcmcChain);
data{1} = y1;
data{2} = y2;
mbe_2gr_plots(data,mcmcChain);
```
These are examples of the figures that can be created to show the posterior distributions:
![alt tag](https://cloud.githubusercontent.com/assets/17763631/14428032/2d2907c6-ffef-11e5-8db6-b8103da62c78.jpg)
![alt tag](https://cloud.githubusercontent.com/assets/17763631/14428036/2d380186-ffef-11e5-8165-301fa3f731d1.jpg)
![alt tag](https://cloud.githubusercontent.com/assets/17763631/14428034/2d3323fa-ffef-11e5-8fcb-c0163dd34dfe.jpg)


## Installation

The MBE toolbox uses the open source software **JAGS** (Just Another Gibbs Sampler) to conduct Markov-Chain-Monte-Carlo sampling. Instead of using Rjags (as you would when using Kruschke's code), MBE uses the Matlab-JAGS interface **matjags.m** that will communicate with JAGS and import the results back to Matlab.

**JAGS** can be downloaded here:
http://mcmc-jags.sourceforge.net/

**matjags.m** can be downloaded here:
http://psiexp.ss.uci.edu/research/programs_data/jags/

Further installation descriptions are provided on these websites.
If you have installed JAGS and matjags.m successfully, the MBE Toolbox should work right out of the box. Just add the directory to your Matlab path.

The MBE Toolbox uses additional functions obtained via Matlab's File Exchange. The functions are contained in this toolbox and don't need to be downloaded separately. The licenses of these functions are stored in the corresponding folder.


## References

Kruschke, J. K. (2013). Bayesian estimation supersedes the t test. Journal of Experimental Psychology: General, 142(2), 573.

Kruschke, J. K. (2014). Doing Bayesian Data Analysis: A Tutorial with R, JAGS, and STAN (2nd ed.). Amsterdam: Academic Press.


## License

Copyright Nils Winter, 2016
