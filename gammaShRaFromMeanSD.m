function [shape,rate] = gammaShRaFromMeanSD(mean,sd)
if mean <=0
    error('mean must be > 0');
end
if sd <=0
    error('sd must be > 0');
end
shape = mean.^2./sd.^2;
rate = mean./sd.^2;
end