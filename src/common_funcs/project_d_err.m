function [d, err] = project_d_err(R, t, s, X, v)
    Y = s*R*X + repmat(t, 1, size(X, 2));
    d = xnorm(Y);
    vp = Y ./ repmat(d, 3, 1);
    err = xnorm(v-vp);
end