function [shape,rate] = gammaShRaFromModeSD(mode,sd)
if mode <=0
    error('mode must be > 0');
end
if sd <=0
    error('sd must be > 0');
end
rate = (mode + sqrt(mode.^2 + 4.*sd.^2)) / (2.*sd.^2);
shape = 1 + mode * rate;
end