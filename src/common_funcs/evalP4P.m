function [R1, t1, trials] = evalP4P(X, x, K, th_pixel, p)
    if nargin < 5, p = 0.99; end
    [R1, t1, ~, trials] = ransac(K, X, x, @RPnP, 4, th_pixel, p);
end