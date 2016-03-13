%% MATLAB - BEST
% Nils Winter
% see http://www.indiana.edu/~kruschke/BEST/ for R code
% This is a Matlab-Version of John Kruschke's R code

cd('D:\Exp Data\Glasgow\matBEST');
% This function generates an MCMC sample from the posterior distribution.
% Description of arguments:
% showMCMC is a flag for displaying diagnostic graphs of the chains.
% If F (the default), no chain graphs are displayed. If T, they are.

% EXAMPLE
% y1 = [101,100,102,104,102,97,105,105,98,101,100,123,105,103,100,95,102,106,...
%        109,102,82,102,100,102,102,101,102,102,103,103,97,97,103,101,97,104,...
%        96,103,124,101,101,100,101,101,104,100,101];
% y2 = [99,101,100,101,102,100,97,101,104,101,102,102,100,105,88,101,100,...
%        104,100,100,100,101,102,103,97,101,101,100,101,99,101,100,100,...
%        101,100,99,101,100,102,99,100,99];
% load('D:\Exp Data\Glasgow\Fei\mi_leye_rt_bubinv_Nils.mat');
% y1 = mi_leye_rt.face(1,:);
% y2 = mi_leye_rt.face(2,:);
load('D:\Exp Data\Glasgow\Fei\mi_leye_erp_RE_bubinv_Nils.mat');
data{1} = mi_leye_erp.face_RE(1,:,:);
data{2} = mi_leye_erp.face_RE(2,:,:);

for indTime = 1:size(data{1},2)
    y1 = squeeze(data{1}(1,indTime,:))';
    y2 = squeeze(data{2}(1,indTime,:))';
    

   
priorOnly = 0;
showMCMC = 0;
numSavedSteps = 12000;
thinSteps = 5;
mu1PriorMean = mean([y1,y2]);
mu1PriorSD = std([y1,y2])*5;
mu2PriorMean = mean([y1,y2]);
mu2PriorSD = std([y1,y2])*5;
sigma1PriorMode = std([y1,y2]);
sigma1PriorSD = std([y1,y2])*5;
sigma2PriorMode = std([y1,y2]);
sigma2PriorSD = std([y1,y2])*5;
nuPriorMean = 30;
nuPriorSD = 30;
nChains = 1;


%------------------------------------------------------------------------------
% THE DATA.
% Load the data:
y = [y1,y2]; % combine data into one vector
x = [ones(1,length(y1)),2*ones(1,length(y2))]; % create group membership code
Ntotal = length(y);

% Specify the data and prior constants in a structure, for later shipment to JAGS:
if priorOnly
    [Sh1, Ra1] = gammaShRaFromModeSD(sigma1PriorMode,sigma1PriorSD);
    [Sh2, Ra2] = gammaShRaFromModeSD(sigma2PriorMode,sigma2PriorSD);
    [ShNu, RaNu] = gammaShRaFromMeanSD(nuPriorMean,nuPriorSD);
    
    dataList = struct('x',x,'Ntotal',Ntotal,...
        'mu1PriorMean',mu1PriorMean,'mu1PriorSD',mu1PriorSD,...
        'mu2PriorMean',mu2PriorMean,'mu2PriorSD',mu2PriorSD,...
        'Sh1',Sh1,'Ra1',Ra1,'Sh2',Sh2,'Ra2',Ra2,'ShNu',ShNu,'RaNu',RaNu);
    
else
    [Sh1, Ra1] = gammaShRaFromModeSD(sigma1PriorMode,sigma1PriorSD);
    [Sh2, Ra2] = gammaShRaFromModeSD(sigma2PriorMode,sigma2PriorSD);
    [ShNu, RaNu] = gammaShRaFromMeanSD(nuPriorMean,nuPriorSD);
    
    dataList = struct('y',y,'x',x,'Ntotal',Ntotal,...
        'mu1PriorMean',mu1PriorMean,'mu1PriorSD',mu1PriorSD,...
        'mu2PriorMean',mu2PriorMean,'mu2PriorSD',mu2PriorSD,...
        'Sh1',Sh1,'Ra1',Ra1,'Sh2',Sh2,'Ra2',Ra2,'ShNu',ShNu,'RaNu',RaNu);
end
%----------------------------------------------------------------------------
% THE MODEL.
fprintf('Running time point: %d \n',indTime)
modelString = [' model {\n',...
    '    for ( i in 1:Ntotal ) {\n',...
    '    y[i] ~ dt( mu[x[i]] , 1/sigma[x[i]]^2 , nu )\n',...
    '    }\n',...
    '    mu[1] ~ dnorm( mu1PriorMean , 1/mu1PriorSD^2 )  # prior for mu[1]\n',...
    '    sigma[1] ~ dgamma( Sh1 , Ra1 )     # prior for sigma[1]\n',...
    '    mu[2] ~ dnorm( mu2PriorMean , 1/mu2PriorSD^2 )  # prior for mu[2]\n',...
    '    sigma[2] ~ dgamma( Sh2 , Ra2 )     # prior for sigma[2]\n',...
    '    nu ~ dgamma( ShNu , RaNu ) # prior for nu \n'...
    '}'];
% Write out modelString to a text file

fileID = fopen('BESTmodel.txt','wt');
fprintf(fileID,modelString);
fclose(fileID);
model = fullfile(pwd,'BESTmodel.txt');
  %------------------------------------------------------------------------------
  % INTIALIZE THE CHAINS.
  % Initial values of MCMC chains based on data:
  mu = [mean(y1),mean(y2)];
  sigma = [std(y1),std(y2)];
  % Regarding initial values in next line: (1) sigma will tend to be too big if 
  % the data have outliers, and (2) nu starts at 5 as a moderate value. These
  % initial values keep the burn-in period moderate.
  
  % Set initial values for latent variable in each chain
for i=1:nChains
    initsList(i) = struct('mu', mu, 'sigma',sigma,'nu',5); % init0 is a structure array that has the initial values for all latent variables for each chain
end

  
  %------------------------------------------------------------------------------
  % RUN THE CHAINS
  
  parameters = {'mu','sigma','nu'};     % The parameters to be monitored
%  adaptSteps = 500;               % Number of steps to 'tune' the samplers
  burnInSteps = 1000;

[samples, stats, structArray] = matjags(...
    dataList,...
    model,...
    initsList,...
    'monitorparams', parameters,...
    'nChains', nChains,...
    'nBurnin', burnInSteps,...
    'thin', thinSteps,...
    'verbosity',1,...
    'nSamples',12000);
    

%------------------------------------------------------------------------------
% !!!NEEDS TO BE IMPLEMENTED    -    EXAMINE THE RESULTS
%   if showMCMC
%       for paramName = varnames(codaSamples) % NEEDS TO BE CHECKED
%           diagMCMC(codaSamples,paramName);
%       end
%   end

% Convert coda-object codaSamples to matrix object for easier handling.
% But note that this concatenates the different chains into one long chain.
% Result is mcmcChain[ stepIdx , paramIdx ]
% mcmcChain = as.matrix(codaSamples); % NEEDS TO BE CHECKED

%% SUMMARY
summary{indTime} = BESTsummary(y1,y2,structArray);
end

%% PLOTS
BESTplot(y1,y2,structArray,0,0,... 
                    0,0,1);

plot(1:151,muDiffERP)
ylim([-0.06 0.06])
hold on
plot(1:151,muDiffHDIlow,'r')
plot(1:151,muDiffHDIhigh,'r')

for i = 1:151
    muDiffERP(i) = summary{i}.muDiff.median;
    muDiffHDIlow(i) = summary{i}.muDiff.HDIlow;
    muDiffHDIhigh(i) = summary{i}.muDiff.HDIhigh;
end












