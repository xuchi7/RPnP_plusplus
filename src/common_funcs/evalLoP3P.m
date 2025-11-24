function [R1, t1, trials] = evalLoP3P(X, x, K, th_pixel, p)
    if nargin < 5, p = 0.99; end
    [R1, t1, ~, trials] = loransac(K, X, x, @kP3P, @applyDSWGN2, 3, th_pixel, p);
end