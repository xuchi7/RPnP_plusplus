function [R1, t1] = applyOPnPGN(R, t, X, x, K, th_pixel)
    xn = xx2xxn(K, x);
    v = xxn2xxv(xn);
    thv = th_pixel/K(1,1);
    inliers = calcInliers(R, t, X, x, K, th_pixel);
    if sum(inliers) > 5
        [R1, t1] = OPnP1(X(:, inliers), xn(:, inliers));
        if isempty(R1)
            R1 = R; t1 = t;
        end
    else
        R1 = R; t1 = t;
    end
    [R1, t1] = dsw_gn(R1, t1, X, v, thv, inf, 1);
    if isempty(R1)
        R1 = R; t1 = t;
    end
end