function [R1, t1, trials] = evalR1PPnP(X, x, K, th_pixel)
    xn = xx2xxn(K, x);
    focal = K(1,1);
    [R1, t1, trials] = R1PPnP(X, xn, focal, th_pixel);
end