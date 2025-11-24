function [R1, t1, trials] = evalLoP4Pinf(X, x, K, th_pixel, p)
    if nargin < 5, p = 0.99; end
    [R1, t1, ~, trials] = loransac(K, X, x, @RPnP, @applyDSWGNinf, 4, th_pixel, p);
end