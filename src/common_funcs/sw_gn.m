% soft weighted (sw) gaussian newton (gn)
function [R, t, w, err] = sw_gn(R0, t0, X, v, thv, err, weight_order, max_iter)
    % init err
    if isempty(err)
        [~, err] = project_d_err(R0, t0, 1, X, v); 
    end
    % calc w
    w = calc_weight(err, thv, weight_order);
    n = length(w);
    % calc vcam
    z = xnormalize_vec(weighted_mean(v, w));
    if z(1) > z(2)
        x = xnormalize_vec(xcross_vec([0,1,0], z));
        y = xnormalize_vec(xcross_vec(z, x));
    else
        y = xnormalize_vec(xcross_vec(z, [1, 0, 0]));
        x = xnormalize_vec(xcross_vec(y, z));
    end
    R_vcam = [x, y, z];
    v_vcam = R_vcam'*v;
    % calc X_bar
    X_bar = weighted_mean(X, w);
    X_vcam = (R_vcam'*R0) * (X - repmat(X_bar, 1, n));
    t_vcam = R_vcam' * (R0*X_bar+t0);
    % optimize
    [R1, t1, w1, err1] = optimize_gn(X_vcam, v_vcam, t_vcam, thv, w, err, weight_order, max_iter);
    % calc pose    
    R = R_vcam*R1*R_vcam'*R0;
    t = R_vcam*t1-R*X_bar;
    w = w1;
    err = err1;
end

% X (3, n)
% w (1, n)
% Y (3, 1)
function Y = weighted_mean(X, w)
    Y = sum(X .* repmat(w, 3, 1), 2) / sum(w);
end

function Y = xnormalize_vec(X)
    Y = X / norm(X);
end

function c = xcross_vec(a,b)
    c = [a(2)*b(3)-a(3)*b(2);
         a(3)*b(1)-a(1)*b(3);
         a(1)*b(2)-a(2)*b(1)];
end
