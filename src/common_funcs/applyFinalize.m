function [R1, t1] = applyFinalize(R, t, X, x, K, th_pixel)
    xn = xx2xxn(K, x);
    v = xxn2xxv(xn);
        
    thv = th_pixel/K(1,1);
    [R1, t1] = dsw_gn(R, t, X, v, thv, [3 4 inf]);
    
    if isempty(R1)
        R1 = R; t1 = t;
    end
end