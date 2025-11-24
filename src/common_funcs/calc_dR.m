function err = calc_dR(R_gt, R)
    R = real(R);
    R = R./repmat(xnorm(R), 3, 1);
    tmp = sum(R_gt.*R, 1);
    tmp = acos(clip(tmp, -1, 1));
    err = max(tmp)*180/pi;
end

function y = clip(x, a, b)
    y = min(max(x, a), b);
end
