% dynamic soft weighted (dsw) gaussian newton (gn)
function [R, t, w, err] = dsw_gn(R0, t0, X, v, thv, weights, max_iter, err)
    % init inputs
    if nargin < 7, max_iter = 4; end
    if nargin < 8, err = []; end % default []
    if isempty(err)
        [~, err] = project_d_err(R0, t0, 1, X, v); 
    end
    % check whether enough points
    if sum(err < thv) < 5
        R = [];
        t = [];
        w = [];
        return
    end
    % reduce point set
    idx = err < thv*7;
    X1 = X(:,idx);
    v1 = v(:,idx);
    err1 = err(idx);
    % sw_gn
    R = R0;
    t = t0;
    for weight_order = weights
        [R, t, w1, err1] = sw_gn(R, t, X1, v1, thv, err1, weight_order, max_iter);
    end
    % restore point set
    w = zeros(size(idx));
    w(idx) = w1;
    err(idx) = err1;
end