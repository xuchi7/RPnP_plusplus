% X (m, n)
% Y (m, n)
function Y = xnormalize(X)
    Y = X ./ repmat(xnorm(X), size(X, 1), 1);
end
