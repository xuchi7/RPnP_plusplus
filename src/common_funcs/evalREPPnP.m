function [R1, t1, trials] = evalREPPnP(X, x, K, th_pixel)
    trials = 1;
    xn = xx2xxn(K, x);
    if all(X(3,:)==0)
        [R1, t1] = REPPnP_planar(X, xn);
    else
        [R1, t1] = REPPnP(X, xn);
    end
end