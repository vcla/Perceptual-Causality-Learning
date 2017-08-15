function [ infoA1 ] = bernoulli_KL( f, h )
%bernoulli_KL calculates the KL divergence for f over h


    if f == 0 
        infoA1 = (1-f) * log((1-f)/(1-h));
    elseif f == 1
        infoA1 = f * log(f / h);
    else
        infoA1 = f * log(f / h) + (1-f) * log((1-f)/(1-h));
    end

end

