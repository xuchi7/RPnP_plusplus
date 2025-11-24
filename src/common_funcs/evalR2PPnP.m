function [R1, t1, trials] = evalR2PPnP(X, x, K, th_pixel)
    xn = xx2xxn(K, x);
    thv = th_pixel/K(1,1);
    nr1 = 30; 
    [R1, t1, trials] = r2ppnp(X, xn, thv, nr1);
end