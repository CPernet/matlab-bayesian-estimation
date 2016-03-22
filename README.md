# Matlab Toolbox for Bayesian Estimation (MBE)

## Synopsis

This is an easy-to-use Matlab Toolbox for Bayesian Estimation. The basis of the code is a Matlab implementation of Kruschke's R code described in the following paper (Kruschke, 2013), book (Kruschke, 2014) and website (http://www.indiana.edu/~kruschke/BEST/). This toolbox is intended to provide the user with similiar possible analyses as Kruschke's code does, yet makes it applicable in a Matlab-only environment. In addition, it strives to provide the user with better structured and thus more comprehensible code.

Since I am using this code to do Bayesian Estimation in EEG data analyses, I added functions and examples providing the user with the possibility to do time series analyses.


## Code Example

A description will follow soon.


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
