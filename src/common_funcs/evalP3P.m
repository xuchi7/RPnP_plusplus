function [R1, t1, trials] = evalP3P(X, x, K, th_pixel, p)
    if nargin < 5, p = 0.99; end
    [R1, t1, ~, trials] = ransac(K, X, x, @kP3P, 3, th_pixel, p);
end