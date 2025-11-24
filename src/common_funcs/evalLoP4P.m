function [R1, t1, trials] = evalLoP4P(X, x, K, th_pixel, p)
    if nargin < 5, p = 0.99; end
    [R1, t1, ~, trials] = loransac(K, X, x, @RPnP, @applyDSWGN2, 4, th_pixel, p);
end