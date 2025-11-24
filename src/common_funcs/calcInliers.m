function [inliers, err] = calcInliers(R, t, X, x, K, th_pixel)
    n = size(X, 2);
    Y = R * X + repmat(t, 1, n);
    xp = Y(1:2,:) ./ repmat(Y(3,:), 2, 1);
    xp = xxn2xx(K, xp);
    err = xnorm(x - xp);
    inliers = err < th_pixel;
end